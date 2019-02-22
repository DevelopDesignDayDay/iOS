//
//  String.swift
//  DDD
//
//  Created by Gunter on 22/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
