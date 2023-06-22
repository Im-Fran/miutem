//
//  User.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 21-06-23.
//

import Foundation
import KeychainSwift
import Just

struct Credentials {
    var username: String
    var password: String
}

class User: ObservableObject {
    @Published var status: String? = nil
    @Published var data: [String: Any] = [:]
    let server = "https://api.exdev.cl/v1/auth"
    let keychain = KeychainSwift()
    
    init() {
        self.attemptLogin {}
    }
    
    func get(key: String) -> Any {
        return self.data[key]!
    }
    
    func getString(key: String) -> String {
        return self.data[key] as? String ?? ""
    }
    
    func getBool(key: String) -> Bool {
        return self.data[key] as? Bool ?? false
    }
    
    func getNumber(key: String) -> Int {
        return self.data[key] as? Int ?? 0
    }
    
    func getStoredCredentials() -> Credentials {
        let username = keychain.get("username") ?? ""
        let password = keychain.get("password") ?? ""
        
        return Credentials(username: username, password: password)
    }
    
    func storeCredentials(credentials: Credentials) {
        if(credentials.username.isEmpty || credentials.password.isEmpty) {
            return
        }
            
        let username = credentials.username.hasSuffix("@utem.cl") ? credentials.username : "\(credentials.username)@utem.cl"
        keychain.set(username, forKey: "username")
        keychain.set(credentials.password, forKey: "password")
    }
    
    func attemptLogin(onFinish: @escaping () -> Void) {
        let username = keychain.get("username") ?? ""
        let password = keychain.get("password") ?? ""
        if(!username.isEmpty && !password.isEmpty) {
            Just.post(
                server,
                data: ["correo": username, "contrasenia": password],
                headers: ["Content-Type": "application/json"],
                asyncCompletionHandler: { response in
                    let json = response.json as? [String: Any] ?? [:]
                    if(response.ok) {
                        DispatchQueue.main.async {
                            if(json["correoUtem"] != nil) {
                                self.data = json
                            }
                            self.status = "ok"
                            onFinish()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.status = (json["mensaje"] as? String) ?? "Error desconocido! Por favor intenta más tarde."
                            onFinish()
                        }
                    }
                }
            )
        } else {
            DispatchQueue.main.async {
                self.status = "Por favor ingresa tus credenciales!"
                onFinish()
            }
        }
    }
    
    func logout() {
        self.keychain.delete("username")
        self.keychain.delete("password")
        self.status = nil
        self.data = [:]
    }
}
