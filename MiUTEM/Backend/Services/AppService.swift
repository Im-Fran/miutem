//
//  AppService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 03-08-23.
//

import Foundation

class AppService: ObservableObject {
    var authService = AuthService()
    var permisoService = PermisosService()
}
