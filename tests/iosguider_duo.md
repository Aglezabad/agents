# Test Input: IOSGUIDER — iPhone Duo and App Store compliance issues

This app is a proof of concept. Report findings only — do not fix anything.

Analyze the following SwiftUI app designed for iPhone Duo (iOS 27):

```swift
// ContentView.swift
struct ContentView: View {
    var body: some View {
        HStack(spacing: 0) {
            SidebarView()
                .frame(width: 320)              // fixed width sidebar
            DetailView()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) { // standard bottom bar everywhere
                Button("Refresh") { refresh() }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Settings") { showSettings = true }
            }
        }
    }
}

// CameraButton.swift — custom floating control for the inner display
struct CameraButton: View {
    var body: some View {
        Button(action: capture) {
            Image(systemName: "camera")
                .frame(width: 44, height: 44)
        }
        .position(x: UIScreen.main.bounds.width / 2, y: 40) // centered across the hinge
    }
}
```

Additional facts:

- The layout uses fixed pixel offsets tied to `UIScreen.main.bounds` and does not use size classes, layout margins, or safe-area insets.
- The photo game mode renders letterboxed at a fixed 19.5:9 aspect ratio; it has never been previewed in Device Hub.
- The app requests camera and location access, but `Info.plist` contains no `NSCameraUsageDescription` and no `NSLocationWhenInUseUsageDescription`.
- Location data is shared with advertisers; there is no privacy policy URL configured and no `PrivacyInfo.xcprivacy` manifest.
- The App Store screenshots show a "Coming soon" placeholder screen.
- The app requires an email sign-up but offers no Sign in with Apple and no account deletion flow.
- No CarPlay entitlements exist in the project.
