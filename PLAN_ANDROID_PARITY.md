# iOS Sample App — Android Parity Plan

Bringing six Android features to the iOS sample app:

1. Environment switcher in Settings (full parity)
2. Access token + Core API v3 create-order path
3. IP-based URL fallback logic
4. Debug logs viewer + 7-tap unlock
5. UPI intent app selection (gpay / phonepe / paytm)
6. **EMI enforcement** — payment mode + 4 sub-options (all / debit / credit / cardless)

This document is plan-only. No code is changed until you approve.

---

## Current state of the iOS app (what already exists)

- `Views/Settings/SettingsViewController.swift` — environment switcher with Prod / Pre-Prod / QA, plus editable QA URL field. Persists to `UserDefaults` keys `selectedEnvironment` and `qaEnvironmentUrl`.
- `Supporting/SampleShopAPIUtils.swift` — **already has** IP-based fallback logic (`isIpBasedUrl`, `resolveShopBaseUrl`, `resolveShopOrderUrl`, `formatUrl`) that mirrors Android. Used only for the shop-order URL today.
- `ViewModels/Payment/PaymentManager.swift` — has UPI sub-options (collect / intent / collect+intent) but no UPI app picker after "intent".
- `Supporting/Config.swift` — defines `Environment`, `Experience` enums and `EnvironmentUrls` (prod, preProd, qa1).
- No access token field. No Core API v3 path. No debug logs viewer. No 7-tap unlock.

## Gap analysis vs Android

| Feature | Android | iOS today | Action |
|---|---|---|---|
| Environment switcher | `NimbblConfigActivity` with Prod/Pre-Prod/QA + editable QA URL, persisted under `app_configs_prefs` | Partial (Prod/Pre-Prod/QA + editable URL) | Align persistence key names + add SDK env propagation on Done |
| Access token | Field in Config under debug section; used for `/api/v3/create-order` Bearer auth | Missing | Add UI + persistence + plumbing |
| Core API v3 path | `createOrderV3Request()` when token present | Missing | New `OrderV3Client` |
| IP fallback | `resolveShopBaseUrl()` falls back to `BASE_URL_QA3` when configured URL is IP; raw IP still passed to SDK `setEnvironmentUrl` | Partial — only used for shop URL | Apply same split: SDK env URL = configured (incl. IP), shop-API base = QA fallback when IP |
| Debug logs viewer | `DebugLogsActivity` streams `logcat --pid=$pid`, search, pause/resume, copy, clear | Missing | New `DebugLogsViewController` using stderr/stdout pipe capture |
| 7-tap unlock | Tap header view 7× within 2s window; `debug_menu_unlocked` in prefs; reveals access-token field, SDK debug log toggle, and Debug Logs entry | Missing | Add same gesture on Settings header |
| UPI intent app | When Payment=UPI + Sub=Intent, show third dropdown of gpay/phonepe/paytm; codes `gpay`, `phonepeupi`, `paytmupi` | Missing | Add picker + propagate code into order request |
| EMI enforcement | Payment mode `emi` + sub-payment dropdown of `all emis` / `debit card emi` / `credit card emi` / `cardless emi`. Codes: `""` / `debit` / `credit` / `cardless`. Sample app calls `Options.Builder.setEMICode(...)`; SDK appends `&emi_code=` to WebView URL | Missing | Add EMI option to PaymentManager + new sub-options list + propagate `emiCode` into `NimbblCheckoutOptions` (requires SDK Part 2 step 1) |

---

## File-by-file change list

### 1. New files

| Path | Purpose |
|---|---|
| `NimbblSampleApp/Supporting/AppPreferenceKeys.swift` | Centralize UserDefaults keys to mirror Android `AppPreferenceKeys.kt` (`shop_base_url`, `qa_environment_url`, `access_token`, `debug_logs_enabled`, `debug_menu_unlocked`, `sample_app_mode`). Add `UserDefaults` extension accessors so the rest of the app reads typed properties. |
| `NimbblSampleApp/ViewModels/Payment/OrderV3Client.swift` | `URLSession`-based client for `POST {base}/api/v3/create-order` with `Authorization: Bearer <token>`. Mirrors Android `createOrderV3Request`. Payload shape per Android (currency, quantity, total_amount, invoice_id, optional user, order_line_items array). Returns `Result<String, Error>` where `.success` carries the order `token`. |
| `NimbblSampleApp/ViewModels/Payment/OrderCreator.swift` | Thin façade picking shop-proxy vs v3 path based on whether a non-empty access token is configured. Replaces the current direct shop call inside `PaymentManager`. Mirrors Android's branch inside `OrderCreateActivity.setListeners()`. |
| `NimbblSampleApp/Views/Debug/DebugLogsViewController.swift` | UIViewController with `UITextView` log surface + search bar + back/more menu (Pause/Resume, Clear, Copy, Search). Captures `stdout` + `stderr` via `dup2` to a `Pipe`, decodes lines off-main, appends to bounded buffer (200k chars like Android). |
| `NimbblSampleApp/Supporting/AppLogStream.swift` | Singleton that owns the stderr/stdout pipe + ring buffer + observer pattern. Created lazily once per process. Used by `DebugLogsViewController`. (Alternative path noted below in Risks if pipe redirection proves brittle in Release builds.) |
| `NimbblSampleApp/Views/Payment/UpiAppPickerBottomSheetViewController.swift` | Bottom-sheet picker for UPI apps. Mirrors the existing `SubPaymentOptionsBottomSheetViewController` structure. |

### 2. Edited files

#### `Supporting/Config.swift`
- Add `Environment.qa` (single `"QA"` value, matching Android) and deprecate `qa1` / `qa2`. Keep them as aliases for back-compat but stop showing them in the picker.
- Add `UserDefaults` accessors: `shopBaseUrl`, `qaEnvironmentUrl`, `accessToken`, `debugLogsEnabled`, `debugMenuUnlocked`, `sampleAppMode`. (Or move these into the new `AppPreferenceKeys.swift`.)
- Add `EnvironmentUrls.qa3 = "https://qa3api.qa.nimbbl.tech/"` to align with Android's `BASE_URL_QA3` default for the QA option.

#### `Supporting/AppConstants.swift`
- Add text constants: `accessTokenTitle`, `accessTokenPlaceholder`, `sdkDebugLogsLabel`, `viewDebugLogs`, `debugOptionsUnlocked`, `upiAppTitle`, plus UPI app names (`upiAppGpay`, `upiAppPhonepe`, `upiAppPaytm`).

#### `Supporting/SampleShopAPIUtils.swift`
- Expose two distinct resolvers so callers can ask either:
  - `resolveSdkEnvironmentUrl(configured:)` — returns configured URL formatted; **does not** rewrite IP. (Mirrors Android `sdkEnvUrl` branch.)
  - `resolveShopBaseUrl(configured:)` — existing IP→QA3 fallback. Already correct, just bump default to `qa3api.qa.nimbbl.tech` to match Android.
- Add `resolveCoreApiV3Url(configured:)` returning `{base}/api/v3/create-order` — uses configured base verbatim (same as Android), not the shop-host rewrite.

#### `Views/Settings/SettingsViewController.swift`
- Add hidden "Debug" section (UIStackView) containing: `accessTokenTextField` + clear button, `sdkDebugLogsSwitch`, "View Debug Logs" row → pushes `DebugLogsViewController`. Section's `isHidden` driven by `UserDefaults.debugMenuUnlocked`.
- Add `UITapGestureRecognizer` on `headerView`: count taps, reset if >2s since last, on 7th tap set `debugMenuUnlocked = true`, unhide section, toast "Debug options unlocked".
- On Done: persist `shopBaseUrl` (resolved from environment selection), `qaEnvironmentUrl` (raw input), `accessToken` (trimmed), `debugLogsEnabled`, `sampleAppMode`. Then call `NimbblCheckoutSDK.shared.setEnvironmentUrl(...)`. Mirrors Android `savePreferences()`.
- Collapse `qa1`/`qa2` picker entries into a single `QA`.

#### `Views/ViewController.swift`
- Replace the existing shop-only order creation call with `OrderCreator.createOrder(...)`. Continue calling `NimbblCheckoutSDK.shared.checkout(...)` afterwards.
- Before checkout, set SDK env URL using `SampleShopAPIUtils.resolveSdkEnvironmentUrl(configured:)` (NOT the shop URL). This is the iOS equivalent of Android's `sdkEnvUrl` branch — preserves raw IP for WebView checkout while still using QA3 for sample-app API calls.
- Wire the SDK debug-log flag: `NimbblCheckoutSDK.shared.setDebugLoggingEnabled(UserDefaults.standard.debugLogsEnabled)` if such a setter exists in the iOS SDK (need to confirm — see Open Questions).
- Add UPI-app picker triggering: when the user selects Payment=UPI and Sub=Intent, reveal a new "UPI app" button (similar to `subPaymentButton`); tapping opens `UpiAppPickerBottomSheetViewController`.

#### `ViewModels/Payment/PaymentManager.swift`
- Add:
  ```swift
  var upiIntentAppOptions: [SubPaymentOption] = [
      SubPaymentOption(imageName: "gpayImg",    name: "Google Pay", code: "gpay"),
      SubPaymentOption(imageName: "phonepeImg", name: "PhonePe",    code: "phonepeupi"),
      SubPaymentOption(imageName: "paytmImg",   name: "Paytm",      code: "paytmupi"),
  ]
  var selectedUpiApp: SubPaymentOption?

  // EMI: appended to paymentOptions
  // PaymentOption(icon: UIImage(systemName: "calendar"), name: "emi", code: "emi")
  var emiSubOptions: [SubPaymentOption] = [
      SubPaymentOption(imageName: "menuImg",  name: "all emis",         code: ""),
      SubPaymentOption(imageName: "menuImg",  name: "debit card emi",   code: "debit"),
      SubPaymentOption(imageName: "menuImg",  name: "credit card emi",  code: "credit"),
      SubPaymentOption(imageName: "menuImg",  name: "cardless emi",     code: "cardless"),
  ]
  var selectedEmiOption: SubPaymentOption?
  ```
- Add `shouldShowUpiAppPicker(payment: PaymentOption, sub: SubPaymentOption?) -> Bool` returning true when payment.code == "upi" and sub.code == "intent".
- Extend `getSubPaymentOptions(for:)` and `shouldShowSubPaymentOptions(for:)` to include `"emi"` → `emiSubOptions`.
- When building the create-order request, if `selectedUpiApp != nil`, include its `code` as `sub_payment_mode` (overriding the generic "intent" code) — same as Android's `getBankCode` branching collapses UPI app to a payment code.
- For EMI, do **not** put the EMI sub-code into `sub_payment_mode`; instead it must be passed as `emiCode` on `NimbblCheckoutOptions` (the SDK then appends `&emi_code=` to the WebView URL). The shop/v3 request's `sub_payment_mode` stays empty for EMI (matches Android: `getBankCode("all emis")` returns "" because that name isn't in the bank map).

### 3. Assets
- Add three UPI-app icons to `Assets.xcassets`: `gpayImg`, `phonepeImg`, `paytmImg`. If you already have the PNGs in the Android `res/drawable` folder we can reuse them; otherwise placeholders + filenames matching the new code paths.

---

## Behavior details (matching Android precisely)

### Order creation branch logic
```
let token = UserDefaults.standard.accessToken.trimmed
let configuredBase = UserDefaults.standard.shopBaseUrl

NimbblCheckoutSDK.shared.setDebugLoggingEnabled(UserDefaults.standard.debugLogsEnabled)
NimbblCheckoutSDK.shared.setEnvironmentUrl(
    SampleShopAPIUtils.resolveSdkEnvironmentUrl(configured: configuredBase)
)

if token.isEmpty {
    // existing shop-proxy path
    let shopUrl = SampleShopAPIUtils.getShopUrl(environmentUrl: configuredBase)
    ShopOrderClient.create(...)
} else {
    // new v3 path
    let apiBase = SampleShopAPIUtils.resolveShopBaseUrl(configured: configuredBase) // IP → QA3
    OrderV3Client.create(apiBase: apiBase, token: token, ...)
}
```

### v3 payload (Android-aligned, omitting commented-out sections)
```json
{
  "currency": "INR",
  "quantity": 1,
  "amount_before_tax": <amount>,
  "tax": 0,
  "total_amount": <amount>,
  "invoice_id": "inv_<epoch_ms>",
  "user": {                       // omitted if mobile blank
    "email": "...",
    "first_name": "...",
    "last_name": "",
    "country_code": "+91",
    "mobile_number": "..."
  },
  "order_line_items": [{
    "sku_id": "<productId or item_<invoice_id>>",
    "title": "Product",
    "description": "Product description",
    "rate": <amount>,
    "quantity": 1,
    "amount_before_tax": <amount>,
    "tax": 0,
    "total_amount": <amount>,
    "image_url": "",
    "uom": "unit"
  }]
}
```
Headers: `Content-Type: application/json; charset=utf-8`, `Accept: application/json`, `Authorization: Bearer <token>`. 30s timeout. On 2xx, parse `token` from response and pass to `NimbblCheckoutSDK.shared.checkout(...)`.

### EMI enforcement — exact mapping from Android

Android's `getPaymentModeCode` returns `"emi"` for the top-level EMI option, and `getEMICode(...)` maps the four sub-options:

| Display name (Android) | Display name (iOS) | EMI code |
|---|---|---|
| all emis | all emis | `""` (empty — let backend pick) |
| debit card emi | debit card emi | `debit` |
| credit card emi | credit card emi | `credit` |
| cardless emi | cardless emi | `cardless` |

How it flows through the system:

1. User selects payment mode `emi` from the top-level payment dropdown.
2. The sub-payment dropdown populates with the 4 EMI options.
3. User picks one (e.g. "credit card emi").
4. On "Pay Now", the sample app calls:
   ```swift
   let options = NimbblCheckoutOptions(
       orderToken: token,
       paymentModeCode: "emi",        // top-level
       bankCode: nil,                  // EMI doesn't use bankCode
       walletCode: nil,
       paymentFlow: nil,
       upiAppCode: nil,
       emiCode: "credit"               // sub-level
   )
   NimbblCheckoutSDK.shared.checkout(from: self, options: options)
   ```
5. The SDK's `PaymentURLBuilder` (per Part 2) appends `&payment_mode=emi&emi_code=credit` to the WebView URL.

**Sample-app side requires the SDK's `NimbblCheckoutOptions` to have an `emiCode` field** — covered in Part 2, gap **A** (the 10 missing fields). Until that SDK change ships, this feature can be stubbed by passing the EMI code through the **shop / v3 create-order** request body as `sub_payment_mode: "emi:<code>"` (just for the sample app's order-creation API, not for checkout). Recommend doing Part 2 step 1 first so the proper plumbing is available.

### 7-tap unlock
```swift
private var tapCount = 0
private var lastTap: TimeInterval = 0
@objc func headerTapped() {
    let now = Date().timeIntervalSince1970
    if now - lastTap > 2.0 { tapCount = 0 }
    lastTap = now
    tapCount += 1
    if tapCount >= 7 && !UserDefaults.standard.debugMenuUnlocked {
        UserDefaults.standard.debugMenuUnlocked = true
        debugSection.isHidden = false
        showToast("Debug options unlocked")
    }
}
```

### Debug Logs viewer — implementation choice
iOS has no logcat equivalent, so two viable approaches:

- **A. stdout/stderr pipe capture** (mirrors Android most closely)
  - On first access, `AppLogStream` creates a `Pipe`, calls `dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))` and same for `stderr`. Sets `pipe.fileHandleForReading.readabilityHandler` to decode UTF-8 lines and push into a `[String]` ring buffer + notify observers via `NotificationCenter`.
  - Pros: catches `print`, `NSLog`, `fputs` to stderr, and most third-party SDK output. Pause/Resume just adds/removes the observer. Clear empties the buffer.
  - Cons: doesn't capture `os_log` (Apple's unified logging) which goes to a different subsystem. Also keeps the redirect permanently — printing in release becomes invisible to Xcode console once redirected. Mitigate by also `write`-ing back to the original fd via a tee.

- **B. App-side `Logger` wrapper**
  - Replace `print` with `AppLog.d(...)` everywhere; viewer reads the same in-memory buffer. Doesn't capture SDK output unless the SDK exposes a logging hook.
  - Pros: clean, predictable. Cons: misses third-party SDK logs.

Recommend **A** for parity, with the tee to keep Xcode console working in debug. Pause means "stop appending to the buffer" rather than tearing down the pipe.

UI: `UITextView`, mono font, search bar with prev/next, "More" menu with Pause/Resume / Clear / Copy. Bounded to 200k chars, drops oldest half on overflow. Auto-scroll to bottom unless user scrolled up.

Entry point: hidden "View Debug Logs" row in Settings (only visible after 7-tap unlock).

---

## Suggested implementation order

1. **Foundation (no UI yet)** — `AppPreferenceKeys.swift`, `UserDefaults` accessors, update `Config.swift` env enum to single `QA`, update `SampleShopAPIUtils` with `resolveSdkEnvironmentUrl` + `resolveCoreApiV3Url`. Migrate existing readers.
2. **Settings UI parity** — collapse QA picker, add hidden debug section + 7-tap unlock + access-token field. Wire Done to persist new keys and call `setEnvironmentUrl`.
3. **Order creation branching** — extract current shop call into `ShopOrderClient`, add `OrderV3Client`, add `OrderCreator` façade, swap call site in `ViewController`.
4. **UPI intent app picker + EMI enforcement** — add lists (`upiIntentAppOptions`, `emiSubOptions`) to `PaymentManager`, extend payment-mode array with "emi", wire sub-payment dropdown to surface EMI options when "emi" is selected, propagate UPI app `code` into the request `sub_payment_mode`, and propagate EMI `code` into `NimbblCheckoutOptions.emiCode` (requires SDK Part 2 step 1 to ship first, or use the stub fallback documented in the EMI behavior section).
5. **Debug logs viewer** — `AppLogStream` + `DebugLogsViewController`. Wire from Settings debug section.

Each step lands as a self-contained commit so you can test incrementally.

---

## Open questions / things to confirm before coding

1. **iOS SDK debug-logging API.** Android does `NimbblCheckoutSDK.getInstance().setDebugLoggingEnabled(...)`. Is there an equivalent on `nimbbl_mobile_kit_ios_webview_sdk`? If not, we can still capture stdout/stderr but the SDK's internal logs may not surface unless it routes through `print/NSLog`.
2. **UPI app icons.** Do you want me to reuse the Android `drawable` PNGs (I'd need their filenames), generate placeholder icons, or use SF Symbols (no brand color)?
3. **`Experience` enum**: Android stores `sample_app_mode` but only `Webview` is wired end-to-end. Should iOS keep `Native` as a selectable option even though no native-flow code exists yet? (Keeping for parity is fine.)
4. **Backward-compat keys.** Android reads a legacy `order_token` key as a fallback for `access_token`. iOS has no such legacy — okay to skip?
5. **Log capture in release builds.** Are debug logs intended to be usable on TestFlight/release builds, or DEBUG-only? Android limits to debuggable builds; we can do the same with `#if DEBUG`.

---

## Risks

- **stdout redirection** can interact poorly with crash reporters or third-party SDKs that read their own pipes. Mitigate with a tee back to original fd and guard behind `#if DEBUG` if needed.
- **Core API v3** error-shape parsing on Android handles a nested `error.nimbbl_consumer_message` — easy to miss on iOS. Will reproduce the exact same nesting logic.
- **QA URL collapse** (`qa1`/`qa2` → `QA`) is a small migration: code reading the old `selectedEnvironment` values needs to map them to `QA` on first launch. Handled by a one-shot migration in `AppDelegate.didFinishLaunching`.
- **SDK env URL** must always be set before `checkout` — currently iOS sets it only when Settings is dismissed. We'll also set it inline before each checkout call to match Android's safety net.

---

## Estimated effort

Roughly 1.5–2 days for an experienced iOS dev, broken down as:

- Steps 1 + 2 (Settings parity + access token): ~3 hrs
- Step 3 (v3 client + branching): ~3 hrs
- Step 4 (UPI intent picker): ~2 hrs
- Step 5 (debug logs viewer): ~4 hrs
- Testing / wiring / asset work: ~2 hrs

Let me know which open questions to resolve first and I'll start implementation in the suggested order.

---
---

# Part 2 — iOS WebView SDK parity with Android WebView SDK

**Repo:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_webview_sdk`

## Current size comparison

| | iOS WebView SDK | Android WebView SDK |
|---|---|---|
| Source files | 5 Swift files | 15 Kotlin files (+ resources, layouts) |
| `NimbblCheckoutSDK` | ~430 lines | ~600 lines |
| WebView host | 1 controller (1682 lines) | `MainActivity` + `WebViewManager` + `PaymentHandler` + `UPIManager` |
| Options model | Re-exported from Core API SDK | Owned by WebView SDK (Parcelable) |
| Utilities | None separate | `SDKUtils`, `ValidationUtils`, `PaymentURLBuilder`, `WebViewManager`, `UPIManager`, `PaymentHandler`, `LogUtil`, `RestApiUtils` |
| Constants | None | `PaymentConstants` (large) |
| Logging API | `LogUtil.isDebugEnabled` static var | `setDebugLoggingEnabled(Boolean?)` public API |

## Files surveyed

`NimbblCheckoutSDK.swift`, `NimbblCheckoutWebView.swift`, `LogUtil.swift`, `SDKVersion.swift`, `NimbblShimmerView.swift`, and the Core API SDK's `NimbblCheckoutOptions.swift`.

---

## Gap analysis (SDK only — not sample app)

### A. `NimbblCheckoutOptions` model (lives in Core API SDK, re-exported)

iOS today exposes only 5 fields:
```swift
orderToken, paymentModeCode, bankCode, walletCode, paymentFlow
```

Android exposes 15:
```
packageName, amount, currency, name, description, image,
userInfo (NimbblCheckoutUserInfo), subMerchantId, orderToken,
paymentModeCode, bankCode, walletCode, paymentFlow,
upiAppCode, emiCode
```

**Action:** add the 10 missing fields to `nimbbl_mobile_kit_ios_core_api_sdk/NimbblCheckoutOptions.swift`. Keep them all `Optional` and provide a default-arg initializer so existing call sites compile unchanged. Add a new `NimbblCheckoutUserInfo` struct (`displayName`, `email`) in the same module.

### B. `setEnvironmentUrl` — missing IP fallback

Android `NimbblCheckoutSDK.setEnvironmentUrl`:
1. Trims input.
2. If IP-based (`https?://\d+\.\d+\.\d+\.\d+(:\d+)?/?.*`), uses `https://qa3api.qa.nimbbl.tech/` as the **API base** but keeps the raw IP for the **WebView base**.
3. Sets `RestApiUtils.NIMBBL_TECH_URL`, `WEB_VIEW_VIEW_URL`, `WEB_VIEW_RESP_CHECK_URL`.
4. Validates non-empty, fires `API_URL_001` error otherwise.

iOS `setEnvironmentUrl` today is one line: `APIUtils.nimbblTechUrl = apiUrl`. No validation, no IP fallback, no WebView URL recomputation.

**Action:** rewrite `setEnvironmentUrl` to mirror Android: empty check + `API_URL_001` error to delegate, IP detection regex, dual base URL handling. Need to confirm what setters exist on iOS `APIUtils` (likely needs new `webViewBaseUrl` / `webViewRespBaseUrl` fields if those aren't computed lazily).

### C. `setDebugLoggingEnabled(_:)` — missing public API

Android exposes `fun setDebugLoggingEnabled(enabled: Boolean?)` on the SDK class, delegating to `SDKUtils.setDebugLoggingEnabled(...)`. `null` means "fall back to `BuildConfig.DEBUG`". The flag is read in `WebViewManager` to enable Chrome DevTools remote inspection.

iOS has `LogUtil.isDebugEnabled: Bool` as a public **static var**, but no method on `NimbblCheckoutSDK`. The sample app can't toggle it through the SDK public surface.

**Action:** add `@objc public func setDebugLoggingEnabled(_ enabled: NSNumber?)` (NSNumber so we can express the `nil` = "auto" case in ObjC interop), wire to `LogUtil.isDebugEnabled`. Also enable `WKWebView.isInspectable = true` (iOS 16.4+) when the flag is on — this is the iOS equivalent of Android's Chrome DevTools remote inspection.

### D. URL building — inline in WebView controller

Android has a dedicated `PaymentURLBuilder` utility with:
- `buildPaymentURL(baseUrl, options)` — validates URL + appends 6 params (`payment_mode`, `bank_code`, `wallet_code`, `payment_flow`, `upi_app_code`, `emi_code`).
- `buildBrowserBackURL(context, baseUrl, currentUrl, ...)` — preserves existing query params + adds `browserBack=true`.

iOS does this inline at line 597 of `NimbblCheckoutWebView.swift` (`buildCheckoutUrl()`) and only appends 4 params: `payment_mode`, `bank_code`, `wallet_code`, `payment_flow`. **Missing:** `upi_app_code`, `emi_code`. There's also an inline `buildBrowserBackURL` somewhere in that 1682-line file.

**Action:** create new file `PaymentURLBuilder.swift` in the iOS WebView SDK module. Move both functions out of the controller. Add the two missing params. Add input URL validation.

### E. Validation prerequisites — missing utility

Android `ValidationUtils.validateCheckoutPrerequisites(context, listener, options)` returns a tagged `ValidationResult` enum with error codes:
- `CHECKOUT_001` reference null
- `CHECKOUT_002` listener null
- `CHECKOUT_003` options null
- `CHECKOUT_004` orderToken null
- `CHECKOUT_005` orderId null (from JWT)
- `CHECKOUT_006` subMerchantId null (from JWT)
- `API_URL_001` API URL null
- `INIT_001` init failed
- `UNKNOWN_001` generic

iOS has only one ad-hoc check (`guard let orderToken = options.orderToken else { ... return }`) and no error-code system.

**Action:** create `ValidationUtils.swift` + a `NimbblError` enum with the 9 error codes. Each error has `code`, `message`, `nimbblErrorCode` to match Android. Update `checkout(from:options:)` to call validation up front and forward the typed error to `delegate.onCheckoutResponse(data:)` in the same shape Android's `SDKUtils.createErrorResponse(...)` produces.

### F. `PaymentConstants` — missing

Android has a `PaymentConstants` Kotlin object with ~150 named constants: error codes/messages, broadcast actions, URL param names (`payment_mode`, `bank_code`, etc.), JSON keys, log tags, event keys, log message templates.

iOS scatters string literals throughout `NimbblCheckoutSDK.swift` and `NimbblCheckoutWebView.swift`.

**Action:** create `PaymentConstants.swift` mirroring at minimum:
- All error codes + `nimbbl_error_code` mapping
- URL parameter names
- JSON keys for payment response parsing
- Log tags
- Event keys (already partly in `EventConstants` from Core API SDK — don't duplicate)

### G. SDK lifecycle — no `cleanup()`

Android has `cleanup()` and `isCleanedUp()` that:
- Unregisters broadcast receiver.
- Clears activity weak ref, listener, context, receiver.
- Logs cleanup-failed event.

iOS holds `currentProxy`, `currentWebViewController`, and `delegate` as properties of the singleton — these are never explicitly cleared after a checkout completes. The proxy stays alive until the next `checkout()` call.

**Action:** add `@objc public func cleanup()` to `NimbblCheckoutSDK`. Clear `currentProxy = nil`, `currentWebViewController = nil`, `delegate = nil`, remove notification observers. Add `isCleanedUp()` getter. Document that the host app should call `cleanup()` when done.

### H. JWT order-id parsing bug

`NimbblCheckoutSDK.getOrderID(from:)` only adds `=` padding — does **not** translate URL-safe base64 (`-` → `+`, `_` → `/`). `getSubMerchantID(from:)` does it correctly. JWTs use URL-safe base64, so any token containing `-` or `_` in the payload segment will fail to decode and silently return empty string from `getOrderID`.

**Action:** fix `getOrderID` to use the same translation as `getSubMerchantID`. Extract both into a shared `JWTUtils` helper to prevent the inconsistency from coming back.

### I. UPI handling — partial parity

Android `UPIManager`:
- `createUPIAppsJSON()` — builds JSON from `queryIntentActivities` (Android-specific).
- `validateUPIParameters(parameters, orderId, token, subMerchantId)` — validates JS payload has `url`, `package_name`, `transaction_id`.

iOS:
- `NimbblUPIAppDetector.getUPIAppsList(token:)` (lives in Core API SDK) does the apps-list build — equivalent of Android's `createUPIAppsJSON`. **OK.**
- No JS payload validation when the WebView posts UPI parameters back. Risk: malformed payloads crash the launcher.

**Action:** add `validateUPIParameters(_:orderId:token:subMerchantId:) -> Bool` in a new `UPIManager.swift`, called from the JS message handler in `NimbblCheckoutWebView`.

### J. Init parity

Android `init(activity, appCode = null)`:
- Stores activity, listener (cast from activity).
- Initializes broadcast receiver (zeroed `isReceiverRegistered`).
- Validates `deviceFingerPrint` and `deviceID` — both non-empty required, else `INIT_001` error.
- Calls `NimbblCoreApiSDK.initialiseAPISDK(...)`.
- Logs `SDK_INITIALIZED` event.

iOS `initialize(appCode:)`:
- Stores `appCode`.
- Sets `EventLoggingService.setAppCode(...)`.
- Logs `SDK_INITIALIZED` event.
- **No device fingerprint / ID validation. No Core API SDK init call.**

The iOS Core API SDK might auto-init lazily, so this may be intentional. Need confirmation. If not, add equivalent device-id validation and explicit Core API init invocation.

### K. WebView host architecture

The 1682-line `NimbblCheckoutWebView.swift` mixes:
- WebView setup
- URL building
- Back navigation
- Loading state UI
- Error UI
- JS message handling
- UPI app launching
- Payment result parsing
- Browser back URL building

Android splits these across `NimbblCheckoutMainActivity`, `WebViewManager`, `PaymentHandler`, `UPIManager`, `PaymentURLBuilder`.

**Action (optional / phase 2):** refactor by extracting `WebViewManager.swift`, `PaymentHandler.swift`, `UPIManager.swift`, `PaymentURLBuilder.swift` (already proposed in D). Leave the controller as a thin orchestrator. This is a larger refactor and could be deferred — call out as a separate work stream.

---

## Proposed new SDK files

```
nimbbl_mobile_kit_ios_webview_sdk/
├── Constants/
│   └── PaymentConstants.swift          (new)
├── Models/
│   ├── NimbblError.swift               (new — error code enum)
│   └── ValidationResult.swift          (new)
├── Utils/
│   ├── ValidationUtils.swift           (new)
│   ├── PaymentURLBuilder.swift         (new — moves logic out of WebView controller)
│   ├── UPIManager.swift                (new — validateUPIParameters)
│   ├── JWTUtils.swift                  (new — shared JWT decode, fixes bug H)
│   └── SDKUtils.swift                  (new — createErrorResponse, helpers)
├── NimbblCheckoutSDK.swift             (edit — see below)
├── NimbblCheckoutWebView.swift         (edit — see below)
├── LogUtil.swift                       (edit — add public set method)
└── (existing files…)
```

And in the Core API SDK:

```
nimbbl_mobile_kit_ios_core_api_sdk/
├── NimbblCheckoutOptions.swift         (edit — add 10 missing fields)
└── NimbblCheckoutUserInfo.swift        (new)
```

---

## Edit list per file

### `nimbbl_mobile_kit_ios_core_api_sdk/NimbblCheckoutOptions.swift`
- Add fields: `packageName`, `amount: Int`, `currency`, `name`, `description`, `image`, `userInfo: NimbblCheckoutUserInfo?`, `subMerchantId`, `upiAppCode`, `emiCode`.
- Keep all new fields `Optional` with default `nil` in initializer so the existing 5-arg call site still compiles.
- Add a `Builder` pattern equivalent or expose static factory methods so callers can opt into the long form.

### `nimbbl_mobile_kit_ios_core_api_sdk/NimbblCheckoutUserInfo.swift` (new)
```swift
public struct NimbblCheckoutUserInfo: Codable {
    public var displayName: String?
    public var email: String?
    public init(displayName: String? = nil, email: String? = nil) { ... }
}
```

### `LogUtil.swift`
- Add:
  ```swift
  public static func setDebugLoggingEnabled(_ enabled: Bool?) {
      if let enabled { isDebugEnabled = enabled } else {
          #if DEBUG
          isDebugEnabled = true
          #else
          isDebugEnabled = false
          #endif
      }
  }
  ```
- Add `logEvent(...)` helper that bridges to `EventLoggingUtils.safeLogEvent` to match Android's `SDKUtils.logEventWithVersion`.

### `NimbblCheckoutSDK.swift` (existing — edits)
- Add `@objc public func setDebugLoggingEnabled(_ enabled: NSNumber?)` — forwards to `LogUtil.setDebugLoggingEnabled`.
- Rewrite `setEnvironmentUrl(_:)` per gap **B** (IP fallback, dual URLs, error code).
- Replace inline `guard let orderToken` with `ValidationUtils.validateCheckoutPrerequisites(...)` flow + typed `NimbblError` → delegate response.
- Fix `getOrderID(from:)` per gap **H**.
- Add `@objc public func cleanup()` per gap **G**.
- Use `PaymentConstants.errorCode*` everywhere instead of inline literals.

### `NimbblCheckoutWebView.swift` (existing — edits)
- Replace inline `buildCheckoutUrl()` with `PaymentURLBuilder.buildPaymentURL(baseUrl:options:)`. Add `upi_app_code` and `emi_code` params.
- Replace inline browser-back URL building with `PaymentURLBuilder.buildBrowserBackURL(...)`.
- Replace inline UPI parameter validation in JS message handler with `UPIManager.validateUPIParameters(...)`.
- When `LogUtil.isDebugEnabled == true` and iOS ≥ 16.4, set `webView.isInspectable = true`.

### `PaymentURLBuilder.swift` (new)
Mirrors Android implementation. Functions:
- `buildPaymentURL(baseUrl: String, options: NimbblCheckoutOptions) throws -> String`
- `buildBrowserBackURL(baseUrl:String, currentUrl:String, orderID:String, orderToken:String?, subMerchantId:String) -> String`
- Throws `NimbblError.invalidUrl` instead of `IllegalArgumentException`.

### `ValidationUtils.swift` (new)
```swift
public enum ValidationResult {
    case success
    case error(NimbblError)
}
public enum ValidationUtils {
    static func validateCheckoutPrerequisites(delegate:..., options:...) -> ValidationResult
    static func validateOrderId(_ orderId: String) -> ValidationResult
    static func validateSubMerchantId(_ subMerchantId: String) -> ValidationResult
}
```

### `NimbblError.swift` (new)
```swift
public enum NimbblError: Error {
    case initFailed
    case unknown
    case apiUrlNull
    case checkoutReferenceNull
    case checkoutListenerNull
    case checkoutOptionsNull
    case checkoutTokenNull
    case checkoutOrderIdNull
    case checkoutSubMerchantIdNull

    public var code: String      // INIT_001, CHECKOUT_001, etc.
    public var message: String   // matches Android ERROR_MESSAGE_*
    public var nimbblErrorCode: String  // MERCHANT_SDK_*
    public func asDelegatePayload() -> [AnyHashable: Any]
}
```

### `PaymentConstants.swift` (new)
Mirror the Android constants that the iOS code actually needs:
- Error codes + messages + `nimbbl_error_code`s
- URL param names (`payment_mode`, `bank_code`, `wallet_code`, `payment_flow`, `upi_app_code`, `emi_code`, `browserBack`, `response`)
- JSON keys (`payload`, `error`, `nimbbl_merchant_message`, `nimbbl_error_code`, `nimbbl_consumer_message`, `error_reason`, `callback_url`)
- Log tags
- Event keys / values
- JavaScript interface name (`NimbblSDK`)

---

## Backward compatibility risks

1. **`NimbblCheckoutOptions` field additions** — additive only, all `Optional`, no breaking change for existing call sites. But the **type lives in Core API SDK**, so bumping that SDK requires a coordinated release.
2. **`setEnvironmentUrl` validation** — existing callers passing empty strings will now receive an `API_URL_001` error in delegate callback rather than silently succeeding. Document in `CHANGELOG.md`. Consider feature-flagging via a new `setEnvironmentUrlStrict(_:)` if you don't want behavior change.
3. **`cleanup()` is new and additive.** Not breaking.
4. **`NimbblError` payload shape** — needs to match Android's `SDKUtils.createErrorResponse` exactly so cross-platform merchant code can rely on the same keys. Will document the JSON shape in `INTEGRATION_GUIDE.md`.

---

## Suggested order (SDK)

1. **Add `NimbblCheckoutUserInfo` + extend `NimbblCheckoutOptions`** in Core API SDK. Release a `2.0.18-alpha` pod build for testing.
2. **Add `LogUtil.setDebugLoggingEnabled` + SDK forwarder.** Easy win, no risk.
3. **Fix `getOrderID` JWT bug + extract `JWTUtils`.** Standalone correctness fix.
4. **Create `PaymentConstants`, `NimbblError`, `ValidationUtils`.** Pure additions.
5. **Rewrite `setEnvironmentUrl` with IP fallback + validation.** Behavior change — coordinate with sample-app changes from Part 1 (since the sample app is now passing IP through).
6. **Extract `PaymentURLBuilder`.** Move 2 functions out of WebView controller; add `upi_app_code` + `emi_code` params.
7. **Add `UPIManager.validateUPIParameters` and wire from JS message handler.**
8. **Add `cleanup()` + integrate into delegate proxy's `dismiss` flow.**
9. **(Optional / phase 2) Extract `WebViewManager` and `PaymentHandler`** to slim down the 1682-line controller. Pure refactor, low priority unless the file becomes a maintenance burden.

Each of steps 2–8 lands as a self-contained commit. Step 1 needs a Core API SDK release; everything else is internal to the WebView SDK.

---

## Open questions (SDK)

1. **`APIUtils` on iOS** — does it auto-derive WebView URLs from `nimbblTechUrl`, or do they need separate setters like Android's `WEB_VIEW_VIEW_URL` / `WEB_VIEW_RESP_CHECK_URL`? Need a quick look at `nimbbl_mobile_kit_ios_core_api_sdk/APIUtils.swift`.
2. **`NimbblUPIAppDetector` lives in Core API SDK** — is its behavior already at parity with Android `UPIManager.createUPIAppsJSON()`, or are there response-shape differences?
3. **Device fingerprint / device-id validation** at SDK init — is iOS Core API SDK doing this internally already? If yes, skip gap **J**.
4. **Pod release cadence.** Both SDKs are published as separate pods. Are you okay with the Core API SDK bump being a prerequisite for the WebView SDK changes, or do you want the WebView SDK to ship without options-model changes (which would mean the iOS sample app can't pass `upiAppCode` until both pods are out)?
5. **`@objc` interop** — is any host app integrating from Objective-C? If yes, all new public APIs need `@objc` annotations and the `NimbblError` enum needs a parallel `@objc` `NSError`-style representation.

---

## Combined effort estimate (Parts 1 + 2)

- **Part 1 (sample app):** ~1.5–2 days as previously stated.
- **Part 2 (SDK):** ~3–4 days for steps 1–8. Add ~1 day if the optional WebView controller refactor (step 9) is in scope. Plus 0.5 day for pod release + sample-app re-integration testing.

Total: **~5–6 days** for end-to-end parity, ~7 days with the optional refactor.

I recommend doing Part 2 steps 1–4 first (additive, low risk, fast), then Part 1 in parallel with Part 2 steps 5–8 (sample app can validate the new SDK behavior incrementally).

---
---

# Part 3 — iOS Core API SDK parity with Android Core API SDK

**Repo:** `/Users/sandeepyadav/Documents/GitHub/nimbbl_mobile_kit_ios_core_api_sdk`

## Headline numbers

| | iOS Core API SDK | Android Core API SDK |
|---|---|---|
| Source files | 22 Swift files (~2.8k LOC) | ~60 Kotlin files |
| Public API methods | ~6 on `NimbblCoreApiSDK` (callback-based) | ~16 on `NimbblRepository` (suspend) |
| Data models | ~7 response models | ~30 models across order/payment/user/common subfolders |
| Architecture | Direct methods on singleton | Repository pattern + WebService + Repository Impl |
| Constants | 2 files (`APIConstants`, `EventConstants`, `NetworkConstants`) | 5 files (`Constants`, `EventConstants`, `PayloadKeys`, `PreferenceKeys`, `ServiceConstants`) |
| Extensions | None separate | 2 files of JWT, network, md5, device-id helpers |
| Native-checkout interface | None | `INimbblCheckoutBaseSDKInterface` for native UI module |

## What iOS Core API SDK has today

`LogUtil`, `LoggingConfig`, `DataMasker`, `EventLoggingService`, `EventLoggingUtils`, `ApiLoggingUtils`, `APIUtils`, `APIConstants`, `NetworkConstants`, `NetworkHelper`, `NimbblCheckoutOptions` (5 fields), `NimbblErrorResponse`, `NimbblUPIAppDetector`, `UPIAppsVO`, `UPIAppDetailsResponse`, `OrderResponse`, `CheckoutDetailResponse`, `TransactionEnquiryResponse`, `EventConstants`, `SDKVersion`, `Utils`, `NimbblCoreApiSDK` (singleton with ~6 callback-based methods).

## What's missing vs Android (categorized gap)

### 3A. Architecture — Repository pattern
Android exposes a `NimbblRepository` **interface** with implementation that lets host code mock / swap the data layer. iOS scatters HTTP calls directly inside `NimbblCoreApiSDK` methods.

**Cost to port:** ~1 day. Creates `NimbblRepository.swift` protocol and `NimbblRepositoryImpl.swift`. Could be a behind-the-scenes refactor — existing public callback-based methods stay intact and delegate to the new repo.

### 3B. Missing public API methods (13 of 16)
Android's `NimbblRepository` exposes:
- ✅ `updateCheckOutCancelReason` — **iOS has this**
- ✅ `updateOrderDetails` — **iOS has this**
- ✅ `getTransactionEnquiry` — **iOS has this**
- ❌ `getCheckOutResource(url, token, xNimbblKey)` → `CheckoutResourceVo`
- ❌ `getListOfBanks(url, token, xNimbblKey, orderId)` → `ListOfBankResponse`
- ❌ `getListOfWallets(url, token, xNimbblKey, orderId)` → `ListOfWalletResponse`
- ❌ `getPaymentModes(url, token, xNimbblKey, orderId, userToken)` → `PaymentModesResponse`
- ❌ `getOrderDetails(url, token)` → `OrderResponse`
- ❌ `resolveUser(url, token, xNimbblKey, mobileNumber, deviceVerified, orderId)` → `ResolveUserResponse`
- ❌ `verifyUser(url, token, xNimbblKey, mobileNumber, otp, orderId)` → `ResolveUserResponse`
- ❌ `initiatePayment(url, token, xNimbblKey, orderId, callbackUrl, paymentMode, subPaymentMode, cardDetailJsonObj, upiId)` → `InitiatePaymentResponse`
- ❌ `makePayment(url, token, xNimbblKey, orderId, paymentMode, paymentType, otp, upiId, flow, transactionId)` → `InitiatePaymentResponse`
- ❌ `getPublicKey(url)` → `PublicKeyResponse`
- ❌ `getBinData(url, token, xNimbblKey, orderId, cardNo)` → `BinDataResponse`
- ❌ `updateTransactionDetail(url, token, transactionId, errorCode, consumerMessage, merchantMessage)` → `UpdateTransactionResponse`
- ❌ `resendOtp(url, token, xNimbblKey, orderId, paymentMode, transactionId)` → `ResendOtpResponse`

**Cost to port each method:** ~1–2 hrs (HTTP method + body shape + Codable response model + tests).
**Total:** ~3 days for all 13, assuming Android backend API contracts are stable and documented.

### 3C. Missing data models (~25 models)
Grouped by Android folder:

**`data/models/order/`** (5 models)
`OrderLineItem`, `SubMerchant`, `Scheme`, `Item`, and order-related sub-types.

**`data/models/payment/`** (~12 models)
`SubPaymentVoItem`, `ListOfWalletResponse`, `PaymentModesResponseItem`, `ListOfBankResponse`, `Wallet`, `CardType`, `PaymentModesResponse`, `PaymentType`, `CardItemVo`, `SubPaymentVo`, `Bank`, `BinData`, `BinDataResponse`.

**`data/models/user/`** (3 models)
`Geography`, `Address`, `User`.

**`data/models/common/`** (~13 models)
`ExtraInfo`, `CheckoutResourceVo`, `DataX`, `PublicKeyResponse`, `RequestArgs`, `InitiatePaymentErrorResponse`, `Data`, `InitiatePaymentResponse`, `Info`, `Error`, `ResolveUserResponse`, `GenericAPIResponse`, `InitiatePaymentData`, `InitiatePaymentExtraInfo`, `ResendOtpResponse`.

**`api/models/responses/`** (response wrappers + transaction enquiry sub-tree)
`UpdateTransactionResponse`, `transaction_enquiry/CustomAttribute`, `CurrencyConversion`, `RefundDetails`, `Transaction`, `Order`. iOS has a flat `TransactionEnquiryResponse` — needs to be checked whether it's at parity with Android's nested structure or simplified.

**Cost to port:** Codable structs are mechanical. ~30 min per model on average. **Total: ~1.5 days** for all ~25 models.

### 3D. Missing utility classes
| Android | iOS status | Action |
|---|---|---|
| `JsonParser.kt` | Missing | Port if Android consumers need it (likely just `JSONDecoder`-equivalent helpers) |
| `ProcessOutputPayloads.kt` | Missing | Port — used by event logging to mask sensitive fields |
| `extensions/NimbblSDKExtensions.kt` (md5, deviceFingerPrint, deviceID, sessionID, JWT parsing) | Partial — `getOrderID`/`getSubMerchantID` exist on `NimbblCheckoutSDK`; no md5/deviceID/networkCheck helpers | Create `Utils/JWTUtils.swift`, `Utils/DeviceUtils.swift`, `Utils/NetworkUtils.swift` |
| `extensions/NimbblCoreSdkExtensions.kt` (IP, image bitmap, etc.) | Missing | Port the ones actually used |

**Cost:** ~0.5–1 day.

### 3E. Missing constants files
Android splits constants into 5 files; iOS has 3. Specifically missing:
- `PayloadKeys.kt` — keys for event-log payloads (e.g. `order_id`, `transaction_id`, `payment_data`, etc.). Currently scattered as string literals in iOS.
- `PreferenceKeys.kt` — UserDefaults keys (iOS likely doesn't persist SDK state — verify).
- `ServiceConstants.kt` — `BASE_URL`, `DEVICE_FINGERPRINT`, `FINGERPRINT` mutable globals (iOS has these on `APIConstants` already — partial overlap).

**Cost:** ~2 hrs. Mostly extracting strings into a `PayloadKeys.swift`.

### 3F. Missing init-time validation
Android `initialiseAPISDK(url, fingerPrint, deviceFingerPrint, appCode?)`:
- Sets all 4 globals.
- Calls `LoggingConfig.configureForDevelopment()` / `.configureForProduction()` based on `is_debug_enabled`.
- Sets `EventLoggingService.setEventLoggingEnabled(true)`.
- Async-initializes repository with IP, web service, etc.

iOS singleton has `init() {}` (empty private init). There's no explicit `initialiseAPISDK` method on iOS — `APIUtils.nimbblTechUrl` and `APIConstants.FINGERPRINT` / `DEVICE_FINGERPRINT` are set directly by callers.

**Action:** add `public func initialiseAPISDK(url: String, fingerPrint: String, deviceFingerPrint: String, appCode: String? = nil)` to `NimbblCoreApiSDK` to mirror Android, internally setting `APIConstants.*` and configuring logging.

### 3G. RestApiUtils → APIUtils naming + behavior gaps
Android `RestApiUtils` has these utilities iOS doesn't fully match:
- `getWebViewUrl(baseUrl)` — handles IP-based URLs + sonic-domain transformations including QA-number extraction. iOS `APIUtils.webViewViewUrl` has simpler env detection.
- `getWebViewResponseUrl(baseUrl)` — same IP/sonic logic. iOS hardcodes `WEB_VIEW_RESP_CHECK_URL` as a constant.
- `isIpBasedUrl(url)` — iOS has this in `APIConstants` already (✅).
- Mutable `NIMBBL_TECH_URL`, `WEB_VIEW_VIEW_URL`, `WEB_VIEW_RESP_CHECK_URL` — iOS only has the first.

**Action:** flesh out `APIUtils.webViewViewUrl` and add `APIUtils.webViewRespCheckUrl` to mirror Android's IP-and-sonic-domain handling. This is needed by Part 2 gap **B** (`setEnvironmentUrl` IP fallback in WebView SDK).

### 3H. Native checkout interface (`INimbblCheckoutBaseSDKInterface`)
Android exposes an **interface** that a separate native-checkout module would implement. iOS has nothing equivalent — there's no native-checkout module in iOS today.

**Action: scope decision required (see below).** If you have plans to build a native iOS checkout module, port this interface now. Otherwise skip and revisit when the native module starts.

---

## Scope decision — three feasible targets

Given the size of the gap, there isn't one "right" answer. Pick which target fits your business need:

### Option A — Minimal viable (~2 days)
Port only what unblocks Parts 1 + 2:
- 3A repository pattern (defer)
- 3B — only the v3 create-order method that the sample app already does inline today (move it from sample-app into Core API SDK)
- 3C — only `User`, `OrderLineItem`, model additions for `NimbblCheckoutOptions` (10 fields from Part 2 gap A)
- 3D — `JWTUtils.swift` (fixes the URL-safe base64 bug noted in Part 2 gap H)
- 3F — add `initialiseAPISDK(...)` to match Android signature
- 3G — flesh out `APIUtils` IP fallback + WebView URL generation to support Part 2's `setEnvironmentUrl` rewrite
- Skip 3B's other 12 methods, all of 3C native-checkout models, 3E, 3H

**Outcome:** iOS sample app + WebView SDK reach Android parity for the WebView-only flow. Core API SDK stays sized for WebView-only consumption. No dead code.

### Option B — Infrastructure parity (~5 days)
Everything in Option A, plus:
- 3A — port `NimbblRepository` protocol + `NimbblRepositoryImpl` (keep existing public methods, delegate internally)
- 3D — port all extensions, `ProcessOutputPayloads`, `JsonParser`
- 3E — full constants alignment (5 files)
- 3F — match init signature + Logging configuration switch

**Outcome:** iOS SDK is structurally similar to Android, even if API surface is smaller. Future feature additions land in matching places. Still no native-checkout API methods until you actually need them.

### Option C — Full parity (~3 weeks)
Everything in Option B, plus:
- 3B — all 13 missing API methods
- 3C — all ~25 missing data models
- 3H — `INimbblCheckoutBaseSDKInterface` Swift port
- Comprehensive testing of every endpoint against the Nimbbl backend
- Coordinate pod release + integration testing
- Documentation update for new SDK surface

**Outcome:** iOS Core API SDK is feature-equivalent to Android. Required if you plan to build a native iOS checkout module that bypasses the WebView. Heavy investment that produces a lot of code with no immediate consumer.

---

## Recommended path

**Option A** — unless there's an explicit roadmap item to build a native iOS checkout flow. The 13 missing API methods are useless without a native-checkout UI module, and porting Codable models for `BinDataResponse` / `ResolveUserResponse` / `PaymentModesResponse` etc. only adds maintenance overhead with no immediate consumer.

If a native iOS checkout module is on the roadmap for the next 1–2 quarters, jump straight to **Option C** and do the work end-to-end rather than porting Option A now and re-doing it later.

---

## Open questions (Core API SDK)

1. **Is a native iOS checkout flow planned?** This is the single biggest scoping question. The answer drives Option A vs Option C.
2. **`xNimbblKey` header** — Android's repository methods accept this as a parameter. Where does it come from in the iOS architecture today? Currently I don't see it referenced anywhere in the iOS SDK. Need to confirm if it's a backend requirement that iOS just isn't sending.
3. **Backend API contract docs** — for Option C we'd need access to backend API specs to write correct Codable models for ~13 endpoints. Are these in Confluence / Postman?
4. **Pod publishing cadence** — Core API SDK is currently `2.0.17`. Each of Options A/B/C requires a different version bump (patch / minor / major). Want to plan release windows.
5. **`@objc` requirements** — same question as Part 2. Any Objective-C consumers of `NimbblCoreApiSDK`?

---

## Combined effort estimate (Parts 1 + 2 + 3)

| Part | Effort | Target outcome |
|---|---|---|
| Part 1 (sample app) | 1.5–2 days | Sample app feature parity with Android |
| Part 2 (WebView SDK) | 3–4 days | WebView SDK behavioral + API surface parity |
| Part 3 Option A | 2 days | Minimal Core API SDK enablement |
| Part 3 Option B | 5 days | Core API SDK structural parity |
| Part 3 Option C | 3 weeks | Full Core API SDK feature parity |
| **Total (Option A path)** | **~7 days** | WebView flow at parity |
| **Total (Option B path)** | **~10 days** | WebView flow at parity + future-proofed SDK structure |
| **Total (Option C path)** | **~5 weeks** | Everything Android does, on iOS |

**Decision needed:** which Option for Part 3? Reply with A / B / C (or "A for now, revisit C when native iOS module starts") and I'll lock the plan and start implementation.

---

## ✅ Decision: Option C — Full Parity (REVISED to "Option B+")

Locked on 2026-05-15. **Revised mid-implementation** on the same day: user directive — *"don't add APIs in core api sdk as it is not used in webview sdk; skip this"*.

### Revised scope

The 13 missing Core API SDK repository methods (banks, wallets, payment-modes, bin-data, resolve/verify user, OTP, initiate/make payment, get-order, public-key, update-transaction) are **explicitly skipped** because they have no consumer in the WebView flow.

Cascading removals:
- ❌ NimbblRepository protocol + Impl — empty without the methods.
- ❌ ~25 Codable data models (BinDataResponse, PaymentModesResponse, ResolveUserResponse, etc.) — only consumed by the skipped methods.
- ❌ INimbblCheckoutBaseSDKInterface — native-checkout-only.
- ❌ ProcessOutputPayloads / JsonParser — only consumed by the repository.
- ❌ Migration of v3 create-order from sample app into Core API SDK — Phase 3 dependency gone.
- ❌ Cross-platform API parity tests in Phase 5 — nothing to compare since the methods aren't there.

What stays:
- ✅ Phase 0 — already shipped.
- ✅ Phase 1 — already shipped (utilities, constants, options, JWT fix, debug toggle are all foundational regardless of API method presence).
- ✅ Phase 2 — reduced to WebView SDK enrichment + setEnvironmentUrl rewrite only.
- ✅ Phase 4 — sample app feature parity + WebView SDK polish; v3 create-order stays in the sample app inline (not migrated to Core API SDK).
- ✅ Phase 5 — release + docs; cross-platform tests scope reduced to the WebView flow only.

### Revised total effort

Originally 5 weeks for Option C. **Revised to ~9 days** total (Phase 0 + 1 done; ~3 + 4 + 1.5 days for Phases 2 + 4 + 5).

### Phased delivery plan (Option C)

To make progress visible and avoid a 5-week black box, the work is broken into 5 phases. Each phase ships an independent pod release (Core API SDK + WebView SDK) and a sample-app commit.

**Phase 0 — Foundations (Week 1, ~3 days)**
*Blocking — must finish first*
1. Backend API contract gathering — get Postman collection / Swagger spec for the 13 missing endpoints. Without this, Codable models in Phase 2 are guesswork.
2. Confirm `xNimbblKey` source (header value origin in Android flow).
3. Set up versioning: bump both pods to `2.1.0-alpha.1` for Phase 1 development. Lock pod release windows.
4. Phase 3F + 3G — add `initialiseAPISDK(...)` matching Android signature; extend `APIUtils` with full IP-and-sonic-domain WebView URL generation.

**Phase 1 — Foundational SDK work (Week 1–2, ~4 days)**
*All additive, low risk*
1. **Core API SDK**: Add 10 missing fields to `NimbblCheckoutOptions` + new `NimbblCheckoutUserInfo` struct (Part 2 gap A). Pod release `2.1.0-alpha.1`.
2. **Core API SDK**: Add `JWTUtils.swift` (fixes URL-safe base64 bug — Part 2 gap H).
3. **Core API SDK**: Constants file alignment — port `PayloadKeys.swift`, fill out `EventConstants.swift` against Android. (Part 3 gap E)
4. **Core API SDK**: Port utility extensions — `DeviceUtils.swift` (md5, deviceFingerPrint, deviceID, sessionID), `NetworkUtils.swift` (isNetConnected, getIPAddress). (Part 3 gap D)
5. **WebView SDK**: `LogUtil.setDebugLoggingEnabled(_:)` public API + `setDebugLoggingEnabled` on `NimbblCheckoutSDK` (Part 2 gap C).
6. **WebView SDK**: Fix `getOrderID` URL-safe base64 (Part 2 gap H — now uses `JWTUtils`).

**Phase 2 — Architecture + data models (Week 2–3, ~5 days)**
*Structural changes*
1. **Core API SDK**: Repository pattern — `NimbblRepository.swift` protocol + `NimbblRepositoryImpl.swift`. Move existing 3 callback methods to delegate to repo. (Part 3 gap A)
2. **Core API SDK**: Port ~25 missing Codable data models in folders matching Android: `Models/Order/`, `Models/Payment/`, `Models/User/`, `Models/Common/`. (Part 3 gap C)
3. **Core API SDK**: `INimbblCheckoutBaseSDKInterface` Swift port — `NimbblCheckoutBaseSDKInterface.swift` protocol. (Part 3 gap H)
4. **Core API SDK**: `ApiResult` Swift enum (success/error) matching Android sealed class.
5. **Core API SDK**: `ProcessOutputPayloads.swift` for log masking. (Part 3 gap D)
6. **WebView SDK**: New SDK files — `PaymentConstants.swift`, `NimbblError.swift`, `ValidationUtils.swift`, `PaymentURLBuilder.swift`, `UPIManager.swift`, `SDKUtils.swift`. (Part 2 gaps D, E, F, I)
7. **WebView SDK**: Rewrite `setEnvironmentUrl` with IP fallback + validation, using Core API SDK's new `APIUtils.webViewViewUrl(for:)` and `APIUtils.webViewRespCheckUrl(for:)`. (Part 2 gap B)
8. Pod release `2.1.0-alpha.2` for both.

**Phase 3 — Repository API methods (Week 3–4, ~5 days)**
*Heavy lift — needs backend docs from Phase 0*

Port the 13 missing API methods, in dependency order:
1. `getOrderDetails(url, token)` — simplest GET, validates infra.
2. `getCheckOutResource(url, token, xNimbblKey)` — first method using `xNimbblKey`.
3. `getPaymentModes(...)` + `getListOfBanks(...)` + `getListOfWallets(...)` — read paths.
4. `getPublicKey(url)` + `getBinData(...)` — utility reads.
5. `resolveUser(...)` + `verifyUser(...)` + `resendOtp(...)` — user/OTP flow.
6. `initiatePayment(...)` + `makePayment(...)` — payment write paths.
7. `updateTransactionDetail(...)` — transaction update.

Each method gets: protocol declaration, impl, Codable response, unit test, integration test against QA backend. Pod release `2.1.0-alpha.3`.

**Phase 4 — WebView SDK polish + sample app parity (Week 4–5, ~5 days)**
1. **WebView SDK**: Extract `WebViewManager.swift` and `PaymentHandler.swift` from the 1682-line controller. (Part 2 gap K)
2. **WebView SDK**: Add `cleanup()` lifecycle method. (Part 2 gap G)
3. **Sample app (Part 1)**: All six features land — environment switcher, access token + v3 path, IP fallback, debug logs viewer + 7-tap unlock, UPI intent app, EMI enforcement.
4. **Sample app**: Migrate v3 create-order call to use the new Core API SDK `createOrder` method instead of inline `URLSession` code.
5. Pod release `2.1.0` (stable). Sample app commit + tag.

**Phase 5 — Hardening + docs (Week 5, ~2 days)**
1. Cross-platform parity tests: same checkout flow, same options, verify identical event-log payloads between Android and iOS.
2. Update `INTEGRATION_GUIDE.md` and `CHANGELOG.md` for both pods.
3. Migration guide for existing host apps: which API methods are new, breaking changes (if any) on `setEnvironmentUrl`.
4. Release `2.1.0` to CocoaPods Trunk.

### Phase dependencies

```
Phase 0 ──┬─→ Phase 1 ──┬─→ Phase 2 ──┬─→ Phase 3 ──→ Phase 5
          │             │             │
          └─────────────┴─────────────┴─→ Phase 4
```

Phase 4 can start as soon as Phase 2 lands the model + URL-builder work; it doesn't need to wait for Phase 3's API methods to finish. So Phases 3 and 4 run in parallel in week 4.

### What needs to be unblocked NOW (Phase 0 deliverables you provide)

1. **Postman collection or Swagger spec** for these 13 endpoints (Phase 3 cannot start without):
   - `/api/internal/checkout/resource`
   - `/api/internal/checkout/banks`
   - `/api/internal/checkout/wallets`
   - `/api/internal/checkout/payment-modes`
   - `/api/internal/order/details` (GET)
   - `/api/internal/user/resolve`
   - `/api/internal/user/verify`
   - `/api/internal/payment/initiate`
   - `/api/internal/payment/make`
   - `/api/internal/public-key`
   - `/api/internal/bin-data`
   - `/api/internal/transaction/update`
   - `/api/internal/otp/resend`

   (Endpoint paths above are guesses based on Android — actual paths come from Android `ServiceConstants.kt` or your API gateway.)
2. **`xNimbblKey` header source** — is it baked into the SDK (constant per env)? Issued per session? Per merchant?
3. **`@objc` consumers** — confirm whether anyone integrates from Objective-C. Drives whether new types need `@objc` annotations or NSError bridging.
4. **Backend QA env access** — for integration testing each new endpoint, the SDK build needs to hit a stable QA env. Confirm `qa3api.qa.nimbbl.tech` is the right target.

I'll start Phase 0 + Phase 1 in parallel — Phase 1 work is unblocked from those questions and can land right away. Phase 2 starts as Phase 1 wraps. Phase 3 can only start once Phase 0 deliverable 1 (API specs) is in hand.
