//
//  ContentView.swift
//  Neomestre
//
//  Created by João Gabriel Pozzobon dos Santos on 16/10/20.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 11, weight: .semibold)], for: [])
    }
    
    var body: some View {
        TabView {
            InicioView().tabItem {
                Image(systemName: "house")
                Text("início")
            }
            
            BoletimView().tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("boletim")
            }
            
            MateriaisView().tabItem {
                Image(systemName: "square.and.arrow.down")
                Text("materiais")
            }
            
            Text("Recados").tabItem {
                Image(systemName: "message")
                Text("recados")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
