//
//  MainViewController.swift
//  MileageCalculator
//
//  Created by Andrew Robinson on 12/16/17.
//  Copyright © 2017 Andrew Robinson. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet weak var goButton: UIButton!

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let cellID = "locationCell"

    private let green = #colorLiteral(red: 0.001873505418, green: 1, blue: 0, alpha: 1)
    private let red = #colorLiteral(red: 0.916154027, green: 0.1861021519, blue: 0, alpha: 1)
    private let back = #colorLiteral(red: 0.220161885, green: 0.2569702566, blue: 0.402913034, alpha: 1)

    private var locations = [Location]()
    private var locationOrder = [Location]()

    private var checkTimer: Timer?

    private var totalDistance = 0.0 {
        didSet {
            distanceLabel.text = "\(totalDistance) miles"
        }
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = back

        goButton.backgroundColor = green
        goButton.setTitleColor(.white, for: .normal)
        goButton.roundCorners()
        view.bringSubview(toFront: goButton)

        distanceLabel.textColor = .green

        tableView.dataSource = self
        tableView.delegate = self

        let store = Firestore.firestore().collection(Location.root)
        store.getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    let location = Location().load(fromDict: document.data())
                    location.key = document.documentID
                    self.locations.append(location)
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func goButtonPressed(_ sender: UIButton) {
        sender.isHidden = true

        distanceLabel.text = "Searching..."

        LocationManager.manager.startGatheringAndRequestPermission()
        LocationManager.manager.add(asDelegate: self)
    }

    // MARK: - Helpers

    private func calculateDistance(from index: Int) -> Double {
        if index == 0 {
            return 0.0
        } else {
            let previousLocation = locationOrder[index - 1]
            return previousLocation.getDistance(from: locationOrder[index].key)
        }
    }
}

extension MainViewController: LocationDelegate {
    func didUpdate(with location: CLLocation) {
        for pLocation in locations {
            if LocationManager.manager.compareToLastLocation(location: pLocation.location) {
                if self.locationOrder.last !== pLocation {
                    self.locationOrder.append(pLocation)
                    self.totalDistance += self.calculateDistance(from: self.locationOrder.count - 1)
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = locationOrder.count

        if count > 0 {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LocationTableViewCell
        let location = locationOrder[indexPath.row]

        cell.nameLabel.text = location.name
        cell.distanceLabel.text = "\(calculateDistance(from: indexPath.row))"

        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}
