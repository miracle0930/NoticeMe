//
//  LocationsViewController.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/20.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import UserNotifications


class LocationsViewController: UIViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    var currentNotice: Notice? {
        didSet {
            loadSavedLocations()
        }
    }
    var mapView: GMSMapView?
    var locationManager = CLLocationManager()
    var markers = [GMSMarker]()
    var graphs = [GMSPolygon]()
    var graphCreated = false
    var savedLocations: Results<CustomLocation>?
    @IBOutlet var basicView: UIView!
    @IBOutlet var createGraphButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var undoButton: UIButton!
    @IBOutlet var lockMapButtonIndicator: UISwitch!
    @IBOutlet var locationsTableView: UITableView!
    var nextAdded: UITextField!


    // MARK: - Congigure the whole UIView.
    override func viewDidLoad() {
        super.viewDidLoad()
        locationsTableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        locationsTableView.delegate = self
        locationsTableView.dataSource = self
        locationsTableView.register(UINib(nibName: "LocationsTableViewCell", bundle: nil), forCellReuseIdentifier: "locationTableViewCell")
        locationsTableView.rowHeight = 50
        configureMapView()
        updateEditButtonsStatus(enabled: false)
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnTableView))
        longTap.minimumPressDuration = 0.5
        locationsTableView.addGestureRecognizer(longTap)
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.activityType = .fitness
            locationManager.startUpdatingLocation()
        }
        
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureMapView() {
        let mapWidth = basicView.frame.width
        let mapHeight = basicView.frame.height
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight), camera: GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15))
        mapView!.settings.myLocationButton = true
        mapView!.isMyLocationEnabled = true
        mapView!.delegate = self
        basicView.addSubview(mapView!)
        mapView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.leadingMargin, relatedBy: NSLayoutRelation.equal, toItem: basicView, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.trailingMargin, relatedBy: NSLayoutRelation.equal, toItem: basicView, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: basicView, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.bottomMargin, relatedBy: NSLayoutRelation.equal, toItem: basicView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 0).isActive = true
        if let location = locationManager.location {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
            mapView!.animate(to: camera)
        }
        lockMapButtonIndicator.isOn = false
        mapView!.settings.setAllGesturesEnabled(!lockMapButtonIndicator.isOn)
    }
    
    func updateEditButtonsStatus(enabled: Bool) {
        createGraphButton.isEnabled  = enabled
        saveButton.isEnabled = enabled
        undoButton.isEnabled = enabled
        locationsTableView.isUserInteractionEnabled = !enabled
    }

    func loadSavedLocations() {
        savedLocations = currentNotice?.locations.sorted(byKeyPath: "modifiedTime", ascending: false)
    }
    
    // MARK: - Edit buttons pressed.
    @IBAction func drawOnMap(_ : UISwitch) {
        clearMarkers()
        clearGraphs()
        lockMapButtonIndicator.isOn = !lockMapButtonIndicator.isOn
        mapView!.settings.setAllGesturesEnabled(!lockMapButtonIndicator.isOn)
        updateEditButtonsStatus(enabled: lockMapButtonIndicator.isOn)
        graphCreated = false
    }
    
    @IBAction func undoButtonPressed(_ sender: UIButton) {
        removePreviousMarkers()
        clearGraphs()
        graphCreated = false
    }
    
    func removePreviousMarkers() {
        if markers.count != 0 {
            markers[markers.count-1].map = nil
            markers.remove(at: markers.count - 1)
        }
    }
    
    func clearMarkers() {
        for marker in self.markers {
            marker.map = nil
        }
        self.markers = [GMSMarker]()
    }
    
    func clearGraphs() {
        if self.graphs.count != 0 {
            self.graphs[self.graphs.count - 1].map = nil
            self.graphs.remove(at: self.graphs.count - 1)
        }
    }
    
    @IBAction func createGraphButtonPressed(_ sender: UIButton) {
        createGraph(zoom: mapView!.camera.zoom)
        graphCreated = true
    }
    
    func createGraph(zoom: Float) {
        if markers.count != 4 {
            let alert = UIAlertController(title: "Cannot Create Graph", message: "Make sure you create a rectangular area on the map.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        let (path, center) = createGMSMutablePathFromMarkers(marker: markers)
        clearGraphs()
        let camera = GMSCameraPosition.camera(withTarget: center, zoom: zoom)
        mapView!.animate(to: camera)
        let area = GMSPolygon(path: path)
        area.map = mapView
        graphs.append(area)
    }
    
    func createGMSMutablePathFromMarkers(marker: [GMSMarker]) -> (GMSMutablePath, CLLocationCoordinate2D) {
        let path = GMSMutablePath()
        var maxLat = Double(markers[0].position.latitude)
        var minLat = maxLat
        var maxLon = Double(markers[0].position.longitude)
        var minLon = maxLon
        for marker in markers {
            path.add(CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
            maxLat = max(maxLat, Double(marker.position.latitude))
            minLat = min(minLat, Double(marker.position.latitude))
            maxLon = max(maxLon, Double(marker.position.longitude))
            minLon = min(minLon, Double(marker.position.longitude))
        }
        let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2, longitude: (maxLon + minLon) / 2)
        return (path, center)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if !graphCreated {
            let alert = UIAlertController(title: "No Graph Created", message: "Press 'Create Graph' before you save.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            let currentDate = "Location alert on \(getCurrentTime(date: Date()))"
            let alert = createOrModifiyLocationInfo(name: currentDate, status: "New Location", locationData: nil)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func createOrModifiyLocationInfo(name: String, status: String, locationData: CustomLocation?) -> UIAlertController {
        let alert = UIAlertController(title: "\(status)", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.text = name
            self.nextAdded = alertTextField
            self.nextAdded.delegate = self
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (alertAction) in
            if let savedLocation = locationData {
                do {
                    try self.realm.write {
                        savedLocation.locationName = self.nextAdded.text!
                    }
                } catch {
                    print(error)
                }
            } else {
                let newLocation = self.nextAdded.text!
                let location = CustomLocation()
                location.locationName = newLocation
                location.setTime(date: Date())
                self.save(location: location)
                self.clearGraphs()
                self.clearMarkers()
            }
            self.locationsTableView.reloadData()
            self.graphCreated = false
            self.locationManager.startUpdatingLocation()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    
    // MARK: - Utility functions and textField delegate function.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        textField.becomeFirstResponder()
    }
    
    func save(location: CustomLocation) {
        if let selectedNotice = self.currentNotice {
            do {
                try self.realm.write {
                    for marker in self.markers {
                        location.locationData.append(Double(marker.position.latitude))
                        location.locationData.append(Double(marker.position.longitude))
                    }
                    location.zoom = mapView!.camera.zoom
                    selectedNotice.locations.append(location)
                    drawOnMap(lockMapButtonIndicator)
                }
            } catch {
                print(error)
            }
        }
    }

    func getCurrentTime(date: Date) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    
    func allLocationsUntouched() {
        do {
            try realm.write {
                for location in self.savedLocations! {
                    location.isDisplaying = false
                }
            }
        } catch {
            print(error)
        }
    }
    
    
}


// MARK: - UITableView delegate and datasource.
extension LocationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocations!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = locationsTableView.dequeueReusableCell(withIdentifier: "locationTableViewCell", for: indexPath) as! LocationsTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.nameLabel.text = savedLocations![indexPath.row].locationName
        cell.modifiedTimeLabel.text = "Last modified on \(savedLocations![indexPath.row].modifiedTime)"
        if savedLocations![indexPath.row].notified {
            cell.alarmButton.setImage(UIImage(named: "alarmOff"), for: .normal)
        } else {
            cell.alarmButton.setImage(UIImage(named: "alarmOn"), for: .normal)
        }
        cell.deletebuttonPresedCallBack = {
            let alert = UIAlertController(title: "Delete This Location Alert?", message: cell.nameLabel.text, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                if let deleteCell = self.savedLocations?[indexPath.row] {
                    if deleteCell.isDisplaying {
                        self.clearGraphs()
                        self.clearMarkers()
                    }
                    let identifier = "\(self.currentNotice!.noticeName):\(self.savedLocations![indexPath.row].locationName)"
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                    do {
                        try self.realm.write {
                            self.realm.delete(deleteCell)
                            self.locationsTableView.reloadData()
                            self.locationManager.startUpdatingLocation()
                        }
                    } catch {
                        print(error)
                    }
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        cell.locationAlarmButtonPressedCallBack = {
            do {
                try self.realm.write {
                    self.savedLocations![indexPath.row].notified = !self.savedLocations![indexPath.row].notified
                }
            } catch {
                print(error)
            }
            self.locationsTableView.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clearGraphs()
        clearMarkers()
        let selectedLocation = savedLocations![indexPath.row]
        if !selectedLocation.isDisplaying {
            for i in stride(from: 0, to: selectedLocation.locationData.count, by: 2) {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: selectedLocation.locationData[i], longitude: selectedLocation.locationData[i+1])
                marker.icon = UIImage(named: "marker")
                marker.map = mapView
                markers.append(marker)
            }
            createGraph(zoom: selectedLocation.zoom)
        } else {
            let cell = locationsTableView.cellForRow(at: indexPath)
            cell?.isSelected = false
        }
        do {
            try realm.write {
                let flag = selectedLocation.isDisplaying
                for location in self.savedLocations! {
                    location.isDisplaying = false
                }
                selectedLocation.isDisplaying = !flag
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - Google Map and location degelate
extension LocationsViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        var bounds = [GMSCoordinateBounds]()
        var names = [String]()
        for location in savedLocations! {
            let path = GMSMutablePath()
            for i in stride(from: 0, to: location.locationData.count, by: 2) {
                path.add(CLLocationCoordinate2D(latitude: location.locationData[i], longitude: location.locationData[i+1]))
            }
            bounds.append(GMSCoordinateBounds(path: path))
            names.append(location.locationName)
        }
        for i in stride(from: 0, to: bounds.count, by: 1) {
            let bound = bounds[i]
            if bound.contains(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)) && !savedLocations![i].notified {
                self.locationManager.startUpdatingLocation()
                if bound.contains(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)) {
                    let content = UNMutableNotificationContent()
                    content.title = "Are you in \(names[i]) area?"
                    content.body = "Don't forget to check your notice \(self.currentNotice!.noticeName)"
                    content.sound = UNNotificationSound.default()
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let identifier = "\(currentNotice!.noticeName):\(names[i])"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger:trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    do {
                        try self.realm.write {
                            self.savedLocations![i].notified = !self.savedLocations![i].notified
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if lockMapButtonIndicator.isOn {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            marker.icon = UIImage(named: "marker")
            marker.map = mapView
            markers.append(marker)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        return true
    }
    
    @objc func longPressOnTableView(longTap: UILongPressGestureRecognizer) {
        let touchPoint = longTap.location(in: locationsTableView)
        if let indexPath = locationsTableView.indexPathForRow(at: touchPoint) {
            let locationData = savedLocations![indexPath.row]
            if presentedViewController == nil {
                let alert = createOrModifiyLocationInfo(name: locationData.locationName, status: "Modify Location", locationData: locationData)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        let location = mapView.myLocation!
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        return false
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView!.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

}

