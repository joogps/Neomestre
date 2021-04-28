//
//  DataModel.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 15/10/20.
//

import Foundation

// Main structure
class DataModel: ObservableObject {
    @Published var settings: Settings = Settings() {
        didSet {
            do {
                let encodedSettings = try JSONEncoder().encode(settings)
                UserDefaults.standard.set(encodedSettings, forKey: "settings")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    @Published var usuarios: Array<Resultado> = [] {
        didSet {
            do {
                let encoder = JSONEncoder()
                let encodedResultados = try encoder.encode(usuarios)
                UserDefaults.standard.set(encodedResultados, forKey: "usuarios")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    var configured: Bool {
        return usuarios.count > 0
    }
    
    @Published var refreshing: Bool = false
    
    @Published var currentUsuarioCode: Int? = UserDefaults.standard.integer(forKey: "currentUsuario") {
        didSet {
            UserDefaults.standard.set(currentUsuarioCode, forKey: "currentUsuario")
        }
    }
    
    @Published var currentTurmaCode: Int? = UserDefaults.standard.integer(forKey: "currentTurma") {
        didSet {
            UserDefaults.standard.set(currentTurmaCode, forKey: "currentTurma")
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "settings") {
            do {
                settings = try JSONDecoder().decode(Settings.self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "usuarios") {
            do {
                let decoder = JSONDecoder()
                usuarios = try decoder.decode(Array<Resultado>.self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

struct Settings: Codable {
    var biometrics = false
}

// Computed properties and filtering functions
extension DataModel {
    var currentUsuario: Resultado? {
        if let usuario = usuarios.first(where: { $0.cd_pessoa == currentUsuarioCode }) {
            return usuario
        }
        return nil
    }
    
    var currentTurma: Turma? {
        if let turma = currentUsuario!.turmas.first(where: { $0.cd_turma == currentTurmaCode }) {
            return turma
        }
        return nil
    }
    
    var currentMatricula: Matricula? {
        if let matricula = currentUsuario!.matriculas.first(where: { $0.cd_turma == currentTurmaCode }) {
            return matricula
        }
        return nil
    }
    
    var currentEtapas: [Etapa]? {
        if let matricula = currentMatricula {
            return currentUsuario!.arr_etapas.filter( { $0.cd_matricula == matricula.cd_matricula } )
        }
        return nil
    }
    
    var currentDisciplinas: [DisciplinaMaterialApoio]? {
        if let usuario = currentUsuario {
            return usuario.arr_disciplinas_material_apoio.filter( { $0.cd_turma == currentTurmaCode } )
        }
        return nil
    }
    
    var currentMateriais: [MaterialApoio]? {
        if let usuario = currentUsuario {
            return usuario.arr_materiais_apoio.filter( { $0.cd_turma == currentTurmaCode } )
        }
        return nil
    }
    
    func getDisciplina(by code: Int) -> DisciplinaMaterialApoio? {
        if let resultado = currentUsuario {
            return resultado.arr_disciplinas_material_apoio.filter( { $0.cd_disciplina == code } )[0]
        }
        return nil
    }
    
    func getMateriais(for disciplina: DisciplinaMaterialApoio) -> [MaterialApoio]? {
        if let resultado = currentUsuario {
            return resultado.arr_materiais_apoio.filter( { $0.cd_disciplina == disciplina.cd_disciplina } )
        }
        return nil
    }
    
    func getArquivos(for material: MaterialApoio) -> [ArquivoMaterialApoio]? {
        if let resultado = currentUsuario {
            return resultado.arr_materiais_apoio_arquivos.filter( { $0.cd_material_apoio == material.cd_material_apoio } )
        }
        return nil
    }
}
