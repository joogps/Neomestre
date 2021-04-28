//
//  MateriaisView.swift
//  Neomestre (iOS)
//
//  Created by João Gabriel Pozzobon dos Santos on 22/10/20.
//

import SwiftUI

import SlideOverCard
import SwiftUIRefresh

struct MateriaisView: View {
    @EnvironmentObject var appData: DataModel
    
    @State var currentMaterial: MaterialApoio?
    
    @State var showingFilter = false
    
    @State var filterSearch: String = ""
    @State var filterDisciplina: Int?
    @State var filterDate: Date?
    
    let filterDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var filtering: Bool {
        return filterDisciplina != nil || filterDate != nil
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .heavy), .kern: -1.5]
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy), .kern: -0.5]
        
        UIDatePicker.appearance().backgroundColor = UIColor(Color.accentColor).withAlphaComponent(0.02)
    }
    
    var materiais: [MaterialApoio]? {
        if var materiais = appData.currentMateriais {
            if filterDisciplina != nil {
                materiais = materiais.filter({ $0.cd_disciplina == filterDisciplina })
            }
            
            if filterDate != nil {
                materiais = materiais.filter({  Calendar.current.isDate($0.date, equalTo: filterDate!, toGranularity: .day) })
            }
            
            if filterSearch != "" {
                let options: NSString.CompareOptions =  [.diacriticInsensitive, .caseInsensitive]
                materiais = materiais.filter({ $0.ds_titulo.folding(options: options, locale: .current).contains(filterSearch.folding(options: options, locale: .current)) })
            }
            
            return materiais
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    search
                    
                    if materiais != nil {
                        header
                        list
                    }
                }.pullToRefresh(
                    isRefreshing: $appData.refreshing,
                    onRefresh: {
                        DataLoader.sync(resultado: appData.currentUsuario!, completion: updateData)
                    }
                )
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
    
    func updateData(result: Result<Resultado, Error>) {
        switch result {
        case .success(let resultado):
            appData.usuarios[appData.usuarios.firstIndex(where: { $0.cd_pessoa == resultado.cd_pessoa })!] = resultado
            appData.refreshing = false
        case .failure(let error):
            print(error._domain, error._code, error.localizedDescription)
        }
    }
    
    var search: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(Color(.systemGray2))
            TextField("Procurar", text: $filterSearch)
        }.padding(8)
        .background(Color(.systemGray6).continuousCornerRadius(12))
        .padding(.horizontal)
    }
    
    var header: some View {
        HStack(alignment: .top) {
            Text("\(materiais!.count) materiais")
            Spacer()
            
            VStack(alignment: .trailing) {
                if filterDisciplina != nil {
                    Text("Disciplina: ").fontWeight(.medium) + Text((appData.getDisciplina(by: filterDisciplina!)?.formattedName)!)
                }
                if filterDate != nil {
                    Text("Data: ").fontWeight(.medium) + Text(filterDate!, formatter: filterDateFormatter)
                }
            }
        }.font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    var list: some View {
        LazyVStack (alignment: .leading, spacing: 10) {
            ForEach(materiais!, id: \.cd_material_apoio) { material in
                MaterialRow(material: material, disciplina: appData.getDisciplina(by: material.cd_disciplina)!).onTapGesture {
                    self.currentMaterial = material
                }
            }
        }.padding([.horizontal, .bottom])
    }
}

struct MaterialRow: View {
    let material: MaterialApoio
    let disciplina: DisciplinaMaterialApoio
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(material.ds_titulo).font(.system(size: 18, weight: .semibold))
                
                HStack(spacing: 4) {
                    Label(disciplina.formattedName, systemImage: "tag")
                        .padding(8)
                        .background(Color.accentColor.opacity(0.1).continuousCornerRadius(8))
                    Label(material.formattedDate, systemImage: "calendar")
                        .padding(8)
                        .background(Color.accentColor.hueRotation(.init(degrees: 90)).opacity(0.1).continuousCornerRadius(8))
                }.lineLimit(1)
                .font(Font.system(size: 12, weight: .semibold))
                .padding(.top, 2)
            }
            Spacer()
        }.padding(15)
        .background(Color(.systemGray6))
        .continuousCornerRadius(16.0)
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
                ForEach(appData.currentDisciplinas!, id: \.cd_disciplina) { disciplina in
                    Button(action: {
                            filterDisciplina = disciplina.cd_disciplina == filterDisciplina ? nil : disciplina.cd_disciplina
                    }, label: {
                        HStack {
                            Text(disciplina.formattedName)
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

struct MateriaisView_Previews: PreviewProvider {
    static var previews: some View {
        MateriaisView()
    }
}
