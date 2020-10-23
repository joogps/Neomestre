//
//  NeomestreApp.swift
//  Shared
//
//  Created by João Gabriel Pozzobon dos Santos on 14/10/20.
//

import SwiftUI

@main
struct NeomestreApp: App {
    @StateObject private var appData = DataModel()
    
    var body: some Scene {
        WindowGroup {
            if appData.resultados.count == 0 {
                LoginScreenView().environmentObject(appData)
            } else {
                ContentView().environmentObject(appData)
            }
        }
    }
}