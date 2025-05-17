//
//  Geometry.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


struct Geometry: Codable {
    let outbound: [[Double]]
    let geometryReturn: [[Double]]

    enum CodingKeys: String, CodingKey {
        case outbound
        case geometryReturn = "return"
    }
}