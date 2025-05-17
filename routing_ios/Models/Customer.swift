//
//  Customer.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


struct Customer: Identifiable, Codable, Hashable {
    var id: Int
    var firstName: String
    var lastName: String
    var phone: String?
    
    var name: String { "\(firstName) \(lastName)" }
}