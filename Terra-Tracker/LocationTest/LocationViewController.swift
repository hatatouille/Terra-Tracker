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

class LocationViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    
    var latitudeNow: String = ""
    var longitudeNow: String = ""

    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セットアップ
        setupLocationManager()
    }
    /// - Parameter sender: "位置情報を取得"ボタン
    @IBAction func getLocationInfo(_ sender: Any) {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            showAlert()
        } else if status == .authorizedWhenInUse {
            self.latitude.text = latitudeNow
            self.longitude.text = longitudeNow
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
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        // 格納する
        self.latitudeNow = String(latitude!)
        self.longitudeNow = String(longitude!)
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")
    }
}
