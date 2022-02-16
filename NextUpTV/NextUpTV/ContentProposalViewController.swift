//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

/// An enum indicating the selected action by the user
enum ContentProposalAction {
    case accept
    case reject
    /// Used when the 'back' or 'menu' button was pressed on the remote
    case `defer`
}

/// A custom data object that holds information about the upcoming content. Used only for rendering the content proposal view.
struct ContentProposal {
    var contentTimeForTransition: TimeInterval
    var previewImage: UIImage
    var title: String
    var description: String
    var source: Source
}

/// Delegate for notifying about the selected action
protocol ContentProposalViewControllerDelegate: AnyObject {
    /// Gets called when user selects any of the actions or pressed 'back' or 'menu' button on the remote
    /// - Parameters:
    ///    - contentProposal: current proposal
    ///    - action: selected action
    ///    - animated: `true` if the view controller was dismissed using animation, otherwise `false`
    func didDismissContentProposal(
        _ contentProposal: ContentProposal,
        withAction action: ContentProposalAction,
        animated: Bool
    )
}

/// ViewController handling the UI for the content proposal.
/// See `Main.storyboard` for UI layout
class ContentProposalViewController: UIViewController {
    @IBOutlet private var previewImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var acceptButton: UIButton!
    @IBOutlet private var rejectButton: UIButton!

    var contentProposal: ContentProposal?
    weak var delegate: ContentProposalViewControllerDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.image = contentProposal?.previewImage
        titleLabel.text = contentProposal?.title
        descriptionLabel.text = contentProposal?.description
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [acceptButton, rejectButton]
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, action: .defer, completion: completion)
    }

    func dismiss(animated: Bool, action: ContentProposalAction, completion: (() -> Void)? = nil) {
        super.dismiss(animated: animated) {
            if let contentProposal = self.contentProposal {
                self.delegate?.didDismissContentProposal(
                    contentProposal,
                    withAction: action,
                    animated: animated
                )
            }
            completion?()
        }
    }

    @IBAction private func accept(_ sender: UIButton) {
        dismiss(animated: true, action: .accept)
    }

    @IBAction private func reject(_ sender: UIButton) {
        dismiss(animated: true, action: .reject)
    }
}
