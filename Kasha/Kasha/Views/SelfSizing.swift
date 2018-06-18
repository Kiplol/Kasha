//
//  SelfSizing.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/18/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

protocol SelfSizing {
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize
}
