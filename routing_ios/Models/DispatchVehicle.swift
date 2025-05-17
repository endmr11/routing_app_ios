//
//  DispatchVehicle.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


struct DispatchVehicle: Identifiable, Codable, Hashable {
    var id: Int
    var vehicle: Vehicle
    var dispatch: [Dispatch]
    var routeDate: Int
    
    static func == (lhs: DispatchVehicle, rhs: DispatchVehicle) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
