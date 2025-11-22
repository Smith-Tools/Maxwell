# TCA Project Bootstrap & Scaffolding

> **Complete guide to create TCA projects from scratch with proper dependencies**

## 🚀 Full Project Creation Workflow

### Step 1: Project Initialization

#### Create New Xcode Project
```
File → New → Project → macOS → App
- Product Name: YourAppName
- Interface: SwiftUI
- Language: Swift
- Minimum Deployment: macOS 12.0+
```

#### Add TCA Dependency
```
File → Add Package Dependencies...
URL: https://github.com/pointfreeco/swift-composable-architecture
Version: 1.23.0+
Add to: YourAppName target
```

### Step 2: Directory Structure Setup

```
YourAppName/
├── YourAppName/
│   ├── Features/
│   │   ├── AppFeature.swift
│   │   ├── SettingsFeature.swift
│   │   └── [Other Features]/
│   ├── Dependencies/
│   │   ├── APIClient.swift
│   │   └── [Other Dependencies]/
│   ├── Models/
│   │   └── [Shared Models]/
│   ├── Resources/
│   └── YourAppNameApp.swift
├── YourAppNameTests/
│   └── [Test Files]/
└── Package.swift (if using SPM)
```

### Step 3: Base Files Creation

#### Main App Integration
```swift
// YourAppNameApp.swift
import SwiftUI
import ComposableArchitecture

@main
struct YourAppNameApp: App {
    var body: some Scene {
        WindowGroup {
            AppFeatureView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
```

#### Base Feature Structure
```swift
// Features/AppFeature.swift
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        // Your app state here
    }

    enum Action {
        // Your actions here
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Your reducer logic here
        }
    }
}

struct AppFeatureView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        // Your view here
    }
}
```

## 🔧 Automation Scripts

### Project Setup Script
```bash
#!/bin/bash
# setup-tca-project.sh

PROJECT_NAME="$1"
if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./setup-tca-project.sh YourAppName"
    exit 1
fi

# Create Features directory
mkdir -p "$PROJECT_NAME/Features"
mkdir -p "$PROJECT_NAME/Dependencies"
mkdir -p "$PROJECT_NAME/Models"

# Create base files
cat > "$PROJECT_NAME/Features/AppFeature.swift" << 'EOF'
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var isShowingAlert = false
    }

    enum Action {
        case buttonTapped
        case alertResponse(AlertState<ButtonAction>.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                state.isShowingAlert = true
                return .none

            case .alertResponse:
                state.isShowingAlert = false
                return .none
            }
        }
        .if(\.isShowingAlert) { $0 } scope: { state, action in
            Scope(state: \.self, action: \.alertResponse) {
                EmptyReducer()
            }
        } destination: { state in
            AlertState(
                title: TextState("Welcome to TCA!"),
                actions: {
                    ButtonState(action: .accepted) {
                        TextState("OK")
                    }
                }
            )
        }
    }
}

struct AppFeatureView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        VStack {
            Text("TCA App Ready!")
                .font(.title)

            Button("Test Alert") {
                store.send(.buttonTapped)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .alert($store.scope(state: \.isShowingAlert, action: \.alertResponse))
    }
}
EOF

echo "✅ TCA project setup complete for $PROJECT_NAME"
echo "Don't forget to add ComposableArchitecture dependency in Xcode"
```

## 🎯 Bootstrap Checklist

### Before Coding
- [ ] Xcode project created
- [ ] TCA dependency added
- [ ] Directory structure established
- [ ] Base files created

### Verification Steps
- [ ] `import ComposableArchitecture` compiles
- [ ] Basic @Reducer structure works
- [ ] SwiftUI view with Store functions
- [ ] Alert presentation works

### Common Issues to Avoid
- [ ] Missing TCA import
- [ ] Wrong deployment targets
- [ ] Incompatible Swift version
- [ ] Target not linked to dependency

## 📚 Related Documentation

- [TCA SETUP.md](./TCA-SETUP.md) - Dependency details
- [TCA-PATTERNS.md](./TCA-PATTERNS.md) - Implementation patterns
- [TCA-TESTING.md](./TCA-TESTING.md) - Testing setup

---

**Result**: Complete TCA project ready for development with proper structure and dependencies.