//
//  DispatchDistributionView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import Combine

struct DispatchDistributionView: View {
    let branch: Branch
    @StateObject private var viewModel = DispatchDistributionViewModel()
    @State private var showOnlyWithTimeRange = false
    
    var body: some View {
        VStack {
            Text("Create Dispatch List")
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
                Alert(
                    "Warning! Dispatches with a delivery range not matching the vehicle's delivery time will not be shown in the list!",
                    isPresented: .constant(true)
                )
                
                Form {
                    Section(header: Text("Vehicle")) {
                        Picker("Select Vehicle", selection: $viewModel.selectedVehicle) {
                            Text("Select").tag(nil as Vehicle?)
                            ForEach(viewModel.vehicles) { vehicle in
                                Text(vehicle.licensePlate).tag(vehicle as Vehicle?)
                            }
                        }
                        .onChange(of: viewModel.selectedVehicle) { _ in
                                viewModel.vehicleChanged()
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Section(header: Text("Dispatches")) {
                        Toggle("Only those with a time range", isOn: $showOnlyWithTimeRange)
                            .onChange(of: showOnlyWithTimeRange) { _ in
                                viewModel.filterDispatches(hasPreferredTime: showOnlyWithTimeRange)
                            }
                        
                        List {
                            ForEach(viewModel.filteredDispatches) { dispatch in
                                DispatchRow(dispatch: dispatch, isSelected: viewModel.selectedDispatches.contains(dispatch.id))
                                    .onTapGesture {
                                        viewModel.toggleDispatchSelection(dispatch)
                                    }
                            }
                        }
                    }
                    
                    Button("Create Distribution") {
                        viewModel.createDispatchDistribution()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.selectedVehicle == nil || viewModel.selectedDispatches.isEmpty)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.fetchVehicles()
        }
        .alert(isPresented: $viewModel.showSuccessAlert) {
            SwiftUI.Alert(
                title: Text("Success"),
                message: Text("Dispatch list created successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("Create Distribution")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DispatchRow: View {
    let dispatch: Dispatch
    let isSelected: Bool
    
    private func deliveryRangeToText(_ range: DeliveryRange) -> String {
        switch range {
        case .MORNING:
            return "Morning (07:00-10:00)"
        case .MIDMORNING:
            return "Midmorning (10:00-13:00)"
        case .AFTERNOON:
            return "Afternoon (13:00-16:00)"
        case .EVENING:
            return "Evening (16:00-19:00)"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dispatch.customer.name)
                    .font(.headline)
                Text("Address: \(dispatch.receiverAddress)")
                    .font(.subheadline)
                Text("Delivery Range: \(deliveryRangeToText(dispatch.deliveryRange))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct Alert: View {
    let message: String
    @Binding var isPresented: Bool
    
    init(_ message: String, isPresented: Binding<Bool>) {
        self.message = message
        self._isPresented = isPresented
    }
    
    var body: some View {
        if isPresented {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text(message)
                    .font(.subheadline)
                Spacer()
            }
            .padding()
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}
