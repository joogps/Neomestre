//
//  NeomestreApp.swift
//  Shared
//
//  Created by João Gabriel Pozzobon dos Santos on 14/10/20.
//

import SwiftUI
import LocalAuthentication

@main
struct NeomestreApp: App {
    @StateObject private var appData = DataModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var setupScreen: SetupScreen? = nil
    
    @State var locked = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if locked || !appData.configured {
                    ZStack {
                        IrregularGradientView(colors: [Color(#colorLiteral(red: 0.9960784314, green: 0.7960784314, blue: 0.1607843137, alpha: 1)), Color(#colorLiteral(red: 0.6588235294, green: 0.8117647059, blue: 0.2705882353, alpha: 1)), Color(#colorLiteral(red: 0.5058823529, green: 0.7294117647, blue: 0.462745098, alpha: 1)), Color(#colorLiteral(red: 0.3529411765, green: 0.6470588235, blue: 0.6588235294, alpha: 1)), Color(#colorLiteral(red: 0.3201098442, green: 0.3626264334, blue: 0.8252855539, alpha: 1))], backgroundColor: Color(#colorLiteral(red: 0.3201098442, green: 0.3626264334, blue: 0.8252855539, alpha: 1)))
                            .ignoresSafeArea()
                            .onAppear(perform: toggleSetup)
                        
                        if locked {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                authenticate()
                            }, label: {
                                Label("desbloquear", systemImage: "faceid")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 17, weight: .heavy))
                                    .padding(28)
                            }).background(Color(.systemGray5))
                            .continuousCornerRadius(25)
                        }
                    }
                } else {
                    ContentView()
                        .environmentObject(appData)
                }
            }.displaySetup(setupScreen: $setupScreen, appData: appData)
            .onAppear {
                if (appData.configured && appData.settings.biometrics) {
                    locked = true
                    authenticate()
                }
            }
        }
    }
    
    func toggleSetup() {
        setupScreen = !appData.configured ? .welcome : nil
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "É preciso acesso ao Touch ID para a autenticação por biometria."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        locked = false
                    }
                }
            }
        } else {
            
        }
    }
}
