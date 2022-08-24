//
//  SheetScreenShotApp.swift
//  SheetScreenShot
//
//  Created by Andy Bezaire on 23.8.2022.
//

import SwiftUI

@main
struct SheetScreenShotApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: .constant(true)) {
                    Text("It's a sheet")
                }
        }
    }
}
