//
//  Vehicle.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


struct Vehicle: Identifiable, Codable, Hashable {
    var id: Int
    var vehicleType: VehicleType
    var deliveryRange: DeliveryRange
    var licensePlate: String
    var branch: Branch
}

enum VehicleType: String, Codable {
    case PANELVAN = "PANELVAN"
    case LORRY = "LORRY"
    case TRUCK = "TRUCK"
    
    func toText() -> String {
        switch self {
        case .PANELVAN: return "Panelvan"
        case .LORRY: return "Lorry"
        case .TRUCK: return "Truck"
        }
    }
}
