//
//  DispatchType.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


enum DispatchType: String, Codable {
    case BAG = "BAG"
    case SACK = "SACK"
    case PARCEL = "PARCEL"
    case FILE = "FILE"
}

extension DispatchType {
    func toText() -> String {
        switch self {
        case .SACK: return "Sack"
        case .BAG: return "Bag"
        case .PARCEL: return "Parcel"
        case .FILE: return "File"
        }
    }
}
