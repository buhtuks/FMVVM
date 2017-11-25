//
//  MainViewModel.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 3/25/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

typealias MainCellViewModel = String

struct MainPresentersContainer {
    let titlePresenter: Presenter<String>
    let nonePresenter: Presenter<()>
    let counterScreenPresenter: Presenter<CounterViewModel.AnyPresentable>
    let textScreenPresenter: Presenter<TextViewModel.AnyPresentable>
    let cellsPresenter: Presenter<[MainCellViewModel]>
    let cellSelectorPresenter: Presenter<(Int) -> ()>
}

final class MainViewModel {
    let child: Property<Child>
    let selector: (Int) -> ()

    init(dependencies: Dependencies, context: Context) {
        let child = MutableProperty<Child>(.none)
        let backAction = Action<(), (), NoError> {
            child.value = .none
            return .empty
        }
        selector = {
            switch $0 {
            case 0:
                let viewmodel = CounterViewModel(dependencies: CounterViewModel.Dependencies(backAction: backAction),
                                                 context: CounterViewModel.Context())
                child.value = .counter(viewmodel)
            case 1:
                let viewmodel = TextViewModel(dependencies: TextViewModel.Dependencies(backAction: backAction),
                                              context: TextViewModel.Context())
                child.value = .text(viewmodel)
            default: break
            }
        }
        self.child = Property(child)
    }

    deinit {
        print(self)
    }

    struct Dependencies {}
    struct Context {}
}

extension MainViewModel: Presentable {
    typealias Presenters = MainPresentersContainer

    var present: (Presenters) -> Disposable? {
        return { presenters in
            let childPresenter = Presenter<Child>.UI {
                switch $0 {
                case .none:
                    return presenters.nonePresenter <~ ()
                case .counter(let viewModel):
                    return presenters.counterScreenPresenter <~ viewModel
                case .text(let viewModel):
                    return presenters.textScreenPresenter <~ viewModel
                }
            }
            return CompositeDisposable([
                presenters.titlePresenter <~ "Main",
                presenters.cellsPresenter <~ ["Counter" , "Text"],
                presenters.cellSelectorPresenter <~ self.selector,
                childPresenter.serial() <~ self.child
                ])
        }
    }

    enum Child {
        case text(TextViewModel)
        case counter(CounterViewModel)
        case none
    }
}
