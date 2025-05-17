//
//  Branch.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


struct Branch: Identifiable, Codable,Hashable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var boundingBoxLatitude1: Double = 0.0
    var boundingBoxLatitude2: Double = 0.0
    var boundingBoxLongitude1: Double = 0.0
    var boundingBoxLongitude2: Double = 0.0
}

extension Branch {
    func contains(latitude: Double, longitude: Double) -> Bool {
        let isWithinLatitude = latitude <= boundingBoxLatitude1 && latitude >= boundingBoxLatitude2
        let isWithinLongitude = longitude >= boundingBoxLongitude1 && longitude <= boundingBoxLongitude2
        return isWithinLatitude && isWithinLongitude
    }
}
