# visionOS Windows and Spaces: Complete Implementation Guide

**Source**: https://developer.apple.com/documentation/visionos/presenting-windows-and-spaces

**Description**: Complete guide to opening and closing the scenes that make up your app's interface in visionOS.

---

## 🎯 Overview

visionOS apps use **scenes** to create and manage their user interface, consisting of:
- **Windows** - Traditional 2D app interfaces
- **Spaces** - Immersive 3D environments (Full Space, Mixed Space)

This guide covers the complete patterns for managing multiple scenes simultaneously, a critical requirement for SharePlay-enabled apps.

---

## 🏗️ **Foundation: Multiple Scene Architecture**

### **Basic App Structure**

```swift
@main
struct MailReader: App {
    var body: some Scene {
        WindowGroup(id: "mail-viewer") {
            MailViewer()
        }

        Window("Connection Status", id: "connection") {
            ConnectionStatus()
        }
    }
}
```

**Key Requirements:**
- ✅ **Unique Scene IDs** - Essential for programmatic control
- ✅ **Multiple Scene Support** - Required for SharePlay coordination
- ✅ **Proper Info.plist Configuration** - Enable multiple scenes

---

## 🔧 **Enable Multiple Simultaneous Scenes**

### **Info.plist Configuration**

**Required Keys:**
```xml
<key>UIApplicationSupportsMultipleScenes</key>
<true/>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

**Critical for SharePlay Apps:**
- ✅ **Required for immersive spaces** - Cannot have windows + immersive without this
- ✅ **Enables simultaneous scenes** - Foundation for SharePlay scene coordination
- ✅ **System integration** - Required for proper SharePlay behavior

### **Runtime Support Check**

```swift
struct NewWindowButton: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open New Window") {
            openWindow(id: "mail-viewer")
        }
        .opacity(supportsMultipleWindows ? 1 : 0)
    }
}
```

**Pattern Benefits:**
- ✅ **Graceful fallback** - Handle devices that don't support multiple windows
- ✅ **Conditional UI** - Show/hide features based on capability
- ✅ **User-friendly** - Clear indication of available functionality

---

## 🪟 **Window Management Patterns**

### **Open Windows Programmatically**

```swift
struct NewViewerButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("New Mail Viewer") {
            openWindow(id: "mail-viewer")
        }
    }
}
```

### **Open Multiple Window Types**

```swift
struct ConnectionStatusButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Connection Status") {
            openWindow(id: "connection")
        }
    }
}
```

### **Close Windows Programmatically**

```swift
private struct ContentView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Button("Done") {
            dismissWindow(id: "connection")
        }
    }
}
```

---

## 🌌 **Immersive Space Management**

### **Open Spaces Programmatically**

```swift
struct NewSpaceButton: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button("View Orbits") {
            Task {
                await openImmersiveSpace(id: "orbits")
            }
        }
    }
}
```

### **Close Spaces Programmatically**

```swift
private struct ContentView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        Button("Done") {
            Task {
                await dismissImmersiveSpace()
            }
        }
    }
}
```

---

## 🔄 **Advanced Scene Transitions**

### **Window to Space Transitions**

```swift
Button("Start") {
    Task {
        await openImmersiveSpace(id: "chessboard")
        dismissWindow(id: "start") // Runs after the space opens.
    }
}
```

**Critical Pattern for SharePlay:**
- ✅ **Sequential operations** - Space opens before window closes
- ✅ **Smooth transitions** - No visual gaps between scenes
- ✅ **State preservation** - Maintains app continuity

### **Space to Window Transitions**

```swift
Button("Exit Immersive") {
    Task {
        dismissWindow(id: "start")
        await dismissImmersiveSpace()
        openWindow(id: "results")
    }
}
```

---

## 🎮 **SharePlay Scene Coordination Patterns**

### **Multi-Scene SharePlay Architecture**

```swift
@main
struct SharePlayApp: App {
    var body: some Scene {
        // Primary SharePlay window
        WindowGroup(id: "main-game") {
            GameView()
                .handlesExternalEvents(
                    preferring: [GameActivity.activityIdentifier],
                    allowing: [GameActivity.activityIdentifier]
                )
        }

        // Secondary SharePlay window (optional)
        WindowGroup(id: "game-tools") {
            ToolsView()
                .handlesExternalEvents(
                    preferring: [],
                    allowing: [GameActivity.activityIdentifier]
                )
        }

        // Immersive space for SharePlay
        ImmersiveSpace(id: "immersive-game") {
            ImmersiveGameView()
                .handlesExternalEvents(
                    preferring: [],
                    allowing: [GameActivity.activityIdentifier]
                )
        }
    }
}
```

### **SharePlay Scene Management**

```swift
class SharePlaySceneManager: ObservableObject {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    func enterSharePlayImmersiveMode() async {
        // Open immersive space first
        await openImmersiveSpace(id: "immersive-game")

        // Transition windows
        dismissWindow(id: "main-menu")
        openWindow(id: "shareplay-tools")
    }

    func exitSharePlayImmersiveMode() async {
        // Close immersive space
        await dismissImmersiveSpace()

        // Return to normal interface
        dismissWindow(id: "shareplay-tools")
        openWindow(id: "main-menu")
    }
}
```

---

## 🏛️ **Designate Main Interface Patterns**

### **Primary Scene Declaration**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup(id: "primary") {
            MainView()
        }
        .defaultLaunchBehavior(.presented)
        .restorationBehavior(.automatic)

        ImmersiveSpace(id: "immersive") {
            ImmersiveView()
        }
        .defaultLaunchBehavior(.suppressed)
    }
}
```

**Key Settings:**
- ✅ **defaultLaunchBehavior** - Controls initial scene presentation
- ✅ **restorationBehavior** - Handles state restoration
- ✅ **Primary scene identification** - System knows which scene is main

---

## 📱 **Platform-Specific Considerations**

### **visionOS-Specific Features**

```swift
#if os(visionOS)
WindowGroup(id: "volumetric-content") {
    VolumetricView()
}
.windowStyle(.volumetric)
.defaultSize(Size3D(width: 0.5, height: 0.3, depth: 0.2))

ImmersiveSpace(id: "mixed-reality") {
    MixedRealityView()
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)
.immersiveEnvironmentBehavior(.coexist)
#endif
```

### **Cross-Platform Compatibility**

```swift
@main
struct CrossPlatformApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            #if os(visionOS)
            VisionOSMainView()
            #else
            IOSMainView()
            #endif
        }

        #if os(visionOS)
        ImmersiveSpace(id: "immersive") {
            ImmersiveView()
        }
        #endif
    }
}
```

---

## 🚀 **Best Practices and Guidelines**

### **Scene ID Management**

```swift
enum SceneIDs {
    static let mainWindow = "main-window"
    static let settings = "settings-window"
    static let tools = "tools-window"
    static let immersive = "immersive-space"
    static let shareplayTools = "shareplay-tools"
}
```

### **State Coordination**

```swift
@MainActor
class SceneManager: ObservableObject {
    @Published var currentWindows: Set<String> = []
    @Published var immersiveSpaceOpen = false

    func trackWindowOpen(_ id: String) {
        currentWindows.insert(id)
    }

    func trackWindowClose(_ id: String) {
        currentWindows.remove(id)
    }

    func trackImmersiveSpaceOpen() {
        immersiveSpaceOpen = true
    }

    func trackImmersiveSpaceClose() {
        immersiveSpaceOpen = false
    }
}
```

### **Error Handling**

```swift
struct RobustWindowManager: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open Window") {
            do {
                openWindow(id: "window-id")
            } catch {
                // Handle window opening failures
                print("Failed to open window: \(error)")
            }
        }
    }
}
```

---

## 🔧 **Integration with SharePlay Knowledge Base**

This guide enhances our existing SharePlay documentation:

### **Related Documents:**
- **[Green Spurt ShareLink Patterns](./GreenSpurt-ShareLink-Implementation-Patterns.md)** - Hidden ShareLink integration
- **[GroupActivityAssociation Enhanced](./GroupActivityAssociation-Enhanced-Integration.md)** - Scene association patterns
- **[Spatial Persona Support](./references/Apple-SpatialPersona-Official.md)** - Immersive space coordination
- **[Nearby Sharing Integration](./Nearby-Sharing-Integration-Enhanced.md)** - Mixed reality coordination

### **SharePlay Scene Architecture:**

1. **Multiple Scene Foundation** (This guide) → Enable simultaneous scenes
2. **Scene Association** → Connect SharePlay to correct scenes
3. **Spatial Coordination** → Handle immersive spaces with personas
4. **Window Management** → Coordinate window transitions during SharePlay
5. **State Synchronization** → Keep all scenes in sync

---

## 🏆 **Critical Requirements for SharePlay Apps**

### **Must-Have Configuration:**

- [x] **UIApplicationSupportsMultipleScenes = true**
- [x] **Unique scene IDs** for all scenes
- [x] **Proper Info.plist configuration**
- [x] **Scene association** with SharePlay activities
- [x] **Multi-scene management** for SharePlay coordination

### **Implementation Checklist:**

- [ ] Configure Info.plist for multiple scenes
- [ ] Implement unique scene IDs
- [ ] Add runtime capability checks
- [ ] Create scene management system
- [ ] Handle window/space transitions smoothly
- [ ] Integrate with SharePlay scene association
- [ ] Test cross-platform compatibility

---

## 📚 **Complete Reference Implementation**

```swift
@main
struct ProductionSharePlayApp: App {
    @StateObject private var sceneManager = SceneManager()

    var body: some Scene {
        // Main application window
        WindowGroup(id: SceneIDs.mainWindow) {
            MainView()
                .environmentObject(sceneManager)
                .onAppear { sceneManager.trackWindowOpen(SceneIDs.mainWindow) }
                .onDisappear { sceneManager.trackWindowClose(SceneIDs.mainWindow) }
                .groupActivityAssociation(.primary("main-activity"))
        }
        .defaultLaunchBehavior(.presented)
        .restorationBehavior(.automatic)

        // SharePlay tools window
        WindowGroup(id: SceneIDs.shareplayTools) {
            SharePlayToolsView()
                .environmentObject(sceneManager)
                .groupActivityAssociation(.secondary("tools-activity"))
        }
        .defaultLaunchBehavior(.suppressed)

        // Immersive space for spatial experiences
        ImmersiveSpace(id: SceneIDs.immersive) {
            ImmersiveGameView()
                .environmentObject(sceneManager)
                .groupActivityAssociation(.primary("immersive-activity"))
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        .defaultLaunchBehavior(.suppressed)
    }
}
```

---

**This complete guide provides the foundational knowledge required for all visionOS apps, especially those implementing SharePlay functionality with complex multi-scene architectures.**

**Key Insight**: Multiple scene support is **mandatory** for SharePlay apps that use immersive spaces, requiring proper Info.plist configuration and scene management patterns.