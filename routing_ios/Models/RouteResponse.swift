//
//  RouteResponse.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

struct RouteResponse: Codable {
    let routes: [Route]
    let dispatches: [Dispatch]
    let totalDurationMinutes: Int
    let totalDurationFormatted: String
    let geometry: Geometry
    let totalDistance: Int
    let vehicle: Vehicle
    let unassignedJobs: [Int]?

    enum CodingKeys: String, CodingKey {
        case routes, dispatches, totalDurationMinutes, totalDurationFormatted, geometry, totalDistance, vehicle, unassignedJobs
    }
}
