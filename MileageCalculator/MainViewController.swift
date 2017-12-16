//
//  MainViewController.swift
//  MileageCalculator
//
//  Created by Andrew Robinson on 12/16/17.
//  Copyright © 2017 Andrew Robinson. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var goButton: UIButton!

    private let green = #colorLiteral(red: 0.001873505418, green: 1, blue: 0, alpha: 1)
    private let red = #colorLiteral(red: 0.916154027, green: 0.1861021519, blue: 0, alpha: 1)
    private let back = #colorLiteral(red: 0.220161885, green: 0.2569702566, blue: 0.402913034, alpha: 1)

    private var locations = [Location]()
    private var locationOrder = [Location]()

    private var checkTimer: Timer?

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = back

        goButton.backgroundColor = green
        goButton.setTitleColor(.white, for: .normal)
        goButton.roundCorners()

        let store = Firestore.firestore().collection(Location.root)
        store.getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    self.locations.append(Location().load(fromDict: document.data()))
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func goButtonPressed(_ sender: UIButton) {
        sender.backgroundColor = red
        sender.setTitle("STOP", for: .normal)

        LocationManager.manager.startGatheringAndRequestPermission()

        checkTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            if let _ = LocationManager.manager.lastLocation {
                for location in self.locations {
                    if LocationManager.manager.compareToLastLocation(location: location.location) {
                        self.locationOrder.append(location)
                    }
                }
            }
        })
    }
}
