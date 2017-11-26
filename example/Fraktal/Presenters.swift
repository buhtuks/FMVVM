//
//  Presenters.swift
//  AGU
//
//  Created by Dmitry Levsevich on 12/21/16.
//  Copyright © 2016 Montex. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

protocol PresenterType {
    associatedtype ViewModel
    var presenter: Presenter<ViewModel> { get }
}

extension PresenterType where ViewModel: AnyPresentableContvertable {
    func present<T: Presentable>(_ presentable: T) -> Disposable?
        where T.Presenters == ViewModel.Presenters {
            return self.presenter.present(ViewModel(presentable))
    }
}

protocol SerialPresenterType {
    associatedtype ViewModel
    var presenter: SerialPresenter<ViewModel> { get }
}

extension SerialPresenterType where ViewModel: AnyPresentableContvertable {
    func present<T: Presentable>(_ presentable: T) -> Disposable?
        where T.Presenters == ViewModel.Presenters {
            return self.presenter.present(ViewModel(presentable))
    }
}

protocol OptionalConvertablePresenter {
    associatedtype ViewModel
    func optional() -> Presenter<ViewModel?>
}

protocol SerialConvertablePresenter {
    associatedtype ViewModel
    func serial() -> SerialPresenter<ViewModel>
}

protocol Presentable {
    associatedtype Presenters
    associatedtype AnyPresentable = AnyPresentableType<Presenters>
    var present: (Presenters) -> Disposable? { get }
}

final class Presenter<T>: PresenterType {
    typealias ViewModel = T
    fileprivate let bind: (ViewModel) -> Disposable?
    var presenter: Presenter { return self }

    func present(_ viewModel: ViewModel) -> Disposable? {
        return bind(viewModel)
    }

    fileprivate init(_ bind: @escaping (ViewModel) -> Disposable?) {
        self.bind = bind
    }
}

extension Presenter: SerialConvertablePresenter {
    func serial() -> SerialPresenter<ViewModel> {
        return SerialPresenter {
            return PresentationIntent(item: $0, presenter: self)
        }
    }
}

extension Presenter: OptionalConvertablePresenter {
    func optional() -> Presenter<ViewModel?> {
        return Presenter<ViewModel?> {
            return $0.flatMap(self.present)
        }
    }
}

extension Presenter {
    static func empty() -> Presenter {
        return Presenter({ _ in return nil})
    }
    
    static func UI(_ bind: @escaping (ViewModel) -> Disposable?) -> Presenter {
        return Presenter { viewModel in
            let disposable = CompositeDisposable()
            disposable += UIScheduler().schedule {
                disposable += bind(viewModel)
            }
            return disposable
        }
    }
}

fileprivate class PresentationIntent {
    let present: () -> Disposable?

    init<T>(item: T, presenter: Presenter<T>) {
        present = { presenter.present(item) }
    }

    init() {
        present = { return nil }
    }
}

final class SerialPresenter<T>: SerialPresenterType {
    var presenter: SerialPresenter<ViewModel> { return self }
    typealias ViewModel = T
    typealias Model = SignalProducer<T, NoError>
    fileprivate let presentationIntent: (T) -> PresentationIntent
    fileprivate let serialDisposable = SerialDisposable()
    
    fileprivate init(_ intent: @escaping (T) -> PresentationIntent) {
        self.presentationIntent = intent
    }
}

extension SerialPresenter {
    func present(_ viewModel: Model) -> Disposable? {
        serialDisposable.inner?.dispose()
        let composite = CompositeDisposable()
        composite += viewModel
            .startWithValues() { value in
                self.serialDisposable.inner = self.presentationIntent(value).present()
        }
        composite += serialDisposable
        return composite
    }

    func optional() -> SerialPresenter<T?> {
        return SerialPresenter<T?> {
            $0.map { self.presentationIntent($0) } ?? PresentationIntent()
        }
    }
}


protocol AnyPresentableContvertable: Presentable {
    init<T: Presentable>(_ presentable: T) where T.Presenters == Presenters
}

protocol AnyPresentableSourceType {
    associatedtype Presenters
    var presenters: Presenters { get }
}

final class AnyPresentableType<Presenters>: AnyPresentableContvertable {
    init<T: Presentable>(_ presentable: T) where T.Presenters == Presenters {
        self.present = presentable.present
    }

    public let present: (Presenters) -> Disposable?
}

extension AnyPresentableType: Presentable {
}

infix operator <>
infix operator <~

func <><Target : Presentable, Source : AnyPresentableSourceType>(target: Target, source: Source) -> Disposable?
    where Target.Presenters == Source.Presenters {
    return target.present(source.presenters)
}

func <~<Target : OptionalConvertablePresenter, Source : PropertyProtocol>(target: Target, source: Source) -> Disposable?
    where Source.Value : OptionalProtocol, Source.Value.Wrapped == Target.ViewModel, Source.Error == NoError {
        return target.optional().present(source.value.optional)
}

func <~<Target : PresenterType, Source : PropertyProtocol>(target: Target, source: Source) -> Disposable?
    where Source.Value == Target.ViewModel, Source.Error == NoError {
        return target.presenter.present(source.value)
}

func <~<Target : SerialPresenterType, Source : PropertyProtocol>(target: Target, source: Source) -> Disposable?
    where Source.Value == Target.ViewModel, Source.Error == NoError {
        return target.presenter.present(source.producer)
}

func <~<Target : PresenterType, Source>(target: Target, source: Source) -> Disposable?
    where Source == Target.ViewModel {
        return target.presenter.present(source)
}

func <~<Target : OptionalConvertablePresenter, Source : OptionalProtocol>(target: Target, source: Source) -> Disposable?
    where Source.Wrapped == Target.ViewModel {
        return target.optional().present(source.optional)
}

func <~<Target : PresenterType, Source: Presentable>(target: Target, source: Source) -> Disposable?
    where Target.ViewModel: AnyPresentableContvertable, Source.Presenters == Target.ViewModel.Presenters {
        return target.presenter.present(Target.ViewModel(source))
}
