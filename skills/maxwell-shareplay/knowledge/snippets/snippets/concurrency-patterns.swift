// Swift Concurrency Patterns for SharePlay
// Use these patterns for modern async/await-based SharePlay implementation

import Foundation
import GroupActivities

// MARK: - 1. Actor-based Session State Management
actor SharePlaySessionState {
    private var participants: [GroupActivitySession.Participant] = []
    private var sharedState: [String: any Codable] = [:]
    private var messageQueue: [SharePlayMessage] = []
    private var isProcessing = false

    // Thread-safe access to participants
    var currentParticipants: [GroupActivitySession.Participant] {
        participants
    }

    // Thread-safe state management
    func updateState<T: Codable>(key: String, value: T) {
        sharedState[key] = value
    }

    func getState<T: Codable>(key: String, type: T.Type) -> T? {
        sharedState[key] as? T
    }

    // Participant management
    func addParticipant(_ participant: GroupActivitySession.Participant) {
        participants.append(participant)
    }

    func removeParticipant(_ participant: GroupActivitySession.Participant) {
        participants.removeAll { $0.id == participant.id }
    }

    // Message processing with serialization
    func enqueueMessage(_ message: SharePlayMessage) {
        messageQueue.append(message)

        if !isProcessing {
            Task {
                await processMessageQueue()
            }
        }
    }

    private func processMessageQueue() async {
        isProcessing = true
        defer { isProcessing = false }

        while !messageQueue.isEmpty {
            let message = messageQueue.removeFirst()
            await handleMessage(message)

            // Small delay to prevent overwhelming the system
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func handleMessage(_ message: SharePlayMessage) async {
        // Process individual messages
        switch message.type {
        case .stateUpdate:
            await handleStateUpdate(message)
        case .action:
            await handleAction(message)
        case .participantJoined:
            await handleParticipantJoined(message)
        case .participantLeft:
            await handleParticipantLeft(message)
        }
    }

    private func handleStateUpdate(_ message: SharePlayMessage) async {
        // Handle state update logic
    }

    private func handleAction(_ message: SharePlayMessage) async {
        // Handle action logic
    }

    private func handleParticipantJoined(_ message: SharePlayMessage) async {
        // Handle participant joined logic
    }

    private func handleParticipantLeft(_ message: SharePlayMessage) async {
        // Handle participant left logic
    }
}

// MARK: - 2. AsyncStream-based Message Processing
class SharePlayMessageProcessor {
    private let sessionState: SharePlaySessionState
    private var continuation: AsyncStream<SharePlayMessage>.Continuation?
    private var messageStream: AsyncStream<SharePlayMessage>?

    init(sessionState: SharePlaySessionState) {
        self.sessionState = sessionState
        setupMessageStream()
    }

    private func setupMessageStream() {
        var continuation: AsyncStream<SharePlayMessage>.Continuation?

        messageStream = AsyncStream<SharePlayMessage> { cont in
            continuation = cont
        }

        self.continuation = continuation
    }

    func processIncomingMessages() async {
        guard let messageStream = messageStream else { return }

        for await message in messageStream {
            await sessionState.enqueueMessage(message)
        }
    }

    func receiveMessage(_ message: SharePlayMessage) {
        continuation?.yield(message)
    }

    // Stream of processed messages for UI updates
    // Uses verified SDK pattern: session.$activeParticipants.values
    func processedMessageStream() -> AsyncStream<StateChange> {
        AsyncStream<StateChange> { continuation in
            Task {
                var previousState: [String: Any]? = nil

                // Monitor participant changes using verified SDK pattern
                for await activeParticipants in session.$activeParticipants.values {
                    let currentState: [String: Any] = [
                        "participantCount": activeParticipants.count,
                        "activeParticipants": activeParticipants.map { $0.id.uuidString },
                        "timestamp": Date()
                    ]

                    if previousState != currentState {
                        let changes = detectStateChanges(
                            from: previousState,
                            to: currentState
                        )

                        for change in changes {
                            continuation.yield(change)
                        }

                        previousState = currentState
                    }

                    // Add small delay to prevent excessive updates
                    try? await Task.sleep(for: .milliseconds(16))
                }

                continuation.finish()
            }
        }
    }

    private func detectStateChanges(
        from previousState: [String: Any]?,
        to currentState: [String: Any]
    ) -> [StateChange] {
        guard let previous = previousState else {
            return [StateChange(
                key: "initialState",
                oldValue: nil,
                newValue: currentState,
                timestamp: currentState["timestamp"] as? Date ?? Date()
            )]
        }

        var changes: [StateChange] = []

        // Detect participant count changes
        let oldCount = previous["participantCount"] as? Int ?? 0
        let newCount = currentState["participantCount"] as? Int ?? 0
        if oldCount != newCount {
            changes.append(StateChange(
                key: "participantCount",
                oldValue: oldCount,
                newValue: newCount,
                timestamp: Date()
            ))
        }

        return changes
    }
}

struct StateChange: Sendable {
    let key: String
    let oldValue: Any?
    let newValue: Any
    let timestamp: Date
}

// MARK: - 3. TaskGroup for Concurrent Operations
class SharePlayOperationManager {
    private let session: GroupActivitySession
    private var operations: [Task<Void, Never>] = []

    init(session: GroupActivitySession) {
        self.session = session
    }

    func performConcurrentOperations<T: Codable>(
        operations: [T],
        operation: @escaping (T) async throws -> Void
    ) async rethrows {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for item in operations {
                group.addTask {
                    try await operation(item)
                }
            }

            try await group.waitForAll()
        }
    }

    func broadcastWithRetry<T: Codable>(
        _ data: T,
        maxRetries: Int = 3
    ) async throws {
        var attempts = 0
        var lastError: Error?

        while attempts < maxRetries {
            do {
                let encodedData = try JSONEncoder().encode(data)
                // Broadcast logic here
                return
            } catch {
                lastError = error
                attempts += 1

                // Exponential backoff
                let delay = pow(2.0, Double(attempts)) * 100_000_000 // nanoseconds
                try await Task.sleep(nanoseconds: UInt64(delay))
            }
        }

        throw lastError ?? SharePlayError.broadcastFailed
    }
}

// MARK: - 4. AsyncImage Loading for Shared Content
actor SharedContentCache {
    private var cache: [URL: Data] = [:]
    private var loadingTasks: [URL: Task<Data, Error>] = [:]

    func content(for url: URL) async throws -> Data {
        // Return cached content if available
        if let cached = cache[url] {
            return cached
        }

        // Return existing loading task if already in progress
        if let existingTask = loadingTasks[url] {
            return try await existingTask.value
        }

        // Create new loading task
        let task = Task<Data, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }

        loadingTasks[url] = task

        do {
            let data = try await task.value
            cache[url] = data
            loadingTasks.removeValue(forKey: url)
            return data
        } catch {
            loadingTasks.removeValue(forKey: url)
            throw error
        }
    }

    func preloadContent(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    try? await self.content(for: url)
                }
            }
        }
    }
}

// MARK: - 5. Timeout and Cancellation Patterns
struct SharePlayTimeout {
    let duration: TimeInterval

    func execute<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                return try await operation()
            }

            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(self.duration * 1_000_000_000))
                throw SharePlayError.timeout
            }

            // Return the first completed task
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - 6. Debounced State Updates
@MainActor
class DebouncedStateUpdater {
    private var updateTasks: [String: Task<Void, Never>] = [:]
    private let debounceTime: TimeInterval

    init(debounceTime: TimeInterval = 0.3) {
        self.debounceTime = debounceTime
    }

    func scheduleUpdate<T: Codable>(
        key: String,
        value: T,
        updateHandler: @escaping (T) async -> Void
    ) {
        // Cancel existing task for this key
        updateTasks[key]?.cancel()

        // Schedule new debounced task
        updateTasks[key] = Task { @MainActor in
            try? await Task.sleep(for: .seconds(debounceTime))

            guard !Task.isCancelled else { return }

            await updateHandler(value)
            updateTasks.removeValue(forKey: key)
        }
    }

    func cancelUpdate(key: String) {
        updateTasks[key]?.cancel()
        updateTasks.removeValue(forKey: key)
    }

    func cancelAllUpdates() {
        updateTasks.values.forEach { $0.cancel() }
        updateTasks.removeAll()
    }
}

// MARK: - 7. Error Types
enum SharePlayError: LocalizedError {
    case sessionNotFound
    case broadcastFailed
    case timeout
    case participantDisconnected
    case stateCorruption

    var errorDescription: String? {
        switch self {
        case .sessionNotFound:
            return "SharePlay session not found"
        case .broadcastFailed:
            return "Failed to broadcast message to participants"
        case .timeout:
            return "Operation timed out"
        case .participantDisconnected:
            return "Participant disconnected from session"
        case .stateCorruption:
            return "Shared state corruption detected"
        }
    }
}

// MARK: - 8. Usage Examples
@MainActor
class SharePlayViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var participantCount = 0
    @Published var currentActivity: String?

    private let sessionState = SharePlaySessionState()
    private let messageProcessor: SharePlayMessageProcessor
    private let operationManager: SharePlayOperationManager
    private let stateUpdater = DebouncedStateUpdater()

    private var session: GroupActivitySession?

    init() {
        self.messageProcessor = SharePlayMessageProcessor(sessionState: sessionState)
        self.operationManager = SharePlayOperationManager(session: session!)

        startProcessing()
    }

    private func startProcessing() {
        Task {
            await messageProcessor.processIncomingMessages()
        }

        // Monitor participant count
        Task { @MainActor in
            for await _ in Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().values {
                let count = await sessionState.currentParticipants.count
                if participantCount != count {
                    participantCount = count
                }
            }
        }
    }

    func updateActivity(_ activity: String) {
        stateUpdater.scheduleUpdate(key: "activity", value: activity) { [weak self] newActivity in
            await self?.broadcastActivityChange(newActivity)
        }
    }

    private func broadcastActivityChange(_ activity: String) async {
        do {
            try await operationManager.broadcastWithRetry(activity)
        } catch {
            print("Failed to broadcast activity change: \(error)")
        }
    }
}