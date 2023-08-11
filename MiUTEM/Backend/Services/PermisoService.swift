//
//  PermisoService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 02-08-23.
//

import Foundation
import Cache
import Combine
import Just

class PermisosService {
    static func invalidateCaches() {
        try? GlobalStorage.shared?.removeExpiredObjects()
        try? GlobalStorage.shared?.removeObject(forKey: "permisos")
    }
    
    /* Obtiene permisos simples de manera async */
    static func getPermisosSimples() async throws -> [PermisoSimple] {
        try? GlobalStorage.shared?.removeExpiredObjects()
        if let permisos = try? GlobalStorage.shared?.transformCodable(ofType: [PermisoSimple].self).object(forKey: "permisos") {
            return permisos
        }
        
        let (data, _, _) = try await HTTPRequest(method: .post, uri: "https://api.exdev.cl/v1/permisos", body: .json(CredentialsService.getStoredCredentials())).perform()
        if data == nil {
            throw ServerError.networkError
        }
        
        let permisosSimples = try JSONDecoder().decode([PermisoSimple].self, from: data!)
        try? GlobalStorage.shared?.transformCodable(ofType: [PermisoSimple].self).setObject(permisosSimples, forKey: "permisos")
        return permisosSimples
    }
    
    /* Obtiene permiso detallado de manera async */
    static func getPermisoDetallado(permisoSimple: PermisoSimple) async throws -> Permiso {
        try? GlobalStorage.shared?.removeExpiredObjects()
        if let permiso = try? GlobalStorage.shared?.transformCodable(ofType: Permiso.self).object(forKey: "permiso.\(permisoSimple.id)") {
            return permiso
        }
        
        let (data, _, _) = try await HTTPRequest(method: .post, uri: "https://api.exdev.cl/v1/permisos/\(permisoSimple.id)", body: .json(CredentialsService.getStoredCredentials())).perform()
        if data == nil {
            throw ServerError.networkError
        }
        
        let permiso = try JSONDecoder().decode(Permiso.self, from: data!)
        try? GlobalStorage.shared?.transformCodable(ofType: Permiso.self).setObject(permiso, forKey: "permiso.\(permisoSimple.id)")
        return permiso
    }
    
    /* Genera un codigo qr basado el permiso y su tamaño. */
    static func generateQr(permiso: Permiso, size: CGSize = .init(width: 128, height: 128)) async -> Image? {
        try? GlobalStorage.shared?.removeExpiredObjects()
        if let cached = try? GlobalStorage.shared?.transformImage().object(forKey: "qr.\(permiso.codigoQr)-\(size.width)x\(size.height)") {
            return cached
        }
        
        if let image = QRGeneratorService.qrCode(text: permiso.codigoQr, size: size) {
            try? GlobalStorage.shared?.transformImage().setObject(image, forKey: "qr.\(permiso.codigoQr)-\(size.width)x\(size.height)")
            return image
        }
        
        return nil
    }
    
}
