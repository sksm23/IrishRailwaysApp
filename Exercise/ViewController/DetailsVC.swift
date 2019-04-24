//
//  DetailsVC.swift
//  Exercise
//
//  Created by Sunil Kumar on 11/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import MapKit

class DetailsVC: BaseVC {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude = 0.0
    var longitude = 0.0
    var name = "NA"
    var desc = "NA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = desc
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = location
        annotation.title = name
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
}
