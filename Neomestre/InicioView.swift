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
            header.padding(.horizontal, 20).padding(.vertical, 26)
        }.overlay(VStack {
            LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.25), Color.accentColor.opacity(0)]), startPoint: .top, endPoint: .bottom).frame(height: 100)
            Spacer()
        }.ignoresSafeArea()).sheet(isPresented: $showingSettings) { SettingsView().environmentObject(appData) }
    }
    
    var header: some View {
        HStack {
            VStack (alignment: .leading, spacing: 2) {
                Text(titleDate).foregroundColor(.gray).font(.footnote).bold()
                Text(titleGreeting).font(.largeTitle).fontWeight(.heavy).kerning(-1.5)
            }
            Spacer()
            
            if let resultado = appData.resultadoAtual {
                VStack {
                    Spacer()
                    
                    Button(action: { showingSettings = true }, label: {
                        UserPicture(code: resultado.cd_pessoa).frame(width: 38, height: 38)
                    })
                }
            }
        }
    }
    
    var titleDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd 'de' MMMM"
        
        let date = Date()
        
        dateFormatter.locale = Locale(identifier: "pt_BR")
        return dateFormatter.string(from: date).uppercased()
    }
    
    var titleGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let suffix = appData.resultadoAtual?.pessoa.ds_nome.split(separator: " ").first?.capitalized ?? "aluno"
        
        switch hour {
        case 5..<13:
            return "bom dia, \(suffix)"
        case 13..<18:
            return "boa tarde, \(suffix)"
        default:
            return "boa noite, \(suffix)"
        }
    }
}


struct UserPicture: View {
    let code: Int
    
    var body: some View {
        URLImage(url: URL(string: "https://app.unimestre.com/mobile/v1.0/pessoa-imagem/"+String(code))!,
                 empty: { Image(systemName: "person.crop.circle").resizable() },
                 inProgress: { _ in Image(systemName: "person.crop.circle").resizable() },
                 failure: { _,_ in Image(systemName: "person.crop.circle").resizable() },
                 content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                 }
        )
    }
}
struct InicioView_Previews: PreviewProvider {
    static var previews: some View {
        InicioView()
    }
}
