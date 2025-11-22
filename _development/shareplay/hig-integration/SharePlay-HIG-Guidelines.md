# SharePlay Human Interface Guidelines Integration

*Complete integration of Apple's SharePlay HIG into our skill knowledge base*

---

## 🎯 **SharePlay HIG Overview**

**Core Principle**: SharePlay helps multiple people share activities — like viewing a movie, listening to music, playing a game, or sketching ideas on a whiteboard — while they're in a FaceTime call or Messages conversation.

**Key Innovation**: The system synchronizes app playback on all participating devices to support seamless media and content sharing that lets everyone enjoy the experience simultaneously.

---

## 🏆 **Critical HIG Principles**

### **1. Discovery & Communication**

#### **✅ Let people know that you support SharePlay**
**HIG Principle**: People often expect media playback experiences to be shareable, so indicate this capability in your interface.
**Implementation**: Use the `shareplay` SF Symbol to identify shareable content or experiences.
**Technical Integration**: Add `.shareplay` SF Symbol to UI elements for shareable activities.

#### **✅ Use the term *SharePlay* correctly**
**HIG Principle**: Use *SharePlay* as a noun and as a verb for direct actions in your interface.
**DO**: "Join SharePlay", "SharePlay Movie"
**DON'T**: Add adjectives, create variations like "SharePlayed", "SharePlays"
**Technical Integration**: Ensure all UI text follows Apple's terminology guidelines.

### **2. Activity Design**

#### **✅ Briefly describe each activity**
**HIG Principle**: When people receive an invitation, your description helps them understand the experience.
**Implementation**: Write simple, meaningful descriptions short enough to avoid truncation.
**Technical Integration**: Use `GroupActivityMetadata.title` and `GroupActivityMetadata.subtitle` effectively.

#### **✅ Make it easy to start sharing an activity**
**HIG Principle**: If there's no session available, present UI that lets people start a group activity.
**Implementation**: Show system share sheet when starting shareable activities.
**Technical Integration**: Handle the case where no existing session exists and create new ones.

#### **✅ Help people prepare to join a session**
**HIG Principle**: Display views that help people perform required tasks before showing the activity UI.
**Implementation**: Handle login, downloads, or payments before activity starts.
**Technical Integration**: Pre-session validation and preparation flows.

### **3. visionOS Specific Guidelines**

#### **✅ People expect most visionOS apps to support SharePlay**
**Platform Expectation**: Spatial Personas, shared context, and natural interactions.
**Implementation**: Design for spatial collaboration with Personas.

#### **✅ Choose the spatial Persona template that suits your shared activity**
**Three Templates Available**:
1. **Side-by-side**: Participants next to each other, facing content (good for media viewing)
2. **Surround**: Participants around content in center (good for 3D content, promotes interaction)
3. **Conversational**: Participants around circle, content along circle (good for background activities)

**Technical Integration**: Use `SpatialTemplatePreference` and `SystemCoordinator` APIs.

#### **✅ Be prepared to launch directly into your shared activity**
**HIG Principle**: When sharing on FaceTime, the system automatically launches your app for everyone.
**Implementation**: Avoid displaying unrelated windows, use autodismissible windows for required tasks.
**Technical Integration**: Immediate activity launch without unnecessary UI.

#### **✅ Help people enter a shared activity together, but don't force them**
**HIG Principle**: Check if changing immersion would disrupt current tasks, offer choice.
**Implementation**: Present alerts for immersion changes, respect user choice.
**Technical Integration**: Handle immersion level synchronization with user consent.

#### **✅ Smoothly update a shared activity when new participants join**
**HIG Principle**: Integrate new participants without disrupting experience for others.
**Implementation**: Update immersive content to keep all participants synchronized.
**Technical Integration**: Dynamic participant management and content synchronization.

### **4. Shared Context Management**

#### **✅ Make sure everyone views the same state of your app**
**HIG Principle**: Avoid letting different participants view different states, which diminishes shared feeling.
**Implementation**: Synchronize app states across all participants.
**Technical Integration**: Consistent state management and synchronization.

#### **✅ Use Spatial Audio to enrich your shared activity**
**HIG Principle**: Spatial Audio strengthens realism of shared experience.
**Implementation**: Implement spatial audio for collaborative experiences.
**Technical Integration**: Use `AVAudioEngine` and spatial audio APIs.

#### **✅ Let people discover natural, social solutions**
**HIG Principle**: Avoid displaying UI for conflicts, let people use social solutions.
**Implementation**: Simple rules like "last change wins", natural interaction patterns.
**Technical Integration**: Minimal conflict resolution UI, focus on social dynamics.

#### **✅ Help people keep their private and shared content separate**
**HIG Principle**: System differentiates shared windows from private ones.
**Implementation**: Clear visual distinction between shared and private content.
**Technical Integration**: Proper window management and content separation.

### **5. Personalization & Accessibility**

#### **✅ Let people personalize their experience without changing it for others**
**HIG Principle**: People might need to adjust settings for comfort or accessibility.
**Implementation**: Personal settings like volume, subtitles per participant.
**Technical Integration**: Per-user preference management.

#### **✅ Consider when to give each participant a unique view**
**HIG Principle**: Some content needs specific viewing angles or personal perspectives.
**Implementation**: Allow per-person views when content requires it.
**Technical Integration**: Coordinate system management and perspective handling.

#### **✅ Make it easy for people to exit and rejoin**
**HIG Principle**: People need to perform unrelated tasks or engage with surroundings.
**Implementation**: Quick rejoin controls, continue displaying shared content.
**Technical Integration**: Session pause/resume, participant state management.

---

## 🔧 **Technical Implementation Mapping**

### **SharePlay Indicator Integration**
```swift
// HIG: Use shareplay SF Symbol for shareable content
Image(systemName: "shareplay")
    .foregroundColor(.blue)
```

### **Activity Description Best Practices**
```swift
// HIG: Brief, meaningful descriptions
var metadata: GroupActivityMetadata {
    var metadata = GroupActivityMetadata()
    metadata.title = "Watch Movie Together"
    metadata.subtitle = "Join friends for synchronized viewing"
    return metadata
}
```

### **Spatial Persona Templates**
```swift
// HIG: Choose appropriate template for activity
enum SharePlayTemplate {
    case sideBySide      // Media viewing
    case surround        // 3D content, interaction
    case conversational  // Background activities
}

// Technical implementation using SpatialTemplatePreference
```

### **Immediate Launch Requirements**
```swift
// HIG: Launch directly into shared activity
class SharePlayViewController: UIViewController {
    func handleSharePlayLaunch() {
        // Skip unnecessary UI, go directly to activity
        presentSharedActivity()
    }
}
```

---

## 📊 **Design Validation Checklist**

### **Discovery & Communication**
- [ ] **SharePlay Support Indicated**: `shareplay` SF Symbol used for shareable content
- [ ] **Correct Terminology**: "SharePlay" used as noun/verb, no variations
- [ ] **Clear Activity Descriptions**: Short, meaningful descriptions in invitations

### **Activity Design**
- [ ] **Easy Activity Starting**: System share sheet presented when appropriate
- [ ] **Pre-session Preparation**: Login, downloads, payments handled before activity
- [ ] **Deferred Non-essential Tasks**: Non-critical tasks delayed until appropriate times

### **visionOS Specific**
- [ ] **Spatial Persona Template**: Appropriate template chosen for activity type
- [ ] **Direct Activity Launch**: No unrelated windows, immediate activity access
- [ ] **Immersion Choice**: User consent for immersion changes
- [ ] **Participant Integration**: Smooth new participant integration

### **Shared Context**
- [ ] **Consistent State**: All participants see same app state
- [ ] **Spatial Audio**: Implemented for enhanced realism
- [ ] **Natural Conflict Resolution**: Social solutions over UI controls
- [ ] **Content Separation**: Clear shared vs private content distinction

### **Personalization**
- [ ] **Individual Settings**: Volume, subtitles per participant
- [ ] **Unique Views When Needed**: Per-person views for specific content
- [ ] **Easy Exit/Rejoin**: Quick controls for temporary departure

---

## 🎯 **Common Anti-Patterns to Avoid**

### **❌ SharePlay Discovery Issues**
- **Missing SharePlay indicators**: Users don't know content is shareable
- **Incorrect terminology**: Using "SharePlayed", "SharePlaying", etc.
- **Unclear activity descriptions**: Users don't understand what they're joining

### **❌ Activity Design Problems**
- **Complex onboarding**: Requiring too many steps before joining
- **Blocking tasks**: Essential tasks blocking group participation
- **No session creation**: Users can't start new SharePlay sessions

### **❌ visionOS Integration Issues**
- **Wrong spatial template**: Using side-by-side for interactive 3D content
- **Unnecessary windows**: Showing unrelated UI when launching directly
- **Forced immersion changes**: Not giving users choice about immersion levels

### **❌ Shared Context Violations**
- **Inconsistent states**: Different participants seeing different app states
- **Missing spatial audio**: Flat audio experience in spatial collaboration
- **Over-engineered conflict resolution**: Complex UI for simple conflicts

---

## 🚀 **Implementation Examples**

### **Good: Movie Watching App**
```swift
// Side-by-side template for media viewing
.spatialTemplatePreference = .sideBySide

// Clear activity description
metadata.title = "Movie Night"
metadata.subtitle = "Watch together in sync"

// Immediate launch to movie view
class MovieViewController {
    func handleSharePlayLaunch() {
        presentMoviePlayer() // No unnecessary UI
    }
}
```

### **Good: 3D Game**
```swift
// Surround template for 3D interactive content
.spatialTemplatePreference = .surround

// Natural conflict resolution
class GameViewController {
    func handleMultiplayerMove(_ move: GameMove) {
        applyMove(move) // Last move wins, no UI conflict resolution
    }
}
```

### **Good: Collaborative Whiteboard**
```swift
// Conversational template for background activity
.spatialTemplatePreference = .conversational

// Easy exit/rejoin with overlay
class WhiteboardViewController {
    func showRejoinOverlay() {
        presentRejoinControl() // Quick rejoin option
    }
}
```

---

## 📈 **Success Metrics**

### **User Experience Metrics**
- **Discovery Rate**: Percentage of users who find shareable content
- **Join Rate**: Percentage of invited users who successfully join
- **Engagement Time**: Average time spent in shared activities
- **Return Rate**: Percentage of users who return for more sharing

### **Technical Metrics**
- **Session Success Rate**: Percentage of sessions that start successfully
- **Synchronization Accuracy**: How well content stays synchronized
- **Performance**: Impact of SharePlay on app performance
- **Crash Rate**: Stability during SharePlay sessions

---

*This integration provides complete coverage of Apple's SharePlay HIG, enabling developers to create experiences that not only function correctly but also provide the high-quality user experience that Apple users expect.*