//
//  DeliveryRange.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


enum DeliveryRange: String, Codable {
    case MORNING = "MORNING"
    case MIDMORNING = "MIDMORNING"
    case AFTERNOON = "AFTERNOON"
    case EVENING = "EVENING"
}

extension DeliveryRange {
    func toText() -> String {
        switch self {
        case .MORNING: return "Morning"
        case .MIDMORNING: return "Midmorning"
        case .AFTERNOON: return "Afternoon"
        case .EVENING: return "Evening"
        }
    }
    static func fromText(_ text: String) -> DeliveryRange? {
        switch text {
        case "Morning": return .MORNING
        case "Midmorning": return .MIDMORNING
        case "Afternoon": return .AFTERNOON
        case "Evening": return .EVENING
        default: return nil
        }
    }
    func hours() -> (Int, Int) {
        switch self {
        case .MORNING, .MIDMORNING:
            return (7, 12)
        case .AFTERNOON, .EVENING:
            return (13, 18)
        }
    }
}
