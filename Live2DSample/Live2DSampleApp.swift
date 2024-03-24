//
//  Live2DSampleApp.swift
//  Live2DSample
//
//  Created by subdiox on 2024/03/24.
//

import SwiftUI
import Live2DMetalObjC

@main
struct Live2DSampleApp: App {
    init() {
        L2DCubism.initialize()
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            L2DCubism.dispose()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
