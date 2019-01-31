//
//  ConfigurationTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import DiffFormatterApp
import SnapshotTesting
import XCTest

final class ConfigurationTests: XCTestCase {
    func testConfigurator() {
        assertSnapshot(
            matching: Configurator(
                options: .blank,
                meta: .mock,
                environment: [:],
                fileManager: .mock
            ).configuration,
            as: .dump
        )
    }
}
