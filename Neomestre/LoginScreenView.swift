//
//  LoginScreenView.swift
//  Shared
//
//  Created by João Gabriel Pozzobon dos Santos on 14/10/20.
//

import SwiftUI
import CodeScanner
import SlideOverCard

struct LoginScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appData: DataModel
    
    @State private var showingScanner = false
    
    @State private var showingManual = false
    
    @State var username = ""
    @State var password = ""
    @State var code = ""
    
    @State private var showingProgress = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                /*Image((colorScheme == .dark ? "Dark" : "Light") + "Icon")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .continuousCornerRadius(cornerRadius: 21.0)
                    .shadow(color: colorScheme == .dark ? Color(white: 0.2).opacity(0.5) : Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                
                Text("Neomestre")
                    .font(.system(size: 42, weight: .bold))
                    .padding(10)
                 */
                
                if !showingManual {
                    VStack (spacing: 10) {
                        Button(action: { withAnimation { showingScanner = true } }) {
                            Label("Escanear QR code", systemImage: "qrcode").font(.system(size: 16, weight: .bold))
                        }.buttonStyle(LoginButtonStyle(colorScheme: colorScheme))
                        
                        Button(action: { withAnimation(.easeInOut(duration: 0.25)) { showingManual = true } }) {
                            Label("Acesso manual", systemImage: "rectangle.and.pencil.and.ellipsis").font(.system(size: 16, weight: .bold))
                        }.buttonStyle(LoginButtonStyle(colorScheme: colorScheme))
                    }.padding(.top, 4)
                } else {
                    VStack (spacing: 10) {
                        TextField("Usuário", text: $username).modifier(LoginTextFieldStyle())
                        SecureField("Senha", text: $password).modifier(LoginTextFieldStyle())
                        TextField("Código da instituição", text: $code).keyboardType(.numberPad).modifier(LoginTextFieldStyle())
                        
                        HStack {
                            Button(action: { withAnimation(.easeInOut(duration: 0.25)) { showingManual = false } }) { Text("Voltar").padding(.horizontal, 20) }
                                .buttonStyle(LoginButtonStyle(colorScheme: colorScheme))
                            Button(action: { withAnimation { handleManual(username: username, password: password, code: code) } }) { Text("Entrar").bold().padding(.horizontal, 20) }
                                .buttonStyle(LoginButtonStyle(colorScheme: colorScheme))
                        }.padding(.top, 4)
                    }.padding(.horizontal, 45).padding(.top, 4)
                }
            }.blur(radius: showingProgress ? 5 : 0)
            .zIndex(1)
            
            if showingProgress {
                ProgressView("Aguarde...")
                    .progressViewStyle(BackdropProgressView())
                    .zIndex(2)
            }
            
            VStack {
                Spacer()
                /*Text("versão beta 1.0")
                    .font(.system(size: 14, weight: .light))*/
            }
        }.slideOverCard(isPresented: $showingScanner, content: { ScannerView(isPresented: $showingScanner, completion: self.handleScan) })
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.showingScanner = false
        
        switch result {
        case .success(let data):
            let decodedData = Data(base64Encoded: data)!
            let jsonString = String(data: decodedData, encoding: .utf8)!
            let jsonData = jsonString.data(using: .utf8)!
            
            withAnimation {
                showingProgress = true
            }
            
            DataLoader.login(json: jsonData, completion: updateData)
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
        
        withAnimation {
            showingProgress = true
        }
        
        DataLoader.login(json: jsonData, completion: updateData)
    }
    
    func updateData(result: Result<Resultado, Error>) {
        switch result {
        case .success(let resultado):
            withAnimation { showingProgress = false }
            appData.resultados.append(resultado)
            if appData.resultados.count == 1 {
                appData.codigoResultadoAtual = resultado.cd_pessoa
                appData.codigoTurmaAtual = resultado.turmas.last?.cd_turma
            }
            appData.syncData()
            presentationMode.wrappedValue.dismiss()
        case .failure(let error):
            withAnimation { showingProgress = false }
            print(error.localizedDescription)
        }
    }
}

struct LoginButtonStyle: ButtonStyle {
    var colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(20)
            .foregroundColor(Color.primary)
            .background(colorScheme == .dark ? Color(.systemGray6) : Color(white: 0.98))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.725))
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
                    .stroke(colorScheme == .dark ? Color(.systemGray6) : Color(white: 0.95), lineWidth: 2)
            )
            .background(Color.clear)
        
    }
}

struct ContinuousCornerRadius: ViewModifier {
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func continuousCornerRadius(cornerRadius: CGFloat) -> some View {
        self.modifier(ContinuousCornerRadius(cornerRadius: cornerRadius))
    }
}

struct BackdropProgressView: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 10) {
            ProgressView()
            configuration.label.foregroundColor(.gray)
        }.padding(20).background(Rectangle().fill(Color(.systemBackground))
                                    .aspectRatio(1.0, contentMode: .fill)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5))
    }
}

struct ScannerView: View {
    @Binding var isPresented: Bool
    
    @State private var isCameraHidden = true
    
    var completion: (Result<String, CodeScannerView.ScanError>) -> Void
    
    var body: some View {
        VStack(spacing: .zero) {
            Text("Escanear QR code")
                .font(.system(size: 28, weight: .bold))
            Text("Scan the QR code displayed on your computer screen")
                .font(.system(size: 13))
                .padding(.horizontal)
                .padding(.top, 2)
            Spacer()
            
            if !isCameraHidden {
                CodeScannerView(codeTypes: [.qr], completion: completion)
                    .cornerRadius(25)
                    .padding(.top, 20)
            } else {
                Color.black.cornerRadius(25)
                    .padding(.top, 20)
            }
        }.multilineTextAlignment(.center)
        .frame(maxHeight: 420)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isCameraHidden = false
            }
        }
    }
}
