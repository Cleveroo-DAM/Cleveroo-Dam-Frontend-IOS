//
//  CleverooApp.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI
import CoreData

@main
struct CleverooApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(\.colorScheme, .light)
    }
}
