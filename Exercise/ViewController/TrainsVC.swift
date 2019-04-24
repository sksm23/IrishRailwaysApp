//
//  TrainsVC.swift
//  Exercise
//
//  Created by Sunil Kumar on 10/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class TrainsVC: BaseVC {
    
    private let trainsViewModel = TrainsViewModel()
    @IBOutlet weak var tableView: UITableView!
    private var trainsList: [Train] = []
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
            trainsViewModel.getCurrentTrains(trainType: nil)
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
        _ = trainsViewModel.trainList.asObservable().subscribe(onNext: { [weak self] trains in
            if let list = trains {
                self?.isRefreshing = false
                self?.trainsList = list
                OperationQueue.main.addOperation {
                    if (self?.refreshControl.isRefreshing)! {
                        self?.refreshControl.endRefreshing()
                    }
                    self?.tableView.reloadData()
                }
            }
        })
        
        _ = trainsViewModel.apiError.asObservable().subscribe(onNext: { [weak self] error in
            if let error = error {
                self?.isRefreshing = false
                OperationQueue.main.addOperation {
                    if (self?.refreshControl.isRefreshing)! {
                        self?.refreshControl.endRefreshing()
                    }
                    self?.showAlert(titleStr: "Error!", messageStr: error)
                }
            }
        })
    }
}

// MARK: - UITableViewDataSource
extension TrainsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "aTrainsCell", for: indexPath) as? TrainsCell else { return UITableViewCell() }
        let train = trainsList[indexPath.row]
        let status = train.status == "R" ? "(Running)" : "(Not yet running)"
        cell.trainName.text = "\(train.code) " + status
        cell.trainCode.text = train.direction
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate
extension TrainsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let train = trainsList[indexPath.row]
       guard let detailsVC = storyboard?.instantiateViewController(withIdentifier: "aDetailsVC") as? DetailsVC else { return }
        detailsVC.latitude = train.latitude
        detailsVC.longitude = train.longitude
        let status = train.status == "R" ? "(Running)" : "(Not yet running)"
        detailsVC.desc = "* Name: \(train.code)\(status), \n* Going: \(train.direction) - \(train.date), \n* Notice: \(train.publicMessage)"
        detailsVC.name = train.code
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TrainsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aTrainsSortCell", for: indexPath) as? TrainsSortCell else { return UICollectionViewCell() }
        cell.titleLabel.text = collectionViewData[indexPath.item]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrainsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width * 0.25, height: collectionView.frame.size.height)
    }
}

// MARK: - UICollectionViewDelegate
extension TrainsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25) {
            self.collectionViewContainerHeight.constant = 0.0
            self.view.layoutIfNeeded()
        }
        let title = collectionViewData[indexPath.item]
        trainsViewModel.getCurrentTrains(trainType: title)
    }
}
