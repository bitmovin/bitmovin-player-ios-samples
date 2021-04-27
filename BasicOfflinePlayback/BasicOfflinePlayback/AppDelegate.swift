//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize the singleton offline manager which is used to manage the whole lifecycle of offline assets
        OfflineManager.initializeOfflineManager()

        // Create a reachability object to be able to check if an internet connection exists
        if reach == nil {
            reach = Reachability.forInternetConnection()
        }

        return true
    }

    /**
     If your app is in the background, the system may suspend your app while the download is performed in another process.
     In this case, when the download finishes, the system resumes the app and calls this delegate method. In case this delegate method is NOT implemented,
     then as soon as currently scheduled background download is finished the app is not going to be waken up for the further downloads.
     */
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        OfflineManager.sharedInstance().add(completionHandler: completionHandler, for: identifier)
    }
}
