//
//  RoutingTests.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import XCTest
@testable import DiffFormatter

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
            args: [.actionable(.buildNumber, "56789")]
        )

        XCTAssert(output.isEmpty)

        _ = ArgumentRouter.diffHandler.handle(context, scheme)

        XCTAssert(output == "Output copied to pasteboard: \n# 6.19.1 (56789)\n\n### Features\n\n\n### Bug Fixes\n\n\n### Platform Improvements\n\n\n### Timeline\n- Begin development:\n- Feature cut-off / Start of bake / dogfooding:\n- Submission:\n- Release (expected):\n- Release (actual):\n")
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

        XCTAssert(output == "DiffFormatter 1.0.1 (12345)")
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

        XCTAssert(output == "\nDiffFormatter Info:\n    -h, --help\n        Displays this dialog\n    -v, --version\n        Displays DiffFormatter version information\n\nDiff Formatting:\n    The first 2 arguments must be (branch or tag) version strings, given as:\n\n    `DiffFormatter OLD_VERSION NEW_VERSION`\n\nDiff-Modifying Arguments:\n    --no-show-version\n        The ability to hide the version header\n    --release-manager\n        The release manager\'s email, e.g. `--release-manager=$(git config --get user.email)`\n    --project-dir\n        Project directory if DiffFormatter is not being called from project directory\n    --git-diff\n        Manually-passed git diff in expected format. See README for format details.\n\nConfiguration:\n    Configuration instructions available in the README.\n\n\nAdditional information available at: https://github.com/namolnad/DiffFormatter\n")
    }
}
