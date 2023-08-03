//
//  CarreraService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 02-08-23.
//

import Foundation
import Just

class CarreraService {
    
    static func getCarreras(token: String) -> [Carrera] {
        print("Obteniendo carreras...")
        let response = Just.get("https://api.exdev.cl/v1/carreras", headers: ["Authorization": "Bearer \(token)"])
        if(!response.ok) {
            return []
        }
        
        return JsonService.fromJsonArray([Carrera].self, response.json!) ?? []
    }
}
