//
//  AuthService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 26-06-23.
//

import Foundation
import Cache
import KeychainSwift
import Combine

class AuthService {
    var perfil: Perfil?
    
    let keychain = KeychainSwift()
    let storage = try? Storage<String, Perfil>(
        diskConfig: DiskConfig(name: "miutem.perfil", expiry: .seconds(604800), protectionType: .complete),
        memoryConfig: MemoryConfig(expiry: .seconds(604800)),
        transformer: TransformerFactory.forCodable(ofType: Perfil.self)
    )
    
    var cancellables: [AnyCancellable] = []
    
    init() {
        _ = hasCachedPerfil()
    }
    
    func getStoredCredentials() -> Credentials {
        Credentials(correo: keychain.get("correo") ?? "", contrasenia: keychain.get("password") ?? "")
    }
    
    func storeCredentials(credentials: Credentials) {
        if(credentials.correo.isEmpty || credentials.contrasenia.isEmpty) {
            return
        }
        
        let correo = credentials.correo.hasSuffix("@utem.cl") ? credentials.correo : "\(credentials.correo)@utem.cl"
        keychain.set(correo, forKey: "correo")
        keychain.set(credentials.contrasenia, forKey: "contrasenia")
    }
    
    func hasCachedPerfil() -> Bool {
        let cached = (try? storage?.existsObject(forKey: "perfil")) ?? false
        if self.perfil == nil && cached {
            // Run getPerfil to store it!
            
        }
        
        return cached
    }
    
    
    func getPerfil() -> AnyPublisher<Perfil, ServerError> {
        if self.perfil != nil {
            return Just(self.perfil!)
                .setFailureType(to: ServerError.self)
                .eraseToAnyPublisher()
        }
        
        try? storage?.removeExpiredObjects()
        if let storedPerfil = try? storage?.object(forKey: "perfil") {
            return Just(storedPerfil)
                .setFailureType(to: ServerError.self)
                .handleEvents(receiveOutput: { perfil in
                    self.perfil = perfil
                })
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "https://api.exdev.cl/v1/auth") else {
            return Fail(error: .networkError)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: 20.0)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(self.getStoredCredentials())
        } catch {
            return Fail(error: .encodeError).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ServerError.networkError
                }
                        
                switch httpResponse.statusCode {
                case 200:
                    return data
                default:
                    if let serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
                        throw serverError
                    } else {
                        throw ServerError.unknownError
                    }
                }
            }
            .decode(type: Perfil.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { perfil in
                try? self.storage?.setObject(perfil, forKey: "perfil")
            })
            .mapError { error in
                if let serverError = error as? ServerError {
                    return serverError
                } else {
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func logout() {
        keychain.delete("correo")
        keychain.delete("contrasenia")
        try? storage?.removeAll()
    }
}
