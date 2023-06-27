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
import PDFKit
import SwiftSoup

class AuthService: ObservableObject {
    @Published var status: String? = nil
    @Published var perfil: Perfil? = nil
    @Published var permisos: [Permiso] = []
    let server = "https://api.exdev.cl/v1/auth"
    let keychain = KeychainSwift()
    
    init() {
        self.attemptLogin()
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
    
    func invalidatePermisos() {
        do {
            let storage = try? Storage<String, [Permiso]>(diskConfig: DiskConfig(name: "miutem.permisos", expiry: .seconds(43200), protectionType: .complete), memoryConfig: MemoryConfig(expiry: .seconds(43200)), transformer: TransformerFactory.forCodable(ofType: [Permiso].self))
            try storage?.removeObject(forKey: "permisos")
        }catch{}
    }
    
    func loadPermisos(onFinish: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            do {
                let storage = try? Storage<String, [Permiso]>(diskConfig: DiskConfig(name: "miutem.permisos", expiry: .seconds(43200), protectionType: .complete), memoryConfig: MemoryConfig(expiry: .seconds(43200)), transformer: TransformerFactory.forCodable(ofType: [Permiso].self))
                try storage?.removeExpiredObjects()
                
                let saved = try? storage?.object(forKey: "permisos")
                if(saved != nil) {
                    self.permisos = saved!
                } else {
                    let cookies = try self.getMiUTEMCookies()
                    if(cookies.isEmpty) {
                        print("No cookies were found.")
                        onFinish()
                        return
                    }
                    
                    let csrfToken = cookies["csrftoken"] ?? ""
                    let sessionId = cookies["sessionid"] ?? ""
                    let solicitudesResponse = Just.post("https://mi.utem.cl/solicitudes/solicitudes_ingreso", data: ["tipo_envio": "4", "csrfmiddlewaretoken": csrfToken], headers: ["Cookie": "csrftoken=\(csrfToken); sessionid=\(sessionId)"])
                    if(!solicitudesResponse.ok) {
                        print("Error al cargar permisos! #2")
                        onFinish()
                    }
                    
                    let json = solicitudesResponse.json as! [String: Any]

                    var localPermisos: [Permiso] = []
                    if let dataArray = json["data"] as? [[String: Any]] {
                        for dataObject in dataArray {
                            var data: [String: String] = [:]
                            data["token"] = try SwiftSoup.parse((dataObject["btn_descarga"] as? String) ?? "").select("a[token]").attr("token")
                            data["fechaSolicitud"] = (dataObject["fecha_solicitud"] as? String) ?? ""
                            ["campus", "edificio", "jornada", "motivo", "tipo"].forEach { key in
                                data[key] = (dataObject[key] as? String) ?? ""
                            }
                            
                            // Now we look for the qr code
                            let pdfRes = Just.post("https://mi.utem.cl/solicitudes/solicitudes_ingreso", data: ["tipo_envio": "5", "csrfmiddlewaretoken": csrfToken, "solicitud": data["token"] ?? ""], headers: ["Cookie": "csrftoken=\(csrfToken); sessionid=\(sessionId)"])
                            if(!pdfRes.ok || pdfRes.content == nil || pdfRes.content?.count == 2) {
                                continue
                            }
                            
                            guard let pdf = PDFDocument(data: pdfRes.content!) else {
                                continue
                            }
                            let lines = (pdf.string ?? "").components(separatedBy: .newlines).map { it in
                                return it.trimmingCharacters(in: .whitespaces)
                            }.filter { it in
                                return !it.isEmpty
                            }
                            data["codigoQr"] = lines.first { it in
                                return it.contains("\(self.perfil?.rut ?? -1)")
                            } ?? ""
                            let permiso = try Permiso(dictionary: data)
                            localPermisos.append(permiso)
                        }
                    }
                    
                    if(!localPermisos.isEmpty) {
                        try storage?.setObject(localPermisos, forKey: "permisos")
                    }
                    
                    self.permisos = localPermisos
                }
                
                print(self.permisos)
                onFinish()
            } catch {
                print("Error al cargar los permisos! #1")
                onFinish()
            }
        }
    }
    
    func attemptLogin(onFinish: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            do {
                let storage = try? Storage<String, Perfil>(diskConfig: DiskConfig(name: "miutem.perfil", expiry: .seconds(604800), protectionType: .complete), memoryConfig: MemoryConfig(expiry: .seconds(604800)), transformer: TransformerFactory.forCodable(ofType: Perfil.self))
                try storage?.removeExpiredObjects()
                
                let perfil = try storage?.object(forKey: "perfil")
                if(perfil != nil) {
                    self.perfil = perfil!
                }
            } catch {}
            
            
            let username = self.keychain.get("username") ?? ""
            let password = self.keychain.get("password") ?? ""
            if(!username.isEmpty && !password.isEmpty) {
                let response = Just.post(self.server, data: ["correo": username, "contrasenia": password], headers: ["Content-Type": "application/json"])
                let json = response.json as? [String: Any] ?? [:]
                if(response.ok && json["correoUtem"] != nil) {
                    do {
                        self.perfil = try Perfil(dictionary: json)
                        self.status = "ok"
                        onFinish()
                        
                        do {
                            let storage = try? Storage<String, Perfil>(diskConfig: DiskConfig(name: "miutem.perfil", expiry: .seconds(604800), protectionType: .complete), memoryConfig: MemoryConfig(expiry: .seconds(604800)), transformer: TransformerFactory.forCodable(ofType: Perfil.self))
                            
                            try storage?.setObject(self.perfil!, forKey: "perfil")
                        } catch {}
                    } catch {
                        self.status = "Error al decodificar datos! Intenta más tarde."
                        onFinish()
                    }
                } else {
                    self.status = (json["mensaje"] as? String) ?? "Error desconocido! Por favor intenta más tarde."
                    onFinish()
                }
            } else {
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
    
    func getMiUTEMCookies() throws -> [String: String] {
        let storage = try? Storage<String, [String: String]>(diskConfig: DiskConfig(name: "miutem.auth", expiry: .seconds(9000), protectionType: .complete), memoryConfig: MemoryConfig(expiry: .seconds(9000)), transformer: TransformerFactory.forCodable(ofType: [String: String].self))
        try storage?.removeExpiredObjects()
        
        var saved = try? storage?.object(forKey: "cookies")
        let loginForm = Just.get("https://mi.utem.cl/")
        if(loginForm.text?.contains("id=\"kc-form-login\"") == true) {
            let credentials = getStoredCredentials()
            let loginUri = try SwiftSoup.parse(loginForm.text!).select("form[id=kc-form-login]").attr("action")
            var cookieHeader = ""
            loginForm.cookies.forEach { (key: String, value: HTTPCookie) in
                cookieHeader = "\(cookieHeader)\(key)=\(value.value);"
            }
            
            Just.post(loginUri, data: [ "username": credentials.username, "password": credentials.password ], headers: [ "Cookie": cookieHeader ])
            
            let loginResponse = Just.post(loginUri, data: [ "username": credentials.username, "password": credentials.password ], headers: [ "Cookie": cookieHeader ])
            
            if(loginResponse.url?.absoluteString.contains("sso.utem.cl") == false && loginResponse.url?.absoluteString.contains("session_code=") == false) {
                return [:]
            }
            
            var res = Just.get("https://mi.utem.cl")
            if(res.error != nil) {
                res = Just.get(((res.error as! URLError).failingURL?.absoluteString ?? "").replacing("http://", with: "https://", maxReplacements: 1))
            }
            
            if(res.statusCode != 200) {
                return [:]
            }
            
            let cookies = res.cookies.mapValues { cookie in
                return cookie.value
            }
            if(cookies.count > 0) {
                try storage?.setObject(cookies, forKey: "cookies")
                saved = cookies
            }
        }
        
        return saved ?? [:]
    }
}
