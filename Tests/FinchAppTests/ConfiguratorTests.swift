//
//  ConfiguratorTests.swift
//  FinchTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import FinchApp
import SnapshotTesting

final class ConfiguratorTests: TestCase {
    func testDefault() {
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

    func testProjectDirOption() {
        assertSnapshot(
            matching: Configurator(
                options: .init(
                    projectDir: "current",
                    shouldPrintVersion: false,
                    verbose: false
                ),
                meta: .mock,
                environment: [:],
                fileManager: .mock
                ).configuration,
            as: .dump
        )
    }
}
