//
//  AddDispatchView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import MapKit
import Combine

struct AddDispatchView: View {
    let branch: Branch
    @StateObject private var viewModel = AddDispatchViewModel()
    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var address: String = "Not Selected"
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(branch: Branch) {
        self.branch = branch
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Form {
                        Section(header: Text("Dispatch Information")) {
                            Picker("Dispatch Type", selection: $viewModel.dispatchType) {
                                ForEach([DispatchType.BAG, .SACK, .PARCEL, .FILE], id: \ .self) { type in
                                    Text(type.toText()).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            TextField("Weight (kg)", value: $viewModel.weight, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        
                        Section(header: Text("Customer")) {
                            Picker("Select Customer", selection: $viewModel.selectedCustomer) {
                                Text("Select").tag(nil as Customer?)
                                ForEach(viewModel.customers) { customer in
                                    Text("\(customer.name)").tag(customer as Customer?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Section(header: Text("Delivery Time")) {
                            HStack {
                                DatePicker("Start", selection: $viewModel.deliveryStartTime, displayedComponents: .hourAndMinute)
                                    .onChange(of: viewModel.deliveryStartTime) { _ in
                                        viewModel.updateDeliveryRange()
                                    }
                                
                                DatePicker("End", selection: $viewModel.deliveryEndTime, displayedComponents: .hourAndMinute)
                                    .onChange(of: viewModel.deliveryEndTime) { _ in
                                        viewModel.updateDeliveryRange()
                                    }
                            }
                            
                            Picker("Delivery Range", selection: $viewModel.deliveryRange) {
                                ForEach([DeliveryRange.MORNING, .MIDMORNING, .AFTERNOON, .EVENING], id: \ .self) { range in
                                    Text(range.toText()).tag(range)
                                }
                            }
                            .onChange(of: viewModel.deliveryRange) { _ in
                                viewModel.updateDeliveryTime()
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Section(header: Text("Select Location")) {
                            VStack {
                                ZStack {
                                    CustomMapView(
                                        region: $region,
                                        annotations: viewModel.mapAnnotations,
                                        outboundRouteCoordinates: [],
                                        returnRouteCoordinates: [],
                                        showOutboundRoute: false,
                                        showReturnRoute: false,
                                        branchBoundingBoxCoordinates: viewModel.branchBoundingBox,
                                        onTap: { coordinate in
                                            selectedCoordinate = coordinate
                                            viewModel.updateSelectedLocation(coordinate)
                                            viewModel.fetchAddress(for: coordinate)
                                        }
                                    )
                                    .frame(height: 300)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Latitude: \(region.center.latitude, specifier: "%.6f")")
                                        Text("Longitude: \(region.center.longitude, specifier: "%.6f")")
                                        Text("Address: \(viewModel.address)")
                                            .lineLimit(2)
                                    }
                                    .font(.caption)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .frame(height: 650)
                    
                    Button(action: {
                        viewModel.validateAndCreateDispatch(branchId: branch.id) { success, message in
                            if success {
                                alertMessage = "Dispatch added successfully!"
                            } else {
                                alertMessage = "Error: \(message)"
                            }
                            showAlert = true
                        }
                    }) {
                        Text("Add Dispatch")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.isSubmitDisabled)
                    .padding()
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.fetchCustomers()
            viewModel.addBranchAnnotation(branch: branch)
            viewModel.setBranchBoundingBox(branch: branch)
        }
        .alert(isPresented: $showAlert) {
            SwiftUI.Alert(
                title: Text(alertMessage.contains("Error") ? "Error" : "Success"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if !alertMessage.contains("Error") {
                        viewModel.resetForm()
                    }
                }
            )
        }
        .navigationTitle("Add Dispatch")
        .navigationBarTitleDisplayMode(.inline)
    }
} 

#Preview {
    AddDispatchView(branch: Branch(id: 1, name: "Test Branch", latitude: 37.7749, longitude: -122.4194))
}
