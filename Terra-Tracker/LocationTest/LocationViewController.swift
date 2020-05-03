//
//  LocationViewController.swift
//  Terra-Tracker
//
//  Created by 塩塚 弘樹 on 2020/05/02.
//  Copyright © 2020 塩塚 弘樹. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

class LocationViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var latitudeNow: String = ""
    var longitudeNow: String = ""
    var addressNow: String = ""

    var locationManager: CLLocationManager!
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セットアップ
        setupLocationManager()
    }
    
//    override func loadView() {
//    }

    /// - Parameter sender: "位置情報を取得"ボタン
    @IBAction func getLocationInfo(_ sender: Any) {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            showAlert()
        } else if status == .authorizedWhenInUse {
            self.latitude.text = latitudeNow
            self.longitude.text = longitudeNow
            self.address.text = addressNow
        }
    }
    
    /// - Parameter sender: "クリア"ボタン
    @IBAction func clearLabel(_ sender: Any) {
        self.latitude.text = "デフォルト"
        self.longitude.text = "デフォルト"
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        
        // 位置情報取得許可ダイアログの表示
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }

    func showAlert() {
        let alertTitle = "位置情報が許可されていません。"
        let alertMessage = "OSの「設定 > プライバシー > 位置情報サービス」から変更してください。"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert
        )
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    /// 位置情報が更新された際に、位置情報を格納する
    /// - Parameters:
    ///     - manager: ロケーションマネージャ
    ///     - locations: 位置情報
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.first {
            let _latitude = location.coordinate.latitude
            let _longitude = location.coordinate.longitude
            
            let camera = GMSCameraPosition.camera(withLatitude: _latitude, longitude: _longitude, zoom: 18.0)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            view = mapView
            
            // ピンを立てる
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
            marker.title = "現在地"
            marker.snippet = "自宅"
            marker.map = mapView

            self.geocoder.reverseGeocodeLocation(location, completionHandler: { ( placemarks, error ) in
                if let placemark = placemarks?.first {
                    let administrativeArea = (placemark.administrativeArea == nil ? "" : placemark.administrativeArea!) + (placemark.subAdministrativeArea == nil ? "" : placemark.subAdministrativeArea!)
                    let locality = (placemark.locality == nil ? "" : placemark.locality!) + (placemark.subLocality == nil ? "" : placemark.subLocality!)
                    let thoroughfare = (placemark.thoroughfare == nil ? "" : placemark.thoroughfare!) + (placemark.subThoroughfare == nil ? "" : placemark.subThoroughfare!)
                    let _address = administrativeArea + locality + thoroughfare
                    self.addressNow = _address
//                    print("address: \(String(describing: _address))")
                    print("address: _address")
                }
            } )
            // 格納する
            self.latitudeNow = String(_latitude)
            self.longitudeNow = String(_longitude)
            print("latitude: \(_latitude)\nlongitude: \(_longitude)")
        }
    }
}
