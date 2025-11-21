# Green Spurt ShareLink Implementation Patterns: Production Analysis

**Source**: Green Spurt (Reality2713) - Production visionOS SharePlay Implementation

**Analysis Date**: November 2025

---

## 🎯 Key Findings: Green Spurt's ShareLink Strategy

### **Critical Discovery: Hidden ShareLink Pattern**

Green Spurt uses a **hidden ShareLink** approach that enables the bottom share menu behavior without cluttering the UI:

```swift
// GreenSpurtApp.swift:69-72
ShareLink(
  item: EscapeTogether(startingTime: .now),
  preview: SharePreview("EscapeTogether")
).hidden()
```

**This is BRILLIANT** - The ShareLink is present in the view hierarchy but hidden, allowing:
- ✅ **Bottom share menu integration** - Users can share from system share menu
- ✅ **No UI clutter** - ShareLink doesn't interfere with app design
- ✅ **Always available** - Share functionality is always accessible via system UI

---

## 🏗️ Complete Implementation Architecture

### **1. Activity Definition (EscapeTogether.swift)**

```swift
public struct EscapeTogether: GroupActivity, Equatable, Transferable, Sendable {
  public static let activityIdentifier = "io.reality2713.GreenSpurt.escape-together"
  public let startingTime: Date

  public init(startingTime: Date) {
    self.startingTime = startingTime
  }

  public var metadata: GroupActivityMetadata {
    var metadata = GroupActivityMetadata()
    metadata.title = "The Green Spurt"
    metadata.type = .generic
    metadata.fallbackURL = URL(string: "https://reality2713.com/thegreenspurt")
    return metadata
  }
}
```

**Key Production Patterns:**
- ✅ **Reverse domain identifier** for uniqueness
- ✅ **Simple data model** - only `startingTime` for synchronization
- ✅ **Fallback URL** for participants without the app
- ✅ **Generic activity type** for custom experiences

### **2. Hidden ShareLink Integration (GreenSpurtApp.swift)**

```swift
WindowGroup(id: String.WindowID.hexatable) {
  ZStack {
    ShareLink(
      item: EscapeTogether(startingTime: .now),
      preview: SharePreview("EscapeTogether")
    ).hidden()

    GameView(store: Self.store)
      // ... rest of UI
  }
  .handlesExternalEvents(
    preferring: [EscapeTogether.activityIdentifier],
    allowing: [EscapeTogether.activityIdentifier]
  )
}
```

**Architecture Benefits:**
- ✅ **Always present** - ShareLink exists throughout app lifecycle
- ✅ **Hidden from view** - No visual impact on design
- ✅ **System integration** - Works with iOS/visionOS share sheets
- ✅ **Scene association** - Properly configured for SharePlay coordination

### **3. Smart Availability Checking (MainMenuView.swift)**

```swift
Button {
  let activity = groupStateObserver.isEligibleForGroupSession
    ? EscapeTogether(startingTime: .now)
    : nil
  store.send(.showMultiplayerMenu(activity: activity))
} label: {
  // Multiplayer button UI
}
```

**User Experience Pattern:**
- ✅ **Conditional creation** - Only create activity if SharePlay is available
- ✅ **Graceful fallback** - Handles ineligible states elegantly
- ✅ **Clear messaging** - Shows different status messages based on availability

### **4. Session Activation (AppFeature.swift)**

```swift
case .mainMenu(.delegate(.multiplayerPickerDisplayed(let activity))):
  guard state.sessionState == nil else { return .none }
  guard let activity else { return .none }
  return .run(priority: .userInitiated) { _ in
    await groupActivityClient.donate(activity)
    try await groupActivityClient.activate(activity)
  }
```

**Production Best Practices:**
- ✅ **Session guard** - Prevents multiple simultaneous sessions
- ✅ **High priority** - Uses `.userInitiated` for responsive UI
- ✅ **Donate + Activate** - Proper system integration
- ✅ **Error handling** - Implicitly handles activation failures

---

## 🔄 Complete User Journey

### **Share Menu Access Flow:**

1. **User opens app** → Hidden ShareLink is available in view hierarchy
2. **User accesses share menu** → System finds ShareLink in view
3. **Share menu shows SharePlay option** → "The Green Spurt" appears with system SharePlay UI
4. **User selects SharePlay** → Activity activates and session starts
5. **Participants join** → System coordinates scene association

### **Direct App Access Flow:**

1. **User clicks Multiplayer button** → App checks `isEligibleForGroupSession`
2. **Shows availability status** → Clear messaging about SharePlay readiness
3. **Creates activity if eligible** → `EscapeTogether(startingTime: .now)`
4. **Activates directly** → Bypasses share menu, goes straight to FaceTime sheet

---

## 🎯 Key Implementation Insights

### **1. Hidden ShareLink Pattern (Revolutionary)**

```swift
// This is the KEY insight - hide the ShareLink but keep it functional
ShareLink(
  item: YourActivity(data: yourData),
  preview: SharePreview("Your Activity")
).hidden()
```

**Why This Works:**
- SwiftUI still processes the ShareLink for system integration
- Share sheet discovers the available ShareLink
- No visual impact on your app's UI
- Bottom share menu gets SharePlay options automatically

### **2. Activity Data Simplicity**

```swift
// Keep it minimal - only what's needed for synchronization
public struct EscapeTogether: GroupActivity {
  public let startingTime: Date  // Only essential data
  // No complex state - that's handled via messaging
}
```

**Benefits:**
- Faster activity creation and sharing
- Reliable synchronization via separate messaging system
- Clear separation between activity metadata and runtime state

### **3. State Management Integration**

```swift
// Green Spurt uses TCA for state management
extension SharedReaderKey where Self == InMemoryKey<GroupSession<EscapeTogether>?> {
  public static var session: Self {
    inMemory("session")
  }
}
```

**Pattern:**
- Centralized session state management
- Reactive UI updates based on session state
- Clean separation of concerns

---

## 🚀 Implementation Checklist

### **Required Components:**

- [ ] **Activity Definition** with `GroupActivity`, `Transferable`, `Sendable`
- [ ] **Unique Activity Identifier** using reverse domain notation
- [ ] **Metadata Configuration** with title, type, and fallback URL
- [ ] **Hidden ShareLink** in main view hierarchy
- [ ] **Scene Association** using `handlesExternalEvents`
- [ ] **Availability Checking** with `GroupStateObserver`
- [ ] **Session Management** with proper state tracking

### **ShareLink Integration:**

```swift
// 1. Define your activity
struct MyActivity: GroupActivity, Transferable {
    static let activityIdentifier = "com.myapp.myactivity"
    let data: SharedData

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "My Activity"
        metadata.type = .generic
        metadata.fallbackURL = URL(string: "https://myapp.com")
        return metadata
    }
}

// 2. Add hidden ShareLink to main view
var body: some Scene {
    WindowGroup {
        ZStack {
            ShareLink(
                item: MyActivity(data: sharedData),
                preview: SharePreview("My Activity")
            ).hidden()

            YourMainView()
        }
        .handlesExternalEvents(
            preferring: [MyActivity.activityIdentifier],
            allowing: [MyActivity.activityIdentifier]
        )
    }
}
```

### **Activation Pattern:**

```swift
// Direct activation (from button)
Button("Start SharePlay") {
    Task {
        if groupStateObserver.isEligibleForGroupSession {
            let activity = MyActivity(data: currentData)
            await groupActivityClient.donate(activity)
            try await groupActivityClient.activate(activity)
        }
    }
}
```

---

## 🔍 Advanced Insights

### **1. System Integration Benefits**

The hidden ShareLink pattern provides:
- **Native share menu integration** - Users expect this in modern apps
- **No custom UI required** - Leverages system SharePlay UI
- **Consistent behavior** - Same across all Apple platforms
- **Accessibility** - Inherits system accessibility features

### **2. Performance Considerations**

- **Minimal overhead** - Hidden ShareLink has negligible performance impact
- **Fast discovery** - System quickly finds ShareLink in view hierarchy
- **Reliable activation** - No custom UI logic to debug

### **3. User Experience**

- **Familiar interaction** - Users know how to use system share menu
- **Always available** - Share functionality isn't hidden behind specific screens
- **Professional polish** - Matches system behavior patterns

---

## 🏆 Production-Proven Benefits

### **Why Green Spurt's Approach is Superior:**

1. **Zero UI Compromise** - ShareLink doesn't affect your design
2. **System Integration** - Works perfectly with iOS/visionOS share sheets
3. **Simple Implementation** - Minimal code for maximum functionality
4. **Robust Behavior** - No custom UI bugs or edge cases
5. **Future-Proof** - Adapts to system SharePlay improvements automatically

### **This Pattern Solves:**
- ❌ **Share menu integration complexity**
- ❌ **Custom SharePlay UI development**
- ❌ **Activity discovery issues**
- ❌ **Scene association coordination**
- ❌ **User experience inconsistencies**

---

## 📚 Integration with Knowledge Base

This analysis enhances our existing documentation:

- **[Defining SharePlay Activities](./Defining-SharePlay-Activities-Complete-Guide.md)** - Activity definition patterns
- **[SharePlay Data Synchronization](./SharePlay-Data-Synchronization-Complete-Guide.md)** - Runtime state management
- **[GroupActivityAssociation Enhanced](./GroupActivityAssociation-Enhanced-Integration.md)** - Modern scene association

**The hidden ShareLink pattern is the missing piece for perfect system integration!**

---

**🎯 Bottom Line**: Green Spurt's hidden ShareLink implementation is the **production-proven best practice** for SharePlay integration that provides perfect system menu behavior without any UI compromises. This pattern should be adopted as the standard approach for all visionOS SharePlay implementations.