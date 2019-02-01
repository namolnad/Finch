//
//  OutputMock.swift
//  DiffFormatterAppTests
//
//  Created by Dan Loman on 1/31/19.
//

import DiffFormatterUtilities

final class OutputMock: OutputType {

    var lastOutput: String = ""

    func print(_ value: String, kind: Output.Kind, verbose: Bool) {
        lastOutput = value
    }
}
