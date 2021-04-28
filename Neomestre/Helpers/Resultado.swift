//
//  Resultado.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 13/03/21.
//

import Foundation

struct Resultado: Codable, Hashable {
    var pessoas: [Pessoa]
    var turmas: [Turma]
    
    var matriculas: [Matricula]
    var arr_etapas: [Etapa]
    var arr_disciplinas_boletim: [DisciplinaBoletim]
    
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

struct Matricula: Codable, Hashable {
    var cd_matricula: Int
    var cd_turma: Int
}

struct Etapa: Codable, Hashable {
    var cd_turma_etapa: Int
    var cd_matricula: Int
    var ds_etapa_descricao: String
    var ds_etapa_abreviado: String
    var nr_ordenacao: Int
}

struct DisciplinaBoletim: Codable, Hashable {
    var cd_disciplina: String
    var ds_disciplina: String
    
    var vl_nota: String?
    var vl_media_final: Double?
    var ds_situacao: String?
    
    var cd_turma: String
    var nr_etapa: String
    
    var sn_situacao_exame: Bool
}

struct Response: Codable {
    var sucesso: Bool
    var resultado: Resultado?
}
