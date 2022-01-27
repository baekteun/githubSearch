//
//  Search.swift
//  GithubSearch
//
//  Created by 최형우 on 2022/01/27.
//  Copyright © 2022 baegteun. All rights reserved.
//

import ComposableArchitecture

struct SearchState: Equatable{
    var searchQuery = ""
    var users: [User] = []
    var nextURL: URL?
}

enum SearchAction {
    case updateQuery(String)
    case getNextUsers
    case usersResponse(Result<([User], URL?), GithubClient.Failure>)
    case updateUser(Result<User, GithubClient.Failure>, _ index: Int)
    case appendUsers(Result<([User], URL?), GithubClient.Failure>)
}

struct SearchEnvironment {
    var githubClient: GithubClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment>{ state, action, env in
    struct SearchUserID: Hashable {}
    switch action{
    case let .updateQuery(q):
        state.searchQuery = q
        guard !q.isEmpty else {
            state.users = []
            return .cancel(id: SearchUserID())
        }
        
        return env.githubClient
            .searchUsers(q)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .debounce(id: SearchUserID(), for: 0.3, scheduler: env.mainQueue)
            .map(SearchAction.usersResponse)
            .cancellable(id: SearchUserID(), cancelInFlight: true)
        
    case .getNextUsers:
        guard let nextUrl = state.nextURL else {
            return .none
        }
        return env.githubClient
            .getNextUsers(nextUrl)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .debounce(id: SearchUserID(), for: 0.3, scheduler: env.mainQueue)
            .map(SearchAction.usersResponse)
            .cancellable(id: SearchUserID(), cancelInFlight: true)
        
    case let .usersResponse(.success((users, nextUrl))):
        struct UsersRepoCountID: Hashable {}
        state.users = users
        state.nextURL = nextUrl
        
        return Effect.merge(users.enumerated().map { index, user in
            env.githubClient
                .getUser(user.name)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map { SearchAction.updateUser($0, index) }
        })
        
    case let .usersResponse(.failure(error)):
        return .none
        
    case let .updateUser(.success(user), index):
        state.users[index] = user
        return .none
        
    case let .updateUser(.failure(error), _):
        return .none
        
    case let .appendUsers(.success((users, nextUrl))):
        state.users.append(contentsOf: users)
        state.nextURL = nextUrl
        
        return Effect.merge(users.enumerated().map { index, user in
            env.githubClient
                .getUser(user.name)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map { SearchAction.updateUser($0, index) }
        })
    case let .appendUsers(.failure(error)):
        return .none
    }
}
