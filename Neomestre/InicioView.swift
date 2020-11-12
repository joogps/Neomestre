//
//  InicioView.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 16/10/20.
//

import SwiftUI
import URLImage

struct InicioView: View {
    @EnvironmentObject var appData: DataModel
    
    @State private var showingSettings = false
    
    var body: some View {
        ScrollView {
            HStack {
                VStack (alignment: .leading, spacing: 2) {
                    Text(titleDate()).foregroundColor(.gray).font(.footnote).bold()
                    Text("Início").font(.largeTitle).bold()
                }
                Spacer()
                
                if let resultado = appData.resultadoAtual {
                    VStack {
                        Spacer()
                        
                        Button(action: { showingSettings = true }, label: {
                            URLImage(URL(string: "https://app.unimestre.com/mobile/v1.0/pessoa-imagem/"+String(resultado.cd_pessoa))!, placeholder: Image(systemName: "person.crop.circle").resizable()) { proxy in
                                proxy.image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                            }.frame(width: 38, height: 38)
                        })
                    }
                }
            }.padding(.horizontal, 20).padding(.vertical, 26)
        }.padding(.top, 1).sheet(isPresented: $showingSettings) { SettingsView().environmentObject(appData) }
    }
    
    func titleDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd 'de' MMMM"
        
        let date = Date()
        
        dateFormatter.locale = Locale(identifier: "pt_BR")
        return dateFormatter.string(from: date).uppercased()
    }
}

struct InicioView_Previews: PreviewProvider {
    static var previews: some View {
        InicioView()
    }
}
