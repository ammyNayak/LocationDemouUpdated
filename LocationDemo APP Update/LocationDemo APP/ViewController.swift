//
//  ViewController.swift
//  LocationDemo APP
//
//  Created by Amit on 09/09/22.
//

import UIKit
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapVw: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var locationManager = CLLocationManager()
    let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
    var lat:String = ""
    var lang:String  = ""
    var currentLocationStr = "User's Location"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapVw.delegate = self
       

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineCurrentLocation()
    }
  
    //MARK:- Intance Methods

    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

//MARK: For user current location
extension ViewController:CLLocationManagerDelegate
{

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapVw.setRegion(mRegion, animated: true)

        // Get user's Current Location and Drop a pin
    
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
      
        mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
        mapVw.addAnnotation(mkAnnotation)
    }
    //MARK:- Intance Methods

    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)

        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in

            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                            self.mkAnnotation.title = self.currentLocationStr
                            self.lat = "\(mLattitude)"
                            self.lang = "\(mLongitude)"
                            
                            self.locationLabel.text = self.currentLocationStr
                            self.latitudeLabel.text = self.lat
                            self.longitudeLabel.text = self.lang
                        }
                    }
                }
            }
        }
        
        return currentLocationStr
    }
   
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//
//        var alert = UIAlertController(title: "Location", message: "Address: \(self.currentLocationStr) \n\nLattitude: \(self.lat) , Longitude: \(self.lang)", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Ok", style:.default , handler: nil))
//        self.present(alert, animated: true, completion: nil)
//
//    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways{

            let alertController = UIAlertController(title: "Location Permission Update", message: "You can update your location permission by clicking on setting.", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                    //Redirect to Settings app
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(cancelAction)

                alertController.addAction(okAction)

                self.present(alertController, animated: true, completion: nil)
            
            
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("No Location access")

            break;
        case .restricted, .denied:
            print("No Location access")
            break;
        case .authorizedWhenInUse:
                print("When in use permission granted.")

            break;
        case .authorizedAlways:
            DispatchQueue.main.async{

            }
            print("Always on permission granted.")
            break;
        default:
            return
        }
    }
}
