//
//  Live2DSampleApp.swift
//  Live2DSample
//
//  Created by subdiox on 2024/03/24.
//

import SwiftUI
import Live2DMetalObjC

@main
final class Live2DSampleApp: App {
    init() {
        L2DCubism.initialize()
    }

    deinit {
        L2DCubism.dispose()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
