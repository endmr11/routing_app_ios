//
//  BranchAnnotationView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import MapKit
import Combine

struct BranchAnnotationView: View {
    let title: String
    
    var body: some View {
        VStack {
            Image("branch")
                .resizable()
                .frame(width: 32, height: 32)
            Text(title)
                .font(.caption)
                .background(Color.white.opacity(0.7))
                .cornerRadius(4)
        }
    }
}