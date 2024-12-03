//
//  managerApp.swift
//  manager
//
//  Created by Taiki Kuwahara on 2024/12/03.
//

import SwiftUI
import FirebaseCore


@main
struct managerApp: App {
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
