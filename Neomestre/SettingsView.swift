//
//  SettingsView.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 18/10/20.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var appData: DataModel
    
    @State private var showingWipeAlert = false
    
    @State private var setupScreen: SetupScreen? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section (header: Text("Usuários").padding(.top, 10)) {
                    if appData.configured {
                        ForEach(appData.usuarios, id: \.cd_pessoa) { usuario in
                            let pessoa = usuario.pessoa
                            let turmas = usuario.turmas
                            
                            Menu {
                                Text("Turmas")
                                ForEach(turmas, id: \.cd_turma) { turma in
                                    Button(action: {
                                        appData.currentUsuarioCode = usuario.cd_pessoa
                                        appData.currentTurmaCode = turma.cd_turma
                                    }) {
                                        Label(turma.ds_descricao.capitalized, systemImage: "checkmark")
                                            .labelStyle(SelectionLabel(isSelected: appData.currentUsuarioCode == pessoa.cd_pessoa &&
                                                                                   appData.currentTurmaCode == turma.cd_turma))
                                    }
                                }
                            } label: {
                                UserRow(pessoa: pessoa, turma: appData.currentTurma!.ds_chave_turma, isCurrentUser: appData.currentUsuarioCode == pessoa.cd_pessoa)
                            }.listRowInsets(EdgeInsets())
                            .padding(.horizontal, 12).padding(.vertical, 6)
                        }.onDelete(perform: delete)
                    }
                    
                    Button(action: { setupScreen = .login }) {
                        Label("Adicionar usuário", systemImage: "plus")
                    }
                }
                
                Section (header: Text("Segurança").padding(.top, 10), footer: Text("A biometria adiciona uma camada extra de segurança ao seu acesso ao neomestre. Você pode desativá-la a qualquer momento.").padding(.horizontal)) {
                    Toggle(LAContext().biometricType == .none ? "Biometria" : "Desbloqueio por \(LAContext().biometricType == .faceID ? "Face ID" : "Touch ID")", isOn: $appData.settings.biometrics)
                        .disabled(LAContext().biometricType == .none)
                }
                
                Section (header: Text("Geral").padding(.top, 10)) {
                    Button(action: {
                        showingWipeAlert = true
                    }) {
                        Label("Apagar dados", systemImage: "trash")
                    }.foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("configurações")
            .navigationBarItems(trailing: Button("OK", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }.displaySetup(setupScreen: $setupScreen, appData: appData)
        .alert(isPresented: $showingWipeAlert) {
            Alert(title: Text("Você tem certeza?"),
                  message: Text("Essa ação apagará todos os dados."),
                  primaryButton: .default(Text("Cancelar")),
                  secondaryButton: .destructive(Text("Apagar")) {
                    presentationMode.wrappedValue.dismiss()
                    
                    appData.usuarios = []
                    appData.settings = Settings()
                  }
            )
        }
    }
    
    func delete(offsets: IndexSet) {
        if appData.usuarios.count == 1 {
            showingWipeAlert = true
        } else {
            appData.usuarios.remove(atOffsets: offsets)
            
            if appData.currentUsuario == nil && appData.configured {
                appData.currentUsuarioCode = appData.usuarios.first?.cd_pessoa
                appData.currentTurmaCode = appData.currentUsuario!.turmas.last?.cd_turma
            }
        }
    }
}

struct UserRow: View {
    var pessoa: Pessoa
    var turma: String
    var isCurrentUser: Bool
    
    var body: some View {
        HStack {
            UserPicture(code: pessoa.cd_pessoa).frame(width: 60, height: 60).padding(10)
            
            VStack(alignment: .leading) {
                Text(pessoa.ds_nome.capitalized).foregroundColor(Color.primary).font(.system(size: 16, weight: .medium))
                Text(String(pessoa.cd_pessoa) + (turma.isEmpty || !isCurrentUser ? "" : " • " + turma)).foregroundColor(Color(.systemGray2)).font(.system(size: 16, weight: .regular))
            }
            
            Spacer()
            if isCurrentUser {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 18, weight: .medium)).padding(10)
            }
        }
    }
}

struct SelectionLabel : LabelStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            if isSelected {
                configuration.icon
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
