//
//  AppDelegate.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 3/18/17.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var root: Root = Root()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = root.present(presenters)
        return true
    }
}

extension AppDelegate: AnyPresentableSourceType {
    typealias Presenters = Root.RootPresentersContainer
    var presenters: Root.RootPresentersContainer {
        return Root.RootPresentersContainer(mainPresenter: self.mainPresenter,
                                            nonePresenter: self.nonePresenter)
    }

    var mainPresenter: Presenter<AnyPresentableType<MainPresentersContainer>> {
        return Presenter.UI { viewmodel in
            guard let window = self.window else { return nil }
            let main = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "MainScreen")
            as! MainViewController
            window.rootViewController = UINavigationController(rootViewController: main)
            window.makeKeyAndVisible()
            main.loadViewIfNeeded()
            return viewmodel <- main
        }
    }

    var nonePresenter: Presenter<()> {
        return Presenter.UI { viewmodel in
            return nil
        }
    }
}

