//
//  BranchSelectionView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import Combine

struct BranchSelectionView: View {
    @StateObject private var viewModel = BranchViewModel()
    @State private var selectedBranch: Branch? = nil
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Please select a branch to continue")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.3)
                Spacer()
            } else if let error = viewModel.error {
                Spacer()
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                Button("Try Again") {
                    viewModel.fetchBranches()
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.branches) { branch in
                            BranchCard(branch: branch)
                                .onTapGesture {
                                    selectedBranch = branch
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            viewModel.fetchBranches()
        }
        .navigationDestination(item: $selectedBranch){ branch in
            HomeView(branch: branch)
        }
    }
}




