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
    @Published var permisosSimples: [PermisoSimple] = []
    @Published var carreras: [Carrera] = []
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
        PermisoService.invalidatePermisos()
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
        DispatchQueue.global(qos: .utility).async {
            let permisosSimples = PermisoService.getPermisos(credentials: self.getStoredCredentials())
            DispatchQueue.main.async {
                self.permisosSimples = permisosSimples
                onFinish()
            }
        }
    }
    
    func attemptLogin(onFinish: @escaping () -> Void = {}) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("Intentando login...")
            let storage = try? Storage<String, Perfil>(
                diskConfig: DiskConfig(name: "miutem.perfil", expiry: .seconds(604800), protectionType: .complete),
                memoryConfig: MemoryConfig(expiry: .seconds(604800)),
                transformer: TransformerFactory.forCodable(ofType: Perfil.self)
            )
            try? storage?.removeExpiredObjects()
            print("Perfil en cache cargado!")
            
            var perfil: Perfil? = try? storage?.object(forKey: "perfil")
            if(perfil != nil) {
                // Prueba el token al hacer una solicitud a carreras y guardarla en el perfil
                let carreras = CarreraService.getCarreras(token: perfil!.token)
                if(!carreras.isEmpty) {
                    print("Datos en cache válidos!")
                    return DispatchQueue.main.async {
                        self.perfil = perfil
                        self.carreras = carreras
                        self.status = "ok"
                        onFinish()
                    }
                }
            }
            
            
            let username = self.keychain.get("username") ?? ""
            let password = self.keychain.get("password") ?? ""
            if(username.isEmpty || password.isEmpty) {
                print("Credenciales vacias.")
                return DispatchQueue.main.async {
                    self.status = nil
                    onFinish()
                }
            }
            
            print("Probando credenciales...")
            let response = Just.post("https://api.exdev.cl/v1/auth", data: ["correo": username, "contrasenia": password], headers: ["Content-Type": "application/json"])
            let json = response.json as? [String: Any] ?? [:]
            if(!response.ok || json["mensaje"] != nil) {
                let error = json["mensaje"] as? String ?? "Error desconocido! Por favor intenta más tarde."
                print("Error en respuesta. \(error)")
                return DispatchQueue.main.async {
                    self.status = error
                    onFinish()
                }
            }
            
            perfil = JsonService.fromJson(Perfil.self, json)
            if(perfil == nil) {
                print("Perfil nulo")
                return DispatchQueue.main.async {
                    self.status = "Error al decodificar datos! Intenta más tarde."
                    onFinish()
                }
            }
            
            // Ahora se obtiene las carreras
            let carreras = CarreraService.getCarreras(token: perfil!.token)
            if(carreras.isEmpty) {
                print("Carreras no encontradas")
                return DispatchQueue.main.async {
                    self.status = "Error al obtener datos de carreras! Intenta más tarde."
                    onFinish()
                }
            }
            
            print("Todo ok!")
            
            return DispatchQueue.main.async {
                self.perfil = perfil
                self.carreras = carreras
                try? storage?.setObject(perfil!, forKey: "perfil")
                self.status = "ok"
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
