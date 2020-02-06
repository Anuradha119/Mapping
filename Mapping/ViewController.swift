//
//  ViewController.swift
//  Mapping
//
//  Created by Marni Anuradha on 2/6/20.
//  Copyright © 2020 Marni Anuradha. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON


class ViewController: UIViewController,UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    var acvc = GMSAutocompleteViewController()
    var selectedTf:String = ""

    @IBOutlet weak var sourceTF: UITextField!
    
    @IBOutlet weak var destinationTF: UITextField!
    var sourceLocation = CLLocation()
    var destinationLocation = CLLocation()
    
    
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTF.delegate = self
        destinationTF.delegate = self
        acvc.delegate = self
        
        let camera1 = GMSCameraPosition.init(latitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera = camera1
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.map = mapView
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Success")
        if(selectedTf == "Source")
        {
            sourceTF.text = place.name
            sourceLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        else
        {
            selectedTf == "Destination"
            destinationTF.text = place.name
            destinationLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Cancelled")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == sourceTF)
        {
            selectedTf = "Source"
            textField.resignFirstResponder()
            present(acvc, animated: true, completion: nil)
        }else if(textField == destinationTF){
            selectedTf = "Destination"
            textField.resignFirstResponder()
            present(acvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func getDirectionBtnTp(_ sender: Any) {
        drawPath(startLocation: sourceLocation, endLocation: destinationLocation)
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        mapView.clear()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        marker.title = sourceTF.text!
        marker.snippet = sourceTF.text!
        marker.map = mapView
        
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        marker2.title = destinationTF.text!
        marker2.snippet = destinationTF.text!
        marker2.map = mapView
        
        
        
        
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDuBvXGuYzrnh51qC3brdG0OQCsXFHCNLU"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            do{
            let json = try JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.mapView
            }
                
                let camera = GMSCameraPosition.camera(withLatitude: self.sourceLocation.coordinate.latitude, longitude: self.sourceLocation.coordinate.longitude, zoom: 5.0
            )
                
                self.mapView.camera = camera
            }catch
            {
                print("unable to create route")
            }
            
        }
    
}

}
