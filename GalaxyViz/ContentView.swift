//
//  ContentView.swift
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

import SwiftUI

struct ContentView: View {
    @State var text: String = "..."
    var body: some View {
        ZStack {
            SimulationMetalView()
            HStack {
                VStack {
                    Text("Available Simulations").font(.title)
                    SimulationSelector()
                }
                Spacer()
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewModel()).previewLayout(.fixed(width: 1200, height: 900))
    }
}
