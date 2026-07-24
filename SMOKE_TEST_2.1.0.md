# Smoke Test Checklist — iOS 2.1.0-alpha.1

Manual on-device verification for the six features that landed in this release.
Each item lists the expected behavior so you (or a QA tester) can tick through
them after `pod install` + build.

## Pre-flight

- [ ] `pod install` succeeds with both pods at `2.1.0-alpha.1`.
- [ ] Sample app launches without crashing.
- [ ] Xcode console shows `initialiseAPISDK completed — BASE_URL=...` on launch
      (if you've wired the host app to call it) OR the existing
      `APIConstants.BASE_URL` default applies.
- [ ] Tap the gear icon top-right → Settings screen opens.

## 1. Environment switcher

- [ ] Settings → Environment shows **3 options**: Prod, Pre-Prod, QA.
- [ ] Picking **QA** reveals the editable URL field below the picker.
- [ ] Default QA URL is `https://qa3api.qa.nimbbl.tech/` (not the legacy QA1).
- [ ] Edit URL → tap Done → reopen Settings → URL persisted.
- [ ] Picking Prod/Pre-Prod hides the URL field.
- [ ] Done → return to main → next checkout uses the new env.

## 2. Access token + Core API v3 path

- [ ] On main screen, tap the header logo **7 times within 2 seconds**.
- [ ] Toast/alert appears: *"Debug options unlocked"*.
- [ ] Settings → debug section is now visible.
- [ ] Paste any non-empty string into the Access Token field.
- [ ] Tap Clear button → field empties.
- [ ] Re-paste a token → tap Done.
- [ ] Tap Pay Now → console shows `[DEBUG] v3 checkout options: …`
      (instead of the shop-proxy path).
- [ ] Network log: a `POST {base}/api/v3/create-order` request with
      `Authorization: Bearer <your_token>` header.
- [ ] Clear the token in Settings → Pay Now reverts to the shop-proxy path
      (`/create-shop` endpoint).

## 3. IP-based URL fallback

- [ ] Settings → QA → enter an IP URL like `http://192.168.1.100:8080/` → Done.
- [ ] Tap Pay Now (with no access token).
- [ ] Check Xcode console for `Environment set — API: https://qa3api.qa.nimbbl.tech/,
      WebView: http://192.168.1.100:8080/?token=…, Resp: http://192.168.1.100:8080/mobile/redirect`.
- [ ] The shop-order POST goes to `qa3sonicshopapi.qa.nimbbl.tech/create-shop`
      (NOT the IP).
- [ ] The WebView itself opens against your IP host with `?token=<jwt>`.

## 4. Debug logs viewer + 7-tap unlock

- [ ] Without the 7-tap unlock, Settings shows NO debug section.
- [ ] After 7 taps within 2 seconds on the header → unlock toast.
- [ ] Debug section shows: Access Token field, SDK Debug Logs switch,
      View Debug Logs row.
- [ ] Tap View Debug Logs → push (or modal) into the log viewer.
- [ ] Viewer initially shows the snapshot of captured stdout/stderr.
- [ ] Trigger an action that prints (e.g. tap Pay Now) → new lines appear
      live in the viewer.
- [ ] Tap Pause → "Pause" becomes "Resume", no new lines appear.
- [ ] Tap Resume → live appending resumes.
- [ ] Type a search term in the search bar → matches highlighted yellow,
      current match orange.
- [ ] Up/down arrows cycle through matches; scroll follows.
- [ ] Tap Clear → text view emptied.
- [ ] Tap Copy → pasteboard contains the captured logs.

## 5. UPI intent app picker

- [ ] On the main screen, payment dropdown now lists 6 options:
      all / netbanking / wallet / card / upi / **emi**.
- [ ] Pick UPI → sub-payment dropdown shows `collect + intent / collect / intent`.
- [ ] Pick **intent** → after the sub-sheet dismisses (~0.25s),
      a UPI app picker bottom sheet appears with: Google Pay / PhonePe / Paytm.
- [ ] Pick PhonePe → console log `[DEBUG] UPI app picked: PhonePe (code: phonepeupi)`.
- [ ] Tap Pay Now → checkout WebView URL contains `&upi_app_code=phonepeupi`.
- [ ] Re-pick a non-intent sub-option → UPI app picker does NOT appear.

## 6. EMI enforcement

- [ ] Payment dropdown → pick **emi**.
- [ ] Sub-payment dropdown shows: all emis / debit card emi / credit card emi / cardless emi.
- [ ] Pick "credit card emi" → tap Pay Now.
- [ ] Checkout WebView URL contains `&payment_mode=emi&emi_code=credit`.
- [ ] Test the three other EMI sub-options similarly:
  - [ ] all emis → URL contains `&payment_mode=emi` (no `emi_code` param, matches Android).
  - [ ] debit card emi → URL contains `&emi_code=debit`.
  - [ ] cardless emi → URL contains `&emi_code=cardless`.

## SDK validation (error paths)

These shouldn't trigger in normal usage but verify they fire correctly if
you induce them deliberately:

- [ ] Set `NimbblCheckoutSDK.shared.environmentUrl = ""` → delegate receives
      `error: "API_URL_001"`.
- [ ] Call `checkout(...)` with `options.orderToken = nil` → delegate receives
      `error: "CHECKOUT_004"`.
- [ ] Call `checkout(...)` without setting `delegate` → console logs
      `checkout validation failed: Checkout listener is missing…`.

## Pod lifecycle

- [ ] Call `NimbblCheckoutSDK.shared.cleanup()` after a successful checkout
      → `NimbblCheckoutSDK.shared.isCleanedUp()` returns `true`.
- [ ] Subsequent `checkout(...)` call with a re-set delegate works again.

---

If anything above fails, capture the Debug Logs (Clear + reproduce + Copy)
and paste into the bug report along with the URL the WebView opened with.
