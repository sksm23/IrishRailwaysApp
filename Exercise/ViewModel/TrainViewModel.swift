//
//  TrainViewModel.swift
//  Exercise
//
//  Created by Sunil Kumar on 10/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import RxSwift

struct TrainsViewModel {
    
    var trainList: Variable<[Train]?> = Variable(nil)
    var apiError: Variable<String?> = Variable(nil)
    
    init() {
        getCurrentTrains(trainType: nil)
    }
    
    func getCurrentTrains(trainType: String?) {
        // TODO: -  Move url strings to single constant file
        var getAllTrainsUrl = "getCurrentTrainsXML"
        if let type = trainType {
            let typeChar = type.prefix(1)
            getAllTrainsUrl = "getCurrentTrainsXML_WithTrainType?TrainType=\(typeChar)"
        }
        ApiManager.request(getAllTrainsUrl,
                           params: nil,
                           method: .get,
                           headers: [:],
                           successClosure: { response in
                            guard let responseXml = response else { return }
                            let array = responseXml["ArrayOfObjTrainPositions"]["objTrainPositions"].all
                            var trains: [Train] = []
                            for obj in array {
                                let stat = obj["TrainStatus"].element?.text ?? "NA"
                                let lat = obj["TrainLatitude"].element?.text ?? "0.0"
                                let lon = obj["TrainLongitude"].element?.text ?? "0.0"
                                let code = obj["TrainCode"].element?.text ?? "NA"
                                let date = obj["TrainDate"].element?.text ?? "NA"
                                let message = obj["PublicMessage"].element?.text ?? "NA"
                                let dir = obj["Direction"].element?.text ?? "NA"
                                let model =  Train(status: stat,
                                                   latitude: Double(lat)!,
                                                   longitude: Double(lon)!,
                                                   code: code,
                                                   date: date,
                                                   publicMessage: message,
                                                   direction: dir)
                                trains.append(model)
                            }
                            self.trainList.value = trains
        }) { error in
            if let error = error {
                debugPrint(error) // Handle error properly
                self.apiError.value = error.localizedDescription
            }
        }
    }
    
    func getTrainDetailsWith(id: String?, date: String?) {
        // TODO: -  Move url strings to single constant file
        var getAllTrainsUrl = "getTrainMovementsXML?TrainId=\(id!)&TrainDate=\(date!)"
        getAllTrainsUrl = getAllTrainsUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        ApiManager.request(getAllTrainsUrl,
                           params: nil,
                           method: .get,
                           headers: [:],
                           successClosure: { response in
                            guard let responseXml = response else { return }
                            debugPrint(responseXml)
        }) { error in
            if let error = error {
                debugPrint(error) // Handle error properly
            }
        }
    }
}
