//
//  DataModel.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 15/10/20.
//

import Foundation

class DataModel: ObservableObject {
    @Published var resultado: Resultado? {
        didSet {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(resultado)
                UserDefaults.standard.set(data, forKey: "resultado")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    @Published var pessoaAtual: Int?
    @Published var turmaAtual: String?
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "resultado") {
            do {
                let decoder = JSONDecoder()
                resultado = try decoder.decode(Resultado.self, from: data)
                pessoaAtual = resultado!.pessoas[0].cd_pessoa
                turmaAtual = resultado!.turmas[0].ds_chave_turma
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

class Resultado: NSObject, Codable {
    var pessoas: [Pessoa]
    var turmas: [Turma]
}

struct Pessoa: Codable {
    var cd_pessoa: Int
    var ds_nome: String
}

struct Turma: Codable, Hashable {
    var ds_chave_turma: String
    var ds_anosemestre: String
    var ds_descricao: String
}

struct Response: Codable {
    var sucesso: Bool
    var resultado: Resultado
}
