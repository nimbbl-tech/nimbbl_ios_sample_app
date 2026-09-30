/*
Created by Sandeep Y. on 15/05/26.
Copyright (c) 2026 Bigital Technologies Pvt. Ltd. All rights reserved.

Strictly mirrors Android `OrderCreateActivity.createOrderV3Request(...)`.
Hits `{baseUrl}/api/v3/create-order` with the `Bearer <accessToken>` header
when a Core API token is configured. Used by `OrderCreator` to branch away
from the shop-proxy path.
*/

import Foundation

enum OrderV3Error: Error {
    case invalidURL(String)
    case http(status: Int, body: String?)
    case network(Error)
    case decoding(String)
}

struct OrderV3Response {
    let token: String
    let orderId: String?
    let rawJSON: [String: Any]
}

enum OrderV3Client {

    /// Create an order using Nimbbl's Core API v3.
    /// Docs: https://docs.nimbbl.tech/api-reference/create-an-order-v-3/
    ///
    /// - Parameters:
    ///   - apiBaseUrl: API base URL (e.g. "https://qa3api.qa.nimbbl.tech/"). Must end with `/`.
    ///   - accessToken: Bearer token from Settings.
    ///   - totalAmount: order amount in lowest currency unit.
    ///   - emailId: user email (may be empty).
    ///   - firstName: user first name (may be empty).
    ///   - mobileNumber: user mobile number; when empty, the `user` object is omitted.
    ///   - productId: product/SKU identifier; fallback to "item_<invoice>" if empty.
    ///   - paymentMode: payment mode code or empty.
    ///   - subPaymentMode: sub-payment mode code (bank / wallet / EMI) or nil.
    ///   - completion: called with the order token + raw JSON on success.
    static func create(
        apiBaseUrl: String,
        accessToken: String,
        totalAmount: Int,
        emailId: String,
        firstName: String,
        mobileNumber: String,
        productId: String,
        paymentMode: String,
        subPaymentMode: String?,
        completion: @escaping (Result<OrderV3Response, OrderV3Error>) -> Void
    ) {
        let base = (apiBaseUrl.hasSuffix("/") ? apiBaseUrl : apiBaseUrl + "/")
        let urlString = "\(base)api/v3/create-order"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL(urlString)))
            return
        }

        let invoiceId = "inv_\(Int64(Date().timeIntervalSince1970 * 1000))"
        let amountBeforeTax = totalAmount
        let tax = 0
        var payload: [String: Any] = [
            "currency": "INR",
            "quantity": 1,
            "amount_before_tax": amountBeforeTax,
            "tax": tax,
            "total_amount": totalAmount,
            "invoice_id": invoiceId
        ]

        // User object — only included when mobile number is present (matches Android).
        if !mobileNumber.isEmpty {
            var user: [String: Any] = [
                "first_name": firstName,
                "last_name": "",
                "country_code": "+91",
                "mobile_number": mobileNumber
            ]
            if !emailId.isEmpty { user["email"] = emailId }
            payload["user"] = user
        }

        // Order line items — Android always includes 1 item, matching that behavior here.
        let lineItemSku = productId.isEmpty ? "item_\(invoiceId)" : productId
        payload["order_line_items"] = [[
            "sku_id": lineItemSku,
            "title": "Product",
            "description": "Product description",
            "rate": totalAmount,
            "quantity": 1,
            "amount_before_tax": totalAmount,
            "tax": 0,
            "total_amount": totalAmount,
            "image_url": "",
            "uom": "unit"
        ]]

        guard let body = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(.decoding("Failed to serialize request payload")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body

        // Structured request log — mirrors Android `logSampleApiRequest("OrderCreate-v3", ...)`.
        SampleApiLogger.logRequest(
            tag: "OrderCreate-v3",
            method: "POST",
            url: urlString,
            headers: [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json",
                "Authorization": "Bearer \(SampleApiLogger.maskToken(accessToken))"
            ],
            body: String(data: body, encoding: .utf8)
        )

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                SampleApiLogger.logResponse(
                    tag: "OrderCreate-v3",
                    code: -1,
                    message: "network error",
                    body: error.localizedDescription
                )
                DispatchQueue.main.async { completion(.failure(.network(error))) }
                return
            }
            guard let http = response as? HTTPURLResponse else {
                SampleApiLogger.logResponse(
                    tag: "OrderCreate-v3",
                    code: -1,
                    message: "no HTTPURLResponse",
                    body: nil
                )
                DispatchQueue.main.async {
                    completion(.failure(.http(status: -1, body: nil)))
                }
                return
            }
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) }
            // Mirror Android: log every response regardless of status code.
            SampleApiLogger.logResponse(
                tag: "OrderCreate-v3",
                code: http.statusCode,
                message: HTTPURLResponse.localizedString(forStatusCode: http.statusCode),
                body: bodyString
            )
            guard (200..<300).contains(http.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.http(status: http.statusCode, body: bodyString)))
                }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.decoding("Failed to decode response JSON")))
                }
                return
            }
            let token = (json["token"] as? String) ?? ""
            let orderId = json["order_id"] as? String
            guard !token.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(.decoding("Order token missing in response")))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(OrderV3Response(token: token, orderId: orderId, rawJSON: json)))
            }
        }.resume()
    }
}
