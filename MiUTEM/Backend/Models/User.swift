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
    @Published var hasCredentials: Bool = false
    let server = "https://api.exdev.cl/v1/auth"
    let keychain = KeychainSwift()
    
    init() {
        let username = keychain.get("username") ?? ""
        let password = keychain.get("password") ?? ""
        if(!username.isEmpty && !password.isEmpty) {
            hasCredentials.toggle()
        }
    }
    
    func storeCredentials(credentials: Credentials) throws {
        keychain.set(credentials.username, forKey: "username")
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
                    if(response.ok) {
                        print("Response:", response.json ?? "{}")
                    }
                    
                    DispatchQueue.main.async {
                        self.status = nil
                        onFinish()
                    }
                }
            )
        } else {
            Task {
                try await Task.sleep(nanoseconds: 2000000000)
                
                DispatchQueue.main.async {
                    self.status = "Por favor ingresa tus credenciales!"
                    onFinish()
                }
            }
        }
    }
}
