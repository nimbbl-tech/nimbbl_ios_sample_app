import Foundation

enum SampleShopAPIUtils {
    private enum URLConstants {
        // Android sample app alignment (ApiConstants.kt)
        static let nimbblTechUrl = "https://api.nimbbl.tech/"
        static let baseUrlQA1 = "https://qa1api.qa.nimbbl.tech/"
        
        static let shopOrderUrlQA1 = "https://qa1sonicshopapi.qa.nimbbl.tech/create-shop"
    }
    
    static func getShopUrl(environmentUrl: String?) -> String {
        // Matches Android sample app flow:
        // resolveShopBaseUrl() -> resolveShopOrderUrl(apiBaseUrl)
        let shopBaseUrl = resolveShopBaseUrl(configuredBaseUrl: environmentUrl)
        return resolveShopOrderUrl(apiBaseUrl: shopBaseUrl)
    }

    private static func resolveShopBaseUrl(configuredBaseUrl: String?) -> String {
        let trimmed = (configuredBaseUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let finalBaseUrl: String
        if trimmed.isEmpty {
            finalBaseUrl = URLConstants.nimbblTechUrl
        } else if isIpBasedUrl(trimmed) {
            finalBaseUrl = URLConstants.baseUrlQA1
        } else {
            finalBaseUrl = trimmed
        }
        
        let formatted = formatUrl(finalBaseUrl)
        return formatted.isEmpty ? URLConstants.nimbblTechUrl : formatted
    }
    
    private static func resolveShopOrderUrl(apiBaseUrl: String) -> String {
        let normalized = formatUrl(apiBaseUrl)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        guard let url = URL(string: normalized), let host = url.host else {
            return URLConstants.shopOrderUrlQA1
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

