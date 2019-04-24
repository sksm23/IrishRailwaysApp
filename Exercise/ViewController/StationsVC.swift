//
//  ViewController.swift
//  Exercise
//
//  Created by Sunil Kumar on 09/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class StationsVC: BaseVC {
    
    private let stationsViewModel = StationsViewModel()
    @IBOutlet weak var tableView: UITableView!
    private var stationsList: [Station] = []
    private let collectionViewData = ["All", "Mainline", "Suburban", "DART"]
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewContainerHeight: NSLayoutConstraint!
    private let refreshControl = UIRefreshControl()
    private var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        let refreshAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: refreshAttributes)
        tableView.addSubview(refreshControl)
        bindViewModel()
    }
    
    @objc private func refreshList() {
        if !isRefreshing {
            isRefreshing = true
            stationsViewModel.getAllStations(stationType: nil)
        }
    }
    
    @IBAction func rightBarButtonAction(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.25) {
            self.collectionViewContainerHeight.constant = self.collectionViewContainerHeight.constant == 50.0 ? 0.0 : 50.0
            self.view.layoutIfNeeded()
        }
        collectionView.reloadData()
    }
    
    // MARK: - Bind ViewModel
    func bindViewModel() {
        _ = stationsViewModel.stationsList.asObservable().subscribe(onNext: { [weak self] stations in
            if let list = stations {
                self?.stationsList = list
                self?.isRefreshing = false
                OperationQueue.main.addOperation {
                    if (self?.refreshControl.isRefreshing)! {
                        self?.refreshControl.endRefreshing()
                    }
                    self?.tableView.reloadData()
                }
            }
        })
        
        _ = stationsViewModel.apiError.asObservable().subscribe(onNext: { [weak self] error in
            if let error = error {
                self?.isRefreshing = false
                OperationQueue.main.addOperation {
                    self?.showAlert(titleStr: "Error!", messageStr: error)
                    if (self?.refreshControl.isRefreshing)! {
                        self?.refreshControl.endRefreshing()
                    }
                }
            }
        })
    }
}

// MARK: - UITableViewDataSource
extension StationsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "aStationsCell", for: indexPath) as? StationsCell else { return UITableViewCell() }
        let station = stationsList[indexPath.row]
        cell.stationName.text = station.description
        cell.stationCode.text = "\(station.code)(\(station.id))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate
extension StationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = stationsList[indexPath.row]
        guard let detailsVC = storyboard?.instantiateViewController(withIdentifier: "aDetailsVC") as? DetailsVC else { return }
        detailsVC.latitude = station.latitude
        detailsVC.longitude = station.longitude
        detailsVC.desc = "* Name: \(station.description) \n* Code: \(station.code), \(station.id)"
        detailsVC.name = station.code
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension StationsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aStationsSortCell", for: indexPath) as? StationsSortCell else { return UICollectionViewCell() }
        cell.titleLabel.text = collectionViewData[indexPath.item]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StationsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width * 0.25, height: collectionView.frame.size.height)
    }
}

// MARK: - UICollectionViewDelegate
extension StationsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25) {
            self.collectionViewContainerHeight.constant = 0.0
            self.view.layoutIfNeeded()
        }
        let title = collectionViewData[indexPath.item]
        stationsViewModel.getAllStations(stationType: title)
    }
}
