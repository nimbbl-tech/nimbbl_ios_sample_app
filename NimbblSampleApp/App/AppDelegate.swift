/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Pipe capture is unsafe under Xcode (SIGPIPE during checkout). Use DebugLog.log instead.
        if !AppLogStream.isXcodeDebugSession {
            AppLogStream.shared.install()
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = ViewController()
        let nav = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
}

