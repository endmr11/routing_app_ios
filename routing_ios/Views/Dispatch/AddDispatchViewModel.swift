//
//  AddDispatchViewModel.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import Foundation
import Combine
import MapKit
import SwiftUI

class AddDispatchViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var dispatchType: DispatchType = .PARCEL
    @Published var weight: Double = 0.0
    @Published var selectedCustomer: Customer? = nil
    @Published var deliveryRange: DeliveryRange = .MORNING
    @Published var deliveryStartTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var deliveryEndTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var selectedLatitude: Double? = nil
    @Published var selectedLongitude: Double? = nil
    @Published var address: String = "Seçilmedi"
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var mapAnnotations: [MapAnnotationItem] = []
    @Published var branchBoundingBox: [CLLocationCoordinate2D] = []
    
    private var preferFirstDeliveryTime: Int? = nil
    private var preferLastDeliveryTime: Int? = nil
    
    var isSubmitDisabled: Bool {
        return selectedCustomer == nil || weight <= 0 || selectedLatitude == nil || selectedLongitude == nil
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let apiManager = APIManager.shared
    
    func fetchCustomers() {
        isLoading = true
        error = nil
        
        apiManager.fetchCustomers()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = "An error occurred while loading customers: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] customers in
                guard let self = self else { return }
                self.customers = customers
            })
            .store(in: &cancellables)
    }
    
    func addBranchAnnotation(branch: Branch) {
        let branchAnnotation = MapAnnotationItem(
            id: "branch-\(branch.id)",
            coordinate: CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude),
            isBranch: true,
            hasPreferredTime: false,
            info: nil,
        )
        
        _ = MapAnnotationItem(
            id: "branch-bbox",
            coordinate: CLLocationCoordinate2D(
                latitude: (branch.boundingBoxLatitude1 + branch.boundingBoxLatitude2) / 2,
                longitude: (branch.boundingBoxLongitude1 + branch.boundingBoxLongitude2) / 2
            ),
            isBranch: false,
            hasPreferredTime: false,
            info: nil,
        )
        
        mapAnnotations = [branchAnnotation]
    }
    
    func updateSelectedLocation(_ coordinate: CLLocationCoordinate2D) {
        selectedLatitude = coordinate.latitude
        selectedLongitude = coordinate.longitude

        let customerPin = MapAnnotationItem(
            id: "customer-pin",
            coordinate: coordinate,
            isBranch: false,
            hasPreferredTime: false,
            info: nil
        )

        mapAnnotations = mapAnnotations.filter { $0.id != "customer-pin" }
        mapAnnotations.append(customerPin)
    }
    
    func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.address = "Address not found: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first {
                let address = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.subLocality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
                
                self.address = address
            } else {
                self.address = "Address not found"
            }
        }
    }
    
    func updateDeliveryTime() {
        
        switch deliveryRange {
        case .MORNING:
            deliveryStartTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            deliveryEndTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
        case .MIDMORNING:
            deliveryStartTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
            deliveryEndTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
        case .AFTERNOON:
            deliveryStartTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
            deliveryEndTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
        case .EVENING:
            deliveryStartTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
            deliveryEndTime = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date()) ?? Date()
            
        }
    }
        
    
    func updateDeliveryRange() {
        if deliveryStartTime >= deliveryEndTime {
            deliveryEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: deliveryStartTime) ?? deliveryStartTime
        }
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: deliveryStartTime)
        let endHour = calendar.component(.hour, from: deliveryEndTime)
        
        let startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        var startTimeComponents = calendar.dateComponents([.hour, .minute], from: deliveryStartTime)
        startTimeComponents.year = startComponents.year
        startTimeComponents.month = startComponents.month
        startTimeComponents.day = startComponents.day
        
        let endComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        var endTimeComponents = calendar.dateComponents([.hour, .minute], from: deliveryEndTime)
        endTimeComponents.year = endComponents.year
        endTimeComponents.month = endComponents.month
        endTimeComponents.day = endComponents.day
        
        if let startDate = calendar.date(from: startTimeComponents),
           let endDate = calendar.date(from: endTimeComponents) {
            preferFirstDeliveryTime = Int(startDate.timeIntervalSince1970)
            preferLastDeliveryTime = Int(endDate.timeIntervalSince1970)
        }
        
        if startHour >= 7 && endHour < 10 {
            deliveryRange = .MORNING
        } else if startHour >= 10 && endHour < 13 {
            deliveryRange = .MIDMORNING
        } else if startHour >= 13 && endHour < 16 {
            deliveryRange = .AFTERNOON
        } else if startHour >= 16 && endHour < 19 {
            deliveryRange = .EVENING
        }
    }
    
    func isWithinBoundingBox(latitude: Double, longitude: Double, branchId: Int) -> Bool {
        return true
    }
    
    func validateAndCreateDispatch(branchId: Int, completion: @escaping (Bool, String) -> Void) {
        guard let customer = selectedCustomer else {
            completion(false, "Please select a customer")
            return
        }
        
        guard weight > 0 else {
            completion(false, "Please enter a valid weight")
            return
        }
        
        guard let latitude = selectedLatitude, let longitude = selectedLongitude else {
            completion(false, "Please select a location on the map")
            return
        }
        
        if !isWithinBoundingBox(latitude: latitude, longitude: longitude, branchId: branchId) {
            completion(false, "The delivery address is not within the branch boundaries!")
            return
        }
        
        let dispatch = Dispatch(
            id: 0,
            dispatchType: dispatchType,
            weight: weight,
            customer: customer,
            deliveryRange: deliveryRange,
            preferFirstDeliveryTime: preferFirstDeliveryTime,
            preferLastDeliveryTime: preferLastDeliveryTime,
            receiverLatitude: latitude,
            receiverLongitude: longitude,
            receiverAddress: address
        )
        
        isLoading = true
        error = nil
        
        apiManager.createDispatch(dispatch: dispatch)
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .finished:
                    completion(true, "Dispatch added successfully")
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func resetForm() {
        dispatchType = .PARCEL
        weight = 0.0
        selectedCustomer = nil
        deliveryRange = .MORNING
        deliveryStartTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        deliveryEndTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
        selectedLatitude = nil
        selectedLongitude = nil
        address = "Seçilmedi"
        
        mapAnnotations = mapAnnotations.filter { $0.id != "customer-pin" }
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
