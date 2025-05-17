//
//  DispatchViewModel.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import Combine

class DispatchViewModel: ObservableObject {
    @Published var dispatches: [Dispatch] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDispatches() {
        isLoading = true
        
        APIManager.shared.fetchDispatches()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = "An error occurred while loading dispatches: \(error.localizedDescription)"
                    print("An error occurred while loading dispatches: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] dispatches in
                self?.dispatches = dispatches
            })
            .store(in: &cancellables)
    }
}
