//
//  ViewController.swift
//  GoogleMaps
//
//  Created by iMac on 08.11.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // Центр Москвы
    private let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    private var marker: GMSMarker?
    private var locationManager: CLLocationManager?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 16)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true

        configureLocationManager()
    }

    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }


    func addLine() {
        route = GMSPolyline()
        route?.strokeColor = .systemBlue
        route?.strokeWidth = 2
        routePath = GMSMutablePath()
        route?.map = mapView
    }

    func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = mapView
        self.marker = marker
        mapView.animate(toLocation: position)

    }

    func removeMarker() {
        marker?.map = nil
        marker = nil
    }


    func addLastRoute() {
        var lastRoute: [Route] = []
        do {
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded:false)
            let realm = try Realm(configuration: config)
            guard let routePath = routePath else { return }

            for i in 0..<routePath.count() {
                let currentCoordinate = routePath.coordinate(at: i)
                let route = Route()
                route.latitude = currentCoordinate.latitude
                route.longitude = currentCoordinate.longitude
                lastRoute.append(Route(value: route))
            }

            try realm.write{
                    realm.deleteAll()
                    realm.add(lastRoute)
                }

        } catch {
            print(error)
        }
    }

    func lastRoute() {
        let realm = try! Realm()
        let lastRoute: Results<Route> = { realm.objects(Route.self) }()
        guard !lastRoute.isEmpty else { return }
        addLine()
        for coordinates in lastRoute {
            routePath?.add(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
            route?.path = routePath
        }
        let firstCoordinates = CLLocationCoordinate2D(latitude: lastRoute.first!.latitude, longitude: lastRoute.first!.longitude)
        let lastCoordinates = CLLocationCoordinate2D(latitude: lastRoute.last!.latitude ,longitude: lastRoute.last!.longitude)
        let bounds = GMSCoordinateBounds(coordinate: firstCoordinates, coordinate: lastCoordinates)
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
        mapView.camera = camera
        mapView.moveCamera(GMSCameraUpdate.zoomOut())
    }
    
    
    @IBAction func stopAction(_ sender: UIButton) {
        locationManager?.stopUpdatingLocation()
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
        addLastRoute()
    }
    
    @IBAction func lastAction(_ sender: UIButton) {
        lastRoute()
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        addLine()
        locationManager?.startUpdatingLocation()
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        route?.path = routePath
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16)
        mapView.animate(to: camera)
        removeMarker()
        addMarker(position: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
