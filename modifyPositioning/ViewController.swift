//
//  ViewController.swift
//  modifyPositioning
//
//  Created by daiyazhou on 2018/10/30.
//  Copyright © 2018年 daiyazhou. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate{
    private let locationManager: CLLocationManager = {
        let locationManager =  CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = 10
//        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        return locationManager
    }()
    private var currentLocation : CLLocation = {
        let currentLocation = CLLocation(latitude: 31.167103637855593, longitude: 121.3849957673268)
        return currentLocation
    }()
    private let longitudeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 100, width: UIScreen.main.bounds.width - 20, height: 40))
        label.text = "经度"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        return label
    }()
    private let latitudeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 150, width: UIScreen.main.bounds.width - 20, height: 40))
        label.text = "纬度"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        return label
    }()
    private let currentLongitudeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 200, width: UIScreen.main.bounds.width - 20, height: 40))
        label.text = "当前经度"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        return label
    }()
    private let currentLatitudeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 250, width: UIScreen.main.bounds.width - 20, height: 40))
        label.text = "当前纬度"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        return label
    }()
    private let currentPostLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 300, width: UIScreen.main.bounds.width - 20, height: 200))
        label.text = "当前位置"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    private let updateButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width/3, y: 500, width: UIScreen.main.bounds.width - 20, height: 100))
        button.setTitle("更新", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.setupView()
        self.updateButton.addTarget(self, action: #selector(onClickUpdateButton), for: .touchUpInside)
        CLGeocoder().reverseGeocodeLocation(currentLocation) { [weak self](placemarks, error) in
            guard let weakSelf = self else {return}
            weakSelf.setupData(placemarks: placemarks)
        }
        self.currentLatitudeLabel.text = "纬度:\(currentLocation.coordinate.latitude)"
        self.currentLongitudeLabel.text = "经度:\(currentLocation.coordinate.longitude)"
        locationManager.startUpdatingLocation()
    }
    
    private func setupView() {
//        self.view.addSubview(longitudeLabel)
//        self.view.addSubview(latitudeLabel)
        self.view.addSubview(currentLongitudeLabel)
        self.view.addSubview(currentLatitudeLabel)
        self.view.addSubview(currentPostLabel)
        self.view.addSubview(updateButton)
    }

    @objc private func onClickUpdateButton() {
        locationManager.startUpdatingLocation()
    }
    private func setupData(placemarks:[CLPlacemark]? ) {
        guard let placemarks = placemarks, placemarks.count > 0 else {return}
        guard let currentCity = placemarks[0].locality else {
            currentPostLabel.text = "无法定位当前城市"
            locationManager.stopUpdatingLocation()
            return
        }
        let placeMark = placemarks[0]
        //具体地址
        currentPostLabel.text = "\(placeMark.country  ?? ""),\(currentCity),\(placeMark.subLocality  ?? ""),\(placeMark.thoroughfare  ?? ""),\(placeMark.name  ?? "")"
        print(currentPostLabel.text)
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last?.coordinate else {return}
        self.currentLatitudeLabel.text = "纬度:\(currentLocation.latitude)"
        self.currentLongitudeLabel.text = "经度:\(currentLocation.longitude)"
        self.currentLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        //地理反编码 可以根据坐标(经纬度)确定位置信息(街道 门牌等)
        let geoCoder: CLGeocoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locations.last!) { [weak self ](placemarks, error) in
            guard let weakSelf = self else {return}
            weakSelf.setupData(placemarks: placemarks)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.authorizationStatus() == .denied {
            let alertVC = UIAlertController(title: /*"获取您的地理位置失败"*/"getLocationFail", message: /*"请开启定位功能"*/"pleaseStartLocation", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: /*"开启"*/"startLocation", style: UIAlertAction.Style.destructive) { (action) in
                //跳到APP设置页面
                guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly : true], completionHandler: nil)
                }else {
                    UIApplication.shared.openURL(url)
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: nil)
            alertVC.addAction(ok)
            alertVC.addAction(cancel)
            present(alertVC, animated: true, completion: nil)
        }
        print(error.localizedDescription)
    }
}

