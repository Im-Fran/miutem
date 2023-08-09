//
//  AuthServiceUnitTest.swift
//  MiUTEMUnitTests
//
//  Created by Francisco Solis Maturana on 03-08-23.
//

import XCTest
import Mocker
@testable import MiUTEM

final class AuthServiceUnitTests: XCTestCase {
    
    var authService: AuthService?
    
    override func setUpWithError() throws {
        self.authService = AuthService()
        self.authService?.logout() // Remover datos de cache
        self.authService?.storeCredentials(credentials: Credentials(correo: "usuario@utem.cl", contrasenia: "123567890"))
    }
    
    override func tearDownWithError() throws {
        Mocker.removeAll()
    }
    
    func test_successful_user_authentication() throws {
        Mock(url: URL(string: "https://api.exdev.cl/v1/auth")!, dataType: .json, statusCode: 200, data: [
            .post: try! Data(contentsOf: MockedData.authResponseJson)
        ]).register() // Registra mocker
        
        let expectation = XCTestExpectation(description: "Obtener Perfil Sin Problemas")
            
        let cancellable = self.authService?.getPerfil()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Se esperaba una respuesta satisfactoria, pero se obtuvo el error: \(error)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { perfil in
                XCTAssertEqual(perfil.nombreCompleto, "JOHN DOE")
                XCTAssertEqual(perfil.correoUtem, "john.doe@utem.cl")
            })
            
        wait(for: [expectation], timeout: 10.0)
        cancellable?.cancel()
    }

    func test_unsuccessful_user_authentication() throws {
        Mock(url: URL(string: "https://api.exdev.cl/v1/auth")!, dataType: .json, statusCode: 401, data: [
            .post: try JSONEncoder().encode(["mensaje": "Credenciales inválidas!"])
        ]).register()
        let expectation = XCTestExpectation(description: "Get Perfil Retorna Error")
        
        let cancellable = self.authService?.getPerfil() // Obtener perfil
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                case .finished:
                    break;
                }
            }, receiveValue: { val in
                XCTFail("Se esperaba un error pero se obtuvo: \(val)") // Valor inesperado
            })

        wait(for: [expectation], timeout: 10.0)
        cancellable?.cancel()
    }
    
}

