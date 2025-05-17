//
//  DispatchDetailsView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import MapKit
import Combine

struct DispatchDetailsView: View {
    let dispatchId: Int
    @StateObject private var viewModel = DispatchDetailsViewModel()
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0, longitude: 29.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dispatch Details")
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if let dispatch = viewModel.dispatch {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dispatch #\(dispatch.id)")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        DetailRow(
                            label: "Dispatch Type",
                            value: dispatch.dispatchType.toText()
                        )
                        
                        DetailRow(
                            label: "Weight",
                            value: "\(dispatch.weight) kg"
                        )
                        
                        if let startTime = dispatch.preferFirstDeliveryTime,
                           let endTime = dispatch.preferLastDeliveryTime {
                            DetailRow(
                                label: "Preferred Time Range",
                                value: "\(formatUnixTime(startTime)) - \(formatUnixTime(endTime))"
                            )
                        } else {
                            DetailRow(
                                label: "Preferred Time Range",
                                value: "Not available"
                            )
                        }
                        
                        DetailRow(
                            label: "Delivery Range",
                            value: dispatch.deliveryRange.toText()
                        )
                        
                        DetailRow(
                            label: "Customer",
                            value: "\(dispatch.customer.name) (\(dispatch.customer.phone ?? "No phone"))"
                        )
                        
                        DetailRow(
                            label: "Coordinates",
                            value: "(\(dispatch.receiverLatitude), \(dispatch.receiverLongitude))"
                        )
                        
                        DetailRow(
                            label: "Address",
                            value: dispatch.receiverAddress
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    CustomMapView(
                        region: $viewModel.region,
                        annotations: viewModel.mapAnnotations,
                        outboundRouteCoordinates: [],
                        returnRouteCoordinates: [],
                        showOutboundRoute: false,
                        showReturnRoute: false,
                        branchBoundingBoxCoordinates: viewModel.branchBoundingBox
                    )
                    .frame(height: 400)
                    .cornerRadius(12)
                    .padding()
                } else {
                    Text("Dispatch not found")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.fetchDispatch(id: dispatchId)
        }
        .navigationTitle("Dispatch Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatUnixTime(_ unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .fontWeight(.medium)
                .frame(width: 140, alignment: .leading)
            
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
    }
} 
