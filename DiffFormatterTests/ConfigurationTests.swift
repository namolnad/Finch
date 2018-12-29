//
//  ConfigurationTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import XCTest
@testable import DiffFormatter
import SnapshotTesting

final class ConfigurationTests: XCTestCase {
    func testConfigurator() {
        assertSnapshot(
            matching: Configurator(
                processInfo: .mock,
                argScheme: .mock,
                fileManager: .mock
            ).configuration,
            as: .dump
        )
    }
}
