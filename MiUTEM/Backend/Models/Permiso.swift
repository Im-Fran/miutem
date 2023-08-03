//
//  Permiso.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 25-06-23.
//

import Foundation
import Just

struct Permiso: Codable {
    var codigoValidacion: String
    var fechaSolicitud: String
    var motivo: String
    var codigoQr: String
    var codigoBarra: String
    var jornada: String
    var perfil: String
    var vigencia: String
    var campus: String?
    var dependencia: String?
}

struct PermisoSimple: Codable, Hashable {
    var id: String
    var perfil: String
    var motivo: String
    var campus: String?
    var dependencia: String?
    var jornada: String
    var fechaSolicitud: String
}
