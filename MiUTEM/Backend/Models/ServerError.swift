//
//  ServerError.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 04-08-23.
//

import Foundation

struct ServerError: Error, Codable {
    var codigoHttp, codigoInterno: Int?
    var error: String?
    var mensaje: String
    
    var localizedDescription: String {
        mensaje
    }
    
    static let networkError = ServerError(mensaje: "Error de conexión! Por favor intenta más tarde")
    static let internalError = ServerError(mensaje: "Error interno! Por favor intenta más tarde")
    static let decodeError = ServerError(mensaje: "Error al decodificar datos! Por favor intenta más tarde")
    static let encodeError = ServerError(mensaje: "Error al codificar datos! Por favor intenta más tarde")
    static let unknownError = ServerError(mensaje: "Error desconocido! Por favor intenta más tarde")
}
