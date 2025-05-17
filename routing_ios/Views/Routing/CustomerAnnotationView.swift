//
//  CustomerAnnotationView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import MapKit
import Combine

struct CustomerAnnotationView: View {
    let title: String
    let isExistPreferedDeliveryTime: Bool
    var body: some View {
        VStack {
            Image("marker-green")
                .resizable()
                .frame(width: 28, height: 28)
            Text(title)
                .font(.caption)
                .background(Color.white.opacity(0.7))
                .cornerRadius(4)
        }
    }
}
