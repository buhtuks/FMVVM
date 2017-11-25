//
//  Root.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 3/18/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import ReactiveSwift

final class Root {
    fileprivate var child = MutableProperty<Child>(.none)
    enum Child {
        case none
        case main(MainViewModel)
    }

    init() {
        let vm = MainViewModel(dependencies: MainViewModel.Dependencies(),
                               context: MainViewModel.Context())
        child.value = .main(vm)
    }
}

extension Root: Presentable {
    struct RootPresentersContainer {
        let mainPresenter: Presenter<AnyPresentableType<MainPresentersContainer>>
        let nonePresenter: Presenter<()>
    }

    typealias Presenters = RootPresentersContainer

    var present: (Presenters) -> Disposable? {
        return { presenters in
            let childPresenter = Presenter<Child>.UI {
                switch $0 {
                case .none:
                    return presenters.nonePresenter <~ ()
                case .main(let viewModel):
                    return presenters.mainPresenter <~ viewModel
                }
            }
            return CompositeDisposable([
                childPresenter.serial() <~ self.child])
        }
    }
}
