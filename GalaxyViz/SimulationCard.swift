//
//  SimulationCard.swift
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

import SwiftUI

struct SimulationCard: View {
    
    var simulationData: SimulationData = SimulationData(image_bundle: "galaxy-merger", title: "Spiral Galaxy Merger", description: "Two spiral galaxies collide and merge together")
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .edgesIgnoringSafeArea(.all)
            VStack {
                Image(simulationData.image_bundle).resizable().scaledToFit().cornerRadius(30)
                Text(simulationData.title).font(.title3)
                Text(simulationData.description).font(.caption)
            }.padding()
        }.frame(width: 250, height:200).cornerRadius(20)
    }
}

struct SimulationCard_Previews: PreviewProvider {
    static var previews: some View {
        SimulationCard()
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
