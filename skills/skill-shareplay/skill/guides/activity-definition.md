# Defining Your App's SharePlay Activities: Complete Implementation Guide

**Source**: https://developer.apple.com/documentation/groupactivities/defining-your-apps-shareplay-activities

**Description**: Configure your app's SharePlay support and define the activities that people can perform from your app.

---

## Overview

To enable SharePlay in your app, you need to:

1. **Configure SharePlay entitlements** in Xcode
2. **Define activities** by conforming to `GroupActivity`
3. **Provide metadata** for system presentation
4. **Implement transferable representation** for ShareLink integration
5. **Customize activity identifiers** for system recognition

---

## 1. Configure the SharePlay Entitlements

### Required Steps:

1. **Add GroupActivities Capability** in Xcode:
   - Open your project settings
   - Select your target
   - Go to "Signing & Capabilities"
   - Click "+" and add "GroupActivities"

2. **Required Entitlements**:
   - `com.apple.developer.groupactivities`
   - `com.apple.developer.group-session`

3. **Info.plist Configuration** (if needed):
   - Add `NSGroupActivitiesUsageDescription` for user permission

---

## 2. Turn an Existing App Feature into an Activity

### Basic Activity Definition:

```swift
// First, define your data model
struct Movie: Codable {
    var title: String
    var movieURL: URL

    // Codable support for synchronization
    enum CodingKeys: String, CodingKey {
        case title, movieURL
    }
}

// Then define the SharePlay activity
struct WatchTogether: GroupActivity {
    // The movie to watch together
    var movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }
}
```

### Key Requirements:
- Activity must conform to `GroupActivity`
- All properties must be `Codable` for synchronization
- Implement proper initializer for activity creation

---

## 3. Customize the Unique Identifier for Your Activity

### Custom Activity Identifier:

```swift
struct WatchTogether: GroupActivity {
    // Specify the activity type to the system
    static let activityIdentifier = "com.example.myapp.watch-movie-together"

    // The movie to watch together
    var movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }
}
```

**Best Practices:**
- Use reverse domain notation: `com.company.app.activity-name`
- Make identifiers unique across your app
- Keep them descriptive and memorable

---

## 4. Provide Descriptive Information About the Activity

### Activity Metadata Implementation:

```swift
extension WatchTogether {
    // Provide information about the activity
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .watchTogether
        metadata.title = "\(movie.title)"
        metadata.fallbackURL = movie.movieURL
        metadata.supportsContinuationOnTV = true

        return metadata
    }
}
```

### Available Metadata Properties:

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `type` | `GroupActivity.ActivityType` | System-defined activity type | ✅ |
| `title` | `String` | Display name for the activity | ✅ |
| `fallbackURL` | `URL` | URL for participants without app | ✅ |
| `supportsContinuationOnTV` | `Bool` | Enable Apple TV continuation | ❌ |
| `subtitle` | `String` | Additional descriptive text | ❌ |

### Activity Types:
- `.generic` - Default for custom activities
- `.watchTogether` - Media viewing experiences
- `.playTogether` - Gaming activities
- `.workoutTogether` - Fitness activities
- `.browseTogether` - Web/content browsing

---

## 5. Include a Transferable Representation of Your Activity

### Transferable Data Model:

```swift
struct Movie: Transferable, Codable {
    var title: String
    var movieURL: URL

    // A transferable version of the movie URL and group activity
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.movieURL)

        GroupActivityTransferRepresentation { movie in
            WatchTogether(movie: movie)
        }
    }

    // Codable support...
    enum CodingKeys: String, CodingKey {
        case title, movieURL
    }
}
```

### ShareLink Integration:

```swift
struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        ShareLink(
            item: movie,
            preview: SharePreview(
                movie.title))
    }
}
```

### Transfer Representation Components:

1. **ProxyRepresentation**: Handles basic URL sharing
2. **GroupActivityTransferRepresentation**: Creates SharePlay activity from shared data

---

## 6. Complete Activity Implementation Example

### Full Implementation:

```swift
// MARK: - Data Model
struct SharedContent: Transferable, Codable {
    let id: UUID
    let title: String
    let contentURL: URL
    let contentType: ContentType

    enum ContentType: String, Codable, CaseIterable {
        case movie = "movie"
        case music = "music"
        case document = "document"
        case game = "game"
    }

    // Transfer representation for ShareLink
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.contentURL)

        GroupActivityTransferRepresentation { content in
            ShareExperience(content: content)
        }
    }
}

// MARK: - SharePlay Activity
struct ShareExperience: GroupActivity {
    static let activityIdentifier = "com.myapp.shared-experience"

    var content: SharedContent

    init(content: SharedContent) {
        self.content = content
    }
}

// MARK: - Activity Metadata
extension ShareExperience {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()

        // Set activity type based on content
        switch content.contentType {
        case .movie:
            metadata.type = .watchTogether
        case .game:
            metadata.type = .playTogether
        default:
            metadata.type = .generic
        }

        metadata.title = content.title
        metadata.fallbackURL = content.contentURL
        metadata.supportsContinuationOnTV = (content.contentType == .movie)

        return metadata
    }
}

// MARK: - ShareLink Integration
struct ContentView: View {
    let sharedContent: SharedContent

    var body: some View {
        VStack {
            Text(sharedContent.title)
                .font(.title)

            ShareLink(
                item: sharedContent,
                preview: SharePreview(
                    "Share \(sharedContent.title)",
                    image: Image(systemName: "person.3.fill")
                )
            )
            .buttonStyle(.borderedProminent)
        }
    }
}
```

---

## 7. Activity Activation and Session Management

### Activity Activation Pattern:

```swift
class SharePlayManager: ObservableObject {
    @Published var currentSession: GroupSession<ShareExperience>?
    @Published var isActive = false

    func startActivity(with content: SharedContent) async {
        let activity = ShareExperience(content: content)

        do {
            // This presents the SharePlay UI to the user
            try await activity.activate()

            // Handle successful session start
            print("SharePlay session started successfully")
        } catch {
            print("Failed to start SharePlay session: \(error)")
        }
    }

    func configureSession(_ session: GroupSession<ShareExperience>) {
        self.currentSession = session
        self.isActive = true

        // Set up messaging and coordination
        Task {
            await setupSessionMessenger(session)
        }

        session.join()
    }
}
```

---

## 8. Best Practices and Guidelines

### Activity Design Principles:

1. **Keep Activities Focused**: Each activity should represent a single, clear experience
2. **Use Descriptive Metadata**: Help users understand what they're joining
3. **Handle Edge Cases**: Account for participants without your app
4. **Provide Fallbacks**: Always include fallback URLs
5. **Test Thoroughly**: Verify behavior across different scenarios

### Performance Considerations:

1. **Minimize Data Size**: Keep activity payloads small for faster synchronization
2. **Lazy Load Content**: Load large resources after session starts
3. **Efficient Sync Strategy**: Use appropriate message types and batching

### User Experience Guidelines:

1. **Clear Activity Purpose**: Users should immediately understand what they're joining
2. **Seamless Transition**: Make joining an activity smooth and intuitive
3. **Appropriate Permissions**: Request necessary permissions at the right time

---

## 9. Integration with Existing Knowledge Base

This guide complements our existing SharePlay documentation:

### Related Documents:
- **[SharePlay Data Synchronization](./SharePlay-Data-Synchronization-Complete-Guide.md)** - For real-time data exchange
- **[Spatial Persona Support](./references/Apple-SpatialPersona-Official.md)** - For visionOS experiences
- **[Nearby Sharing Integration](./Nearby-Sharing-Integration-Enhanced.md)** - For proximity-based sharing
- **[GroupActivityAssociation Enhanced](./GroupActivityAssociation-Enhanced-Integration.md)** - Modern scene association

### Implementation Sequence:
1. **Activity Definition** (This guide) → Define your activities
2. **Session Management** → Handle lifecycle and coordination
3. **Data Synchronization** → Exchange data between participants
4. **Scene Association** → Coordinate UI updates
5. **Spatial Features** → Add visionOS spatial experiences

---

## 10. Testing and Validation

### Testing Checklist:

- [ ] Activity metadata displays correctly
- [ ] ShareLink integration works properly
- [ ] Activity identifier is unique
- [ ] Fallback URLs work for non-app users
- [ ] Session lifecycle functions correctly
- [ ] Data synchronization works across participants
- [ ] Error conditions are handled gracefully

### Debugging Tips:

1. **Use Activity Logging**: Monitor session state changes
2. **Test Edge Cases**: Network failures, app crashes, participant drops
3. **Verify Entitlements**: Ensure all required capabilities are configured
4. **Check Metadata**: Validate that activity information displays correctly

---

This comprehensive guide provides all the necessary information to properly define SharePlay activities in your app, from basic implementation to advanced features and best practices.

---

**Related Documentation:**
- [Apple SharePlay Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/shareplay/)
- [GroupActivities Framework Reference](https://developer.apple.com/documentation/GroupActivities)
- [Transferable Protocol Documentation](https://developer.apple.com/documentation/Swift/Transferable)