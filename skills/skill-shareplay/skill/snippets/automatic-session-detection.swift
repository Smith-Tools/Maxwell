// Automatic Session Detection for SharePlay
// Reactive patterns for detecting and managing SharePlay sessions without manual intervention

import Foundation
import GroupActivities
import SwiftUI
import Combine

// MARK: - 1. Session Detection Manager
@MainActor
class AutomaticSessionDetectionManager: ObservableObject {
    @Published var detectedSessions: [DetectedSession] = []
    @Published var isDetectionActive = false
    @Published var primarySession: DetectedSession?
    @Published var lastDetectionTime: Date?

    private var detectionTask: Task<Void, Never>?
    private var sessionMonitor: SessionMonitor
    private var sessionFilter: SessionFilter

    init(sessionFilter: SessionFilter = .default) {
        self.sessionMonitor = SessionMonitor()
        self.sessionFilter = sessionFilter
        setupSessionMonitoring()
    }

    func startDetection() {
        guard !isDetectionActive else { return }

        isDetectionActive = true
        detectionTask = Task { @MainActor in
            await continuouslyDetectSessions()
        }
    }

    func stopDetection() {
        isDetectionActive = false
        detectionTask?.cancel()
        detectionTask = nil
    }

    private func continuouslyDetectSessions() async {
        while !Task.isCancelled {
            let sessions = await detectAndFilterSessions()

            if sessions != detectedSessions {
                await updateDetectedSessions(sessions)
            }

            // Adaptive detection interval based on session activity
            let interval = sessions.isEmpty ? 3.0 : 1.0
            try? await Task.sleep(for: .seconds(interval))
        }
    }

    private func detectAndFilterSessions() async -> [DetectedSession] {
        let allSessions = await sessionMonitor.detectAllSessions()
        return sessionFilter.filter(allSessions)
    }

    private func updateDetectedSessions(_ sessions: [DetectedSession]) async {
        detectedSessions = sessions
        lastDetectionTime = Date()

        // Update primary session
        if let primary = sessions.sorted(by: { $0.priority > $1.priority }).first {
            if primarySession?.id != primary.id {
                primarySession = primary
                await notifyPrimarySessionChange(primary)
            }
        } else {
            primarySession = nil
            await notifyPrimarySessionChange(nil)
        }
    }

    private func notifyPrimarySessionChange(_ session: DetectedSession?) async {
        NotificationCenter.default.post(
            name: .primarySessionDidChange,
            object: session
        )
    }

    private func setupSessionMonitoring() {
        sessionMonitor.sessionDiscovered
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                Task { @MainActor in
                    await self?.handleSessionDiscovered(session)
                }
            }
            .store(in: &cancellables)

        sessionMonitor.sessionEnded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionID in
                Task { @MainActor in
                    await self?.handleSessionEnded(sessionID)
                }
            }
            .store(in: &cancellables)
    }

    private func handleSessionDiscovered(_ session: DetectedSession) async {
        if !detectedSessions.contains(where: { $0.id == session.id }) {
            detectedSessions.append(session)
        }
    }

    private func handleSessionEnded(_ sessionID: UUID) async {
        detectedSessions.removeAll { $0.id == sessionID }
        if primarySession?.id == sessionID {
            primarySession = nil
        }
    }

    private var cancellables = Set<AnyCancellable>()
}

// MARK: - 2. Detected Session Model
struct DetectedSession: Identifiable, Codable {
    let id: UUID
    let activity: String
    let title: String
    let participantCount: Int
    let maxParticipants: Int
    let isJoinable: Bool
    let requiresInvite: Bool
    let priority: Int
    let discoveryTime: Date
    let metadata: SessionMetadata

    var participantRatio: Double {
        guard maxParticipants > 0 else { return 0 }
        return Double(participantCount) / Double(maxParticipants)
    }

    var availability: Availability {
        switch participantRatio {
        case 0..<0.5:
            return .plentiful
        case 0.5..<0.8:
            return .available
        case 0.8..<1.0:
            return .limited
        default:
            return .full
        }
    }

    enum Availability {
        case plentiful
        case available
        case limited
        case full

        var color: Color {
            switch self {
            case .plentiful: return .green
            case .available: return .blue
            case .limited: return .orange
            case .full: return .red
            }
        }

        var description: String {
            switch self {
            case .plentiful: return "Plenty of space"
            case .available: return "Space available"
            case .limited: return "Limited space"
            case .full: return "Session full"
            }
        }
    }
}

struct SessionMetadata: Codable {
    let supportsImmersiveSpace: Bool
    let supportsVoiceChat: Bool
    let supportsVideo: Bool
    let activityType: String
    let version: String
    let hostID: UUID?
}

// MARK: - 3. Session Monitor
class SessionMonitor: ObservableObject {
    @Published var isMonitoring = false

    let sessionDiscovered = PassthroughSubject<DetectedSession, Never>()
    let sessionEnded = PassthroughSubject<UUID, Never>()

    private var knownSessions: Set<UUID> = []
    private var monitoringTask: Task<Void, Never>?

    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        monitoringTask = Task { @MainActor in
            await performContinuousMonitoring()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
        knownSessions.removeAll()
    }

    private func performContinuousMonitoring() async {
        while !Task.isCancelled {
            let currentSessions = await detectAllSessions()

            // Find new sessions
            for session in currentSessions {
                if !knownSessions.contains(session.id) {
                    knownSessions.insert(session.id)
                    sessionDiscovered.send(session)
                }
            }

            // Find ended sessions
            let endedSessions = knownSessions.subtracting(Set(currentSessions.map(\.id)))
            for sessionID in endedSessions {
                knownSessions.remove(sessionID)
                sessionEnded.send(sessionID)
            }

            try? await Task.sleep(for: .seconds(2))
        }
    }

    func detectAllSessions() async -> [DetectedSession] {
        var sessions: [DetectedSession] = []

        // Monitor different GroupActivity types
        let activityTypes: [any GroupActivity.Type] = [
            EscapeTogether.self,
            VisionOSGroupActivity.self,
            GameActivity.self,
            CollaborativeActivity.self
        ]

        for activityType in activityTypes {
            do {
                let activitySessions = await activityType.sessions()
                for session in activitySessions {
                    if let detectedSession = await createDetectedSession(from: session) {
                        sessions.append(detectedSession)
                    }
                }
            } catch {
                print("Error detecting sessions for \(activityType): \(error)")
            }
        }

        return sessions
    }

    private func createDetectedSession(from session: GroupSession<any GroupActivity>) async -> DetectedSession? {
        guard let activity = session.activity else { return nil }

        return DetectedSession(
            id: session.id,
            activity: String(describing: type(of: activity)),
            title: activity.metadata.title,
            participantCount: session.activeParticipants.count,
            maxParticipants: session.maximumParticipants,
            isJoinable: session.joinability == .joinable,
            requiresInvite: session.joinability == .inviteOnly,
            priority: calculateSessionPriority(session),
            discoveryTime: Date(),
            metadata: SessionMetadata(
                supportsImmersiveSpace: activity.metadata.supportsGroupImmersiveSpace,
                supportsVoiceChat: activity.metadata.supportsVoiceChat,
                supportsVideo: activity.metadata.supportsVideo,
                activityType: String(describing: type(of: activity)),
                version: "1.0",
                hostID: session.localParticipant?.id
            )
        )
    }

    private func calculateSessionPriority(_ session: GroupSession<any GroupActivity>) -> Int {
        var priority = 0

        // Higher priority for sessions with more participants
        priority += session.activeParticipants.count * 10

        // Higher priority for joinable sessions
        if session.joinability == .joinable {
            priority += 50
        }

        // Higher priority for immersive space sessions
        if session.activity?.metadata.supportsGroupImmersiveSpace == true {
            priority += 25
        }

        return priority
    }
}

// MARK: - 4. Session Filter
struct SessionFilter {
    let filterRules: [FilterRule]

    static let `default` = SessionFilter(filterRules: [
        .excludeFullSessions,
        .requireJoinability,
        .prioritySort
    ])

    static let `all` = SessionFilter(filterRules: [])

    static let immersiveOnly = SessionFilter(filterRules: [
        .requireImmersiveSpace,
        .excludeFullSessions,
        .requireJoinability
    ])

    enum FilterRule {
        case excludeFullSessions
        case requireJoinability
        case requireImmersiveSpace
        case minimumParticipants(Int)
        case maximumParticipants(Int)
        case excludeActivityType(String)
        case prioritySort
        case alphabeticalSort
    }

    func filter(_ sessions: [DetectedSession]) -> [DetectedSession] {
        var filteredSessions = sessions

        for rule in filterRules {
            filteredSessions = applyRule(rule, to: filteredSessions)
        }

        return filteredSessions
    }

    private func applyRule(_ rule: FilterRule, to sessions: [DetectedSession]) -> [DetectedSession] {
        switch rule {
        case .excludeFullSessions:
            return sessions.filter { $0.availability != .full }

        case .requireJoinability:
            return sessions.filter { $0.isJoinable }

        case .requireImmersiveSpace:
            return sessions.filter { $0.metadata.supportsImmersiveSpace }

        case .minimumParticipants(let count):
            return sessions.filter { $0.participantCount >= count }

        case .maximumParticipants(let count):
            return sessions.filter { $0.participantCount <= count }

        case .excludeActivityType(let type):
            return sessions.filter { $0.activity != type }

        case .prioritySort:
            return sessions.sorted { $0.priority > $1.priority }

        case .alphabeticalSort:
            return sessions.sorted { $0.title < $1.title }
        }
    }
}

// MARK: - 5. Session Auto-Join Manager
class SessionAutoJoinManager: ObservableObject {
    @Published var autoJoinEnabled = false
    @Published var autoJoinRules: [AutoJoinRule] = []
    @Published var autoJoinHistory: [AutoJoinAttempt] = []

    private let detectionManager: AutomaticSessionDetectionManager

    init(detectionManager: AutomaticSessionDetectionManager) {
        self.detectionManager = detectionManager
        setupAutoJoinMonitoring()
    }

    private func setupAutoJoinMonitoring() {
        detectionManager.$detectedSessions
            .sink { [weak self] sessions in
                Task { @MainActor in
                    await self?.evaluateAutoJoin(sessions)
                }
            }
            .store(in: &cancellables)
    }

    private func evaluateAutoJoin(_ sessions: [DetectedSession]) async {
        guard autoJoinEnabled else { return }

        for session in sessions {
            if shouldAutoJoin(session) {
                await attemptAutoJoin(session)
            }
        }
    }

    private func shouldAutoJoin(_ session: DetectedSession) -> Bool {
        return autoJoinRules.allSatisfy { rule in
            rule.evaluate(session)
        }
    }

    private func attemptAutoJoin(_ session: DetectedSession) async {
        let attempt = AutoJoinAttempt(
            sessionID: session.id,
            sessionTitle: session.title,
            timestamp: Date(),
            result: .pending
        )

        autoJoinHistory.append(attempt)

        do {
            // Attempt to join the session
            let groupActivity = try await createGroupActivity(for: session)
            let groupSession = try await groupActivity.prepareForActivation()
            try await groupSession.join()

            // Update attempt result
            if let index = autoJoinHistory.firstIndex(where: { $0.sessionID == session.id }) {
                autoJoinHistory[index].result = .success
            }
        } catch {
            // Update attempt result with error
            if let index = autoJoinHistory.firstIndex(where: { $0.sessionID == session.id }) {
                autoJoinHistory[index].result = .failure(error.localizedDescription)
            }
        }
    }

    private func createGroupActivity(for session: DetectedSession) async throws -> GroupActivity {
        // Create appropriate GroupActivity based on session type
        switch session.activity {
        case "EscapeTogether":
            return EscapeTogether()
        case "VisionOSGroupActivity":
            return VisionOSGroupActivity()
        default:
            return VisionOSGroupActivity() // Default fallback
        }
    }

    private var cancellables = Set<AnyCancellable>()
}

// MARK: - 6. Auto-Join Rules
struct AutoJoinRule {
    let name: String
    let description: String
    let isEnabled: Bool
    let evaluate: (DetectedSession) -> Bool

    static let excludeFullSessions = AutoJoinRule(
        name: "Exclude Full Sessions",
        description: "Don't auto-join sessions that are full",
        isEnabled: true
    ) { session in
        session.availability != .full
    }

    static let requireImmersiveSpace = AutoJoinRule(
        name: "Require Immersive Space",
        description: "Only auto-join sessions with immersive space support",
        isEnabled: false
    ) { session in
        session.metadata.supportsImmersiveSpace
    }

    static let maximumParticipants = AutoJoinRule(
        name: "Maximum Participant Limit",
        description: "Don't join sessions with more than 8 participants",
        isEnabled: true
    ) { session in
        session.participantCount <= 8
    }

    static let minimumParticipants = AutoJoinRule(
        name: "Minimum Participant Threshold",
        description: "Only join sessions with at least 2 participants",
        isEnabled: true
    ) { session in
        session.participantCount >= 2
    }
}

// MARK: - 7. Auto-Join History
struct AutoJoinAttempt: Identifiable, Codable {
    let id = UUID()
    let sessionID: UUID
    let sessionTitle: String
    let timestamp: Date
    var result: JoinResult

    enum JoinResult: Codable {
        case pending
        case success
        case failure(String)

        var displayText: String {
            switch self {
            case .pending: return "Attempting to join..."
            case .success: return "Successfully joined"
            case .failure(let error): return "Failed: \(error)"
            }
        }

        var color: Color {
            switch self {
            case .pending: return .orange
            case .success: return .green
            case .failure: return .red
            }
        }
    }
}

// MARK: - 8. Session Discovery UI
struct SessionDiscoveryView: View {
    @StateObject private var detectionManager = AutomaticSessionDetectionManager()
    @StateObject private var autoJoinManager: SessionAutoJoinManager

    @State private var selectedFilter: SessionFilter = .default
    @State private var showingAutoJoinSettings = false

    init() {
        let detectionManager = AutomaticSessionDetectionManager()
        self._autoJoinManager = StateObject(wrappedValue: SessionAutoJoinManager(detectionManager: detectionManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            headerView

            // Filter tabs
            filterTabsView

            // Session list
            sessionListView

            // Auto-join status
            if autoJoinManager.autoJoinEnabled {
                autoJoinStatusView
            }
        }
        .onAppear {
            detectionManager.startDetection()
        }
        .onDisappear {
            detectionManager.stopDetection()
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("SharePlay Sessions")
                    .font(.headline)

                if let lastTime = detectionManager.lastDetectionTime {
                    Text("Last updated: \(lastTime, style: .relative) ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: {
                showingAutoJoinSettings = true
            }) {
                Image(systemName: autoJoinManager.autoJoinEnabled ? "gear.fill" : "gear")
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterTab(
                    title: "All",
                    isSelected: selectedFilter == .all,
                    action: { selectedFilter = .all }
                )

                FilterTab(
                    title: "Default",
                    isSelected: selectedFilter == .default,
                    action: { selectedFilter = .default }
                )

                FilterTab(
                    title: "Immersive",
                    isSelected: selectedFilter == .immersiveOnly,
                    action: { selectedFilter = .immersiveOnly }
                )
            }
            .padding(.horizontal)
        }
    }

    private var sessionListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if detectionManager.detectedSessions.isEmpty {
                    EmptyStateView()
                } else {
                    ForEach(filteredSessions) { session in
                        SessionRowView(
                            session: session,
                            onJoin: {
                                Task {
                                    await joinSession(session)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }

    private var filteredSessions: [DetectedSession] {
        selectedFilter.filter(detectionManager.detectedSessions)
    }

    private var autoJoinStatusView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.blue)
                Text("Auto-Join Active")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }

            if let lastAttempt = autoJoinManager.autoJoinHistory.last {
                HStack {
                    Circle()
                        .fill(lastAttempt.result.color)
                        .frame(width: 8, height: 8)
                    Text(lastAttempt.result.displayText)
                        .font(.caption)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private func joinSession(_ session: DetectedSession) async {
        do {
            // Implement session joining logic
            print("Joining session: \(session.title)")
        } catch {
            print("Failed to join session: \(error)")
        }
    }
}

// MARK: - Supporting Views
struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct SessionRowView: View {
    let session: DetectedSession
    let onJoin: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(session.activity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(session.participantCount)/\(session.maxParticipants)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    session.availability.color
                        .frame(width: 12, height: 12)
                        .cornerRadius(6)
                }
            }

            HStack {
                Label(session.availability.description, systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(session.availability.color)

                if session.metadata.supportsImmersiveSpace {
                    Label("Immersive", systemImage: "vr.headset")
                        .font(.caption)
                }

                Spacer()

                Button("Join", action: onJoin)
                    .buttonStyle(.bordered)
                    .disabled(!session.isJoinable)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No SharePlay Sessions Found")
                .font(.headline)

            Text("Start a FaceTime call and check back here for available sessions.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let primarySessionDidChange = Notification.Name("primarySessionDidChange")
}

// MARK: - Placeholder Activity Types (replace with actual implementations)
class EscapeTogether: GroupActivity {
    override var metadata: GroupActivityMetadata {
        var metadata = super.metadata
        metadata.title = "Escape Together"
        return metadata
    }
}

class VisionOSGroupActivity: GroupActivity {
    override var metadata: GroupActivityMetadata {
        var metadata = super.metadata
        metadata.title = "visionOS Experience"
        metadata.supportsGroupImmersiveSpace = true
        return metadata
    }
}

class GameActivity: GroupActivity {
    override var metadata: GroupActivityMetadata {
        var metadata = super.metadata
        metadata.title = "Game Session"
        return metadata
    }
}

class CollaborativeActivity: GroupActivity {
    override var metadata: GroupActivityMetadata {
        var metadata = super.metadata
        metadata.title = "Collaborative Session"
        return metadata
    }
}