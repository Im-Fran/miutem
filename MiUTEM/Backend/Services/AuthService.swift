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
        let storage = try? Storage<String, [Permiso]>(
            diskConfig: DiskConfig(name: "miutem.permisos", expiry: .seconds(43200), protectionType: .complete),
            memoryConfig: MemoryConfig(expiry: .seconds(43200)),
            transformer: TransformerFactory.forCodable(ofType: [Permiso].self)
        )
        try? storage?.removeObject(forKey: "permisos")
    }
    
    func extractLinesFromPDFData(_ pdfData: Data) -> [String] {
        guard let pdfDocument = PDFDocument(data: pdfData) else {
            return []
        }
        
        var lines: [String] = []
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string {
                    let pageLines = pageText.components(separatedBy: .newlines)
                    lines.append(contentsOf: pageLines)
                }
            }
        }
        
        return lines
    }
    
    func loadPermisos(onFinish: @escaping () -> Void = {}) {
        Task {
            let storage = try? Storage<String, [Permiso]>(
                diskConfig: DiskConfig(name: "miutem.permisos", expiry: .seconds(43200), protectionType: .complete),
                memoryConfig: MemoryConfig(expiry: .seconds(43200)),
                transformer: TransformerFactory.forCodable(ofType: [Permiso].self)
            )
            try? storage?.removeExpiredObjects()
            
            let saved = try? storage?.object(forKey: "permisos")
            if(saved != nil && saved?.isEmpty == false) {
                self.permisos = saved!
            } else {
                let cookies = (try? self.getMiUTEMCookies()) ?? [:]
                if(cookies.isEmpty) {
                    print("Error al cargar permisos! (Falla en autenticar)")
                    onFinish()
                    return
                }
                
                let csrfToken = cookies["csrftoken"] ?? ""
                let sessionId = cookies["sessionid"] ?? ""
                let solicitudesResponse = Just.post("https://mi.utem.cl/solicitudes/solicitudes_ingreso", data: ["tipo_envio": "4", "csrfmiddlewaretoken": csrfToken], headers: ["Cookie": "csrftoken=\(csrfToken); sessionid=\(sessionId)"])
                if(!solicitudesResponse.ok) {
                    print("Error al cargar permisos! (Falla al descargar)")
                    onFinish()
                    return
                }
                
                let json = solicitudesResponse.json as! [String: Any]

                var localPermisos: [Permiso] = []
                if let dataArray = json["data"] as? [[String: Any]] {
                    for dataObject in dataArray {
                        var data: [String: String] = [:]
                        data["token"] = (try? SwiftSoup.parse((dataObject["btn_descarga"] as? String) ?? "").select("a[token]").attr("token")) ?? ""
                        if((data["token"] ?? "").isEmpty) {
                            continue
                        }
                        data["fechaSolicitud"] = (dataObject["fecha_solicitud"] as? String) ?? ""
                        ["campus", "edificio", "jornada", "motivo", "tipo"].forEach { key in
                            data[key] = (dataObject[key] as? String) ?? ""
                        }
                        
                        // Now we look for the qr code
                        let pdfRes = Just.post("https://mi.utem.cl/solicitudes/solicitudes_ingreso", data: ["tipo_envio": "5", "csrfmiddlewaretoken": csrfToken, "solicitud": data["token"] ?? ""], headers: ["Cookie": "csrftoken=\(csrfToken); sessionid=\(sessionId)"])
                        if(!pdfRes.ok || pdfRes.content == nil || pdfRes.content?.count == 2) {
                            continue
                        }
                        
                        guard let pdfDocument = PDFDocument(data: pdfRes.content!) else {
                            continue
                        }
                        
                        let lines = extractLinesFromPDFData(pdfRes.content!)
                        debugPrint(data["motivo"] ?? "", pdfDocument.string ?? "")
                        data["codigoQr"] = lines.first { it in
                            return it.contains("\(self.perfil?.rut ?? -1)")
                        } ?? ""
                        let permiso = try? Permiso(dictionary: data)
                        if(permiso != nil) {
                            localPermisos.append(permiso!)
                        }
                    }
                }
                
                localPermisos = localPermisos.reversed()
                
                if(!localPermisos.isEmpty) {
                    try? storage?.setObject(localPermisos, forKey: "permisos")
                }
                
                self.permisos = localPermisos
            }
         
            print(self.permisos)
            onFinish()
        }
    }
    
    func attemptLogin(onFinish: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            let storage = try? Storage<String, Perfil>(
                diskConfig: DiskConfig(name: "miutem.perfil", expiry: .seconds(604800), protectionType: .complete),
                memoryConfig: MemoryConfig(expiry: .seconds(604800)),
                transformer: TransformerFactory.forCodable(ofType: Perfil.self)
            )
            try? storage?.removeExpiredObjects()
            
            let perfil = try? storage?.object(forKey: "perfil")
            if(perfil != nil) {
                self.perfil = perfil!
            }
            
            
            let username = self.keychain.get("username") ?? ""
            let password = self.keychain.get("password") ?? ""
            if(!username.isEmpty && !password.isEmpty) {
                let response = Just.post(self.server, data: ["correo": username, "contrasenia": password], headers: ["Content-Type": "application/json"])
                let json = response.json as? [String: Any] ?? [:]
                if(response.ok && json["correoUtem"] != nil) {
                    self.perfil = try? Perfil(dictionary: json)
                    if(self.perfil != nil) {
                        try? storage?.setObject(self.perfil!, forKey: "perfil")
                        self.status = "ok"
                        onFinish()
                    } else {
                        self.status = "Error al decodificar datos! Intenta más tarde."
                        onFinish()
                    }
                } else {
                    self.status = (json["mensaje"] as? String) ?? "Error desconocido! Por favor intenta más tarde."
                    onFinish()
                }
            } else {
                self.status = nil
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
        var loginResponse = Just.get("https://mi.utem.cl/")
        if((loginResponse.text?.contains("id=\"kc-form-login\"") == true || (saved?["csrftoken"] ?? "none") == "none")) {
            let credentials = getStoredCredentials()
            if(credentials.username.isEmpty || credentials.password.isEmpty) {
                DispatchQueue.main.async {
                    self.status = nil
                }
                return [:]
            }
            
            let initialCookies = loginResponse.headers["Set-Cookie"] ?? ""
            let loginUri = try SwiftSoup.parse(loginResponse.text!).select("form[id=kc-form-login]").attr("action")
            var tries = 0
            
            while (loginResponse.text?.contains("You are already logged in.") == false && tries < 3) {
                loginResponse = Just.post(loginUri, data: [
                    "username": credentials.username,
                    "password": credentials.password
                ], headers: [
                    "Cookie": initialCookies,
                ])
                tries += 1
            } // Triple post to make sure we have the data :D or at least until we hear a good call!
            
            if loginResponse.text?.contains("You are already logged in") == false {
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
            }.filter { cookies in
                ["sessionid", "csrftoken"].contains(cookies.key)
            }
            
            if(cookies.count > 0) {
                try storage?.setObject(cookies, forKey: "cookies")
                saved = cookies
            }
        }
        
        return saved ?? [:]
    }
}
