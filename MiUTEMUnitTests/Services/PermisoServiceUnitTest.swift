//
//  PermisoServiceUnitTest.swift
//  MiUTEMUnitTests
//
//  Created by Francisco Solis Maturana on 05-08-23.
//

import XCTest
import Mocker
@testable import MiUTEM

final class PermisoServiceUnitTests: XCTestCase {
    
    var permisosService: PermisosService?
    
    override func setUpWithError() throws {
        self.permisosService = PermisosService()
        Mock(url: URL(string: "https://api.exdev.cl/v1/permisos")!, dataType: .json, statusCode: 200, data: [
            .post: try! Data(contentsOf: MockedData.permisosSimplesResponseJson)
        ]).register() // Registra mocker
        
        Mock(url: URL(string: "https://api.exdev.cl/v1/permisos/id")!, dataType: .json, statusCode: 200, data: [
            .post: try! Data(contentsOf: MockedData.permisoDetalleResponseJson)
        ]).register() // Registra mocker
    }
    
    override func tearDownWithError() throws {
        Mocker.removeAll()
    }
    
    func test_successful_permiso_request() throws {
        
        let expectation = XCTestExpectation(description: "Obtener Permisos Simples Sin Problemas")
            
        let cancellable = self.permisosService?.getPermisosSimples(credentials: Credentials(correo: "john.doe@utem.cl", contrasenia: "contrasenia"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Se esperaba una respuesta satisfactoria, pero se obtuvo el error: \(error)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { permisosSimples in
                XCTAssertGreaterThan(permisosSimples.count, 0)
            })
            
        wait(for: [expectation], timeout: 10.0)
        cancellable?.cancel()
    }
    
    func test_successful_permiso_detalle_request() throws {
        let expectation1 = XCTestExpectation(description: "Obtener Permisos Simples Sin Problemas")
        let expectation2 = XCTestExpectation(description: "Obtener Permiso Detallado Sin Problemas")
            
        var permisosSimples: [PermisoSimple] = []
        
        var cancellable = self.permisosService?.getPermisosSimples(credentials: Credentials(correo: "john.doe@utem.cl", contrasenia: "contrasenia"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Se esperaba una respuesta satisfactoria, pero se obtuvo el error: \(error)")
                case .finished:
                    expectation1.fulfill()
                }
            }, receiveValue: { _permisosSimples in
                XCTAssertGreaterThan(_permisosSimples.count, 0)
                permisosSimples = _permisosSimples
            })
            
        wait(for: [expectation1], timeout: 10.0)
        
        cancellable = self.permisosService?.getPermisoDetallado(permisoSimple: permisosSimples.first!, credentials: Credentials(correo: "john.doe@utem.cl", contrasenia: "contrasenia"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Se esperaba una respuesta satisfactoria, pero se obtuvo el error: \(error)")
                case .finished:
                    expectation2.fulfill()
                }
            }, receiveValue: { permiso in
                XCTAssertEqual(permiso?.codigoQr, "A1B2C3D4E5F6G7H8I9J0")
                XCTAssertEqual(permiso?.codigoBarra, "01234567890AaBbC")
                XCTAssertEqual(permiso?.codigoValidacion, "A1B2C3D4E")
            })
        
        wait(for: [expectation2], timeout: 10.0)
        cancellable?.cancel()
    }
    
}

