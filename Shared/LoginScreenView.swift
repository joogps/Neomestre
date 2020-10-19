//
//  LoginScreenView.swift
//  Shared
//
//  Created by João Gabriel Pozzobon dos Santos on 14/10/20.
//

import SwiftUI
import CodeScanner

struct LoginScreenView: View {
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
                Image("Icon")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                
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
                        }.buttonStyle(LoginButtonStyle())
                        
                        Button(action: { withAnimation { showingManual = true } }) {
                            HStack {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Acesso manual").bold()
                            }
                        }.buttonStyle(LoginButtonStyle())
                    }.padding(25)
                } else {
                    VStack (spacing: 10) {
                        TextField("Usuário", text: $username).modifier(LoginTextFieldStyle())
                        SecureField("Senha", text: $password).modifier(LoginTextFieldStyle())
                        TextField("Código da instituição", text: $code).keyboardType(.numberPad).modifier(LoginTextFieldStyle())
                    
                        HStack {
                            Button(action: { handleManual(username: username, password: password, code: code) }) { Text("Voltar") }
                                .buttonStyle(LoginButtonStyle())
                            Button(action: { withAnimation { showingManual = false } }) { Text("Entrar").bold() }
                                .buttonStyle(LoginButtonStyle())
                        }
                    }.padding(25)
                }
            }.blur(radius: showingProgress ? 5 : 0)
            .zIndex(1)
            
            if showingProgress {
                ZStack {
                    Rectangle().fill(Color.white)
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    ProgressView("Aguarde...")
                }.zIndex(2)
            }
            
            if showingScanner {
                Color.gray.opacity(0.45)
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
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .foregroundColor(Color.black)
            .background(Color(white: 0.98))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.725))
    }
}

struct LoginTextFieldStyle : ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .foregroundColor(Color.black)
            .background(Color(white: 0.98))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)

    }
}

struct ScannerView: View {
    @Binding var isPresented: Bool
    var completion: (Result<String, CodeScannerView.ScanError>) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40).fill(Color.white)
            
            VStack (alignment: .center) {
                HStack {
                    Spacer()
                    Button(action: { withAnimation { isPresented = false } }) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.93))
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .font(Font.body.weight(.heavy))
                                .scaleEffect(0.4)
                                .foregroundColor(Color(white: 0.5))
                        }
                    }.frame(width: 22, height: 22)
                }
                Text("Escanear QR code")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.black)
                Text("Entre no seu Unimestre pelo navegador e selecione \"Acesso aplicativo móvel\"")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                CodeScannerView(codeTypes: [.qr], completion: completion)
                    .cornerRadius(25)
                    .padding(.top, 20)
            }.padding(26)
        }.frame(maxHeight: 540)
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}
