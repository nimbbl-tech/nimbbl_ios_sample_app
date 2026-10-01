/*
Created by Sandeep Y. on 15/05/26.
Copyright (c) 2026 Bigital Technologies Pvt. Ltd. All rights reserved.

Plus a typed `UserDefaults` accessor extension so the rest of the app reads
properties instead of stringly-typed `string(forKey:)` calls.
*/

import Foundation

@objc public class AppPreferenceKeys: NSObject {

    private override init() { super.init() }

    // MARK: - Key strings
    @objc public static let APP_PREFERENCE = "app_configs_prefs"
    @objc public static let SAMPLE_APP_MODE = "sample_app_mode"
    @objc public static let SHOP_BASE_URL = "shop_base_url"
    @objc public static let QA_ENVIRONMENT_URL = "qa_environment_url"
    @objc public static let ACCESS_TOKEN = "access_token"
    @objc public static let DEBUG_LOGS_ENABLED = "debug_logs_enabled"
    @objc public static let DEBUG_MENU_UNLOCKED = "debug_menu_unlocked"

    // Backward compatibility for older builds
    @objc public static let ORDER_TOKEN = "order_token"
}

// MARK: - Typed UserDefaults accessors

extension UserDefaults {
    /// Resolved API base URL — Prod, Pre-Prod, or formatted QA URL.
    var shopBaseUrl: String {
        get { string(forKey: AppPreferenceKeys.SHOP_BASE_URL) ?? "" }
        set { set(newValue, forKey: AppPreferenceKeys.SHOP_BASE_URL) }
    }

    /// Raw QA URL entered by the user (separately stored so QA can be re-displayed).
    var qaEnvironmentUrl: String {
        get { string(forKey: AppPreferenceKeys.QA_ENVIRONMENT_URL) ?? "" }
        set { set(newValue, forKey: AppPreferenceKeys.QA_ENVIRONMENT_URL) }
    }

    /// Optional Core API auth token used for `/api/v3/create-order` Bearer auth.
    /// Falls back to legacy `order_token` key for back-compat.
    var accessToken: String {
        get {
            let primary = string(forKey: AppPreferenceKeys.ACCESS_TOKEN) ?? ""
            if !primary.isEmpty { return primary }
            return string(forKey: AppPreferenceKeys.ORDER_TOKEN) ?? ""
        }
        set { set(newValue, forKey: AppPreferenceKeys.ACCESS_TOKEN) }
    }

    /// SDK debug logging toggle (forwarded to `NimbblCheckoutSDK.setDebugLoggingEnabled`).
    var debugLogsEnabled: Bool {
        get { bool(forKey: AppPreferenceKeys.DEBUG_LOGS_ENABLED) }
        set { set(newValue, forKey: AppPreferenceKeys.DEBUG_LOGS_ENABLED) }
    }

    /// Whether the user has unlocked the debug section via 7-tap header gesture.
    var debugMenuUnlocked: Bool {
        get { bool(forKey: AppPreferenceKeys.DEBUG_MENU_UNLOCKED) }
        set { set(newValue, forKey: AppPreferenceKeys.DEBUG_MENU_UNLOCKED) }
    }

    /// Selected app experience: "Webview" or "Native".
    var sampleAppMode: String {
        get { string(forKey: AppPreferenceKeys.SAMPLE_APP_MODE) ?? "Webview" }
        set { set(newValue, forKey: AppPreferenceKeys.SAMPLE_APP_MODE) }
    }
}
