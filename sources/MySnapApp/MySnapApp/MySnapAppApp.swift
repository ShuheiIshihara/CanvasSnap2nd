//
//  MySnapAppApp.swift
//  MySnapApp
//
//  Created by 石原脩平 on 2026/04/16.
//

import SwiftUI
import CoreData

@main
struct MySnapAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
