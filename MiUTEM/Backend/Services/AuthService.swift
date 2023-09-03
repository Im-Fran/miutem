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
    private static let keychain = KeychainSwift()
    
    static func getStoredCredentials() -> Credentials {
        Credentials(correo: keychain.get("correo") ?? "", contrasenia: keychain.get("contrasenia") ?? "")
    }
    
    static func storeCredentials(credentials: Credentials) {
        if(credentials.correo.isEmpty || credentials.contrasenia.isEmpty) {
            return
        }
        
        let correo = credentials.correo.hasSuffix("@utem.cl") ? credentials.correo : "\(credentials.correo)@utem.cl"
        keychain.set(correo, forKey: "correo")
        keychain.set(credentials.contrasenia, forKey: "contrasenia")
    }
    
    static func hasCredentials() -> Bool {
        keychain.get("correo")?.isEmpty == false && keychain.get("contrasenia")?.isEmpty == false
    }
    
    static func logout() {
        keychain.delete("correo")
        keychain.delete("contrasenia")
    }
}

class AuthService {
    
    static func hasCachedPerfil() -> Bool {
        return (try? GlobalStorage.shared?.existsObject(forKey: "perfil")) ?? false
    }
    
    static func getPerfil() async throws -> Perfil {
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
