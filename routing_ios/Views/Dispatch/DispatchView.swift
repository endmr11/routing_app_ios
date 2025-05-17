//
//  DispatchView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import Combine



struct DispatchView: View {
    let branch: Branch
    @StateObject private var viewModel = DispatchViewModel()
    
    var body: some View {
        VStack {
            Text("Dispatches")
                .font(.title)
                .padding()
            
            // Add Dispatch Button
            NavigationLink(destination: AddDispatchView(branch: branch)) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Dispatch")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom)
            }
            
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                
                Button("Try Again") {
                    viewModel.fetchDispatches()
                }
                .padding()
            } else if viewModel.dispatches.isEmpty {
                Text("No dispatches found yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.dispatches) { dispatch in
                        NavigationLink(destination: DispatchDetailsView(dispatchId: dispatch.id)) {
                            VStack(alignment: .leading) {
                                Text("Customer: \(dispatch.customer.name)")
                                    .font(.headline)
                                
                                Text("Type: \(dispatch.dispatchType.toText())")
                                
                                Text("Weight: \(String(format: "%.2f", dispatch.weight)) kg")
                                
                                Text("Delivery Range: \(dispatch.deliveryRange.toText())")
                                
                                Text("Address: \(dispatch.receiverAddress)")
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchDispatches()
        }
        .navigationTitle("Dispatches")
        .navigationBarTitleDisplayMode(.inline)
    }
}
