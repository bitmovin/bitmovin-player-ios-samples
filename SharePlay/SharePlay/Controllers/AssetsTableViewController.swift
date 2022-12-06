//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Combine
import Foundation
import UIKit

class AssetsTableViewController: UITableViewController {
    private let viewModel = ViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        CoordinationManager.shared.$asset
            .receive(on: RunLoop.main)
            .sink { [weak self] asset in
                guard let self = self else { return }

                self.navigationController?.popToRootViewController(animated: true)

                guard let asset = asset else { return }

                self.presentPlaybackViewController(for: asset)
            }
            .store(in: &cancellables)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let asset = viewModel.item(for: indexPath) else { return }

        CoordinationManager.shared.prepareToPlay(asset: asset)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let asset = viewModel.item(for: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier, for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }

        cell.asset = asset
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sectionTitle
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    @IBAction func showInstructions(_ sender: UIButton) {
        present(instructionsAlert, animated: true)
    }
}

private extension AssetsTableViewController {
    var instructionsAlert: UIAlertController {
        let alert = UIAlertController(
            title: "Instructions",
            message: """
                To experience coordinated playback, you need to install the app on two or more devices.

                Start a FaceTime call between the devices, and select an item from the list on one of them.

                The system prompts you to play the movie locally or with the group. Select to play it with the group, and starting playback on one device starts it on the others.
                """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }

    func presentPlaybackViewController(for asset: Asset) {
        let playbackViewModel = PlaybackViewController.ViewModel(
            groupSession: CoordinationManager.shared.groupSession,
            asset: asset
        )

        navigationController?.pushViewController(createPlaybackViewController(with: playbackViewModel), animated: true)
    }

    func createPlaybackViewController(
        with viewModel: PlaybackViewController.ViewModel
    ) -> PlaybackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PlaybackViewController")

        guard let playbackViewController = viewController as? PlaybackViewController else {
            fatalError("Could not create playback view controller")
        }

        playbackViewController.viewModel = viewModel
        return playbackViewController
    }
}
