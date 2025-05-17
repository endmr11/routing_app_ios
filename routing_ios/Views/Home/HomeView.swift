//
//  HomeView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI

struct HomeView: View {
    let branch: Branch
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Branch: \(branch.name)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            
            VStack(spacing: 20) {
                HomeCardButton(
                    title: "Dispatches",
                    subtitle: "View and manage dispatches",
                    icon: "tray.full.fill",
                    color: .blue
                ) {
                    DispatchView(branch: branch)
                }
                HomeCardButton(
                    title: "Dispatch List",
                    subtitle: "Create and assign dispatch lists",
                    icon: "list.bullet.rectangle.portrait.fill",
                    color: .orange
                ) {
                    DispatchDistributionView(branch: branch)
                }
                HomeCardButton(
                    title: "Routing",
                    subtitle: "Plan and view routes",
                    icon: "map.fill",
                    color: .green
                ) {
                    RoutingView(branch: branch)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}



 
