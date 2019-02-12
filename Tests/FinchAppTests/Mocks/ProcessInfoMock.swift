//
//  ProcessInfoMock.swift
//  FinchTests
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension ProcessInfo {
    static let mock: ProcessInfo = ProcessInfoMock(arguments: [], environment: [:])
}

final class ProcessInfoMock: ProcessInfo {
    override var arguments: [String] {
        return _arguments
    }

    private var _arguments: [String]

    override var environment: [String: String] {
        return _environment
    }

    private var _environment: [String: String]

    init(arguments: [String], environment: [String: String]) {
        self._arguments = arguments
        self._environment = environment
    }
}
