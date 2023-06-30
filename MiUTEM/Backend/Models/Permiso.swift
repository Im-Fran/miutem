//
//  Permiso.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 25-06-23.
//

import Foundation
import Just

struct Permiso: DictionaryDecodable, Encodable {
    var token: String
    
    var campus: String
    var edificio: String
    var fechaSolicitud: String
    var jornada: String
    var motivo: String
    var tipo: String
    var codigoQr: String
    var vigencia: String
}
