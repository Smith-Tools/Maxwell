# SharePlay Human Interface Guidelines (HIG)

## 🎯 Overview

This document outlines the essential Human Interface Guidelines for SharePlay experiences across visionOS, iOS, and macOS. These principles ensure consistent, intuitive, and engaging multi-user experiences that align with Apple's design philosophy.

---

## 📱 Platform-Specific Considerations

### visionOS Design Principles
SharePlay experiences in visionOS should leverage the unique spatial computing environment while maintaining consistency with established platform patterns.

#### Spatial Awareness
- **Respect Personal Space**: Position SharePlay UI elements at comfortable viewing distances (1-3 meters)
- **Immersive Integration**: Use SharePlay to enhance, not replace, the core immersive experience
- **Spatial Audio**: Leverage spatial audio for participant presence and communication
- **Gaze and Gesture**: Support natural interaction patterns without breaking immersion

#### Window and Scene Management
```swift
// Example: Proper SharePlay window configuration
window.defaultSize = CGSize(width: 800, height: 600)
window.minimumSize = CGSize(width: 400, height: 300)
window.resizability = .contentSize
```

### iOS Design Patterns
Mobile SharePlay experiences should prioritize accessibility, battery life, and network efficiency.

#### Touch Interface Considerations
- **Reachability**: Ensure SharePlay controls are accessible with one-handed use
- **Progressive Disclosure**: Use tab bars and navigation patterns that scale with group size
- **Context Menus**: Leverage long-press interactions for participant management

### macOS Integration
Desktop SharePlay should complement traditional workflow patterns without disrupting productivity.

#### Menu Bar Integration
- Use menu bar extras for persistent SharePlay session status
- Implement keyboard shortcuts for common SharePlay actions
- Support window management with multiple displays

---

## 👥 Participant Interface Design

### Participant Presence Indicators

#### Visual Representation
```swift
// Recommended participant indicator design principles
struct ParticipantIndicator {
    let principles = [
        "Clear visual hierarchy with host distinction",
        "Status indicators (online, away, disconnected)",
        "Avatar fallbacks with distinctive colors",
        "Activity status (typing, speaking, interacting)"
    ]
}
```

#### Accessibility Requirements
- VoiceOver support for participant list navigation
- High contrast support for status indicators
- Dynamic type scaling for participant names
- Color blind friendly status indicators

### Group Size Scaling

#### Small Groups (2-4 participants)
- Display full participant list with detailed status
- Enable individual participant controls
- Show real-time activity indicators

#### Medium Groups (5-12 participants)
- Prioritize active participants in primary UI
- Use scrollable lists for full participant access
- Implement smart filtering based on activity

#### Large Groups (13+ participants)
- Focus on active speakers and recent interactions
- Use search and filtering for participant discovery
- Provide participant count summaries
- Consider role-based display (hosts, moderators, participants)

---

## 🔄 Activity State Management

### Session Lifecycle UI

#### Discovery and Invitation
```swift
// Recommended invitation UI patterns
struct InvitationPatterns {
    let principles = [
        "Native sharing integration (Share Sheet)",
        "Clear activity description and requirements",
        "Participating device compatibility indicators",
        "Privacy-aware invitation messaging"
    ]
}
```

#### Session States
1. **Preparing**: Show setup progress and participant status
2. **Waiting**: Display lobby/waiting room with expected start time
3. **Active**: Full activity interface with participant engagement
4. **Paused**: Clear indication of temporary state with resume options
5. **Ending**: Graceful transition with next steps

#### Network Condition Indicators
- Subtle connectivity status (not intrusive)
- Quality indicators for media-heavy experiences
- Graceful degradation messaging
- Offline capability indicators when applicable

---

## 🎮 Activity-Specific Guidelines

### Media Sharing Experiences

#### Video Content
- **Playback Controls**: Sync with host permissions
- **Quality Indicators**: Adaptive streaming status
- **Progress Synchronization**: Real-time playback position
- **Audio Balance**: Individual volume controls

#### Music Listening
- **Album Art Display**: Consistent across participants
- **Queue Management**: Shared playlist functionality
- **Lyric Display**: Synchronized with playback
- **Reactions**: Real-time response mechanisms

### Collaborative Activities

#### Drawing and Creativity
- **Canvas Sharing**: Real-time synchronization
- **Tool Selection**: Shared tool state
- **Undo/Redo**: Coordinated history management
- **Layer Management**: Collaborative layer systems

#### Gaming Experiences
- **Game State**: Sync validation and conflict resolution
- **Turn Indicators**: Clear player sequencing
- **Score Tracking**: Real-time score updates
- **Spectator Mode**: Non-participant viewing options

---

## 🔐 Privacy and Trust Indicators

### Data Transparency
- Clear indicators of what data is being shared
- Participant access level visibility
- Recording status indicators (when applicable)
- Data retention policies in accessible format

### Permission Management
- Granular permission requests with clear context
- Easy revocation of granted permissions
- Host control over participant capabilities
- Anonymous participation options when appropriate

### Safety Considerations
- Participant reporting mechanisms
- Content moderation tools for hosts
- Automatic content filtering indicators
- Emergency exit options from uncomfortable situations

---

## 🎨 Visual Design Guidelines

### Brand Integration
- Maintain activity brand identity while following SharePlay patterns
- Use system colors for SharePlay-specific UI elements
- Consistent iconography across the experience
- Adaptive appearance support (light/dark mode)

### Animation and Transitions
- Smooth participant state transitions
- Activity state change animations
- Notification entry/exit animations
- Loading states with progress indication

### Typography
- System font family hierarchy
- Readability considerations for shared content
- Dynamic type support across all text
- Localization-aware text layout

---

## 🔧 Technical Design Integration

### Performance Considerations
- Efficient participant list updates
- Optimized media streaming indicators
- Battery usage awareness
- Network bandwidth optimization

### Responsive Design
- Adaptive layout for different screen sizes
- Orientation change handling
- Multi-window support on applicable platforms
- Accessibility scaling support

### Error States
- Graceful handling of network interruptions
- Clear messaging for participant disconnection
- Recovery options with user guidance
- Fallback interfaces for degraded experiences

---

## 📚 Implementation Best Practices

### SwiftUI Integration
```swift
// Recommended SharePlay UI patterns
@MainActor
struct SharePlayActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sharePlayManager = SharePlayManager()

    var body: some View {
        VStack(spacing: 16) {
            // Activity content
            activityContent

            // Participant bar
            ParticipantBar(participants: sharePlayManager.activeParticipants)
                .transition(.move(edge: .bottom))

            // Session controls
            SessionControls(manager: sharePlayManager)
        }
        .alert("Session Ended", isPresented: $sharePlayManager.sessionEnded) {
            Button("OK") { dismiss() }
        } message: {
            Text(sharePlayManager.endMessage)
        }
    }
}
```

### Testing and Validation
- Multi-device testing scenarios
- Network condition simulation
- Accessibility audit across all interfaces
- Performance testing with maximum participant counts

---

## ✅ Design Validation Checklist

### Core Requirements
- [ ] Activity purpose is immediately clear
- [ ] Participant states are visually distinct
- [ ] Network conditions are appropriately indicated
- [ ] Privacy information is accessible and clear
- [ ] Accessibility features are fully implemented

### Platform Consistency
- [ ] Follows platform-specific navigation patterns
- [ ] Uses standard system colors and typography
- [ ] Implements platform-appropriate touch/target sizes
- [ ] Respects platform conventions for alerts and dialogs

### User Experience
- [ ] Onboarding experience guides new users
- [ ] Error recovery is intuitive and non-disruptive
- [ ] Performance degrades gracefully under poor conditions
- [ ] Session lifecycle is clear and predictable

---

**Last Updated**: November 2025
**Sources**: Apple Human Interface Guidelines, GroupActivities Framework Documentation, Platform-specific Design Resources