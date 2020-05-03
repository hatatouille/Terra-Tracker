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

class PokemonViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var gameScoreView: UIView!
    @IBOutlet weak var diamondScoreView: UIView!
    @IBOutlet weak var butterflyScoreView: UIView!
    @IBOutlet weak var featherScoreView: UIView!
    
    @IBOutlet weak var diamondScoreLabel: UILabel!
    @IBOutlet weak var butterflyScoreLabel: UILabel!
    @IBOutlet weak var featherScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScoreView()
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
}
