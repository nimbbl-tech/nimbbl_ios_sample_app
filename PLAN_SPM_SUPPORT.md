# Adding Swift Package Manager (SPM) Support to Nimbbl iOS SDKs

## ✅ Decisions locked (2026-05-15)

| # | Question | Decision |
|---|---|---|
| 1 | Primary distribution mode | **Binary-first** (xcframework via `.binaryTarget`) |
| 2 | Hosting for xcframework.zip | **GitHub Releases** on `_pod` repos |
| 3 | Pre-release versioning | **Alpha** tags — consumers use `.exact("2.1.0-alpha.1")` |
| 4 | Tag policy | **Different tags** on source vs pod repos allowed |
| 5 | Sample app strategy | **Dual** — keep `Podfile`, add SPM local refs alongside |
| 6 | WebView binary wrapper | **Wrapper target required** — consumers add only WebView SDK package and get Core API SDK transitively |
| 7 | CI ownership for publish | **Stays on dev Macs** — extend `publish_script/`, no GitHub Actions |

### Implementation order (revised based on decisions)

Phase B priority swap — binary-first means **Phase B.3 + B.4 (pod repos) ship first**, source-mode `Package.swift` files (B.1, B.2) are a follow-up. Reasoning: pod repos are what production consumers point at; source repos primarily benefit dev workflow.

```
Implementation sequence:
  1. B.3  Core API pod's  Package.swift  (binaryTarget)
  2. B.4  WebView pod's   Package.swift  (binaryTarget + wrapper)
  3. C.1  publish_script  changes (zip + checksum + GitHub Release upload + tag)
  4. Tag + Release a binary 2.1.0-alpha.1 (validates the whole pipeline)
  5. B.5  Sample app SPM local refs (validates consumer integration)
  6. B.6  INTEGRATION_GUIDE.md updates
  7. B.7  Podspec mixing-warning comments
  8. B.8  .gitignore touch-ups
  9. (Follow-up) B.1 + B.2  Source Package.swift in main SDK repos
```

---

## Phase A — Foundation (decisions only)

### A.1 Directory layout

| Option | Disruption | CocoaPods impact | SPM ergonomics | Recommend |
|---|---|---|---|---|
| (a) Move sources to `Sources/<Target>/` | High — moves ~30 files in each repo, breaks Xcode project file refs, breaks current podspec `source_files` glob | Need podspec `source_files` updated to new path | Native, zero config | No |
| (b) Keep current `<repo>/<repo-name>/*.swift`, override `path:` in `Package.swift` | Zero file moves | None — podspec stays the same | Slight non-standard; well-supported | **Yes** |
| (c) Symlink | Symlink commit weirdness, Xcode mishandling | Risk | Hacky | No |

**Pick (b).** SPM's `path:` + `sources:` overrides exist exactly for this. No file moves, podspec stays as-is, Xcode project stays valid.

Tests: no test targets exist today; SPM allows omitting `testTarget`. We do NOT add `Tests/` in phase 1.

### A.2 Source vs binary distribution

| Mode | Build time | Source visibility | Symbolication | Setup |
|---|---|---|---|---|
| **SPM source** (`Package.swift` in main SDK repo, consumer pulls via git URL) | Slow first build, fast incremental | Full source visible to consumers | Native | Simple — one file commit |
| **SPM binary** (`.binaryTarget` + `xcframework.zip` hosted on GitHub Releases under the `_pod` repos) | Fast (prebuilt) | Closed (parity with current CocoaPods production) | Need dSYMs in zip for line-level | Requires release-time zip + checksum |

**Primary recommendation: ship BOTH, mirroring the existing podspec dual-mode.**
- The main SDK repo (`nimbbl_mobile_kit_ios_core_api_sdk`) gets `Package.swift` pointing at source files → source distribution, used for development and SPM-source consumers.
- The companion `_pod` repos get a second `Package.swift` with a `.binaryTarget` referencing `xcframework.zip` uploaded to a GitHub Release on the `_pod` repo → binary distribution, mirroring production CocoaPods.

Consumers pick by URL: source = main repo URL, binary = pod repo URL. This is exactly the current CocoaPods topology.

### A.3 Sample app strategy

| Option | Pros | Cons |
|---|---|---|
| Keep CocoaPods only | No change, USE_LOCAL_SDKS toggle still works | Doesn't test SPM path |
| Switch entirely to SPM | Tests SPM, simpler dev | Loses pod-mode regression coverage |
| **Dual: keep `Podfile`, add a second Xcode project / scheme that uses SPM local refs** | Validates both paths | A bit of duplication |

**Recommend dual.** Keep `Podfile` exactly as-is. Add SPM local package refs to `NimbblSampleApp.xcodeproj` as "Local Swift Packages" (Xcode's File → Add Package Dependencies → Add Local). Toggle in code via a second target/scheme if helpful, but at minimum the SPM path must be exercised locally before each release.

### A.4 Module / package name

- Swift packages allow underscores in names — `nimbbl_mobile_kit_ios_core_api_sdk` is valid as a package name, product name, and target name. It is unusual (most packages use PascalCase) but Apple's SPM has no syntactic restriction.
- Module identifier is the **target name**. Keeping target name = `nimbbl_mobile_kit_ios_core_api_sdk` preserves `import nimbbl_mobile_kit_ios_core_api_sdk` for all consumers.
- The Package itself can be given a different `name:` in the manifest (e.g. `"NimbblCoreApiSDK"`) but the **target/product name** must stay as the underscore identifier so imports don't break.
- WebView SDK has an existing modulemap with `framework module nimbbl_mobile_kit_ios_webview_sdk` — SPM auto-generates a modulemap for Swift targets, no conflict for the source distribution. For the binary distribution the existing modulemap inside the xcframework is used as-is.

No naming changes required. Flag only: the underscored name will look unusual in Xcode's "Package Dependencies" UI — acceptable.

---

## Phase B — Code & file changes (ordered)

### B.0 PRE-ROLLOUT: Add dSYMs + PrivacyInfo to xcframework build (BLOCKER for any consumer release)

> **🟠 REVIEW FIX — production-blocking.** The current `build_xcframework` step doesn't bundle dSYMs or a `PrivacyInfo.xcprivacy`. Both are critical for SPM-binary consumers.

**dSYMs:** Without them, every crash from production SPM consumers will be unsymbolicated. SPM doesn't let consumers add dSYMs externally — they must live inside the `.xcframework`.

```bash
# in build_xcframework — add this to each `xcodebuild archive` call:
xcodebuild archive \
  ... \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

# then when creating the xcframework, include the dSYMs:
xcodebuild -create-xcframework \
  -framework "ios/${SDK_NAME}.framework" \
    -debug-symbols "$(pwd)/ios/${SDK_NAME}.framework.dSYM" \
  -framework "ios-simulator/${SDK_NAME}.framework" \
    -debug-symbols "$(pwd)/ios-simulator/${SDK_NAME}.framework.dSYM" \
  -output "${SDK_NAME}.xcframework"
```

**PrivacyInfo.xcprivacy:** Apple requires this for any SDK using "required reason API" categories. Core API SDK uses Network calls + UserDefaults + file timestamps — all flagged categories. App Store submissions started rejecting on May 1, 2024. The manifest must live inside the `.framework`:

```
Sources/PrivacyInfo.xcprivacy
```

Minimum content (declare the required-reason API categories the SDK uses):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>
  <key>NSPrivacyCollectedDataTypes</key>
  <array/>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>C617.1</string></array>
    </dict>
  </array>
</dict>
</plist>
```

Add this file to both SDK targets' source list and ensure `xcodebuild archive` includes it in the framework Resources bundle.

**Without B.0 done, do not publish an SPM binary release.**

### B.1 Add `Package.swift` to Core API SDK source repo
**Path:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_core_api_sdk/Package.swift`
**Rationale:** SPM source distribution entry point. Sits next to the existing `.podspec` — both coexist.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "nimbbl_mobile_kit_ios_core_api_sdk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "nimbbl_mobile_kit_ios_core_api_sdk",
            targets: ["nimbbl_mobile_kit_ios_core_api_sdk"]
        )
    ],
    targets: [
        .target(
            name: "nimbbl_mobile_kit_ios_core_api_sdk",
            path: "nimbbl_mobile_kit_ios_core_api_sdk",
            exclude: [],
            sources: nil,                 // include all .swift in the folder
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("Network")
                // CommonCrypto, Foundation, UIKit auto-link
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
```

Notes:
- `path:` matches existing layout from A.1.
- No `exclude:` entries needed yet because no xcframework / Pods / build folders live inside that subdirectory (verified — only `.swift` files there).
- `.linkedFramework("CommonCrypto")` is intentionally omitted: it ships with libSystem and Swift's `import CommonCrypto` works without an explicit link in SPM, identical to the podspec which also doesn't list it.

### B.2 Add `Package.swift` to WebView SDK source repo
**Path:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_webview_sdk/Package.swift`
**Rationale:** SPM source distribution for WebView, with declared dependency on Core API SDK package.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "nimbbl_mobile_kit_ios_webview_sdk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "nimbbl_mobile_kit_ios_webview_sdk",
            targets: ["nimbbl_mobile_kit_ios_webview_sdk"]
        )
    ],
    dependencies: [
        // NOTE: must be `.exact("2.1.0-alpha.1")`, NOT `from:`. SPM's `from:` filters
        // pre-release tags out — so once a stable 2.1.0 exists, `from:` would jump
        // to it and break alpha-pinned consumers. Switch to `from:` only after GA.
        .package(
            url: "https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_core_api_sdk.git",
            exact: "2.1.0-alpha.1"
        )
    ],
    targets: [
        .target(
            name: "nimbbl_mobile_kit_ios_webview_sdk",
            dependencies: [
                .product(name: "nimbbl_mobile_kit_ios_core_api_sdk",
                         package: "nimbbl_mobile_kit_ios_core_api_sdk")
            ],
            path: "nimbbl_mobile_kit_ios_webview_sdk",
            linkerSettings: [
                .linkedFramework("WebKit")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
```

Caveat: `from: "2.1.0-alpha.1"` — SPM treats pre-release tags carefully. If SPM resolution complains about the pre-release, use `.exact("2.1.0-alpha.1")` until a stable tag exists, or switch the constraint after first GA. Decision deferred — see open questions.

### B.3 Add `Package.swift` to Core API POD repo (binary distribution)
**Path:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_core_api_pod/Package.swift`
**Rationale:** Mirrors the production CocoaPods topology — consumers who want a prebuilt binary use this repo's URL.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "nimbbl_mobile_kit_ios_core_api_sdk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "nimbbl_mobile_kit_ios_core_api_sdk",
            targets: ["nimbbl_mobile_kit_ios_core_api_sdk"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "nimbbl_mobile_kit_ios_core_api_sdk",
            // Option A: zip hosted on GitHub Releases (preferred)
            url: "https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_core_api_pod/releases/download/2.1.0-alpha.1/nimbbl_mobile_kit_ios_core_api_sdk.xcframework.zip",
            checksum: "<sha256-from-swift-package-compute-checksum>"
        )
        // Option B fallback for local testing only (commented):
        // .binaryTarget(name: "...", path: "nimbbl_mobile_kit_ios_core_api_sdk.xcframework")
    ]
)
```

The `xcframework.zip` already lives in the pod repo (560 KB confirmed). For SPM it must be attached to a GitHub Release (not just a file in the git tree) so SPM can fetch it via a stable URL.

### B.4 Add `Package.swift` to WebView POD repo (binary distribution)
**Path:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_webview_pod/Package.swift`

> **🔴 REVIEW FIX 1 — binary target rename.** The binary target CANNOT share the same name as the public product when the product's target list points to a different target (the wrapper). Name the internal binary `NimbblWebViewSDKBinary`; the wrapper takes the public name so consumer imports stay unchanged. This matches the Firebase / Stripe-iOS pattern.

> **🔴 REVIEW FIX 2 — wrapper must re-export.** An empty `.swift` file in the wrapper produces a hollow module — `import nimbbl_mobile_kit_ios_webview_sdk` would compile but expose ZERO symbols. The wrapper file must contain `@_exported import` lines so binary symbols + Core API SDK symbols flow through to consumers.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "nimbbl_mobile_kit_ios_webview_sdk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "nimbbl_mobile_kit_ios_webview_sdk",
            targets: ["nimbbl_mobile_kit_ios_webview_sdk"]  // wrapper target (public name)
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_core_api_pod.git",
            exact: "2.1.0-alpha.1"
        )
    ],
    targets: [
        // Binary xcframework — INTERNAL name so it doesn't collide with the product
        .binaryTarget(
            name: "NimbblWebViewSDKBinary",
            url: "https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod/releases/download/2.1.0-alpha.1/nimbbl_mobile_kit_ios_webview_sdk.xcframework.zip",
            checksum: "<sha256>"
        ),
        // Wrapper takes the PUBLIC product name; re-exports binary + transitive Core API SDK
        .target(
            name: "nimbbl_mobile_kit_ios_webview_sdk",
            dependencies: [
                "NimbblWebViewSDKBinary",
                .product(name: "nimbbl_mobile_kit_ios_core_api_sdk",
                         package: "nimbbl_mobile_kit_ios_core_api_pod")
            ],
            path: "Sources/Wrapper"
        )
    ]
)
```

**Required content of `Sources/Wrapper/Exports.swift`:**

```swift
// SPM re-export shim so `import nimbbl_mobile_kit_ios_webview_sdk` exposes both
// the binary xcframework's symbols AND the transitive Core API SDK module.
// Without these @_exported lines the wrapper module is hollow.
@_exported import NimbblWebViewSDKBinary
@_exported import nimbbl_mobile_kit_ios_core_api_sdk
```

This mirrors what Firebase's `FirebaseAuth/Sources/SwiftPM-shim/` does for every binary-distributed module, and Stripe-iOS's `Stripe/Empty.swift` shim. The "empty file" suggestion from earlier was wrong.

### B.5 Update sample app to support SPM
**Path:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_ios_sample_app/NimbblSampleApp.xcodeproj/project.pbxproj` (via Xcode UI)
**Rationale:** Validates SPM during development without removing CocoaPods.

Process (Xcode UI, no manual pbxproj editing):
1. Open `NimbblSampleApp.xcworkspace`.
2. File → Add Package Dependencies → Add Local → choose `../nimbbl_mobile_kit_ios_core_api_sdk` then `../nimbbl_mobile_kit_ios_webview_sdk`.
3. Add the two products to the `NimbblSampleApp` target's "Frameworks, Libraries, and Embedded Content".
4. Keep the existing Podfile setup so `USE_LOCAL_SDKS=true` continues to work — but document in `README.md` that the SPM path is the new preferred local-dev mode for SPM regression coverage.

No changes to `Podfile` itself.

### B.6 Update INTEGRATION_GUIDE.md for both SDKs
**Paths:**
- `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_webview_sdk/INTEGRATION_GUIDE.md`
- (Create equivalent section in Core API repo's README or new INTEGRATION_GUIDE.md.)

Add a new top-level section right after `## Pod Installation` titled `## Swift Package Manager Installation`:

```markdown
## Swift Package Manager Installation

### Xcode UI
1. File → Add Package Dependencies
2. Enter `https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git`
3. Select version rule "Up to Next Major" starting at `2.1.0`
4. Add the `nimbbl_mobile_kit_ios_webview_sdk` product to your target

### Package.swift
dependencies: [
    .package(url: "https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git", from: "2.1.0")
]

### Do NOT mix CocoaPods and SPM
Choose one package manager per app **across BOTH SDKs**. Mixing for the same SDK
will cause duplicate-symbol errors at link time — but ALSO mixing them across
the two SDKs in this family is unsupported. Concretely, an app that uses
CocoaPods for `nimbbl_mobile_kit_ios_core_api_sdk` and SPM for the WebView SDK
will end up with TWO copies of the Core API framework (one from Pods, one
pulled transitively via the WebView SPM package's wrapper target). Link will
fail with `duplicate symbol` errors. Pick a single manager for both SDKs.
```

Add identical block to Core API SDK README.

### B.7 Update podspecs with mixing warning
Add a one-line comment in both `.podspec` files near the top noting that SPM is also offered and that consumers must not use both. Purely cosmetic; CocoaPods has no detection mechanism.

### B.8 .gitignore touch-ups (no SPM artifacts checked in)
**Paths:** `.gitignore` in both SDK repos.
Append:
```
# Swift Package Manager
.swiftpm/
.build/
Package.resolved
```

`Package.resolved` for **library** packages should be ignored (it's only meaningful in apps). The sample app's `Package.resolved` should be committed.

---

## Phase C — Release & integration

### C.1 `publish_script` updates

> **🔴 REVIEW FIX 3 — replace `sed` placeholder with template file.** A first-time `sed s/<sha256>/.../` works once; on the second release the placeholder is gone and `sed` silently no-ops, leaving the previous checksum in `Package.swift`. SPM consumers get `artifact has invalid checksum` errors. Use a `Package.swift.tmpl` file in each pod repo, regenerated on every publish.

Edit `publish_script/publish_core_api.sh` and `publish_script/publish_webview.sh`. New responsibilities after the existing `build_xcframework` + `copy_to_pod_repo` steps, before `git tag`:

1. **Preflight checks:**
   ```bash
   command -v gh >/dev/null || { echo "gh CLI required: brew install gh"; exit 1; }
   gh auth status >/dev/null 2>&1 || { echo "gh auth login required"; exit 1; }
   swift package --version >/dev/null || { echo "Swift 5.6+ required"; exit 1; }
   git diff-index --quiet HEAD -- || { echo "source repo has uncommitted changes"; exit 1; }
   ```
2. **Compute checksum:**
   ```bash
   cd "${POD_REPO_PATH}"
   zip -r "${SDK_NAME}.xcframework.zip" "${SDK_NAME}.xcframework"
   CHECKSUM=$(swift package compute-checksum "${SDK_NAME}.xcframework.zip")
   ```
3. **Render `Package.swift` from a template** (idempotent across releases):
   ```bash
   sed -e "s|@@VERSION@@|${version}|g" \
       -e "s|@@CHECKSUM@@|${CHECKSUM}|g" \
       "${POD_REPO_PATH}/Package.swift.tmpl" \
       > "${POD_REPO_PATH}/Package.swift"
   ```
   Each pod repo gets a `Package.swift.tmpl` checked in with `@@VERSION@@` and `@@CHECKSUM@@` markers. The generated `Package.swift` is committed alongside the zip.
4. **Create a GitHub Release** for tag `${version}` on the pod repo and upload `${SDK_NAME}.xcframework.zip` as a release asset:
   ```bash
   gh release create "${version}" "${SDK_NAME}.xcframework.zip" \
     --repo "nimbbl-tech/${POD_REPO_NAME}" \
     --notes "Binary release ${version}"
   ```
5. **Git tag on the source SDK repo too** (not just the pod repo). SPM source consumers resolve from the source repo URL, so it needs the same tag.
   ```bash
   cd "${SOURCE_REPO_PATH}"
   git diff-index --quiet HEAD -- || { echo "uncommitted changes in source repo"; exit 1; }
   git tag "${version}" && git push origin "${version}"
   ```

### C.2 Versioning policy

SPM resolves by git tag. Recommended: tag both repos with the same version on every release (`2.1.0`, `2.1.1`, …). Pre-release alpha tags like `2.1.0-alpha.1` work but force consumers to pin with `.exact(...)` rather than `from:`.

### C.3 Consumer announcement copy

> **Nimbbl iOS SDK now supports Swift Package Manager.** From 2.1.0 onward you can install `nimbbl_mobile_kit_ios_webview_sdk` via SPM with `https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git`. The Core API SDK is pulled transitively. Existing CocoaPods integrations continue to work unchanged. Do not install via both managers in the same app.

Add this to:
- Both SDK READMEs
- Both pod repo READMEs
- CHANGELOG.md (next version section)

---

## Phase D — Validation

Run from the SDK source repo:

```bash
# 1. Core API SDK builds as a Swift package (source mode)
cd /Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_core_api_sdk
swift package describe
swift build -Xswiftc -sdk -Xswiftc $(xcrun --sdk iphonesimulator --show-sdk-path) \
            -Xswiftc -target -Xswiftc arm64-apple-ios13.0-simulator

# Alternative (recommended) — use xcodebuild against the SwiftPM scheme:
xcodebuild -scheme nimbbl_mobile_kit_ios_core_api_sdk \
           -destination 'generic/platform=iOS Simulator' build

# 2. WebView SDK builds and resolves the Core API SDK dep
cd /Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_webview_sdk
swift package resolve         # confirm Core API SDK is fetched
swift package show-dependencies
xcodebuild -scheme nimbbl_mobile_kit_ios_webview_sdk \
           -destination 'generic/platform=iOS Simulator' build

# 3. Binary distribution (after running publish_script):
cd /Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_webview_pod
swift package resolve
xcodebuild -scheme nimbbl_mobile_kit_ios_webview_sdk \
           -destination 'generic/platform=iOS Simulator' build

# 4. Sample app — Xcode SPM resolution
cd /Users/sandeepyadav/Documents/GitHub/nimbbl_ios_sample_app
xcodebuild -workspace NimbblSampleApp.xcworkspace \
           -scheme NimbblSampleApp \
           -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Acceptance criteria:
- `swift build` succeeds for both source packages on iOS Simulator.
- `swift package show-dependencies` from the WebView SDK lists `nimbbl_mobile_kit_ios_core_api_sdk` as a transitive node.
- Sample app builds with SPM-resolved frameworks and runs an order/checkout flow.
- A clean CocoaPods install (`pod install` from the sample app) still works in parallel.
- An `@objc`-using Obj-C file in a test app can still `@import nimbbl_mobile_kit_ios_webview_sdk;` and call the same APIs (SPM-built Swift modules expose generated `-Swift.h` automatically; verify with a tiny Obj-C smoke target).

---

## ~~Open questions~~ — all resolved (see "Decisions locked" at the top)

All 7 questions answered. Implementation can start immediately following the revised order at the top of this document.
