//
//  SimulationSelector.swift
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

import SwiftUI

struct SimulationSelector: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.availableSimulations, id: \.id) {simData in
                    SimulationCard(simulationData: simData)
                }
            }
        }.frame(width:300)
    }
}

struct SimulationSelector_Previews: PreviewProvider {
    static var previews: some View {
        SimulationSelector().environmentObject(ViewModel())
    }
}
