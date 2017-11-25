//
//  CounterViewController.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 11/23/17.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

final class CounterViewController: UIViewController {
    @IBOutlet var plusButton: UIButton?
    @IBOutlet var minusButton: UIButton?
    @IBOutlet var counterLabel: UILabel?
    @IBOutlet var backButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension CounterViewController: AnyPresentableSourceType {
    typealias Presenters = CounterViewModel.Presenters

    var presenters: CounterViewModel.Presenters {
        return CounterViewModel.Presenters(titlePresenter: self.titlePresenter,
                                           plusActionPresenter: self.plusActionPresenter,
                                           minusActionPresenter: self.minusActionPresenter,
                                           coutnerValuePresenter: self.coutnerValuePresenter,
                                           backActionPresenter: self.backActionPresenter)
    }

    var titlePresenter: Presenter<String> {
        return Presenter.UI {
            self.navigationItem.title = $0
            return nil
        }
    }

    var plusActionPresenter: Presenter<Action<(), (), NoError>> {
        return Presenter.UI {
            self.plusButton?.reactive.pressed = CocoaAction($0)
            return nil
        }
    }

    var minusActionPresenter: Presenter<Action<(), (), NoError>> {
        return Presenter.UI {
            self.minusButton?.reactive.pressed = CocoaAction($0)
            return nil
        }
    }

    var coutnerValuePresenter: Presenter<String> {
        return Presenter.UI { [weak self] in
            self?.counterLabel?.text = $0
            return nil
        }
    }

    var backActionPresenter: Presenter<Action<(), (), NoError>> {
        return Presenter.UI {
            self.backButtonItem?.reactive.pressed = CocoaAction($0)
            return nil
        }
    }
}
