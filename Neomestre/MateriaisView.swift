//
//  MateriaisView.swift
//  Neomestre (iOS)
//
//  Created by João Gabriel Pozzobon dos Santos on 22/10/20.
//

import SwiftUI

struct MateriaisView: View {
    @EnvironmentObject var appData: DataModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let materiais = appData.materiaisAtuais {
                    LazyVStack (alignment: .leading, spacing: 10) {
                        ForEach(materiais, id: \.cd_material_apoio) { material in
                            MaterialRow(material: material)
                        }.navigationTitle("Materiais")
                        .navigationBarItems(trailing: Button(action: {
                            
                        }, label: {
                            Image(systemName: "line.horizontal.3.decrease.circle").font(.system(size: 22, weight: .regular))
                        }))
                    }.padding()
                }
            }
        }
    }
}

struct MaterialRow: View {
    let material: MaterialApoio
    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        let date = isoFormatter.date(from: material.dt_material)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(material.ds_titulo).font(.system(size: 18, weight: .semibold))
                Label(formattedDate, systemImage: "calendar")
            }
            Spacer()
        }
            .padding()
        .background(Color(.systemGray6))
        .continuousCornerRadius(cornerRadius: 16.0)
    }
}

struct MateriaisView_Previews: PreviewProvider {
    static var previews: some View {
        MateriaisView()
    }
}
