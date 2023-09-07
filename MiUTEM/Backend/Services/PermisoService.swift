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
    private static let mockPermisosSimples = [
        PermisoSimple(
            id: "MWFkMThlMjU=", // Obtenido con un generador de GUID (primer dato antes del primer guión '-' convertido en base64)
            perfil: "Estudiante",
            motivo: "Permiso académico de ingreso a clases",
            campus: nil,
            dependencia: nil,
            jornada: "Completa",
            fechaSolicitud: "2022-03-16T00:00:00.000Z"
        ),
    ]
    
    private static let mockPermisos = [
        Permiso(
            codigoValidacion: "A1B2C3D4E",
            fechaSolicitud: "2022-03-16T00:00:00.000Z",
            motivo: "Permiso académico de ingreso a clases",
            codigoQr: "A1B2C3D4E5F6G7H8I9J0",
            codigoBarra: "01234567890AaBbC",
            jornada: "Completa",
            perfil: "Estudiante",
            vigencia: "Semestral"
        )
    ]
    
    static func invalidateCaches() {
        try? GlobalStorage.shared?.removeExpiredObjects()
        try? GlobalStorage.shared?.removeObject(forKey: "permisos")
    }
    
    /* Obtiene permisos simples de manera async */
    static func getPermisosSimples() async throws -> [PermisoSimple] {
        if Helpers.isRunningPreview() {
            return mockPermisosSimples
        }
        
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
        if Helpers.isRunningPreview() {
            if let permiso = mockPermisos.first(where: { it in it.motivo == permisoSimple.motivo && it.fechaSolicitud == permisoSimple.fechaSolicitud }) {
                return permiso
            }
            
            throw ServerError.notFoundError
        }
        
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
