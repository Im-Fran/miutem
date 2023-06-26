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

struct Perfil: DictionaryDecodable {
    var token: String
    
    var correoPersonal: String
    var correoUtem: String
    var username: String
    var rut: Int
    
    var nombreCompleto: String
    
    var nombres: String
    var primerNombre: String {
        return nombres.components(separatedBy: " ").first?.capitalized ?? ""
    }
    var segundosNombres: String {
        return nombres.components(separatedBy: " ").allFrom(index: 1).joined(separator: " ")
    }
    
    var apellidos: String
    var primerApellido: String {
        return apellidos.components(separatedBy: " ").first?.capitalized ?? ""
    }
    var segundoApellido: String {
        return apellidos.components(separatedBy: " ").allFrom(index: 1).joined(separator: " ")
    }
    
    var perfiles: [String]
}

class User: ObservableObject {
    @Published var status: String? = nil
    @Published var perfil: Perfil? = nil
    let server = "https://api.exdev.cl/v1/auth"
    let keychain = KeychainSwift()
    
    init() {
        self.attemptLogin {}
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
                                do {
                                    self.perfil = try Perfil(dictionary: json)
                                } catch {
                                    self.status = "Error al decodificar datos! Intenta más tarde."
                                }
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
        self.perfil = nil
    }
}
