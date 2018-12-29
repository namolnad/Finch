//
//  RoutingTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import DiffFormatter
import SnapshotTesting
import XCTest

final class RoutingTests: XCTestCase {
    func testArgumentRouter() {
        let router: ArgumentRouter = .init(app: .mock, configuration: .mock)

        let routableArgs: [String] = [
            "6.12.1",
            "6.13.0",
            "--git-diff=\(Utilities.inputMock)"
        ]

        let scheme: ArgumentScheme = .init(arguments: routableArgs)

        XCTAssertTrue(router.route(argScheme: scheme) == .handled)

        XCTAssertTrue(router.route(argScheme: .mock) == .notHandled)
    }

    func testDiffHandler() {
        var output: String! = ""

        let context: ArgumentRouter.Context = .init(
            app: .mock,
            configuration: .mock,
            output: { output = $0 }
        )

        let scheme: ArgumentScheme = .init(
            oldVersion: "6.19.0",
            newVersion: "6.19.1",
            args: [.actionable(.buildNumber, "56789"), .flag(.noFetch)]
        )

        XCTAssert(output.isEmpty)

        _ = ArgumentRouter.diffHandler.handle(context, scheme)

        assertSnapshot(matching: output, as: .dump)
    }

    func testVersionHandler() {
        var output: String! = ""

        let context: ArgumentRouter.Context = .init(
            app: .mock,
            configuration: .mock,
            output: { output = $0 }
        )

        let scheme: ArgumentScheme = .init(
            oldVersion: "6.19.0",
            newVersion: "6.19.1",
            args: [.flag(.version)]
        )

        XCTAssert(output.isEmpty)

        _ = ArgumentRouter.versionHandler.handle(context, scheme)

        assertSnapshot(matching: output, as: .dump)
    }

    func testUsageHandler() {
        var output: String! = ""

        let context: ArgumentRouter.Context = .init(
            app: .mock,
            configuration: .mock,
            output: { output = $0 }
        )

        let scheme: ArgumentScheme = .init(
            oldVersion: "6.19.0",
            newVersion: "6.19.1",
            args: [.flag(.help)]
        )

        XCTAssert(output.isEmpty)

        _ = ArgumentRouter.usageHandler.handle(context, scheme)

        assertSnapshot(matching: output, as: .dump)
    }
}
