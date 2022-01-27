//
//  User.swift
//  GithubSearch
//
//  Created by 최형우 on 2022/01/27.
//  Copyright © 2022 baegteun. All rights reserved.
//

import Foundation
import ComposableArchitecture


// MARK: - API Model
struct SearchUserResponse: Codable{
    let items: [User]
}

struct User: Equatable, Codable{
    let id: Int
    let name: String
    let avatarUrlString: String?
    let repoCount: Int?
    
    var avatarUrl: URL? {
        guard let avatarUrlString = avatarUrlString else { return nil }
        return URL(string: avatarUrlString)
    }
}

extension User{
    private enum CodingKeys: String, CodingKey{
        case id
        case name = "login"
        case avatarUrlString = "avatar_url"
        case repoCount = "public_repos"
    }
}

// MARK: - API Client Interface
struct GithubClient{
    var searchUsers: (String) -> Effect<([User], URL?), Failure>
    var getNextUsers: (URL) -> Effect<([User], URL?), Failure>
    var getUser: (String) -> Effect<User, Failure>
    
    struct Failure: Error, Equatable {}
}

