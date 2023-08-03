//
//  Helpers.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 22-06-23.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ShapeStyle where Self == Color {
    
    public static var brand: Color { get { return Color(hex: 0xFF009D9B) } }
    public static var brandLight: Color { get { return Color(hex: 0xFF45BBBC) } }
    public static var brandDark: Color { get { return Color(hex: 0xFF007F7B) } }
    
    public static var utemAzul: Color { get { return Color(hex: 0xFF06607A) } }
    public static var utemVerde: Color { get { return Color(hex: 0xFF1D8E5C) } }
    
    public static var darkGrey: Color { get { return Color(hex: 0xFF363636) } }
    public static var grey: Color { get { return Color(hex: 0xFF7F7F7F) } }
    public static var mediumGrey: Color { get { return Color(hex: 0xFFBDBDBD) } }
    public static var lightGrey: Color { get { return Color(hex: 0xFFF1F1F1) } }
    
}

var brandGradient: LinearGradient { get { return LinearGradient(colors: [Color("brandGreen"), Color("brandBlue")], startPoint: .topTrailing, endPoint: .bottomLeading) } }

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

func generateRandomBytes(length: Int) -> Data? {
    var randomBytes = [UInt8](repeating: 0, count: length)
    
    var status = errSecSuccess
    repeat {
        status = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        if status != errSecSuccess {
            print("Failed to generate random bytes. Status: \(status)")
        }
    } while status != errSecSuccess
    
    return Data(randomBytes)
}

extension Array {
    func allFrom(index: Int) -> ArraySlice<Element> {
        guard index >= 0 && index <= count else {
            return []
        }
        return self[index..<count]
    }
}

protocol DictionaryDecodable: Decodable {
    init(dictionary: [String: Any]) throws
}

extension DictionaryDecodable {
    init(dictionary: [String: Any]) throws {
        try self.init(dictionary: dictionary, decoder: JSONDecoder())
    }
    
    init(dictionary: [String: Any], decoder: JSONDecoder) throws {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        self = try decoder.decode(Self.self, from: data)
    }
    
    init(array: [[String: Any]]) throws {
        try self.init(array: array, decoder: JSONDecoder())
    }
        
    init(array: [[String: Any]], decoder: JSONDecoder) throws {
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        self = try decoder.decode(Self.self, from: data)
    }
}

extension String {
    
    func calcularDigitoVerificador() -> String? {
        let rut = self
        let rutReverso = String(rut.reversed())
        
        let serie = [2, 3, 4, 5, 6, 7, 2, 3, 4, 5, 6, 7] // Serie de multiplicadores
        var suma = 0
        
        for (index, char) in rutReverso.enumerated() {
            if let numero = Int(String(char)) {
                let multiplicador = serie[index % serie.count]
                suma += numero * multiplicador
            } else {
                return nil // El rut contiene caracteres no numéricos
            }
        }
        
        let resto = suma % 11
        let digitoVerificador: String
        
        if resto == 0 {
            digitoVerificador = "0"
        } else if resto == 10 {
            digitoVerificador = "K"
        } else {
            digitoVerificador = String(11 - resto)
        }
        
        return digitoVerificador
    }
    
    func agregarPuntosDecimales() -> String? {
        let numero = self
        guard let numeroInt = Int(numero) else {
            return nil // El número no es válido
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        
        if let numeroFormateado = formatter.string(from: NSNumber(value: numeroInt)) {
            return numeroFormateado
        } else {
            return nil // Error al formatear el número
        }
    }
}
