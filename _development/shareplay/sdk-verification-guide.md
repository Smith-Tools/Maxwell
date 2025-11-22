# SDK Verification Guide: Extracting SharePlay API Signatures

## 🎯 Goal
Extract the actual SDK signatures for GroupActivities framework using `swift symbolgraph-extract` to ensure we implement only verified code.

## 🔧 Commands to Run

### **For visionOS (Primary Platform)**
```bash
# Replace with your actual Xcode path
swift symbolgraph-extract \
  -module-name GroupActivities \
  -target arm64-apple-xros26.0 \
  -output-dir ~/Downloads/SharePlay-SymbolGraph \
  -pretty-print \
  -sdk /Applications/Xcode-26.1.0.app/Contents/Developer/Platforms/XROS.platform/Developer/SDKs/XROS.sdk
```

### **For iOS (Reference)**
```bash
swift symbolgraph-extract \
  -module-name GroupActivities \
  -target arm64-apple-ios17.0 \
  -output-dir ~/Downloads/SharePlay-SymbolGraph-iOS \
  -pretty-print \
  -sdk /Applications/Xcode-26.1.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
```

### **For macOS (Reference)**
```bash
swift symbolgraph-extract \
  -module-name GroupActivities \
  -target arm64-apple-macos14.0 \
  -output-dir ~/Downloads/SharePlay-SymbolGraph-macOS \
  -pretty-print \
  -sdk /Applications/Xcode-26.1.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

## 🔍 Key APIs to Extract and Verify

### **1. CodableValue Structure**
Look for in the extracted symbol graph:
- `CodableValue` enum/struct definition
- Available cases (`.string`, `.bool`, `.double`, `.array`, `.dictionary`, `.null`)
- Initializer methods
- Conversion methods

**Search for in output:**
```json
"symbols": {
  "s:14GroupActivities11CodableValueO": {
    // Look for this symbol definition
  }
}
```

### **2. GroupSession Properties**
Look for:
- `activeParticipants` property signature
- `$activeParticipants` publisher (if available)
- Any AsyncSequence equivalents

**Expected patterns to verify:**
```json
{
  "identifier": "s:14GroupActivities11GroupSessionC17activeParticipantsSay6SetVyAA11ParticipantVG",
  "kind": "property"
}
```

### **3. Compression Framework Availability**
Look for:
- `compression_encode_buffer` function signatures
- `compression_decode_buffer` function signatures
- Available compression types (`COMPRESSION_ZLIB`, etc.)
- Platform availability

### **4. AsyncSequence Support**
Look for:
- Whether `session.activeParticipants` conforms to `AsyncSequence`
- `.values` property availability
- `for await` patterns support

## 📋 Verification Checklist

After running the extraction, please verify:

### ✅ **CodableValue Requirements:**
- [ ] Exact enum case names
- [ ] Initializer parameter types
- [ ] Conversion method signatures
- [ ] Platform availability

### ✅ **GroupSession.activeParticipants:**
- [ ] Property type (Set<Participant>?)
- [ ] Whether `$activeParticipants` publisher exists
- [ ] Whether `.values` AsyncSequence exists
- [ ] Exact method signatures

### ✅ **Compression Framework:**
- [ ] Function parameter types and counts
- [ ] Return value handling
- [ ] Platform availability (iOS, visionOS, macOS)
- [ ] Required imports

### ✅ **Async Patterns:**
- [ ] AsyncSequence conformance on properties
- [ ] Iterator element types
- [ ] AsyncStream/AsyncChannel availability

## 📝 What to Share

Please share the extracted symbol graphs or at least the key findings:

```bash
# After extraction, share these sections:
# 1. CodableValue definition
# 2. GroupSession.activeParticipants definition
# 3. Any compression function signatures found
# 4. AsyncSequence conformations found

# You can extract specific sections:
grep -A 20 "CodableValue" ~/Downloads/SharePlay-SymbolGraph/*.json
grep -A 10 "activeParticipants" ~/Downloads/SharePlay-SymbolGraph/*.json
```

## 🚀 Next Steps

Once you provide the extracted signatures:

1. **I'll implement Phase 1.1** with 100% verified code
2. **Update our knowledge base** with correct API signatures
3. **Create verified code examples** that will actually compile
4. **Remove any theoretical/placeholder code** we previously had

## 📊 Expected Impact

With verified SDK signatures:
- ✅ **100% accurate implementations**
- ✅ **No more theoretical code**
- ✅ **Production-ready examples**
- ✅ **Cross-platform compatibility verified**
- ✅ **API stability ensured**

---

**This approach ensures we never "invent" anything - only implement what the SDK actually provides.** 🎯