//
//  CustomMapView.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MapAnnotationItem]
    var outboundRouteCoordinates: [CLLocationCoordinate2D]
    var returnRouteCoordinates: [CLLocationCoordinate2D]
    var showOutboundRoute: Bool
    var showReturnRoute: Bool
    var branchBoundingBoxCoordinates: [CLLocationCoordinate2D]
    var onTap: ((CLLocationCoordinate2D) -> Void)? = nil

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        if showOutboundRoute && !outboundRouteCoordinates.isEmpty {
            let outboundPolyline = MKPolyline(coordinates: outboundRouteCoordinates, count: outboundRouteCoordinates.count)
            outboundPolyline.title = "outbound"
            mapView.addOverlay(outboundPolyline)
        }

        if showReturnRoute && !returnRouteCoordinates.isEmpty {
            let returnPolyline = MKPolyline(coordinates: returnRouteCoordinates, count: returnRouteCoordinates.count)
            returnPolyline.title = "return"
            mapView.addOverlay(returnPolyline)
        }

        if !branchBoundingBoxCoordinates.isEmpty {
            let polygon = MKPolygon(coordinates: branchBoundingBoxCoordinates, count: branchBoundingBoxCoordinates.count)
            polygon.title = "branch-bbox"
            mapView.addOverlay(polygon)
        }

        for item in annotations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.coordinate
            annotation.title = item.getAnnotationTitle()
            annotation.subtitle = item.info
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onTap?(coordinate)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                if polyline.title == "outbound" {
                    renderer.strokeColor = .systemBlue
                } else if polyline.title == "return" {
                    renderer.strokeColor = .systemOrange
                } else {
                    renderer.strokeColor = .systemGray
                }
                renderer.lineWidth = 4
                return renderer
            } else if let polygon = overlay as? MKPolygon, polygon.title == "branch-bbox" {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = UIColor.systemRed
                renderer.lineWidth = 2
                renderer.fillColor = UIColor.systemRed.withAlphaComponent(0.1)
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            } else {
                annotationView?.annotation = annotation
            }
            
            switch annotation.title {
            case "Branch":
                annotationView?.image = UIImage(named: "branch")
            case "Priority Customer":
                annotationView?.image = UIImage(named: "marker-green")
            default:
                annotationView?.image = UIImage(named: "marker")
            }
            
            annotationView?.frame.size = CGSize(width: 40, height: 40)
            annotationView?.canShowCallout = true
            return annotationView
        }
    }
    
   
    
}
