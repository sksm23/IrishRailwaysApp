//
//  ViewModel.swift
//  Exercise
//
//  Created by Sunil Kumar on 09/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import RxSwift

struct StationsViewModel {
    
    var stationsList: Variable<[Station]?> = Variable(nil)
    var apiError: Variable<String?> = Variable(nil)
    
    init() {
        getAllStations(stationType: nil)
    }
    
    func getAllStations(stationType: String?) {
        // TODO: -  Move url strings to single constant file
        var getAllStationsUrl = "getAllStationsXML"
        if let type = stationType {
            let typeChar = type.prefix(1)
            getAllStationsUrl = "getAllStationsXML_WithStationType?StationType=\(typeChar)"
        }
        ApiManager.request(getAllStationsUrl,
                           params: nil,
                           method: .get,
                           headers: [:],
                           successClosure: { response in
                            guard let responseXml = response else { return }
                            let array = responseXml["ArrayOfObjStation"]["objStation"].all
                            var stations: [Station] = []
                            for obj in array {
                                let desc = obj["StationDesc"].element?.text ?? "NA"
                                let alias = obj["StationAlias"].element?.text ?? "NA"
                                let lat = obj["StationLatitude"].element?.text ?? "0.0"
                                let lon = obj["StationLongitude"].element?.text ?? "0.0"
                                let code = obj["StationCode"].element?.text ?? "NA"
                                let id = obj["StationId"].element?.text ?? "0"
                                let model =  Station(description: desc,
                                                     alias: alias,
                                                     latitude: Double(lat)!,
                                                     longitude: Double(lon)!,
                                                     code: code,
                                                     id: Int(id)! )
                                stations.append(model)
                            }
                            self.stationsList.value = stations
        }) { error in
            if let error = error {
                debugPrint(error) // Handle error properly
                self.apiError.value = error.localizedDescription
            }
        }
    }
}
