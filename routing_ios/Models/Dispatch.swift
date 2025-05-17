//
//  Dispatch.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import Foundation


struct Dispatch: Identifiable, Codable {
    var id: Int
    var dispatchType: DispatchType
    var weight: Double
    var customer: Customer
    var deliveryRange: DeliveryRange
    var preferFirstDeliveryTime: Int?
    var preferLastDeliveryTime: Int?
    var receiverLatitude: Double
    var receiverLongitude: Double
    var receiverAddress: String
}

extension Dispatch {
    func hasPreferredDeliveryTime() -> Bool {
        return preferFirstDeliveryTime != nil && preferLastDeliveryTime != nil
    }

    static func createDateWithTime(hour: Int, duration: Int) -> Date {
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = 0
        let baseDate = calendar.date(from: components) ?? now
        return calendar.date(byAdding: .minute, value: duration, to: baseDate) ?? baseDate
    }
}
