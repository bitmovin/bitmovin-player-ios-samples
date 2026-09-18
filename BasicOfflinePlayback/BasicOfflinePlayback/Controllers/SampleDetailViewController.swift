//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import Foundation
import AVFoundation
import BitmovinPlayer

final class SampleDetailViewController: UIViewController {

    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemStatusLabel: UILabel!
    @IBOutlet private weak var itemPercentageLabel: UILabel!
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!

    var sourceConfig: SourceConfig!
    var offlineContentManager: OfflineContentManager?

    private var reach: Reachability!
    private var offlineManager = OfflineManager.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sourceConfig = sourceConfig else {
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

        // Display name of stream and init the view state based on the current state of the sourceConfig
        itemNameLabel.text = sourceConfig.title

        // Get offline content manager for the source config
        guard let offlineContentManager = try? offlineManager.offlineContentManager(for: sourceConfig) else {
            finishWithError(title: "Internal error", message: "OfflineContentManager not found for source config")
            return
        }
        self.offlineContentManager = offlineContentManager

        setViewState(offlineContentManager.offlineState)

        offlineContentManager.add(listener: self)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            // Back button was pressed. Clean up code goes here.
            offlineContentManager?.remove(listener: self)
        }
    }

    @IBAction private func didTapDownloadButton() {
        guard reach.currentReachabilityStatus() != NetworkStatus.NotReachable else {
            let message = "Cannot download asset because device seems to be offline"
            let alert = UIAlertController(title: "Info", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true)
            return
        }

        if let posterUrl = sourceConfig.posterSource {
            downloadArtworkData(posterUrl) { artworkData in
                self.sourceConfig.metadata[MetadataIdentifierArtwork] = artworkData
                self.download(sourceConfig: self.sourceConfig)
            }
        } else {
            download(sourceConfig: sourceConfig)
        }
    }

    func download(sourceConfig: SourceConfig) {
        let downloadConfig = DownloadConfig()
        downloadConfig.minimumBitrate = 825_000
        offlineContentManager?.download(downloadConfig: downloadConfig)
        setViewState(.downloading)
    }

    @IBAction private func didTapPauseButton() {
        guard offlineContentManager?.offlineState == .downloading else {
            return
        }
        print("[SampleDetailViewController] Pausing downloads")
        offlineContentManager?.suspendDownload()
    }

    @IBAction private func didTapResumeButton() {
        guard offlineContentManager?.offlineState == .suspended else {
            return
        }
        print("[SampleDetailViewController] Resuming downloads")
        offlineContentManager?.resumeDownload()
    }

    @IBAction private func didTapCancelButton() {
        guard offlineContentManager?.offlineState == .downloading else {
            return
        }
        print("[SampleDetailViewController] Canceling downloads")
        offlineContentManager?.cancelDownload()
    }

    @IBAction private func didTapDeleteButton() {
        offlineContentManager?.deleteOfflineData()
        setViewState(.notDownloaded)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard sender as? UIButton != nil,
              let controller = segue.destination as? PlaybackViewController else {
            super.prepare(for: segue, sender: sender)
            return
        }

        controller.sourceConfig = sourceConfig
    }

    private func finishWithError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
            return
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }

    private func setViewState(_ viewState: OfflineState, withProgress progress: Double) {
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

    private func setViewState(_ viewState: OfflineState) {
        setViewState(viewState, withProgress: 0.0)
    }
}

// MARK: OfflineContentManagerListener
extension SampleDetailViewController: OfflineContentManagerListener {
    func onOfflineError(_ event: OfflineErrorEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] Download resulted in error: \(event.message)")
        setViewState(.notDownloaded)
    }

    func onContentDownloadFinished(_ event: ContentDownloadFinishedEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] Download Finished")
        setViewState(.downloaded)
    }

    func onContentDownloadProgressChanged(_ event: ContentDownloadProgressChangedEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] Progress: \(event.progress)")
        // update ui with current progress
        setViewState(.downloading, withProgress: event.progress)
    }

    func onContentDownloadSuspended(_ event: ContentDownloadSuspendedEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] Suspended")
        setViewState(.suspended)
    }

    func onContentDownloadResumed(_ event: ContentDownloadResumedEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] Resumed")
        setViewState(.downloading, withProgress: event.progress)
    }

    func onContentDownloadCanceled(_ event: ContentDownloadCanceledEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] Cancelled")
        setViewState(.notDownloaded)
    }

    func onOfflineContentLicenseRenewed(_ event: OfflineContentLicenseRenewedEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] License renewed")
    }

    func onOfflineContentLicenseExpired(_ event: OfflineContentLicenseExpiredEvent, offlineContentManager: OfflineContentManager) {
        print("[SampleDetailViewController] License expired")
    }
}

// MARK: - Artwork helper methods
extension SampleDetailViewController {
    func downloadArtworkData(_ imageUrl: URL, completion: @escaping (_ data: Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, let _ = UIImage(data: data), error == nil else {
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                completion(data)
            }
        }
        task.resume()
    }
}
