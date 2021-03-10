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
    
    @State var showingFilter = false
    
    @State var filterDisciplina: Int?
    @State var filterDate: Date?
    
    var filtering: Bool {
        return filterDisciplina != nil || filterDate != nil
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .heavy), .kern: -1.5]
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy), .kern: -0.5]
        
        UIDatePicker.appearance().backgroundColor = UIColor(Color.accentColor).withAlphaComponent(0.02)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if materiais != nil {
                    LazyVStack (alignment: .leading, spacing: 10) {
                        ForEach(materiais!, id: \.cd_material_apoio) { material in
                            MaterialRow(material: material, disciplina: appData.getDisciplina(by: material.cd_disciplina)!, animation: animation).onTapGesture {
                                withAnimation {
                                    self.currentMaterial = material
                                }
                            }
                        }
                    }.padding()
                }
            }.navigationTitle("materiais")
            .navigationBarItems(trailing: Button(action: {
                SOCManager.present(isPresented: $showingFilter, content: {
                    FilterView(filterDisciplina: $filterDisciplina, filterDate: $filterDate)
                        .environmentObject(appData)
                })
            }, label: {
                Image(systemName: "line.horizontal.3.decrease.circle\(filtering ? ".fill" : "")").font(.system(size: 22, weight: .regular))
            }))
        }
    }
    
    var materiais: [MaterialApoio]? {
        if var materiais = appData.materiaisAtuais {
            if filterDisciplina != nil {
                materiais = materiais.filter({ $0.cd_disciplina == filterDisciplina })
            }
            if filterDate != nil {
                materiais = materiais.filter({  Calendar.current.isDate($0.date, equalTo: filterDate!, toGranularity: .day) })
            }
            return materiais
        }
        return nil
    }
}

struct FilterView: View {
    @EnvironmentObject var appData: DataModel
    
    @Binding var filterDisciplina: Int?
    @Binding var filterDate: Date?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("filtrar por")
                .narrowTitle()
            
            disciplina.padding(.top, 10)
            data
        }
    }
    
    var disciplina: some View {
        HStack {
            Text("Disciplina")
                .font(.system(size: 17, weight: .medium))
            Spacer()
            Menu {
                Text("Disciplinas")
                ForEach(appData.disciplinasAtuais!, id: \.cd_disciplina) { disciplina in
                    Button(action: {
                            filterDisciplina = disciplina.cd_disciplina == filterDisciplina ? nil : disciplina.cd_disciplina
                    }, label: {
                        HStack {
                            Text(disciplina.ds_disciplina.capitalized)
                            if disciplina.cd_disciplina == filterDisciplina {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                }
            } label: {
                Text(filterDisciplina != nil ? (appData.getDisciplina(by: filterDisciplina!)?.ds_disciplina.capitalized ?? "escolher") : "escolher")
                    .lineLimit(1)
                    .font(.system(size: 17, weight: filterDisciplina != nil ? .medium : .regular))
            }
        }.padding(20)
        .background(Color(.systemGray5))
        .continuousCornerRadius(15)
    }
    
    var data: some View {
        HStack {
            Text("Data")
            Spacer()
            
            if filterDate != nil {
                DatePicker("", selection: Binding<Date>(get: {filterDate ?? Date()}, set: {filterDate = $0}), in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
            } else {
                Button(action: {
                    filterDate = Date()
                }, label: {
                    Text("escolher")
                        .font(.system(size: 17, weight: .regular))
                })
            }
        }.padding(20)
        .font(.system(size: 17, weight: .medium))
        .background(Color(.systemGray5))
        .continuousCornerRadius(15)
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
        .continuousCornerRadius(16.0)
    }
}

struct MateriaisView_Previews: PreviewProvider {
    static var previews: some View {
        MateriaisView()
    }
}
