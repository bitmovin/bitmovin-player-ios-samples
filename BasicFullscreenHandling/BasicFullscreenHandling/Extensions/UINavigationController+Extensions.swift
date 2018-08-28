//
//  UINavigationController+Extensions.swift
//  BasicFullscreenHandling
//
//  Created by Lorenz Schmoliner on 21.08.18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}
