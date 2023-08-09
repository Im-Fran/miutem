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

struct Credentials: Codable {
    var correo: String
    var contrasenia: String
}

struct Perfil: Codable {
    var token: String
    
    var correoPersonal: String
    var correoUtem: String
    var username: String
    var rut: Int
    var dv: String {
        return "\(rut)".calcularDigitoVerificador() ?? ""
    }
    var rutCompleto: String {
        let rut = "\(rut)"
        return "\(rut.agregarPuntosDecimales() ?? "")-\(rut.calcularDigitoVerificador() ?? "")"
    }
    
    var nombreCompleto: String
    var iniciales: String {
        return nombreCompleto.components(separatedBy: " ").map { it in
            return it.first?.description ?? ""
        }.joined(separator: "")
    }
    
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
