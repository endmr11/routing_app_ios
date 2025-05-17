//
//  BranchViewModel.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import Combine

class BranchViewModel: ObservableObject {
    @Published var branches: [Branch] = []
    @Published var error: String? = nil
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchBranches() {
        isLoading = true
        
        APIManager.shared.fetchBranches()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = "Branch fetching failed : \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] branches in
                self?.branches = branches
            })
            .store(in: &cancellables)
    }
}
