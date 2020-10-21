//
//  LoginScreenView.swift
//  Shared
//
//  Created by João Gabriel Pozzobon dos Santos on 14/10/20.
//

import SwiftUI
import CodeScanner

struct LoginScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appData: DataModel
    
    @State private var showingScanner = false
    @State private var showingProgress = false
    
    @State private var showingManual = false
    
    @State var username = ""
    @State var password = ""
    @State var code = ""
    
    var body: some View {
        ZStack {
            VStack {
                Image((colorScheme == .dark ? "Dark" : "Light") + "Icon")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                    .shadow(color: colorScheme == .dark ? Color(white: 0.2).opacity(0.5) : Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                
                Text("Neomestre")
                    .font(.system(size: 42, weight: .bold))
                    .padding(10)
                
                if !showingManual {
                    VStack (spacing: 10) {
                        Button(action: { withAnimation { showingScanner = true } }) {
                            HStack {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Escanear QR code").bold()
                            }
                        }.buttonStyle(LoginButtonStyle(colorScheme: colorScheme))
                        
                        Button(action: { withAnimation(.easeInOut(duration: 0.25)) { showingManual = true } }) {
                            HStack {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Acesso manual").bold()
                            }
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
                        }.padding(.top, 2)
                    }.padding(.horizontal, 45).padding(.top, 4)
                }
            }.blur(radius: showingProgress ? 5 : 0)
            .zIndex(1)
            
            if showingProgress {
                ZStack {
                    Rectangle().fill(Color(.systemBackground))
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    ProgressView("Aguarde...")
                }.zIndex(2)
            }
            
            if showingScanner {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(3)
                VStack {
                    Spacer()
                    ScannerView(isPresented: $showingScanner, completion: self.handleScan)
                        .padding([.horizontal, .bottom], 6)
                }.transition(.move(edge: .bottom))
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(4)
            }
            
            VStack {
                Spacer()
                Text("versão beta 1.0")
                    .font(.system(size: 14, weight: .light))
            }
        }
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
            appData.resultado = resultado
        case .failure(let error):
            withAnimation { showingProgress = false }
            print(error.localizedDescription)
        }
    }
}

struct LoginButtonStyle: ButtonStyle {
    var colorScheme: ColorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .background(colorScheme == .dark ? Color(.systemGray6) : Color(white: 0.98))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.725))
    }
}

struct LoginTextFieldStyle : ViewModifier {
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

struct ScannerView: View {
    @Binding var isPresented: Bool
    
    @State private var isCameraHidden = true
    @State private var viewOffset: CGFloat = 0.0
    
    var completion: (Result<String, CodeScannerView.ScanError>) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color(.systemGray6))
            
            VStack (alignment: .center, spacing: .zero) {
                HStack {
                    Spacer()
                    Button(action: { withAnimation { isPresented = false } }) {
                        XExit()
                    }.frame(width: 24, height: 24)
                }
                
                VStack(spacing: .zero) {
                    Text("Escanear QR code")
                        .font(.system(size: 28, weight: .bold))
                    Text("Entre no seu Unimestre pelo navegador e selecione \"Acesso aplicativo móvel\"")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal).padding(.top, 2)
                    Spacer()
                    
                    if !isCameraHidden {
                        CodeScannerView(codeTypes: [.qr], completion: completion)
                            .cornerRadius(25)
                            .padding(.top, 20)
                    } else {
                        ZStack {
                            Color.black.cornerRadius(25)
                                .padding(.top, 20)
                        }
                    }
                }.padding(2)
            }.padding(24)
        }.frame(maxHeight: 540)
        .offset(x: 0, y: viewOffset/2)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation(.none) { viewOffset = gesture.translation.height > 0 ? gesture.translation.height : 0 }
                }
                .onEnded() { _ in
                    if viewOffset > 150 {
                        withAnimation { isPresented = false }
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) { viewOffset = .zero }
                    }
                }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isCameraHidden = false
            }
        }
    }
}

struct XExit: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .font(Font.body.weight(.heavy))
                .scaleEffect(0.425)
                .foregroundColor(Color(white: colorScheme == .dark ? 0.93 : 0.6))
        }
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}
