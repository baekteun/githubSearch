//
//  TargetApp.swift
//  Target
//
//  
//

import SwiftUI
import ComposableArchitecture

@main
struct TargetApp: App {
    
    var body: some Scene {
        WindowGroup {
            SearchView(
                store: Store(
                    initialState: SearchState(),
                    reducer: searchReducer.debug(),
                    environment: SearchEnvironment(
                        githubClient: GithubClient.live,
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                    )
                )
            )
        }
    }
}
