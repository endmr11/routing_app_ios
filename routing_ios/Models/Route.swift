//
//  Route.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


struct Route: Codable {
    let startTime: String
    let vehicleId: String
    let services: [Service]

    enum CodingKeys: String, CodingKey {
        case startTime
        case vehicleId
        case services
    }
}