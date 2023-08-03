//
//  PermisoService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 02-08-23.
//

import Cache
import Foundation
import Just

class PermisoService {
    
    private static let storageSimple = try? Storage<String, [PermisoSimple]>(
        diskConfig: DiskConfig(name: "miutem.permisos-simples", expiry: .seconds(43200), protectionType: .complete),
        memoryConfig: MemoryConfig(expiry: .seconds(43200)),
        transformer: TransformerFactory.forCodable(ofType: [PermisoSimple].self)
    )
    
    private static let storageDetalle = try? Storage<String, Permiso>(
        diskConfig: DiskConfig(name: "miutem.permisos-detalle", expiry: .seconds(43200), protectionType: .complete),
        memoryConfig: MemoryConfig(expiry: .seconds(43200)),
        transformer: TransformerFactory.forCodable(ofType: Permiso.self)
    )
    
    static func invalidatePermisos() {
        try? storageSimple?.removeObject(forKey: "permisos")
    }
    
    static func getPermisos(credentials: Credentials) -> [PermisoSimple] {
        try? storageSimple?.removeExpiredObjects()
        
        var permisos: [PermisoSimple] = (try? storageSimple?.object(forKey: "permisos")) ?? []
        if(permisos.isEmpty) {
            let response = Just.post("https://api.exdev.cl/v1/permisos", json: ["correo": credentials.username, "contrasenia": credentials.password], headers: ["Content-Type": "application/json"])
            if(response.ok){
                permisos = JsonService.fromJsonArray([PermisoSimple].self, response.json!) ?? []
                try? storageSimple?.setObject(permisos, forKey: "permisos")
            }
        }
        
        return permisos
    }
    
    static func getDetalle(permisoSimple: PermisoSimple, credentials: Credentials) -> Permiso? {
        try? storageDetalle?.removeExpiredObjects()
        
        var permiso: Permiso? = try? storageDetalle?.object(forKey: permisoSimple.id)
        if(permiso == nil) {
            let response = Just.post("https://api.exdev.cl/v1/permisos/\(permisoSimple.id)", json: ["correo": credentials.username, "contrasenia": credentials.password], headers: ["Content-Type": "application/json"])
            if(response.ok){
                permiso = JsonService.fromJson(Permiso.self, response.json!)
                if(permiso != nil) {
                    try? storageDetalle?.setObject(permiso!, forKey: permisoSimple.id)
                }
            }
        }
        
        return permiso
    }
}
