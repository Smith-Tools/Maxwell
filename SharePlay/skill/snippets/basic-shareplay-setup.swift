// Basic SharePlay Setup for visionOS
// Use these snippets as starting points for SharePlay integration

// MARK: - 1. GroupActivity Subclass
import GroupActivities

struct VisionOSGroupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Shared visionOS Experience"
        metadata.subtitle = "Collaborate in immersive space"
        metadata.type = .generic
        metadata.supportsContinuationOnTV = false
        metadata.supportsContinuationOnCar = false
        return metadata
    }
}

// MARK: - 2. Basic Session Manager
@MainActor
class SharePlayManager: ObservableObject {
    @Published var session: GroupActivitySession?
    @Published var participants: [GroupActivitySession.Participant] = []
    @Published var isActive = false

    private var messenger: GroupActivityMessenger?
    private var messageTask: Task<Void, Never>?

    func startSession() async throws {
        let activity = VisionOSGroupActivity()
        session = try await activity.prepareForActivation()

        messenger = GroupActivityMessenger(for: session!) { [weak self] message, participant in
            await self?.handleMessage(message: message, from: participant)
        }

        try await session?.activate()
        isActive = true

        // Start message processing
        startMessageProcessing()
    }

    func endSession() async {
        // Cancel message processing
        messageTask?.cancel()
        messageTask = nil

        await session?.end()
        session = nil
        messenger = nil
        isActive = false
    }

    private func handleMessage(message: Data, from participant: GroupActivitySession.Participant) async {
        // Handle incoming messages on main actor
        // This ensures UI updates happen on main thread
        Task { @MainActor in
            // Process the message and update state
        }
    }

    private func startMessageProcessing() {
        messageTask = Task { @MainActor in
            // Handle any ongoing message processing
        }
    }

    func broadcastState<T: Codable>(_ state: T) async throws {
        guard let messenger = messenger else { return }
        let data = try JSONEncoder().encode(state)
        try await messenger.send(data)
    }
}

// MARK: - 3. Window Menu Bar Integration
import SwiftUI

struct SharePlayWindowContent: View {
    @StateObject private var sharePlayManager = SharePlayManager()

    var body: some View {
        ContentView()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if !sharePlayManager.isActive {
                            Button("Start SharePlay") {
                                Task {
                                    try await sharePlayManager.startSession()
                                }
                            }
                        } else {
                            Button("End SharePlay") {
                                Task {
                                    await sharePlayManager.endSession()
                                }
                            }
                        }
                    } label: {
                        Image(systemName: sharePlayManager.isActive ? "person.3.fill" : "person.3")
                    }
                }
            }
    }
}

// MARK: - 4. Basic Message Types
struct SharePlayMessage: Codable {
    enum MessageType: String, Codable {
        case stateUpdate
        case action
        case participantJoined
        case participantLeft
    }

    let type: MessageType
    let data: Data
    let timestamp: Date
}

struct StateUpdateMessage: Codable {
    let key: String
    let value: CodableValue
}

enum CodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([CodableValue])
    case dictionary([String: CodableValue])
}

// MARK: - 5. State Synchronization Helper
@MainActor
class SynchronizedState<T: Codable>: ObservableObject {
    @Published var value: T {
        didSet {
            if shouldSync {
                Task {
                    try? await broadcastChange()
                }
            }
        }
    }

    private let sharePlayManager: SharePlayManager
    private let key: String
    private var shouldSync = false
    private var broadcastTask: Task<Void, Never>?

    init(initialValue: T, key: String, sharePlayManager: SharePlayManager) {
        self.value = initialValue
        self.key = key
        self.sharePlayManager = sharePlayManager
        self.shouldSync = true
    }

    func updateFromRemote(_ newValue: T) {
        shouldSync = false
        value = newValue
        shouldSync = true
    }

    private func broadcastChange() async throws {
        // Cancel any pending broadcast for this key
        broadcastTask?.cancel()

        // Debounce rapid changes
        broadcastTask = Task {
            try await Task.sleep(for: .milliseconds(100))

            guard !Task.isCancelled else { return }

            let message = StateUpdateMessage(key: key, value: value.encodeToCodableValue())
            let sharePlayMessage = SharePlayMessage(
                type: .stateUpdate,
                data: try JSONEncoder().encode(message),
                timestamp: Date()
            )
            try await sharePlayManager.broadcastState(sharePlayMessage)
        }
    }

    deinit {
        broadcastTask?.cancel()
    }
}

extension Codable {
    func encodeToCodableValue() -> CodableValue {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            let json = try JSONSerialization.jsonObject(with: data)
            return Self.convertJSONToCodableValue(json)
        } catch {
            // Fallback for encoding errors - return string representation
            return .string(String(describing: self))
        }
    }

    private static func convertJSONToCodableValue(_ value: Any) -> CodableValue {
        switch value {
        case let str as String:
            return .string(str)
        case let num as NSNumber:
            // Handle different number types
            if NSStringFromClass(type(of: num)) == "__NSCFBoolean" {
                return .bool(num.boolValue)
            } else if num.doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                return .int(num.intValue)
            } else {
                return .double(num.doubleValue)
            }
        case let arr as [Any]:
            return .array(arr.map { convertJSONToCodableValue($0) })
        case let dict as [String: Any]:
            return .dictionary(dict.mapValues { convertJSONToCodableValue($0) })
        case let null as NSNull:
            return .null
        default:
            // Fallback for unknown types
            return .string(String(describing: value))
        }
    }
}