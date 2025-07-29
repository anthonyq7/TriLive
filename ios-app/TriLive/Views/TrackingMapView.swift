//
//  TrackingMapView.swift
//  TriLive
//
//  Created by Anthony Qin on 7/28/25.
//

import SwiftUI
import MapKit

struct TrackingMapView: UIViewRepresentable {
    @Binding var points: [CLLocationCoordinate2D]
    @Binding var vehicleLocation: CLLocationCoordinate2D?
    let stopLocation: CLLocationCoordinate2D

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.mapType = .mutedStandard
        map.showsCompass = false
        map.showsScale = false

        // Add stop annotation
        let stopAnn = MKPointAnnotation()
        stopAnn.coordinate = stopLocation
        stopAnn.title = "Stop"
        map.addAnnotation(stopAnn)

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove existing overlays
        uiView.removeOverlays(uiView.overlays)

        // Add fresh polyline if we have at least 2 points
        if points.count > 1 {
            let poly = MKPolyline(coordinates: points, count: points.count)
            uiView.addOverlay(poly)
        }

        // Update or add vehicle annotation
        let existing = uiView.annotations.filter { $0.title == "Vehicle" }
        uiView.removeAnnotations(existing)
        if let loc = vehicleLocation {
            let vehAnn = MKPointAnnotation()
            vehAnn.coordinate = loc
            vehAnn.title = "Vehicle"
            uiView.addAnnotation(vehAnn)
        }

        // Auto‑zoom to show stop + vehicle
        uiView.showAnnotations(uiView.annotations, animated: true)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrackingMapView
        init(_ parent: TrackingMapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let pl = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: pl)
                renderer.lineWidth = 4
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineCap = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let title = annotation.title, title == "Vehicle" else { return nil }
            let id = "vehicle"
            // Create a filled circle with white border and TriLive bus logo inside
            let diameter: CGFloat = 24
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
            let circleImage = renderer.image { ctx in
                let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
                // Fill circle with accent color
                let accent = UIColor(named: "AccentColor") ?? UIColor.systemBlue
                accent.setFill()
                ctx.cgContext.fillEllipse(in: rect)
                // Stroke border in white
                ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                ctx.cgContext.setLineWidth(2)
                let inset = rect.insetBy(dx: 1, dy: 1)
                ctx.cgContext.strokeEllipse(in: inset)
                // Draw TriLive logo
                if let logo = UIImage(named: "TriLiveLogo") {
                    let logoSize = CGSize(width: diameter * 0.6, height: diameter * 0.6)
                    let origin = CGPoint(
                        x: (diameter - logoSize.width) / 2,
                        y: (diameter - logoSize.height) / 2
                    )
                    logo.draw(in: CGRect(origin: origin, size: logoSize))
                }
            }

            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view?.centerOffset = CGPoint(x: 0, y: -diameter/2)
                view?.canShowCallout = false
            } else {
                view?.annotation = annotation
            }
            view?.image = circleImage
            return view
        }
    }
}
