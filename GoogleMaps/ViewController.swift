//
//  ViewController.swift
//  GoogleMaps
//
//  Created by iMac on 08.11.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // Центр Москвы
    private let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    private var marker: GMSMarker?
    private var manualMarker: GMSMarker?
    private var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        configureMap()
    }

    private func configureMap() {
        // Создаём камеру с использованием координат и уровнем увеличения
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        // Устанавливаем камеру для карты
        mapView.camera = camera
        // Показать пробки
        mapView.isTrafficEnabled = false
        // Показать мою позицию
        mapView.settings.myLocationButton = false
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
    }
    
    private func mark() {
        marker = GMSMarker(position: coordinate)
        marker?.title = "Hello"
        marker?.snippet = "World"
        marker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker?.map = mapView
    }
    
    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    @IBAction func goToCenter(_ sender: Any) {
        mapView.animate(toLocation: coordinate)
    }
    @IBAction func markAction(_ sender: UIBarButtonItem) {
        marker == nil ? mark() : removeMarker()
    }
    @IBAction func updateLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let market = GMSMarker(position: coordinate)
            market.map = mapView
            manualMarker = marker
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else { return }
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16)
        mapView.animate(to: position)
        let marker = GMSMarker(position: location.coordinate)
        marker.map = mapView
        self.marker = marker
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
