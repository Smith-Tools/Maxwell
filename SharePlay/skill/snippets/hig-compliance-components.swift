// MARK: - HIG-Compliant SharePlay UI Components
// Based on Apple Human Interface Guidelines for SharePlay experiences

import SwiftUI
import GroupActivities

// MARK: - Participant List Component
@MainActor
struct HIGCompliantParticipantList: View {
    let participants: [Participant]
    let localParticipant: Participant?
    let isHost: Bool

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(sortedParticipants, id: \.id) { participant in
                ParticipantRow(
                    participant: participant,
                    isLocal: participant.id == localParticipant?.id,
                    isHost: participant.id == participants.first?.id,
                    showControls: isHost && participant.id != localParticipant?.id
                )
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel("Participants")
        .accessibilityHint("List of all participants in the SharePlay session")
    }

    private var sortedParticipants: [Participant] {
        // Sort by host status, then by join time (simulated)
        return participants.enumerated().sorted { first, second in
            if first.offset == 0 { return true }
            if second.offset == 0 { return false }
            return false // Maintain join order
        }.map { $0.element }
    }
}

// MARK: - Individual Participant Row
struct ParticipantRow: View {
    let participant: Participant
    let isLocal: Bool
    let isHost: Bool
    let showControls: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Avatar with fallback
            ParticipantAvatar(
                participant: participant,
                isLocal: isLocal,
                isHost: isHost
            )

            // Participant info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(displayName)
                        .font(.subheadline)
                        .fontWeight(isLocal ? .semibold : .regular)
                        .foregroundColor(.primary)

                    if isHost {
                        Text("Host")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundColor(.accentColor)
                            .clipShape(Capsule())
                    }

                    if isLocal {
                        Text("You")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.secondary)
                            .clipShape(Capsule())
                    }
                }

                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status indicator
            StatusIndicator(status: participantStatus)
                .accessibilityHidden(true)

            // Host controls
            if showControls {
                Menu {
                    Button("Make Host", role: nil) {
                        // Host management action
                    }
                    Button("Remove Participant", role: .destructive) {
                        // Remove participant action
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Participant options")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var displayName: String {
        // In real implementation, use participant.displayname or similar
        return "Participant \(participant.id.uuidString.prefix(8))"
    }

    private var statusText: String {
        switch participantStatus {
        case .active:
            return "Active"
        case .away:
            return "Away"
        case .disconnected:
            return "Disconnected"
        }
    }

    private var participantStatus: ParticipantStatus {
        // In real implementation, track actual participant status
        return .active
    }
}

// MARK: - Participant Avatar Component
struct ParticipantAvatar: View {
    let participant: Participant
    let isLocal: Bool
    let isHost: Bool

    var body: some View {
        ZStack {
            // Background circle with distinctive color
            Circle()
                .fill(avatarColor)
                .frame(width: 40, height: 40)

            // Initial or icon
            if isHost {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            } else {
                Text(initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Status indicator ring
            if participantStatus != .disconnected {
                Circle()
                    .stroke(statusColor, lineWidth: 2)
                    .frame(width: 44, height: 44)
            }
        }
        .accessibilityHidden(true)
    }

    private var initials: String {
        let name = "Participant" // Use actual participant name
        return String(name.prefix(2)).uppercased()
    }

    private var avatarColor: Color {
        // Generate consistent color based on participant ID
        let hash = participant.id.uuidString.hashValue
        let hue = Double(abs(hash % 360)) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.9)
    }

    private var participantStatus: ParticipantStatus {
        .active // Track actual status
    }

    private var statusColor: Color {
        switch participantStatus {
        case .active:
            return .green
        case .away:
            return .yellow
        case .disconnected:
            return .red
        }
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    let status: ParticipantStatus

    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 8, height: 8)
            .accessibilityLabel(status.accessibilityDescription)
    }

    private var statusColor: Color {
        switch status {
        case .active:
            return .green
        case .away:
            return .yellow
        case .disconnected:
            return .red
        }
    }
}

// MARK: - Session Controls Component
@MainActor
struct HIGCompliantSessionControls: View {
    let session: GroupSession<any GroupActivity>
    @Binding var isMuted: Bool
    @Binding var isPaused: Bool
    let onEndSession: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Play/Pause control
            Button(action: { togglePlayPause() }) {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .accessibilityLabel(isPaused ? "Resume" : "Pause")
            .accessibilityHint(isPaused ? "Resume the SharePlay activity" : "Pause the SharePlay activity")

            // Mute control
            Button(action: { isMuted.toggle() }) {
                Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.title2)
                    .foregroundColor(isMuted ? .red : .primary)
            }
            .accessibilityLabel(isMuted ? "Unmute" : "Mute")
            .accessibilityHint(isMuted ? "Unmute your microphone" : "Mute your microphone")

            Spacer()

            // Participant count
            Button(action: { /* Show participant list */ }) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                    Text("\(session.activeParticipants.count)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .clipShape(Capsule())
            }
            .accessibilityLabel("\(session.activeParticipants.count) participants")
            .accessibilityHint("Show participant list")

            // End session button
            Button(action: onEndSession) {
                Image(systemName: "phone.down.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .accessibilityLabel("End session")
            .accessibilityHint("Leave the SharePlay session")
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private func togglePlayPause() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPaused.toggle()
        }
    }
}

// MARK: - Activity Status Banner
@MainActor
struct ActivityStatusBanner: View {
    let sessionState: SessionState
    let networkQuality: NetworkQuality
    let participantCount: Int

    var body: some View {
        VStack(spacing: 8) {
            // Primary status
            HStack {
                Image(systemName: sessionState.iconName)
                    .foregroundColor(sessionState.color)

                Text(sessionState.description)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if networkQuality != .excellent {
                    HStack(spacing: 4) {
                        Image(systemName: networkQuality.iconName)
                            .foregroundColor(networkQuality.color)
                        Text(networkQuality.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Secondary information
            if let detail = sessionState.detail {
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(sessionState.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(sessionState.borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Activity status: \(sessionState.description)")
    }
}

// MARK: - Network Quality Indicator
struct NetworkQualityIndicator: View {
    let quality: NetworkQuality

    var body: some View {
        HStack(spacing: 6) {
            // Signal bars
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<4) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(width: 3, height: CGFloat(4 + index * 3))
                        .clipShape(RoundedRectangle(cornerRadius: 1))
                }
            }

            // Quality text
            Text(quality.shortDescription)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(quality.color)
        }
        .accessibilityElement()
        .accessibilityLabel("Network quality: \(quality.description)")
        .accessibilityValue(quality.accessibilityValue)
    }

    private func barColor(for index: Int) -> Color {
        let activeBars = quality.barCount
        return index < activeBars ? quality.color : Color.gray.opacity(0.3)
    }
}

// MARK: - Supporting Types
enum ParticipantStatus {
    case active
    case away
    case disconnected

    var accessibilityDescription: String {
        switch self {
        case .active:
            return "Active participant"
        case .away:
            return "Participant is away"
        case .disconnected:
            return "Participant is disconnected"
        }
    }
}

enum SessionState {
    case preparing
    case waiting(participants: Int)
    case active
    case paused
    case ending
    case error(Error)

    var description: String {
        switch self {
        case .preparing:
            return "Preparing session"
        case .waiting(let participants):
            return "Waiting for participants"
        case .active:
            return "Session active"
        case .paused:
            return "Session paused"
        case .ending:
            return "Ending session"
        case .error:
            return "Session error"
        }
    }

    var detail: String? {
        switch self {
        case .waiting(let participants):
            return "\(participants) participant\(participants == 1 ? "" : "s") joined"
        case .error(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }

    var iconName: String {
        switch self {
        case .preparing:
            return "gear.badge"
        case .waiting:
            return "person.2.badge.clock"
        case .active:
            return "play.circle.fill"
        case .paused:
            return "pause.circle.fill"
        case .ending:
            return "stop.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .preparing, .waiting:
            return .blue
        case .active:
            return .green
        case .paused:
            return .yellow
        case .ending:
            return .orange
        case .error:
            return .red
        }
    }

    var backgroundColor: Color {
        color.opacity(0.1)
    }

    var borderColor: Color {
        color.opacity(0.3)
    }
}

enum NetworkQuality {
    case excellent
    case good
    case poor
    case disconnected

    var description: String {
        switch self {
        case .excellent:
            return "Excellent connection"
        case .good:
            return "Good connection"
        case .poor:
            return "Poor connection"
        case .disconnected:
            return "Disconnected"
        }
    }

    var shortDescription: String {
        switch self {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .poor:
            return "Poor"
        case .disconnected:
            return "Offline"
        }
    }

    var iconName: String {
        switch self {
        case .excellent:
            return "wifi"
        case .good:
            return "wifi.exclamationmark"
        case .poor:
            return "wifi.slash"
        case .disconnected:
            return "wifi.slash"
        }
    }

    var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .yellow
        case .poor:
            return .orange
        case .disconnected:
            return .red
        }
    }

    var barCount: Int {
        switch self {
        case .excellent:
            return 4
        case .good:
            return 3
        case .poor:
            return 2
        case .disconnected:
            return 1
        }
    }

    var accessibilityValue: String {
        switch self {
        case .excellent:
            return "4 out of 4 bars"
        case .good:
            return "3 out of 4 bars"
        case .poor:
            return "2 out of 4 bars"
        case .disconnected:
            return "1 out of 4 bars"
        }
    }
}

// MARK: - Accessibility Extensions
extension View {
    func sharePlayAccessibility() -> some View {
        self
            .accessibilityAddTraits(.updatesFrequently)
            .accessibilityRespondsToUserInteraction()
    }
}

// MARK: - Usage Example
@MainActor
struct HIGCompliantSharePlayView: View {
    @StateObject private var sharePlayManager = SharePlayManager()
    @State private var showingParticipantList = false

    var body: some View {
        VStack(spacing: 16) {
            // Activity content would go here
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Text("Activity Content")
                        .font(.headline)
                        .foregroundColor(.secondary)
                )

            // Status banner
            ActivityStatusBanner(
                sessionState: sharePlayManager.sessionState,
                networkQuality: sharePlayManager.networkQuality,
                participantCount: sharePlayManager.participantCount
            )

            // Session controls
            HIGCompliantSessionControls(
                session: sharePlayManager.session!,
                isMuted: $sharePlayManager.isMuted,
                isPaused: $sharePlayManager.isPaused,
                onEndSession: {
                    sharePlayManager.endSession()
                }
            )
        }
        .padding()
        .sheet(isPresented: $showingParticipantList) {
            NavigationView {
                HIGCompliantParticipantList(
                    participants: Array(sharePlayManager.participants),
                    localParticipant: sharePlayManager.localParticipant,
                    isHost: sharePlayManager.isHost
                )
                .navigationTitle("Participants")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingParticipantList = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Mock SharePlay Manager for Demonstration
@MainActor
class SharePlayManager: ObservableObject {
    @Published var sessionState: SessionState = .waiting(participants: 1)
    @Published var networkQuality: NetworkQuality = .good
    @Published var participantCount: Int = 1
    @Published var isMuted: Bool = false
    @Published var isPaused: Bool = false
    @Published var isHost: Bool = true

    var session: GroupSession<any GroupActivity>? {
        // Mock session
        nil
    }

    var participants: Set<Participant> {
        // Mock participants
        Set()
    }

    var localParticipant: Participant? {
        // Mock local participant
        nil
    }

    func endSession() {
        sessionState = .ending
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Handle session end
        }
    }
}