//
//  Pasteboard.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import AppKit.NSPasteboard

func pbCopy(text: String) {
    NSPasteboard.general.declareTypes([.string], owner: nil)
    NSPasteboard.general.setString(text, forType: .string)
}
