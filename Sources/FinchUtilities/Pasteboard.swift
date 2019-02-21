//
//  Pasteboard.swift
//  Finch
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

#if os(macOS)
import AppKit.NSPasteboard

public func pbCopy(text: String) {
    NSPasteboard.general.declareTypes([.string], owner: nil)
    NSPasteboard.general.setString(text, forType: .string)
}
#endif
