//
//  ViewModel.swift
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published var availableSimulations = [
        SimulationData(image_bundle: "galaxy-merger", title: "Spiral Galaxy Collision", description: "Two spiral galaxies colliding together"),
        SimulationData(image_bundle: "binary-stars", title: "Binary Star System", description: "Stable configurations of two-star systems are common"),
        SimulationData(image_bundle: "ternary-stars", title: "Ternary Star System", description: "Ternary star systems are largely unstable")
    ]
}
