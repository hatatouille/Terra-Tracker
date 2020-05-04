//
//  MapboxTestViewController.swift
//  Terra-Tracker
//
//  Created by 塩塚 弘樹 on 2020/05/04.
//  Copyright © 2020 塩塚 弘樹. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class MapboxTestViewController: UIViewController, MGLMapViewDelegate {
    @IBOutlet var mapView: MGLMapView!
    var source: MGLShapeSource!
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        mapView.delegate = self
    }
    
    func setupMapView() {
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 35.6085681, longitude: 139.6717532), zoomLevel: 16, animated: false)
        mapView.styleURL = MGLStyle.darkStyleURL
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 35.6085681, longitude: 139.6717532)
        annotation.title = "ウチ"
        annotation.subtitle = "リモートワークやるならココっしょ"
        mapView.addAnnotation(annotation)
        mapView.showsUserLocation = true
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 1200, pitch: 15, heading: 0)
        mapView.fly(to: camera, withDuration: -1, peakAltitude: -1, completionHandler: nil)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
//        if let url = URL(string: "https://hatatouille.github.io/wanderdrone-fork/?lat=35.6085681&lng=139.6717532") {
        if let url = URL(string: "https://wanderdrone.appspot.com/") {
            source = MGLShapeSource(identifier: "wanderdrone", url: url, options: nil)
            style.addSource(source)

            let droneLayer = MGLSymbolStyleLayer(identifier: "wanderdrone", source: source)
            droneLayer.iconImageName = NSExpression(forConstantValue: "rocket-15")
            droneLayer.iconHaloColor = NSExpression(forConstantValue: UIColor.white)
            style.addLayer(droneLayer)

            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateUrl), userInfo: nil, repeats: true)
        }

    }

    @objc func updateUrl() {
        source.url = source.url
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        timer = Timer()
    }
}
