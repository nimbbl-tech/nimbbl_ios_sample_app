/*
Created by Sandeep Y. on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.

UIScene lifecycle adoption. iOS 27 makes scene adoption mandatory and hard-traps
apps that create their window from the app delegate without a scene manifest
(UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption). This delegate
builds the window from the connecting UIWindowScene instead.
*/

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let rootVC = ViewController()
        window.rootViewController = UINavigationController(rootViewController: rootVC)
        self.window = window
        window.makeKeyAndVisible()
    }
}
