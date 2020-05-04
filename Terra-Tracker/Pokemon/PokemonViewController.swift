//
//  PokemonViewController.swift
//  Terra-Tracker
//
//  Created by 塩塚 弘樹 on 2020/05/02.
//  Copyright © 2020 塩塚 弘樹. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation
import PopupDialog

class PokemonViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var gameScoreView: UIView!
    @IBOutlet weak var diamondScoreView: UIView!
    @IBOutlet weak var butterflyScoreView: UIView!
    @IBOutlet weak var featherScoreView: UIView!
    
    @IBOutlet weak var diamondScoreLabel: UILabel!
    @IBOutlet weak var butterflyScoreLabel: UILabel!
    @IBOutlet weak var featherScoreLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var bearingAngle = 270.0
    var angleOfView = 45.0 // 3Dの傾き
    var zoomLevel:Float = 18
    var capitolLat = 35.6085681
    var capitolLon = 139.6717532
    var userMarker = GMSMarker()
    let userMarkerimageView = UIImageView(image: UIImage.gifImageWithName("player"))
    var diamond1Score = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScoreView()
        initializeMap()
        addMarkers()
    }

    //MARK: ScoreView
    func setupScoreView() {
        self.view.bringSubviewToFront(gameScoreView)
        gameScoreView.layer.cornerRadius = 10
        gameScoreView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        diamondScoreView.layer.cornerRadius = 25
        butterflyScoreView.layer.cornerRadius = 25
        featherScoreView.layer.cornerRadius = 25
        diamondScoreView.layer.masksToBounds = true
        butterflyScoreView.layer.masksToBounds = true
        featherScoreView.layer.masksToBounds = true
    }
    
    func setMapTheme(theme: String) {
        if theme == "Day" {
            do {
                if let styleURL = Bundle.main.url(forResource: "DayStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find DayStyle.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        } else if theme == "Evening" {
            do {
                if let styleURL = Bundle.main.url(forResource: "EveningStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find EveningStyle.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        } else {
            do {
                if let styleURL = Bundle.main.url(forResource: "NightStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find NightStyle.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
    }
    
    func centerMapAtUserLocation() {
        let locationObj = locationManager.location
        let coord = locationObj?.coordinate
        let latitude = coord?.latitude
        let longitude = coord?.longitude
        mapView.isMyLocationEnabled = true
        userMarkerimageView.frame = CGRect(x: 0, y: 0, width: 40, height: 70)
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude ?? capitolLat, longitude: longitude ?? capitolLon, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
        self.mapView.animate(to: camera)
    }
    
    func checkUserPermission() {
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
                case .notDetermined:
                    perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
                case .restricted, .denied:
                    perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.startUpdatingLocation()
                    locationManager.startUpdatingHeading()
                    centerMapAtUserLocation()
            @unknown default:
                NSLog("unknown error occurred.")
            }
        } else {
            perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
        }
    }
    
    @objc private func presentNotDeterminedPopup() {
        let title = "位置情報取得許可"
        let message = "位置情報を許可して、キミの周りにあるだ宝石を集めよう。"
        let image = UIImage(named: "userLocation-cover")
        let popup = PopupDialog(title: title, message: message, image: image)
        let skipButton = CancelButton(title: "スキップ") {
            self.dismiss(animated: true, completion: nil)
        }
        let okButton = DefaultButton(title: "OK") {
            self.locationManager.requestWhenInUseAuthorization()
        }
        popup.addButtons([skipButton, okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    @objc private func presentDeniedPopup() {
        let title = "位置情報取得許可"
        let message = "位置情報を許可して、キミの周りにあるだ宝石を集めよう。設定を開いてアプリの使用中は許可するようにしてよ。"
        let image = UIImage(named: "userLocation-cover")
        let popup = PopupDialog(title: title, message: message, image: image)
        let skipButton = CancelButton(title: "スキップ") {
            print("You canceled the car dialog.")
        }
        let settingsButton = DefaultButton(title: "設定を開く", dismissOnTap: false) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }
        popup.addButtons([skipButton, settingsButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                perform(#selector(presentNotDeterminedPopup), with: nil, afterDelay: 0)
            case .restricted, .denied:
                perform(#selector(presentDeniedPopup), with: nil, afterDelay: 0)
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                self.centerMapAtUserLocation()
        @unknown default:
            NSLog("unknown error occurred.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last ?? CLLocation(latitude: capitolLat, longitude: capitolLon)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
        self.mapView.animate(to: camera)
        mapView.animate(toBearing: newHeading.magneticHeading)
        userMarker.map = nil
        userMarker.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        userMarker.iconView = userMarkerimageView
        userMarker.groundAnchor = CGPoint(x: -1.0, y: 2.0)
        userMarker.map = mapView
    }
    
    func initializeMap() {
        self.mapView.delegate = self
        let camera = GMSCameraPosition.camera(withLatitude: capitolLat, longitude: capitolLon, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
        self.mapView.camera = camera
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
            case 7..<15: setMapTheme(theme: "Day")
            case 15..<18: setMapTheme(theme: "Evening")
            default: setMapTheme(theme: "Night")
        }
        self.mapView.settings.tiltGestures = false
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.zoomGestures = false
        self.mapView.settings.compassButton = true
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = true
        mapView.settings.indoorPicker = false
//        mapView.isBuildingsEnabled = false
        self.mapView.settings.scrollGestures = false
        checkUserPermission()
    }
    
    func distanceInMeters(marker: GMSMarker) -> CLLocationDistance {
        let markerLocation = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        let metres = locationManager.location?.distance(from: markerLocation)
        return Double(metres ?? -1)
    }
    
    func addMarkers() {
        let diamond1Gif = UIImage.gifImageWithName("diamond1")
        let diamond1GifView = UIImageView(image: diamond1Gif)
        diamond1GifView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let randomLatDC = [35.60869082126195,35.60930140634475,35.609789871055796,35.60917928970098,35.61003410229291,35.61031322279377,35.609493303551176,35.61033066779273,35.6111505784532,35.61003410229291,35.60968520029734,35.60930140634475,35.60858614906555,35.607434745866996,35.607609201962205,35.60853381291601,35.60736496332239,35.60818490437746,35.60891761055095,35.60834191340811,35.60739985460231,35.60828957709877,35.607609201962205,35.60914439919709,35.609196734947204,35.60930140634475,35.60877804798765,35.60989454167728,35.60797555852396,35.60821979529979,35.6075568651736,35.6090048370294,35.60802789503868,35.60827213165474,35.607295180716946,35.60996432201552,35.60705094111854,35.60914439919709]
        let randomLonDC = [139.67206478118896,139.67105627059937,139.6723437309265,139.67240810394287,139.67137813568115,139.67371702194214,139.67369556427002,139.6725797653198,139.67421054840088,139.67455387115476,139.67283725738525,139.67466115951538,139.67352390289307,139.67474699020386,139.67285871505737,139.67549800872803,139.6739101409912,139.67330932617188,139.67498302459717,139.6709704399109,139.67189311981198,139.6720004081726,139.6725583076477,139.67303037643433,139.6714210510254,139.67386722564694,139.67049837112427,139.67049837112427,139.67013359069824,139.6694040298462,139.6707558631897,139.67006921768188,139.6712064743042,139.67174291610718,139.6708631515503,139.67094898223877,139.6725583076477,139.6749615669250]
        for i in 0..<randomLonDC.count {
            var marker: GMSMarker?
            let position = CLLocationCoordinate2D(latitude: randomLatDC[i], longitude: randomLonDC[i])
            marker = GMSMarker(position: position)
//            marker?.title = "Distance Left: \(round(100*distanceInMeters(marker: marker!)*0.00062137)/100)miles"
            marker?.title = "\(round(100*distanceInMeters(marker: marker!))/100)m 先にあるよ"
            marker?.map = mapView
            marker?.iconView = diamond1GifView
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let distanceinMeter = round(100*distanceInMeters(marker: marker))/100
        print(distanceinMeter)
        if distanceinMeter < 100 {
            let title = "報酬"
            let message = "宝石が手に入ったよ"
            let popup = PopupDialog(title: title, message: message)
            let okButton = DefaultButton(title: "やったね！") {
                self.diamond1Score = self.diamond1Score + 1
                self.diamondScoreLabel.text = "\(self.diamond1Score)"
                marker.map = nil
            }
            popup.addButton(okButton)
            self.present(popup, animated: true, completion: nil)
        } else {
            let title = "無効"
            let messaage = "その宝石を手に入れるにはもっと近づかないと。"
            let popup = PopupDialog(title: title, message: messaage)
            let okButton = DefaultButton(title: "OK") {
                
            }
            popup.addButton(okButton)
            self.present(popup, animated: true, completion: nil)
        }
        return true
    }
}
