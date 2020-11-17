//
//  MateriaisView.swift
//  Neomestre (iOS)
//
//  Created by João Gabriel Pozzobon dos Santos on 22/10/20.
//

import SwiftUI

struct MateriaisView: View {
    @EnvironmentObject var appData: DataModel
    @Namespace private var animation
    
    @State var currentMaterial: MaterialApoio?
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    if let materiais = appData.materiaisAtuais {
                        LazyVStack (alignment: .leading, spacing: 10) {
                            ForEach(materiais, id: \.cd_material_apoio) { material in
                                MaterialRow(material: material, disciplina: appData.getDisciplina(for: material)!, animation: animation).onTapGesture {
                                    withAnimation {
                                        self.currentMaterial = material
                                    }
                                }
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
}

struct MaterialRow: View {
    let material: MaterialApoio
    let disciplina: DisciplinaMaterialApoio
    
    var animation: Namespace.ID
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(material.ds_titulo).font(.system(size: 18, weight: .semibold))
                Label(disciplina.ds_disciplina, systemImage: "tag")
                Label(material.formattedDate, systemImage: "calendar")
            }
            Spacer()
        }
            .padding()
        .background(Color(.systemGray6).matchedGeometryEffect(id: "Background \(material.cd_material_apoio)", in: animation))
        .continuousCornerRadius(cornerRadius: 16.0)
    }
}

struct MateriaisView_Previews: PreviewProvider {
    static var previews: some View {
        MateriaisView()
    }
}
