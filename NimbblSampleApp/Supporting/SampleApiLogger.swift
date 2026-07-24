/*
Created by Sandeep Y. on 15/05/26.
Copyright (c) 2026 Bigital Technologies Pvt. Ltd. All rights reserved.

Mirrors Android `OrderCreateActivity.logSampleApiRequest()` /
`logSampleApiResponse()`. Prints structured request/response blocks for the
sample app's create-shop and /api/v3/create-order HTTP calls so debugging on
iOS matches Android exactly (`=== API REQUEST ===` / `=== API RESPONSE ===`
banners with the same fields in the same order).

Logs flow to:
  - `print(...)` so they show in Xcode console
  - `AppLogStream.shared.appendLog(...)` so the in-app Debug Logs viewer shows
    them too (matching the Android viewer behavior).
Both are gated by `DebugConfig.debugPrintEnabled` which matches Android's
`BuildConfig.DEBUG` gating.
*/

import Foundation

enum SampleApiLogger {

    /// Mirrors Android `logSampleApiRequest(tag, method, url, headers, body)`.
    /// Emits a 5-line block in the same order: header banner, method, URL,
    /// headers (if any), body (if any), footer banner.
    static func logRequest(
        tag: String,
        method: String,
        url: String,
        headers: [String: String] = [:],
        body: String? = nil
    ) {
        guard DebugConfig.debugPrintEnabled else { return }
        emit(tag: tag, "=== API REQUEST ===")
        emit(tag: tag, "Method: \(method)")
        emit(tag: tag, "URL: \(url)")
        if !headers.isEmpty {
            emit(tag: tag, "Headers: \(headers)")
        }
        if let body = body, !body.isEmpty {
            emit(tag: tag, "Request Body: \(body)")
        }
        emit(tag: tag, "===================")
    }

    /// Mirrors Android `logSampleApiResponse(tag, code, message, body)`.
    static func logResponse(
        tag: String,
        code: Int,
        message: String?,
        body: String?
    ) {
        guard DebugConfig.debugPrintEnabled else { return }
        emit(tag: tag, "=== API RESPONSE ===")
        emit(tag: tag, "Response Code: \(code)")
        emit(tag: tag, "Response Message: \(message ?? "")")
        emit(tag: tag, "Response Body: \(body ?? "")")
        emit(tag: tag, "====================")
    }

    /// Mirrors Android `OrderCreateActivity.maskToken(token)` — hides the middle
    /// of a token so Authorization headers can be logged safely.
    static func maskToken(_ token: String) -> String {
        let t = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count <= 12 { return "****" }
        let prefix = t.prefix(6)
        let suffix = t.suffix(4)
        return "\(prefix)****\(suffix)"
    }

    // MARK: - Internal

    private static func emit(tag: String, _ line: String) {
        // 1. Xcode console (existing host-app debugging workflow).
        print("[\(tag)] \(line)")
        // 2. In-app Debug Logs viewer buffer (matches Android logcat viewer).
        AppLogStream.shared.appendLog("[\(tag)] \(line)")
    }
}
