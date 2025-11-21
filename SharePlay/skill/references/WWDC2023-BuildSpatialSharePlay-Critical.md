# WWDC 2023 Session 10087: Build spatial SharePlay Experiences - Critical Transcript

**Source**: https://developer.apple.com/videos/play/wwdc2023/10087/
**Duration**: 24m 31s
**Focus**: GroupActivities framework for visionOS spatial collaboration

## 🔍 Key Critical Information

### **Shared Context & Spatial Personas:**
- ✅ **"Everyone will see everyone else in the same relative position"**
- ✅ **"Shared context means that everyone will see everyone else in the same relative position"**
- ✅ **"Spatial Personas take up physical space in your room instead of being constrained to a single window"**

### **Scene Coordination - THE CRITICAL PIECE:**
- ✅ **"System coordinator is responsible for receiving system state for active SharePlay session"**
- ✅ **"Scene association determines which window scene will be used with the template"**
- ✅ **"For multiscene apps, you need to specify scene activation conditions using handlesExternalEvents or predicates"**

### **Immersive Apps - CRITICAL FOR OUR ISSUE:**
- ✅ **"Immersive Space allows app to make contents go beyond boundaries"**
- ✅ **"Group immersive space has a shared coordinate system for spatial consistency"**
- ✅ **"To minimize split contacts, use groupImmersionStyle to track others' immersion status"**

### **Multiple Scenes - THIS EXPLAINS OUR ISSUE:**
- ✅ **"If all scenes are open, the wrong scene could be used in the template"**
- ✅ **"Scene association helps prevent accidentally interacting with shared window without realizing"**
- ✅ **"Use unique identifier for each document to match correct scene"**

### **Visual Consistency - APP RESPONSIBILITY:**
- ✅ **"Apps need to keep content and placement in sync for all participants"**
- ✅ **"When Connor scrolls, we should sync scroll position if spatial, but not if non-spatial"**
- ✅ **"It's the responsibility of the app to maintain visual consistency"**

## 🎯 CRITICAL INSIGHTS FOR OUR IMPLEMENTATION

### **The Missing Piece: Scene Association**

**From the transcript:**
> **"For multiscene apps, you need to specify scene activation conditions using handlesExternalEvents or predicates"**
> **"If all scenes are open, the wrong scene could be used in the template"**
> **"Scene association determines which window scene will be used with the template"**

**This suggests:**
1. **Multiple scenes CAN be shared** but system needs to know which one to use
2. **Scene association is critical** for multi-scene apps
3. **Wrong scene selection could prevent spatial personas from appearing**

### **Immersive Space Shared Context**

**Critical quote:**
> **"Group immersive space has a shared coordinate system for spatial consistency"**

**This means:**
- **ImmersiveSpace has shared coordinate system**
- **Spatial consistency is maintained across participants**
- **GroupImmersionStyle helps track immersion status**

## 🔧 Implementation Implications

### **What We Might Be Missing:**

1. **Scene Activation Conditions**: Our `handlesExternalEvents` might not be specific enough
2. **Unique Scene Identifiers**: We might need more specific scene identification
3. **Immersion Status Tracking**: We might need `groupImmersionStyle` for proper coordination
4. **Shared Context Configuration**: The immersive space might need explicit shared context setup

### **Key Questions to Investigate:**

1. **Is our scene association specific enough** to guide the system to the immersive space?
2. **Do we need groupImmersionStyle** for proper coordination between WindowGroup and ImmersiveSpace?
3. **Are we maintaining visual consistency** properly between scenes?
4. **Is there shared context configuration** needed for immersive space?

## ✅ Action Items Based on This Session

1. **Investigate groupImmersionStyle** API for tracking immersion status
2. **Review scene activation conditions** in our handlesExternalEvents implementation
3. **Check shared coordinate system** configuration for immersive space
4. **Ensure visual consistency** maintenance between participants

This session provides the exact guidance we need to fix our spatial persona coordination issues!