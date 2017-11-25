//
//  TextViewController.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 11/23/17.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

struct TextViewModelPresenterContainerImpl: TextViewModelPresenterContainer {
    let titlePresenter: Presenter<String>
    let textPresenter: Presenter<String>
    let textInputPresenter: Presenter<(String?) -> ()>
    let backActionPresenter: Presenter<Action<(), (), NoError>>
}

final class TextViewController: UIViewController {
    @IBOutlet var textField: UITextField?
    @IBOutlet var textView: UITextView?
    @IBOutlet var backButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TextViewController: AnyPresentableSourceType {
    var presenters: TextViewModelPresenterContainer {
        return TextViewModelPresenterContainerImpl(titlePresenter: self.titlePresenter,
                                                   textPresenter: self.textPresenter,
                                                   textInputPresenter: self.textInputPresenter,
                                                   backActionPresenter: self.backActionPresenter)
    }

    typealias Presenters = TextViewModelPresenterContainer

    var textPresenter: Presenter<String> {
        return Presenter.UI { [weak self] in
            guard let textView = self?.textView else {
                assertionFailure()
                return nil
            }
            textView.text = $0
            return nil
        }
    }

    var backActionPresenter: Presenter<Action<(), (), NoError>> {
        return Presenter.UI { value in
            guard let backButtonItem = self.backButtonItem else {
                assertionFailure()
                return nil
            }
            backButtonItem.reactive.pressed = CocoaAction(value)
            return nil
        }
    }

    var titlePresenter: Presenter<String> {
        return Presenter.UI {
            self.navigationItem.title = $0
            return nil
        }
    }

    var textInputPresenter: Presenter<(String?) -> ()> {
        return Presenter.UI {
            guard let textField = self.textField else { assertionFailure(); return nil }
            return textField
                .reactive
                .continuousTextValues
                .observeValues($0)
        }
    }
}
