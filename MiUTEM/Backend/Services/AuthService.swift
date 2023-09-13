//
//  AuthService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 26-06-23.
//

import Foundation
import KeychainSwift
import Combine

class CredentialsService {
    private static var onLogout = {}
    
    private static let keychain = KeychainSwift()
    
    static func getStoredCredentials() -> Credentials {
        if Helpers.isRunningPreview() {
            return Credentials(correo: "john.doe@utem.cl", contrasenia: "password")
        }
        
        return Credentials(correo: keychain.get("correo") ?? "", contrasenia: keychain.get("contrasenia") ?? "")
    }
    
    static func storeCredentials(credentials: Credentials) {
        if(credentials.correo.isEmpty || credentials.contrasenia.isEmpty || Helpers.isRunningPreview()) {
            return
        }
        
        let correo = credentials.correo.hasSuffix("@utem.cl") ? credentials.correo : "\(credentials.correo)@utem.cl"
        keychain.set(correo, forKey: "correo")
        keychain.set(credentials.contrasenia, forKey: "contrasenia")
    }
    
    static func hasCredentials() -> Bool {
        if Helpers.isRunningPreview() {
            return true
        }
        
        return keychain.get("correo")?.isEmpty == false && keychain.get("contrasenia")?.isEmpty == false
    }
    
    static func setOnLogout(onLogout: @escaping () -> ()) {
        CredentialsService.onLogout = onLogout
    }
    
    static func logout() {
        AuthService.clearCache()
        
        keychain.delete("correo")
        keychain.delete("contrasenia")
        
        CredentialsService.onLogout()
    }
}

class AuthService {
    
    static func hasCachedPerfil() -> Bool {
        if Helpers.isRunningPreview() {
            return true
        }
        
        return (try? GlobalStorage.shared?.existsObject(forKey: "perfil")) ?? false
    }
    
    static func getPerfil() async throws -> Perfil {
        if Helpers.isRunningPreview() {
            return Perfil(
                token: "token",
                correoPersonal: "john.doe@example.com",
                correoUtem: "john.doe@utem.cl",
                username: "john.doe",
                rut: 22492396, // Obtenido de un generador de rut
                nombreCompleto: "JOHN DOE",
                nombres: "JOHN",
                apellidos: "DOE",
                perfiles: ["Estudiante"]
            )
        }
        
        try? GlobalStorage.shared?.removeExpiredObjects()
        if let perfil = try? GlobalStorage.shared?.transformCodable(ofType: Perfil.self).object(forKey: "perfil") {
            return perfil
        }
        
        let (data, _, error) = try await HTTPRequest(method: .post, uri: "https://api.exdev.cl/v1/auth", body: .json(CredentialsService.getStoredCredentials())).perform()
        
        if error != nil {
            throw error as! ServerError
        }
        
        if data == nil {
            throw ServerError.networkError
        }
        

        let perfil = try JsonService.fromJson(Perfil.self, data!)
        try? GlobalStorage.shared?.transformCodable(ofType: Perfil.self).setObject(perfil, forKey: "perfil")
        return perfil
    }
    
    static func clearCache() {
        try? GlobalStorage.shared?.removeExpiredObjects()
        try? GlobalStorage.shared?.removeObject(forKey: "perfil")
    }
}
