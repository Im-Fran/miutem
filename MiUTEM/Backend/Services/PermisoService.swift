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

struct PermisosService {
    private let storageSimple = try? Storage<String, [PermisoSimple]>(
        diskConfig: DiskConfig(name: "miutem.permisos-simples", expiry: .seconds(43200), protectionType: .complete),
        memoryConfig: MemoryConfig(expiry: .seconds(43200)),
        transformer: TransformerFactory.forCodable(ofType: [PermisoSimple].self)
    )
    
    private let storageDetalle = try? Storage<String, Permiso>(
        diskConfig: DiskConfig(name: "miutem.permisos-detalle", expiry: .seconds(43200), protectionType: .complete),
        memoryConfig: MemoryConfig(expiry: .seconds(43200)),
        transformer: TransformerFactory.forCodable(ofType: Permiso.self)
    )
    
    func invalidateCaches() {
        try? storageSimple?.removeAll()
        try? storageDetalle?.removeAll()
    }
    
    func getPermisosSimples(credentials: Credentials) -> AnyPublisher<[PermisoSimple], ServerError> {
        try? storageSimple?.removeExpiredObjects()
        if let permisos = try? storageSimple?.object(forKey: "permisos") {
            return Just(permisos)
                .setFailureType(to: ServerError.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "https://api.exdev.cl/v1/permisos") else {
            return Fail(error: ServerError.networkError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: 20.0)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(credentials)
        } catch {
            return Fail(error: ServerError.encodeError).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                ServerError(mensaje: error.localizedDescription)
            }
            .map(\.data)
            .flatMap(maxPublishers: .max(1)) { data -> AnyPublisher<[PermisoSimple], ServerError> in
                print("decoding...")
                do {
                    if let serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
                        return Fail(error: serverError).eraseToAnyPublisher()
                    }
                    
                    let permisos = try JSONDecoder().decode([PermisoSimple].self, from: data)
                    try? storageSimple?.setObject(permisos, forKey: "permisos")
                    return Just(permisos)
                        .setFailureType(to: ServerError.self)
                        .eraseToAnyPublisher()
                } catch {
                    print(error)
                    return Fail(error: ServerError.decodeError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getPermisoDetallado(permisoSimple: PermisoSimple, credentials: Credentials) -> AnyPublisher<Permiso?, Never> {
        guard let url = URL(string: "https://api.exdev.cl/v1/permisos/\(permisoSimple.id)") else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(credentials)
        } catch {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Permiso?.self, decoder: JSONDecoder())
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
