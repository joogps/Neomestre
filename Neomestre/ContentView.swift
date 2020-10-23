//
//  ContentView.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 16/10/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            InicioView().tabItem {
                Image(systemName: "house")
                Text("Início")
            }
            
            Text("Boletim").tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("Boletim")
            }
            
            MateriaisView().tabItem {
                Image(systemName: "square.and.arrow.down")
                Text("Materiais")
            }
            
            Text("Recados").tabItem {
                Image(systemName: "message")
                Text("Recados")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
