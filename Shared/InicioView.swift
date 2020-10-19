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
    
    @State private var showingUserDetail = false
    
    var body: some View {
        ScrollView {
            HStack {
                VStack (alignment: .leading, spacing: 2) {
                    Text(titleDate()).foregroundColor(.gray).font(.footnote).bold()
                    Text("Início").font(.largeTitle).bold()
                }
                Spacer()
                VStack {
                    Spacer()
                    
                    let pessoa = appData.resultado!.pessoas[0]
                    Button(action: { showingUserDetail = true }, label: {
                        URLImage(URL(string: "https://app.unimestre.com/mobile/v1.0/pessoa-imagem/"+String(pessoa.cd_pessoa))!, placeholder: Image(systemName: "person.crop.circle").resizable()) { proxy in
                            proxy.image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                        }.frame(width: 38, height: 38)
                    })
                }
            }.padding(.horizontal, 20).padding(.vertical, 12)
        }.padding(.top, 1).sheet(isPresented: $showingUserDetail) { UserDetailView() }
    }
    
    func titleDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd 'de' MMMM"
         
        let date = Date()
         
        dateFormatter.locale = Locale(identifier: "pt_BR")
        return dateFormatter.string(from: date).uppercased()
    }
}

struct InicioBlockView: View {
    var body: some View {
        VStack {
            HStack {
                Label("Materiais de apoio", systemImage: "square.and.arrow.down")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
            }.padding(20).foregroundColor(.purple)
            
        }.background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple, lineWidth: 2)
        )
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 5)
    }
}

struct InicioView_Previews: PreviewProvider {
    static var previews: some View {
        InicioView()
    }
}
