//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import Foundation
import AVFoundation
import BitmovinPlayer

final class SampleDetailViewController: UIViewController {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemStatusLabel: UILabel!
    @IBOutlet weak var itemPercentageLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    var sourceItem: SourceItem!
    var reach: Reachability!
    var offlineManager = OfflineManager.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sourceItem = sourceItem else {
            finishWithError(title: "No item", message: "There is no item to display")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let reach = appDelegate.reach else {
                finishWithError(title: "Internal error", message: "AppDelegate could not be accessed")
                return
        }

        // Store reference to reachability manager to be able to check for an existing network connection
        self.reach = reach

        // Display name of stream and init the view state based on the current state of the sourceItem
        itemNameLabel.text = sourceItem.itemTitle
        setViewState(offlineManager.offlineState(for: sourceItem))

        offlineManager.add(listener: self, for: sourceItem)
        downloadButton.addTarget(self, action: #selector(SampleDetailViewController.downloadAction), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(SampleDetailViewController.pauseAction), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(SampleDetailViewController.resumeAction), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(SampleDetailViewController.cancelAction), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(SampleDetailViewController.deleteAction), for: .touchUpInside)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            // Back button was pressed. Clean up code goes here.
            offlineManager.remove(listener: self, for: sourceItem)
        }
    }

    @objc func downloadAction(sender: UIButton) {
        guard reach.currentReachabilityStatus() != NetworkStatus.NotReachable else {
            let message = "Cannot download asset because device seems to be offline"
            let alert = UIAlertController(title: "Info", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true)
            return
        }
        offlineManager.download(sourceItem: sourceItem)
        setViewState(.downloading)
    }

    @objc func pauseAction(sender: UIButton) {
        guard offlineManager.offlineState(for: sourceItem) == .downloading else {
            return
        }
        print("[SampleDetailViewController] Pausing downloads")
        offlineManager.suspendDownload(for: sourceItem)
    }

    @objc func resumeAction(sender: UIButton) {
        guard offlineManager.offlineState(for: sourceItem) == .suspended else {
            return
        }
        print("[SampleDetailViewController] Resuming downloads")
        offlineManager.resumeDownload(for: sourceItem)
    }

    @objc func cancelAction(sender: UIButton) {
        guard offlineManager.offlineState(for: sourceItem) == .downloading else {
            return
        }
        print("[SampleDetailViewController] Canceling downloads")
        offlineManager.cancelDownload(for: sourceItem)
    }

    @objc func deleteAction(sender: UIButton) {
        offlineManager.deleteOfflineData(for: sourceItem)
        setViewState(.notDownloaded)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard sender as? UIButton != nil,
              let controller = segue.destination as? PlaybackViewController else {
            super.prepare(for: segue, sender: sender)
            return
        }

        controller.sourceItem = sourceItem
    }

    func finishWithError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(_: UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
            return
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }

    func setViewState(_ viewState: BMPOfflineState, withProgress progress: Double) {
        switch viewState {
        case .downloaded:
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = false
            itemStatusLabel.text = "Downloaded"
            itemPercentageLabel.text = ""

        case .downloading:
            downloadButton.isHidden = true
            pauseButton.isHidden = false
            resumeButton.isHidden = true
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            itemStatusLabel.text = "Downloading:"
            itemPercentageLabel.text = String(format: "%.f", progress) + "%"

        case .notDownloaded:
            downloadButton.isHidden = false
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = true
            itemStatusLabel.text = "Not downloaded"
            itemPercentageLabel.text = ""

        case .suspended:
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            cancelButton.isHidden = true
            deleteButton.isHidden = true
            itemStatusLabel.text = "Suspended"
            itemPercentageLabel.text = ""

        case .canceling:
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = true
            itemStatusLabel.text = "Canceling"
            itemPercentageLabel.text = ""
        }
    }

    func setViewState(_ viewState: BMPOfflineState) {
        setViewState(viewState, withProgress: 0.0)
    }
}

// MARK: OfflineManagerListener
extension SampleDetailViewController: OfflineManagerListener {

    func offlineManager(_ offlineManager: OfflineManager, didFailWithError error: Error?) {
        let errorMessage = error?.localizedDescription ?? "unknown"
        print("[SampleDetailViewController] Download resulted in error: \(errorMessage)")
        setViewState(.notDownloaded)
    }

    func offlineManagerDidFinishDownload(_ offlineManager: OfflineManager) {
        print("[SampleDetailViewController] Download Finished")
        setViewState(.downloaded)
    }

    func offlineManager(_ offlineManager: OfflineManager, didProgressTo progress: Double) {
        print("[SampleDetailViewController] Progress")
        // update ui with current progress
        setViewState(.downloading, withProgress: progress)
    }

    func offlineManagerDidSuspendDownload(_ offlineManager: OfflineManager) {
        print("[SampleDetailViewController] Suspended")
        setViewState(.suspended)
    }

    func offlineManager(_ offlineManager: OfflineManager, didResumeDownloadWithProgress progress: Double) {
        print("[SampleDetailViewController] Resumed")
        setViewState(.downloading, withProgress: progress)
    }

    func offlineManagerDidCancelDownload(_ offlineManager: OfflineManager) {
        print("[SampleDetailViewController] Cancelled")
        setViewState(.notDownloaded)
    }
}
