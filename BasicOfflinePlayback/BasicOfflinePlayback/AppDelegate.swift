//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reach: Reachability?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize the singleton offline manager which is used to manage the whole lifecycle of offline assets
        OfflineManager.initializeOfflineManager()

        // Create a reachability object to be able to check if an internet connection exists
        if reach == nil {
            reach = Reachability.forInternetConnection()
        }

        return true
    }
}
