//
//  DataLoader.swift
//  Neomestre (iOS)
//
//  Created by João Gabriel Pozzobon dos Santos on 18/10/20.
//

import Foundation

struct DataLoader {
    static func login(json: Data, completion: @escaping (Result<Resultado, Error>) -> Void) {
        let url = URL(string: "https://app.unimestre.com/mobile/v3.0/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(String(describing: json.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            let handledData = self.handle(data: data)
            switch handledData {
            case .success(let resultado):
                DispatchQueue.main.async {
                    completion(.success(resultado))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    static func sync(id: Int, completion: @escaping (Result<Resultado, Error>) -> Void) {
        let url = URL(string: "https://app.unimestre.com/mobile/v3.0/sincronizacao?ds_filtro="+String(id))!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            let handledData = self.handle(data: data)
            switch handledData {
            case .success(let resultado):
                DispatchQueue.main.async {
                    completion(.success(resultado))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    static func handle(data: Data) -> Result<Resultado, Error> {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(Response.self, from: data)
            
            if response.sucesso {
                return .success(response.resultado)
            } else {
                return .failure(RequestError.badRequest("The request wasn't successful"))
            }
        } catch let error {
            return .failure(error)
        }
    }
}

enum RequestError: Error {
    case badRequest(String)
}
