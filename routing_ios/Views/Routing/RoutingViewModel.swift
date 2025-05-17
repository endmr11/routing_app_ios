//
//  RoutingViewModel.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import MapKit
import Combine

class RoutingViewModel: ObservableObject {
    @Published var dispatchVehicles: [DispatchVehicle] = []
    @Published var selectedDispatchVehicle: DispatchVehicle? = nil
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var showOutboundRoute = true
    @Published var showReturnRoute = true
    @Published var outboundRouteCoordinates: [CLLocationCoordinate2D] = []
    @Published var returnRouteCoordinates: [CLLocationCoordinate2D] = []
    @Published var branchBoundingBox: [CLLocationCoordinate2D] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDispatchVehicles() {
        isLoading = true
        error = nil
        APIManager.shared.fetchDispatchVehicles()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = "Error loading dispatch vehicles: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] vehicles in
                self?.dispatchVehicles = vehicles
            })
            .store(in: &cancellables)
    }
    
    func createRoute() {
        guard let routeId = selectedDispatchVehicle?.id else { return }
        
        isLoading = true
        
        APIManager.shared.createRoutePlan(routeId: routeId)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error occurred while creating route: \(error.localizedDescription)")
                    self?.error = "Error occurred while creating route: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                self?.updateRouteCoordinates(response:response)
            })
            .store(in: &cancellables)
    }
    
    private func updateRouteCoordinates(response: RouteResponse) {
        self.outboundRouteCoordinates = response.geometry.outbound.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
        self.returnRouteCoordinates = response.geometry.geometryReturn.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
    }
    
    func setBranchBoundingBox(branch: Branch) {
        let bbox = [
            CLLocationCoordinate2D(latitude: branch.boundingBoxLatitude1, longitude: branch.boundingBoxLongitude1),
            CLLocationCoordinate2D(latitude: branch.boundingBoxLatitude1, longitude: branch.boundingBoxLongitude2),
            CLLocationCoordinate2D(latitude: branch.boundingBoxLatitude2, longitude: branch.boundingBoxLongitude2),
            CLLocationCoordinate2D(latitude: branch.boundingBoxLatitude2, longitude: branch.boundingBoxLongitude1),
            CLLocationCoordinate2D(latitude: branch.boundingBoxLatitude1, longitude: branch.boundingBoxLongitude1)
        ]
        self.branchBoundingBox = bbox
    }
}
