//
//  MainTableViewCell.swift
//  Fraktal
//
//  Created by Dmitry Levsevich on 11/24/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import TableKit

final class MainTableViewCell: UITableViewCell, ConfigurableCell {
    func configure(with model: MainCellViewModel) {
        self.textLabel?.text = model
    }
}
