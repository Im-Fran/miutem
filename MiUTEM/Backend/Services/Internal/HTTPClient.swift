//
//  HTTPClient.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 10-08-23.
//

import Foundation


enum HTTPMethod: String {
    case head = "HEAD"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct HTTPRequest {
    let method: HTTPMethod
    let uri: String
    let body: BodyType
    let params: [String: String]?
    let headers: [String: String]?
    let configure: ((inout URLRequest) -> Void)?
    
    enum BodyType {
        case none
        case data(Data)
        case json(Encodable)
    }
    
    init(method: HTTPMethod, uri: String, body: BodyType = .none, params: [String: String]? = nil, headers: [String: String]? = nil, configure: ((inout URLRequest) -> Void)? = nil) {
        self.method = method
        self.uri = uri
        self.body = body
        self.params = params
        self.headers = headers
        self.configure = configure
    }
    
    func perform() async throws -> (Data?, HTTPURLResponse?, Error?) {
        var components = URLComponents(string: uri)
        if let params = params {
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            return (nil, nil, ServerError.networkError)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        switch body {
        case .data(let data):
            request.httpBody = data
        case .json(let encodable):
            request.httpBody = try JsonService.toJson(encodable)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            break
        }
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        configure?(&request) // Apply user-defined configuration
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServerError.internalError
        }
        
        let error = httpResponse.statusCode == 200 ? nil : try? JsonService.fromJson(ServerError.self, data)
        return (data, httpResponse, error)
    }
}
