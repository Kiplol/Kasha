//
//  Section.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class Section: NSObject {
    var title: String?
    var rows: [Row] = []
    
    convenience init(title: String? = nil, rows: [Row]? = nil) {
        self.init()
        self.title = title
        if let rows = rows {
            self.rows = rows
        }
    }
}

class Row: NSObject {
    let data: Any?
    let cellReuseIdentifier: String
    
    init(data: Any? = nil, cellReuseIdentifier: String) {
        self.data = data
        self.cellReuseIdentifier = cellReuseIdentifier
        super.init()
    }
}
