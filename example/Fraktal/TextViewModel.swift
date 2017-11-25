//
//  TextViewModel.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 11/23/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol TextViewModelPresenterContainer {
    var titlePresenter: Presenter<String> { get }
    var textPresenter: Presenter<String> { get }
    var textInputPresenter: Presenter<(String?) -> ()> { get }
    var backActionPresenter: Presenter<Action<(), (), NoError>> { get }
}

final class TextViewModel {
    let text: Property<String?>
    let backAction: Action<(), (), NoError>
    let textInput: (String?) -> ()

    init(dependencies: Dependencies, context: Context) {
        let text = MutableProperty<String?>(nil)
        let input = { text.value = $0 }
        self.textInput = input
        self.backAction = dependencies.backAction
        self.text = Property(text)
    }
    
    struct Dependencies {
        let backAction: Action<(), (), NoError>
    }
    struct Context {}
}

extension TextViewModel: Presentable {
    typealias Presenters = TextViewModelPresenterContainer

    var present: (TextViewModelPresenterContainer) -> Disposable? {
        return { presenters in 
            return CompositeDisposable([
                presenters.titlePresenter <~ "Text",
                presenters.textPresenter.serial().optional() <~ self.text,
                presenters.textInputPresenter <~ self.textInput,
                presenters.backActionPresenter <~ self.backAction
                ])
        }
    }
}
