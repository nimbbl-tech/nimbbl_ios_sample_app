import Foundation

enum SampleShopAPIUtils {
    private enum URLConstants {
        // Android sample app alignment (ApiConstants.kt)
        static let nimbblTechUrl = "https://api.nimbbl.tech/"
        // Default QA fallback for sample-app API calls when configured URL is an IP.
        // Matches Android `ApiConstants.BASE_URL_QA3`.
        static let baseUrlQA3 = "https://qa3api.qa.nimbbl.tech/"
        // Legacy QA1 host kept for prefs migration.
        static let baseUrlQA1 = "https://qa1api.qa.nimbbl.tech/"

        static let shopOrderUrlQA3 = "https://qa3sonicshopapi.qa.nimbbl.tech/create-shop"
        static let shopOrderUrlQA1 = "https://qa1sonicshopapi.qa.nimbbl.tech/create-shop"
    }

    static func getShopUrl(environmentUrl: String?) -> String {
        // Matches Android sample app flow:
        // resolveShopBaseUrl() -> resolveShopOrderUrl(apiBaseUrl)
        let shopBaseUrl = resolveShopBaseUrl(configuredBaseUrl: environmentUrl)
        return resolveShopOrderUrl(apiBaseUrl: shopBaseUrl)
    }

    /// Resolves the API base URL the sample app uses for its own /create-shop or
    /// /api/v3/create-order calls. Mirrors Android `resolveShopBaseUrl()`:
    /// IP-based URLs fall back to QA3.
    static func resolveShopBaseUrl(configuredBaseUrl: String?) -> String {
        let trimmed = (configuredBaseUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let finalBaseUrl: String
        if trimmed.isEmpty {
            finalBaseUrl = URLConstants.nimbblTechUrl
        } else if isIpBasedUrl(trimmed) {
            finalBaseUrl = URLConstants.baseUrlQA3
        } else {
            finalBaseUrl = trimmed
        }

        let formatted = formatUrl(finalBaseUrl)
        return formatted.isEmpty ? URLConstants.nimbblTechUrl : formatted
    }

    /// Resolves the URL passed to `NimbblCheckoutSDK.environmentUrl`. Unlike
    /// `resolveShopBaseUrl`, this one keeps raw IP hosts as-is — matching Android's
    /// `sdkEnvUrl` branch in `OrderCreateActivity`. This lets the WebView launch
    /// against a local IP while sample-app API calls still hit QA3.
    static func resolveSdkEnvironmentUrl(configuredBaseUrl: String?) -> String {
        let trimmed = (configuredBaseUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return URLConstants.nimbblTechUrl
        }
        let formatted = formatUrl(trimmed)
        return formatted.isEmpty ? trimmed : formatted
    }
    
    private static func resolveShopOrderUrl(apiBaseUrl: String) -> String {
        let normalized = formatUrl(apiBaseUrl)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        guard let url = URL(string: normalized), let host = url.host else {
            return URLConstants.shopOrderUrlQA3
        }
        
        let scheme = url.scheme ?? "https"
        let shopHost = host.replacingOccurrences(of: "api", with: "sonicshopapi", options: [], range: host.range(of: "api"))
        return "\(scheme)://\(shopHost)/create-shop"
    }
    
    private static func isIpBasedUrl(_ value: String) -> Bool {
        let normalized: String
        if value.hasPrefix("http://") || value.hasPrefix("https://") {
            normalized = value
        } else {
            normalized = "https://\(value)"
        }
        
        guard let host = URL(string: normalized)?.host else { return false }
        let pattern = #"^(\d{1,3}\.){3}\d{1,3}$"#
        return host.range(of: pattern, options: .regularExpression) != nil
    }
    
    private static func formatUrl(_ url: String) -> String {
        var formatted = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove double slashes (except for protocol)
        formatted = formatted.replacingOccurrences(of: "//", with: "/")
        formatted = formatted.replacingOccurrences(of: "https:/", with: "https://")
        formatted = formatted.replacingOccurrences(of: "http:/", with: "http://")
        
        if !formatted.hasSuffix("/") {
            formatted += "/"
        }
        return formatted
    }
}

