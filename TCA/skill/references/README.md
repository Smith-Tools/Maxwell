# TCA References - Discovery Documents

This directory contains in-depth case studies and solutions for specific TCA issues.

---

## 🔍 DISCOVERY Documents

These are deep-dive investigations into specific problems, anti-patterns, or edge cases in TCA development.

### [DISCOVERY-16-TCA-SWIFTUI-TYPE-INFERENCE.md](./DISCOVERY-16-TCA-SWIFTUI-TYPE-INFERENCE.md)

**Topic:** Type Inference Explosion & Compilation Hangs

**Problem:**
Your TCA reducer compiles for 5+ minutes, or fails with cryptic type errors. You have nested `CombineReducers`, and Swift compiler's type inference is exploding.

**Root Cause:**
When you nest `CombineReducers` or have deeply nested reducer composition, Swift's type inference creates implicit composition chains. Each level adds complexity, and the compiler must infer types through all levels.

**Solution:**
Flat `@ReducerBuilder` composition with helper functions instead of nested `CombineReducers`.

**Key Insights:**
- The problem isn't the NUMBER of reducers, but the **structure**
- Flat composition eliminates type inference chains
- Helper functions allow logical grouping without nesting
- Modern Swift compiler handles flat structures efficiently

**Read this when:**
- Your TCA reducer takes forever to compile
- You get type inference errors in complex reducers
- You have nested `CombineReducers` in your reducer body
- You're migrating from old TCA patterns

**Time to read:** 10-15 minutes

**Verification checklist included:** ✅

---

## 📊 Discovery Document Index

| Document | Topic | Problem | Read Time |
|----------|-------|---------|-----------|
| DISCOVERY-16 | Type Inference | Compilation hangs, nested composition | 10 min |

---

## 🎯 How to Use DISCOVERY Documents

### **When you encounter a problem:**

1. **Identify the symptom** (compilation hang, type error, runtime crash, test failure)
2. **Search DISCOVERY docs** for matching symptoms
3. **Read the matching DISCOVERY doc** (usually 5-15 min)
4. **Apply the solution** described

### **When you see code anti-patterns:**

1. **Recognize the pattern** (nested reducers, wrong @Shared constructor, etc.)
2. **Find it in Red Flags table below**
3. **Read the DISCOVERY doc** for full context
4. **Understand WHY it's wrong**

---

## 🚨 Quick Red Flags → DISCOVERY Mapping

| Red Flag | DISCOVERY Doc | Why It's Wrong |
|----------|---|---|
| Nested `CombineReducers` | DISCOVERY-16 | Type inference explosion |
| Compilation hangs (5+ min) | DISCOVERY-16 | Likely reducer composition |
| Cryptic type errors in reducer | DISCOVERY-16 | Implicit composition chains |

---

## 📚 How DISCOVERY Relates to Guides

**Guides** (in `../guides/`) are comprehensive, prescriptive: "Here's how to do X correctly"

**DISCOVERY documents** are investigative, reactive: "You did X wrong, here's why and how to fix it"

### **Example:**

- **Guide:** TCA-PATTERNS.md Pattern 1 teaches you `@Bindable` correctly
- **DISCOVERY:** If you use `WithViewStore` instead, DISCOVERY-16 explains why it breaks

---

## 🔗 DISCOVERY Cross-References

Each DISCOVERY document references:
- **Related guides** for the correct pattern
- **Verification checklists** for the solution
- **Code examples** showing before/after

---

## 📝 Reading DISCOVERY Documents

DISCOVERY docs follow a consistent structure:

1. **Problem Statement** - What went wrong?
2. **Root Cause Analysis** - Why did it go wrong?
3. **Solution** - How to fix it
4. **Why This Works** - Understanding the fix
5. **Prevention** - How to avoid this in future
6. **Code Examples** - Before/after comparison
7. **Verification Checklist** - How to verify your fix

---

## 🎓 Study Strategy for DISCOVERY

### **Quick Fix (10-15 min)**
- Read Problem Statement
- Jump to Solution
- Apply fix
- Check Verification Checklist

### **Deep Understanding (20-30 min)**
- Read entire DISCOVERY
- Understand Root Cause
- Study Code Examples
- Review prevention strategies

### **Prevention (5 min)**
- Read Red Flags section in related guide
- Understand pattern correctly
- Never revisit this DISCOVERY

---

## 📋 Complete DISCOVERY List

**Available Now:**
- ✅ DISCOVERY-16: Type Inference Explosion

**Coming Soon:**
- DISCOVERY-17: Race Conditions in @Shared State
- DISCOVERY-18: @Dependency Testing Pitfalls
- DISCOVERY-19: Navigation State Cleanup
- DISCOVERY-20: Effect Cancellation Edge Cases

---

## 🔄 Workflow: Using Guide + DISCOVERY Together

### **Scenario 1: Learning a new pattern**
```
User: "I need to implement optional child features"
  ↓
Read: TCA-NAVIGATION.md (comprehensively teaches sheet-based patterns)
  ↓
Code confidently with verification checklist
```

### **Scenario 2: Fixing an existing problem**
```
User: "My reducer takes 5+ minutes to compile"
  ↓
Search: DISCOVERY docs for "compilation"
  ↓
Read: DISCOVERY-16 (investigates the root cause)
  ↓
Fix: Remove nested CombineReducers, flatten composition
  ↓
Verify: Compilation now takes 10 seconds
```

### **Scenario 3: Preventing issues**
```
User: "Before I write code, help me avoid mistakes"
  ↓
Read: TCA-PATTERNS.md Red Flags section
  ↓
Read: Related DISCOVERY docs
  ↓
Code with full understanding of what NOT to do
```

---

## 💡 Key Insight

DISCOVERY documents aren't just for debugging—they're for **understanding the discipline**.

When you read why `Shared(value: x)` is wrong (DISCOVERY), you understand reference semantics better. When you read why nested composition explodes (DISCOVERY-16), you understand Swift type system better.

**Use DISCOVERY to learn deeply, not just to fix problems.**

---

## 🔗 Related Resources

- `../guides/` - Comprehensive pattern guides
- `../SKILL.md` - How to use TCA Skill
- `../../agent/` - Agent implementations
- `../../README.md` - Project overview

---

**Last updated:** November 20, 2025

**Contact:** For new DISCOVERY topics, see `/Volumes/Plutonian/_Developer/Maxwells/source/TCA/README.md`
