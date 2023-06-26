//
//  User.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 21-06-23.
//

import Cache
import Foundation
import Just
import KeychainSwift
import SwiftSoup

struct Credentials {
    var username: String
    var password: String
}

struct Perfil: DictionaryDecodable {
    var token: String
    
    var correoPersonal: String
    var correoUtem: String
    var username: String
    var rut: Int
    
    var nombreCompleto: String
    
    var nombres: String
    var primerNombre: String {
        return nombres.components(separatedBy: " ").first?.capitalized ?? ""
    }
    var segundosNombres: String {
        return nombres.components(separatedBy: " ").allFrom(index: 1).joined(separator: " ")
    }
    
    var apellidos: String
    var primerApellido: String {
        return apellidos.components(separatedBy: " ").first?.capitalized ?? ""
    }
    var segundoApellido: String {
        return apellidos.components(separatedBy: " ").allFrom(index: 1).joined(separator: " ")
    }
    
    var perfiles: [String]
}
