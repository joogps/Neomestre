//
//  SetupView.swift
//  Shared
//
//  Created by João Gabriel Pozzobon dos Santos on 14/10/20.
//

import SwiftUI
import LocalAuthentication

import CodeScanner

enum SetupScreens: Identifiable {
    var id: Int { self.hashValue }

    case welcome
    case login
    case manual
    case qrcode
    case progress
    case biometrics
    case error
}

struct SetupView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appData: DataModel
    
    @Binding var setupScreen: SetupScreens?
    
    @State var username = ""
    @State var password = ""
    @State var code = ""
    
    @State private var isScannerHidden = true
    @State private var scannerAnimation: CGFloat = 0
    
    let progressEllipsisTimer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    @State private var progressEllipsis = ""
    
    @ViewBuilder
    var body: some View {
        switch setupScreen {
        case .welcome:
            initial
        case .login:
            login
        case .qrcode:
            qrcode
        case .manual:
            manual
        case .progress:
            progress
        case .biometrics:
            biometrics
        case .error:
            error
        case .none:
            Color(.systemBackground)
        }
    }
    
    var initial: some View {
        VStack(alignment: .leading) {
            Image("LightIcon")
                .resizable()
                .frame(width: 80, height: 80)
                .continuousCornerRadius(17.5)
            Text("bem-vindo ao neomestre")
                .narrowTitle()
                .padding(.top, 4)
            Text("a nova forma de se conectar com a sua instituição de ensino")
                .narrowSubtitle()
            
            SetupButton(title: "fazer login", primary: true, action: {
                setupScreen = .login
            }).padding(.top, 12)
        }
    }
    
    var login: some View {
        VStack(alignment: .leading) {
            Text(appData.configured ? "adicionar usuário" : "fazer login")
                .narrowTitle()
            Text("escolha a forma de login que preferir")
                .narrowSubtitle()
            
            HStack(spacing: 10) {
                SetupButton(title: "QR code", systemImage: "qrcode", primary: true, action: {
                    setupScreen = .qrcode
                })
                SetupButton(title: "manual", systemImage: "rectangle.and.pencil.and.ellipsis", primary: true, action: {
                    setupScreen = .manual
                })
            }.padding(.top, 12)
            
            SetupButton(title: appData.configured ? "cancelar" : "voltar", systemImage: appData.configured ? "" : "arrow.left", action: {
                if appData.configured {
                    setupScreen = nil
                } else {
                    setupScreen = .welcome
                }
            }).padding(.top, 4)
        }
    }
    
    var qrcode: some View {
        VStack(alignment: .leading) {
            Text("escanear QR code")
                .narrowTitle()
            Text("escaneie o código exibido na tela de seu computador")
                .narrowSubtitle()
            
            Spacer()
            
            if !isScannerHidden {
                CodeScannerView(codeTypes: [.qr], completion: handleScan)
                    .continuousCornerRadius(scannerAnimation*20)
                    .scaleEffect(CGSize(width: 1, height: scannerAnimation), anchor: .center)
                    .brightness(Double(scannerAnimation)-1)
                    .padding(.top, 15)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            scannerAnimation = 1
                        }
                    }
            }
            
            SetupButton(title: "voltar", systemImage: "arrow.left", action: {
                setupScreen = .login
                isScannerHidden = true
            }).padding(.top, 12)
        }.frame(maxHeight: 420)
        .onAppear {
            scannerAnimation = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isScannerHidden = false
            }
        }
    }
    
    var manual: some View {
        VStack(alignment: .leading) {
            Text("acesso manual")
                .narrowTitle()
            Text("insira as informações de sua conta")
                .narrowSubtitle()
            
            TextField("usuário", text: $username).modifier(LoginTextFieldStyle())
                .padding(.top, 14)
            SecureField("senha", text: $password).modifier(LoginTextFieldStyle())
            TextField("código da instituição", text: $code).keyboardType(.numberPad).modifier(LoginTextFieldStyle())
            
            SetupButton(title: "entrar", action: {
                setupScreen = .login
                handleManual(username: username, password: password, code: code)
            }).padding(.top, 12)
            .disabled(username.isEmpty || password.isEmpty || code.isEmpty)
        }
    }
    
    var progress: some View {
        HStack {
            Text("entrando\(progressEllipsis)")
                .narrowTitle()
                .animation(nil)
            Spacer()
        }.padding(.vertical, 15)
        .onReceive(progressEllipsisTimer, perform: { _ in
            progressEllipsis = String(repeating: ".", count: (progressEllipsis.count+1)%4)
        })
    }
    
    var biometrics: some View {
        VStack(alignment: .leading) {
            Image(systemName: LAContext().biometricType == .faceID ? "faceid" : "touchid")
                .resizable()
                .frame(width: 60, height: 60)
            Text("sucesso!")
                .narrowTitle()
                .padding(.top, 4)
            Text("deseja utilizar o \(LAContext().biometricType == .faceID ? "Face ID" : "Touch ID") para proteger os seus dados na próxima vez que fizer login?")
                .narrowSubtitle()
            
            HStack(spacing: 10) {
                SetupButton(title: "não", action: {
                    setupScreen = nil
                })
                
                SetupButton(title: "sim", primary: true, action: {
                    appData.settings.biometrics = true
                    setupScreen = nil
                })
            }.padding(.top, 12)
        }
    }
    
    var error: some View {
        VStack(alignment: .leading) {
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 60, height: 60)
            Text("opa!")
                .narrowTitle()
                .padding(.top, 4)
            Text("houve um erro na efetuação do login")
                .narrowSubtitle()
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                setupScreen = .login
            }, label: {
                Text("tentar novamente").font(.system(size: 18, weight: .heavy))
            }).buttonStyle(SOCActionButton())
            .padding(.top, 12)
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
        case .success(let data):
            print("Read QR code")
            
            if let jsonData = Data(base64Encoded: data) {
                let jsonString = String(data: jsonData, encoding: .utf8)!
                print("Decoded: \(jsonString)")
                
                setupScreen = .progress
                
                DataLoader.login(json: jsonData, completion: updateData)
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func handleManual(username: String, password: String, code: String) {
        let jsonString = """
            {
                "ds_login": "\(username)",
                "ds_senha": "\(password)",
                "cd_cliente": "\(code)",
                "ds_criptografia": "md5"
            }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        DataLoader.login(json: jsonData, completion: updateData)
    }
    
    func updateData(result: Result<Resultado, Error>) {
        switch result {
        case .success(let resultado):
            if !appData.settings.biometrics && LAContext().biometricType != .none {
                setupScreen = .biometrics
            } else {
                setupScreen = nil
            }
            
            appData.resultados.append(resultado)
            if appData.resultados.count == 1 {
                appData.codigoResultadoAtual = resultado.cd_pessoa
                appData.codigoTurmaAtual = resultado.turmas.last?.cd_turma
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

struct SetupButton: View {
    var title: String
    
    var systemImage: String = ""
    var primary: Bool = false
    var action: () -> () = {}
    
    var body: some View {
        if primary {
            raw.buttonStyle(SOCActionButton())
        } else {
            raw.buttonStyle(SOCAlternativeButton())
        }
    }
    
    var raw: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            action()
        }, label: {
            Group {
                if systemImage != "" {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }.font(.system(size: 16, weight: .heavy))
            .foregroundColor(primary ? .white : .primary)
        })
    }
}

struct LoginTextFieldStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(20)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray5), lineWidth: 2)
            )
            .background(Color.clear)
    }
}

extension View {
    func continuousCornerRadius(_ cornerRadius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func displaySetup(setupScreen: Binding<SetupScreens?>, appData: DataModel) -> some View {
        self.slideOverCard(item: setupScreen, options: appData.configured ? [.hideExitButton] : [.disableDragToDismiss, .hideExitButton]) { _ in
            SetupView(setupScreen: setupScreen).environmentObject(appData)
        }
    }
}

extension Text {
    func narrowTitle() -> some View {
        self.font(.system(size: 30, weight: .heavy))
            .kerning(-1.5)
    }
    
    func narrowSubtitle() -> some View {
        self.font(.system(size: 20, weight: .regular))
            .kerning(-1)
    }
}
