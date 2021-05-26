//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin Inc, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

class SetupPlayerViewController: UIViewController {
    static let fromSetupPlayerVCToVCSegueIdentifier = "fromSetupPlayerToViewController"
    static let userInterfaces: [UserInterfaceType] = [.bitmovin, .system]

    var selectedSegmentIndex: Int = 0

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Self.fromSetupPlayerVCToVCSegueIdentifier,
              let viewController = segue.destination as? ViewController else {
            return
        }

        let selectedUserInterfaceType = Self.userInterfaces[selectedSegmentIndex]
        viewController.userInterfaceType = selectedUserInterfaceType
    }

    @IBAction func selectPlayerSegmentControlValueChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
    }
}
