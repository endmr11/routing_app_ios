//
//  DispatchDistributionViewModel.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import Foundation
import Combine

class DispatchDistributionViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var dispatches: [Dispatch] = []
    @Published var filteredDispatches: [Dispatch] = []
    @Published var selectedVehicle: Vehicle? = nil
    @Published var selectedDispatches: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var showSuccessAlert: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var apiManager = APIManager.shared
    
    
    func fetchVehicles() {
        isLoading = true
        error = nil
        
        // Fetch vehicles
        apiManager.fetchVehicles()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = "An error occurred while loading vehicles: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }, receiveValue: { [weak self] vehicles in
                guard let self = self else { return }
                self.vehicles = vehicles
                
                self.fetchDispatches()
            })
            .store(in: &cancellables)
    }
    
    private func fetchDispatches() {
        apiManager.fetchDispatches()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = "An error occurred while loading dispatches: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] dispatches in
                guard let self = self else { return }
                self.dispatches = dispatches
                
                filterDispatches()
            })
            .store(in: &cancellables)
    }
    
    func filterDispatches(hasPreferredTime: Bool = false) {
        if selectedVehicle == nil {
            filteredDispatches = dispatches
        } else {
            filteredDispatches = dispatches.filter { isInRange(dispatch: $0.deliveryRange, vehicle: selectedVehicle?.deliveryRange) }
        }
        if hasPreferredTime {
            filteredDispatches = filteredDispatches.filter { $0.hasPreferredDeliveryTime() }
        }
    }
    
    func isInRange(dispatch: DeliveryRange,vehicle: DeliveryRange?) -> Bool {
        var isInRange:Bool = false;
        if (dispatch == .MORNING && vehicle == .MORNING) {
            isInRange = true;
        } else if (dispatch == .MORNING && vehicle == .MIDMORNING) {
            isInRange = true;
        } else if (dispatch == .MIDMORNING && vehicle == .MORNING) {
            isInRange = true;
        } else if (dispatch == .MIDMORNING && vehicle == .MIDMORNING) {
            isInRange = true;
        } else if (dispatch == .AFTERNOON && vehicle == .AFTERNOON) {
            isInRange = true;
        } else if (dispatch == .AFTERNOON && vehicle == .EVENING) {
            isInRange = true;
        } else if (dispatch == .EVENING && vehicle == .AFTERNOON) {
            isInRange = true;
        } else if (dispatch == .EVENING && vehicle == .EVENING) {
            isInRange = true;
        }
        return isInRange;
        
    }
    
    func toggleDispatchSelection(_ dispatch: Dispatch) {
        if selectedDispatches.contains(dispatch.id) {
            selectedDispatches.remove(dispatch.id)
        } else {
            selectedDispatches.insert(dispatch.id)
        }
    }
    
    func createDispatchDistribution() {
        guard let vehicle = selectedVehicle else { return }
        print("vehicle-> \(vehicle)")
        
        isLoading = true
        error = nil
        
        let selectedDispatchesList = dispatches.filter { selectedDispatches.contains($0.id) }
        print("selectedDispatchesList-> \(selectedDispatchesList)")
        let dispatchVehicle = DispatchVehicle(
            id: 0,
            vehicle: vehicle,
            dispatch: selectedDispatchesList,
            routeDate: Int(Date().timeIntervalSince1970)
        )
        
        apiManager.createDispatchVehicle(dispatchVehicle: dispatchVehicle)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    self.showSuccessAlert = true
                    self.resetForm()
                case .failure(let error):
                    self.error = "Distribute Dispatch Failed: \(error.localizedDescription)"
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func vehicleChanged(){
        fetchVehicles()
        fetchDispatches()
    }
    
    private func resetForm() {
        selectedVehicle = nil
        selectedDispatches = []
        filteredDispatches = dispatches

    }
} 
