//
//  DataModel.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 15/10/20.
//

import Foundation

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
    
    @Published var resultados: Array<Resultado> = [] {
        didSet {
            do {
                let encoder = JSONEncoder()
                let encodedResultados = try encoder.encode(resultados)
                UserDefaults.standard.set(encodedResultados, forKey: "resultados")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    var configured: Bool {
        return resultados.count > 0
    }
    
    @Published var codigoResultadoAtual: Int? = UserDefaults.standard.integer(forKey: "pessoaAtual") {
        didSet {
            UserDefaults.standard.set(codigoResultadoAtual, forKey: "pessoaAtual")
        }
    }
    @Published var codigoTurmaAtual: Int? = UserDefaults.standard.integer(forKey: "turmaAtual") {
        didSet {
            UserDefaults.standard.set(codigoTurmaAtual, forKey: "turmaAtual")
        }
    }
    
    var resultadoAtual: Resultado? {
        if let resultado = resultados.first(where: { $0.cd_pessoa == codigoResultadoAtual }) {
            return resultado
        }
        return nil
    }
    
    var turmaAtual: Turma? {
        if let turma = resultadoAtual!.turmas.first(where: { $0.cd_turma == codigoTurmaAtual }) {
            return turma
        }
        return nil
    }
    
    var disciplinasAtuais: [DisciplinaMaterialApoio]? {
        if let resultado = resultadoAtual {
            return resultado.arr_disciplinas_material_apoio.filter( { $0.cd_turma == codigoTurmaAtual } )
        }
        return nil
    }
    
    var materiaisAtuais: [MaterialApoio]? {
        if let resultado = resultadoAtual {
            return resultado.arr_materiais_apoio.filter( { $0.cd_turma == codigoTurmaAtual } )
        }
        return nil
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "settings") {
            do {
                settings = try JSONDecoder().decode(Settings.self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "resultados") {
            do {
                let decoder = JSONDecoder()
                resultados = try decoder.decode(Array<Resultado>.self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getDisciplina(by code: Int) -> DisciplinaMaterialApoio? {
        if let resultado = resultadoAtual {
            return resultado.arr_disciplinas_material_apoio.filter( { $0.cd_disciplina == code } )[0]
        }
        return nil
    }
    
    func getMateriais(for disciplina: DisciplinaMaterialApoio) -> [MaterialApoio]? {
        if let resultado = resultadoAtual {
            return resultado.arr_materiais_apoio.filter( { $0.cd_disciplina == disciplina.cd_disciplina } )
        }
        return nil
    }
    
    func getArquivos(for material: MaterialApoio) -> [ArquivoMaterialApoio]? {
        if let resultado = resultadoAtual {
            return resultado.arr_materiais_apoio_arquivos.filter( { $0.cd_material_apoio == material.cd_material_apoio } )
        }
        return nil
    }
}

struct Settings: Codable {
    var biometrics = false
}


struct Resultado: Codable, Hashable {
    var pessoas: [Pessoa]
    var turmas: [Turma]
    var arr_disciplinas_material_apoio: [DisciplinaMaterialApoio]
    var arr_materiais_apoio: [MaterialApoio]
    var arr_materiais_apoio_arquivos: [ArquivoMaterialApoio]
    
    mutating func sortDisciplinas() {
        arr_disciplinas_material_apoio.sort(by: { $0.ds_disciplina > $1.ds_disciplina})
    }
    
    mutating func sortMateriais() {
        arr_materiais_apoio.sort(by: { $0.date > $1.date})
    }
    
    var pessoa: Pessoa {
        get { return pessoas[0] }
    }
    var cd_pessoa: Int {
        get { return pessoa.cd_pessoa }
    }
}

struct Pessoa: Codable, Hashable {
    var cd_pessoa: Int
    var ds_nome: String
}

struct Turma: Codable, Hashable {
    var cd_turma: Int
    var ds_chave_turma: String
    var ds_anosemestre: String
    var ds_descricao: String
}

struct DisciplinaMaterialApoio: Codable, Hashable {
    var cd_disciplina: Int
    var ds_disciplina: String
    var cd_turma: Int
    
    var formattedName: String {
        return self.ds_disciplina.capitalized
    }
}

struct MaterialApoio: Codable, Hashable {
    var cd_disciplina: Int
    var cd_turma: Int
    var ds_titulo: String
    var me_descricao: String
    var dt_material: String
    var cd_material_apoio: Int
    var ds_link_material: String?
    
    var date: Date {
        let isoFormatter = ISO8601DateFormatter()
        return isoFormatter.date(from: dt_material)!
    }
        
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}

struct ArquivoMaterialApoio: Codable, Hashable {
    var cd_material_arquivo: Int
    var ds_nome_arquivo: String
    var cd_material_apoio: Int
}

struct Response: Codable {
    var sucesso: Bool
    var resultado: Resultado?
}
