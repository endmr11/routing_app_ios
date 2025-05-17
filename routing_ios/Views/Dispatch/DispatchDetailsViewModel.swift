//
//  DispatchDetailsViewModel.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import Foundation
import Combine
import MapKit
import SwiftUI

class DispatchDetailsViewModel: ObservableObject {
    @Published var dispatch: Dispatch? = nil
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var mapAnnotations: [MapAnnotationItem] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0, longitude: 29.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var branchBoundingBox: [CLLocationCoordinate2D] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let apiManager = APIManager.shared
    
    func fetchDispatch(id: Int) {
        isLoading = true
        error = nil
        
        apiManager.fetchDispatchById(id: id)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = "Dispatch fetching failed : \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] dispatch in
                guard let self = self else { return }
                self.dispatch = dispatch
                self.updateMapAnnotations()
                self.updateRegion()
            })
            .store(in: &cancellables)
    }
    
    private func updateMapAnnotations() {
        guard let dispatch = dispatch else { return }
        
        let customerAnnotation = MapAnnotationItem(
            id: "dispatch-\(dispatch.id)",
            coordinate: CLLocationCoordinate2D(
                latitude: dispatch.receiverLatitude,
                longitude: dispatch.receiverLongitude
            ),
            isBranch: false,
            hasPreferredTime: dispatch.hasPreferredDeliveryTime(),
            info: nil,
        )
        
        mapAnnotations = [customerAnnotation]
    }
    
    private func updateRegion() {
        guard let dispatch = dispatch else { return }
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: dispatch.receiverLatitude,
                longitude: dispatch.receiverLongitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        )
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
