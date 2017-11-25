//
//  CounterViewModel.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 11/23/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

struct CounterViewModelPresenterContainer {
    var titlePresenter: Presenter<String>
    var plusActionPresenter: Presenter<Action<(), (), NoError>>
    var minusActionPresenter: Presenter<Action<(), (), NoError>>
    var coutnerValuePresenter: Presenter<String>
    var backActionPresenter: Presenter<Action<(), (), NoError>>
}

final class CounterViewModel {
    let counter: Property<String>
    let plusAction: Action<(), (), NoError>
    let minusAction: Action<(), (), NoError>
    let backAction: Action<(), (), NoError>
    
    init(dependencies: Dependencies, context: Context) {
        let counter = MutableProperty<Int>(0)
        let plusAction = Action<(), (), NoError> {
            counter.value += 1
            return .empty
        }

        let minusAction = Action<(), (), NoError> {
            if counter.value > 0 {
                counter.value -= 1
            }
            return .empty
        }
        self.backAction = dependencies.backAction
        self.counter = counter.map { String($0) }
        self.plusAction = plusAction
        self.minusAction = minusAction
    }

    deinit {
        print(self)
    }

    struct Dependencies {
        let backAction: Action<(), (), NoError>
    }
    struct Context {}
}

extension CounterViewModel: Presentable {
    typealias Presenters = CounterViewModelPresenterContainer

    var present: (CounterViewModelPresenterContainer) -> Disposable? {
        return { presenters in
            return CompositeDisposable([
                presenters.titlePresenter <~ "Counter",
                presenters.plusActionPresenter <~ self.plusAction,
                presenters.minusActionPresenter <~ self.minusAction,
                presenters.coutnerValuePresenter.serial() <~ self.counter,
                presenters.backActionPresenter <~ self.backAction
                ])
        }
    }
}
