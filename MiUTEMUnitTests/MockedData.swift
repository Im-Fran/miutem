//
//  MockedData.swift
//  MiUTEMUnitTests
//
//  Created by Francisco Solis Maturana on 03-08-23.
//

import Foundation

public final class MockedData {
    /* Auth */
    public static let authResponseJson: URL = Bundle(for: MockedData.self).url(forResource: "AuthResponse", withExtension: "json")!
    
    /* Permisos */
    public static let permisosSimplesResponseJson: URL = Bundle(for: MockedData.self).url(forResource: "PermisosResponse", withExtension: "json")!
    public static let permisoDetalleResponseJson: URL = Bundle(for: MockedData.self).url(forResource: "PermisoResponse", withExtension: "json")!
}
