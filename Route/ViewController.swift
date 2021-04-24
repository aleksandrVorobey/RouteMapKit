//
//  ViewController.swift
//  Route
//
//  Created by Александр Воробей on 15.04.2021.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setConstraints()
        
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc func addAdressButtonTapped() {
        alertAddAdress(title: "Find place", placeholder: "Insert adress") { [self] (text) -> (Void) in
            setupPlacemark(adressPlace: text)
        }
    }

    @objc func routeButtonTapped() {
        for index in 0 ... annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinante: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }

    @objc func resetButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }

    func setupPlacemark(adressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            if let error = error {
                print(error)
                alertError(title: "Ошибка", massage: "Сервер не доступен. Попробуйте ввести адрес еще раз")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = adressPlace
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
            
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinante: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinante)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.alertError(title: "Ошибка", massage: "Маршрут не доступен")
                return
            }
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = route.distance < minRoute.distance ? route : minRoute
            }
            self.mapView.addOverlay(minRoute.polyline)
        }
        
    }

}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}

extension ViewController {
    func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 70),
            addAdressButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 70),
            routeButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 60),
            resetButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}
