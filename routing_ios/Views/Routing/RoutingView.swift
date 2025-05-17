//
//  RoutingView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import MapKit
import Combine



struct RoutingView: View {
    let branch: Branch
    @StateObject private var viewModel = RoutingViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        VStack {
            Text("Route Planning")
                .font(.title)
                .padding()
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Picker("Dispatches", selection: $viewModel.selectedDispatchVehicle) {
                    Text("Select").tag(nil as DispatchVehicle?)
                    ForEach(viewModel.dispatchVehicles) { vehicle in
                        Text("Vehicle: \(vehicle.vehicle.licensePlate)").tag(vehicle as DispatchVehicle?)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                
                Button("Create Route") {
                    viewModel.createRoute()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedDispatchVehicle == nil)
                .padding(.bottom)
                
                HStack {
                    Button("\(viewModel.showOutboundRoute ? "Hide" : "Show") Outbound Route") {
                        viewModel.showOutboundRoute.toggle()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    
                    Button("\(viewModel.showReturnRoute ? "Hide" : "Show") Return Route") {
                        viewModel.showReturnRoute.toggle()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding(.bottom)
                
                CustomMapView(
                    region: $region,
                    annotations: createAnnotations(),
                    outboundRouteCoordinates: viewModel.outboundRouteCoordinates,
                    returnRouteCoordinates: viewModel.returnRouteCoordinates,
                    showOutboundRoute: viewModel.showOutboundRoute,
                    showReturnRoute: viewModel.showReturnRoute,
                    branchBoundingBoxCoordinates: viewModel.branchBoundingBox
                )
                .frame(height: 400)
                .cornerRadius(12)
                .padding()
            }
        }
        .onAppear {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            viewModel.setBranchBoundingBox(branch: branch)
            viewModel.fetchDispatchVehicles()
        }
        .navigationTitle("Routing")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func createAnnotations() -> [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []
        
        annotations.append(MapAnnotationItem(
            id: "branch-\(branch.id)",
            coordinate: CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude),
            isBranch:true,
            hasPreferredTime: false,
            info: branch.name
        ))
        
        if let dispatchVehicle = viewModel.selectedDispatchVehicle {
            for (index, dispatch) in dispatchVehicle.dispatch.enumerated() {
                annotations.append(MapAnnotationItem(
                    id: "dispatch-\(dispatch.id)",
                    coordinate: CLLocationCoordinate2D(latitude: dispatch.receiverLatitude, longitude: dispatch.receiverLongitude),
                    isBranch: false,
                    hasPreferredTime: dispatch.hasPreferredDeliveryTime(),
                    info: "Name: \(dispatch.customer.name),Adress: \(dispatch.receiverAddress),Weight: \(dispatch.weight)"
                ))
            }
        }
        
        return annotations
    }
}








