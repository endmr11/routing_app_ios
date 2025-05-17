//
//  MapPolyline.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//


import SwiftUI
import MapKit
import Combine

struct MapPolyline: Shape {
    var coordinates: [CLLocationCoordinate2D]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard coordinates.count > 1 else { return path }
        
        let points = coordinates.map { coordinate -> CGPoint in
            let latRatio = CGFloat((coordinate.latitude - coordinates[0].latitude) / 0.1)
            let lonRatio = CGFloat((coordinate.longitude - coordinates[0].longitude) / 0.1)
            
            let x = rect.width / 2 + lonRatio * rect.width
            let y = rect.height / 2 - latRatio * rect.height
            
            return CGPoint(x: x, y: y)
        }
        
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        
        return path
    }
}
