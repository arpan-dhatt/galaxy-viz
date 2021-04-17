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
        HStack{
            SimulationMetalView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width: 1200, height: 900))
    }
}
