//
//  ViewController.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 3/18/17.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import TableKit

final class MainViewController: UIViewController {
    @IBOutlet var tableView: UITableView?
    var selector: (Int) -> () = { _ in }

    var tableDirector: TableDirector?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tableView = tableView {
            self.tableDirector = TableDirector(tableView: tableView)
        }
    }
}

extension MainViewController: AnyPresentableSourceType {
    typealias Presenters = MainPresentersContainer

    var presenters: MainPresentersContainer {
        return MainPresentersContainer(titlePresenter: self.titlePresenter,
                                       nonePresenter: self.nonePresenter,
                                       counterScreenPresenter: self.counterPresenter,
                                       textScreenPresenter: self.textPresenter,
                                       cellsPresenter: self.cellsPresenter,
                                       cellSelectorPresenter: self.cellSelectorPresenter)
    }

    fileprivate var titlePresenter: Presenter<String> {
        return Presenter.UI { title in
            self.navigationItem.title = title
            return nil
        }
    }

    var cellsPresenter: Presenter<[MainCellViewModel]> {
        return Presenter.UI { cells in
            let rows = cells.map {
                return TableRow<MainTableViewCell>(item: $0).on(.click) { [weak self] options in
                    self?.selector(options.indexPath.row)
                }
            }
            self.tableDirector?
                .append(rows: rows)
                .reload()
            return nil
        }
    }

    var textPresenter: Presenter<TextViewModel.AnyPresentable> {
        return Presenter.UI { [weak self] viewmodel in
            guard let selfStrong = self else { return nil }
            let view = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "TextScreen")
                as! TextViewController
            view.loadViewIfNeeded()
            selfStrong.navigationController?.pushViewController(view, animated: true)
            return viewmodel <- view
        }
    }

    var counterPresenter: Presenter<CounterViewModel.AnyPresentable> {
        return Presenter.UI { [weak self] viewmodel in
            guard let selfStrong = self else { return nil }
            let view = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "CounterScreen")
                as! CounterViewController
            view.loadViewIfNeeded()
            selfStrong.navigationController?.pushViewController(view, animated: true)
            return viewmodel <- view
        }
    }

    fileprivate var nonePresenter: Presenter<()> {
        return Presenter.UI { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            return nil 
        }
    }

    var cellSelectorPresenter: Presenter<(Int) -> ()> {
        return Presenter.UI {
            self.selector = $0
            return nil
        }
    }
}
