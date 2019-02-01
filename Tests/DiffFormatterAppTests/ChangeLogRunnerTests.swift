//
//  ChangeLogRunnerTests.swift
//  DiffFormatterAppTests
//
//  Created by Dan Loman on 1/31/19.
//

@testable import DiffFormatterApp
import DiffFormatterUtilities
import SnapshotTesting
import XCTest

final class ChangeLogRunnerTests: XCTestCase {

    func testDefault() {
        let outputMock = OutputMock()

        try! ChangeLogRunner().run(
            with: options,
            app: .init(
                configuration: .mock,
                meta: .mock,
                options: .mock,
            output: outputMock
            ),
            env: [:]
        )

        assertSnapshot(matching: outputMock.lastOutput, as: .dump)
    }

    var options: GenerateCommand.Options {
        return .init(
            versions: (.init(0, 1, 2), .init(0, 1, 3)),
            buildNumber: nil,
            gitLog: defaultInputMock,
            noFetch: false,
            noShowVersion: false,
            releaseManager: nil,
            toPasteBoard: false)
    }
}

extension App.Options {
    static let mock: App.Options = .init(
        projectDir: "home/dir",
        shouldPrintVersion: false,
        verbose: false
    )
}
