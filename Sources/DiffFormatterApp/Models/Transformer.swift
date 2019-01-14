//
//  Transformer.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterCore
import Foundation

struct Transformer {
    let pattern: Regex.Replacement

    func transform(text: String) -> String {
        return pattern.findReplace(in: text)
    }
}
