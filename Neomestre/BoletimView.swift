//
//  BoletimView.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 13/03/21.
//

import SwiftUI

struct BoletimView: View {
    @EnvironmentObject var appData: DataModel
    
    @State var selectedEtapaCode: Int?
    
    var selectedEtapa: Etapa? {
        if let etapas = appData.currentEtapas {
            return etapas.first(where: { $0.cd_turma_etapa == (selectedEtapaCode ?? 0) })
        }
        return nil
    }
    
    var selectedDisciplinas: [DisciplinaBoletim]? {
        if let disciplinas = appData.currentUsuario?.arr_disciplinas_boletim {
            return disciplinas.filter({ Int($0.cd_turma) == appData.currentTurmaCode && Int($0.nr_etapa) == selectedEtapa?.nr_ordenacao })
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let disciplinas = selectedDisciplinas {
                        ForEach(disciplinas, id:\.cd_disciplina) { disciplina in
                            Text(disciplina.ds_disciplina)
                        }
                    }
                }
            }.navigationTitle("boletim")
            .navigationBarItems(trailing: etapas)
            .onAppear {
                if let etapas = appData.currentEtapas {
                    selectedEtapaCode = etapas.first?.cd_turma_etapa
                }
            }
        }
    }
    
    var etapas: some View {
        Group {
            if let etapas = appData.currentEtapas {
                Menu {
                    Text("Etapas")
                    ForEach(etapas, id: \.cd_turma_etapa) { etapa in
                        Button(action: {
                            selectedEtapaCode = etapa.cd_turma_etapa
                        }) {
                            Label(etapa.ds_etapa_descricao, systemImage: "checkmark")
                                .labelStyle(SelectionLabel(isSelected: selectedEtapaCode == etapa.cd_turma_etapa))
                        }
                    }
                } label: {
                    Text(selectedEtapa?.ds_etapa_abreviado ?? "etapa")
                        .animation(nil)
                        .fixedSize()
                }
            }
        }
    }
}

struct BoletimView_Previews: PreviewProvider {
    static var previews: some View {
        BoletimView()
    }
}
