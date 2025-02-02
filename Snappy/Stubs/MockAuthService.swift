//
//  MockAuthService.swift
//  Snappy
//
//  Created by Bobby Ren on 2/2/25.
//  Copyright © 2025 RenderApps LLC. All rights reserved.
//

import Foundation
import RenderCloud


struct MockUser: RenderCloud.User {
    let id: String
    let username: String
}
/*
class MockAuthService: CloudAuthService {
    var mockUser: RenderCloud.User?

    func signup(username: String, password: String) async throws -> any RenderCloud.User {
        let user = MockUser(id: "123", username: username)
        mockUser = user
        return user
    }
    
    func login(username: String, password: String) async throws -> any RenderCloud.User {
        let user = MockUser(id: "123", username: username)
        mockUser = user
        return user
    }
    
    func logout() throws {
        mockUser = nil
    }
    
    var delegate: (any RenderCloud.CloudAuthServiceDelegate)?
}
*/
