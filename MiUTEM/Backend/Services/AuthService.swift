//
//  AuthService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 26-06-23.
//

import Cache
import Foundation
import Just
import KeychainSwift
import SwiftSoup

class AuthService: ObservableObject {
    @Published var status: String? = nil
    @Published var perfil: Perfil? = nil
    @Published var miUtemCookies: [String: String]? = nil
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
                    if(response.ok && json["correoUtem"] != nil) {
                        DispatchQueue.main.async {
                            do {
                                self.perfil = try Perfil(dictionary: json)
                                
                                Task {
                                    do {
                                        let cookies = try self.doMiUTEMAuth()
                                        if(cookies != nil) {
                                            DispatchQueue.main.async {
                                                self.miUtemCookies = cookies
                                                self.status = "ok"
                                                onFinish()
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.status = "Error al contactar servicio de MiUTEM. Intenta más tarde."
                                                onFinish()
                                            }
                                        }
                                    } catch {
                                        DispatchQueue.main.async {
                                            self.status = "Error al contactar servicio de MiUTEM. Intenta más tarde."
                                            onFinish()
                                        }
                                    }
                                }
                            } catch {
                                self.status = "Error al decodificar datos! Intenta más tarde."
                                onFinish()
                            }
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
    
    func doMiUTEMAuth() throws -> [String: String]? {
        let storage = try? Storage<String, [String: String]>(diskConfig: DiskConfig(name: "miutem.auth", expiry: .seconds(9000), protectionType: .complete), memoryConfig: MemoryConfig(expiry: .seconds(9000)), transformer: TransformerFactory.forCodable(ofType: [String: String].self))
        try storage?.removeExpiredObjects()
        
        var saved = try? storage?.object(forKey: "cookies")
        if(saved == nil) {
            let credentials = getStoredCredentials()
            let loginForm = Just.get("https://mi.utem.cl/")
            let loginUri = try SwiftSoup.parse(loginForm.text!).select("form[id=kc-form-login]").attr("action")
            var cookieHeader = ""
            loginForm.cookies.forEach { (key: String, value: HTTPCookie) in
                cookieHeader = "\(cookieHeader)\(key)=\(value.value);"
            }
            
            Just.post(loginUri, data: [ "username": credentials.username, "password": credentials.password ], headers: [ "Cookie": cookieHeader ])
            
            let loginResponse = Just.post(loginUri, data: [ "username": credentials.username, "password": credentials.password ], headers: [ "Cookie": cookieHeader ])
            
            if(loginResponse.url?.absoluteString.contains("sso.utem.cl") == false && loginResponse.url?.absoluteString.contains("session_code=") == false) {
                return nil
            }
            
            var res = Just.get("https://mi.utem.cl")
            if(res.error != nil) {
                res = Just.get(((res.error as! URLError).failingURL?.absoluteString ?? "").replacing("http://", with: "https://", maxReplacements: 1))
            }
            
            if(res.statusCode != 200) {
                return nil
            }
            
            let cookies = res.cookies.mapValues { cookie in
                return cookie.value
            }
            if(cookies.count > 0) {
                try storage?.setObject(cookies, forKey: "cookies")
                saved = cookies
            }
        }
        
        return saved
    }
}
