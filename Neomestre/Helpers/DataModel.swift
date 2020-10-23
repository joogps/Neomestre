//
//  DataModel.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 15/10/20.
//

import Foundation

class DataModel: ObservableObject {
    @Published var resultados: Array<Resultado> = []
    
    @Published var codigoResultadoAtual: Int? = UserDefaults.standard.integer(forKey: "pessoaAtual")
    @Published var codigoTurmaAtual: Int? = UserDefaults.standard.integer(forKey: "turmaAtual")
    
    var resultadoAtual: Resultado? {
        get {
            if let resultado = resultados.first(where: { $0.cd_pessoa == codigoResultadoAtual }) {
                return resultado
            }
            return nil
        }
    }
    
    var turmaAtual: Turma? {
        get {
            if let turma = resultadoAtual!.turmas.first(where: { $0.cd_turma == codigoTurmaAtual }) {
                return turma
            }
            return nil
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "resultados") {
            do {
                let decoder = JSONDecoder()
                resultados = try decoder.decode(Array<Resultado>.self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func syncData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(resultados)
            UserDefaults.standard.set(data, forKey: "resultados")
        } catch let error {
            print(error.localizedDescription)
        }
        
        UserDefaults.standard.set(codigoResultadoAtual, forKey: "pessoaAtual")
        UserDefaults.standard.set(codigoTurmaAtual, forKey: "turmaAtual")
    }
}

struct Resultado: Codable, Hashable {
    var pessoas: [Pessoa]
    var turmas: [Turma]
    var arr_disciplinas_material_apoio: [DisciplinaMaterialApoio]
    
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
    var ds_disciplina: String
}

struct Response: Codable {
    var sucesso: Bool
    var resultado: Resultado
}
