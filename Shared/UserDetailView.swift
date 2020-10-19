//
//  UserDetailView.swift
//  Neomestre (iOS)
//
//  Created by João Gabriel Pozzobon dos Santos on 18/10/20.
//

import SwiftUI
import URLImage

struct UserDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appData: DataModel
    
    var body: some View {
        NavigationView {
            List {
                let pessoa = appData.resultado!.pessoas[0]
                let turmas = appData.resultado!.turmas
                
                Section (header: Text("Usuários")) {
                    Menu {
                        ForEach(turmas, id: \.self) { turma in
                            Button(action: {
                                appData.turmaAtual = turma.ds_chave_turma
                            }) {
                                HStack {
                                    Text(turma.ds_descricao.capitalized)
                                    if appData.turmaAtual == turma.ds_chave_turma {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            URLImage(URL(string: "https://app.unimestre.com/mobile/v1.0/pessoa-imagem/"+String(pessoa.cd_pessoa))!, placeholder: Image(systemName: "person.crop.circle").resizable()) { proxy in
                                proxy.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                            }.frame(width: 60, height: 60).padding(10)
                            
                            VStack(alignment: .leading) {
                                Text(pessoa.ds_nome.capitalized).foregroundColor(.white).font(.system(size: 16, weight: .medium))
                                Text(String(pessoa.cd_pessoa)).foregroundColor(Color(.systemGray2)).font(.system(size: 16, weight: .regular))
                            }
                        }
                    }.listRowInsets(EdgeInsets()).padding(.horizontal, 15)
                }
            }.listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Configurações")
            .navigationBarItems(trailing: Button("OK", action: {
                self.presentationMode.wrappedValue.dismiss()
            }))
        }
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView()
    }
}
