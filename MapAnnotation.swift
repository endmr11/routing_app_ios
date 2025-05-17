//
//  MapAnnotation.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import MapKit
import Combine

struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D

    let isBranch: Bool
    let hasPreferredTime: Bool
    let info: String?
    
    
    
    func getAnnotationTitle() -> String {
        if isBranch {
            return "Branch"
        } else {
            if hasPreferredTime {
                return "Priority Customer"
            } else {
                return "Customer"
            }
        }
    }
}
