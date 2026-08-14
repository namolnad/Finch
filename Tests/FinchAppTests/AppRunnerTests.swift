@testable import FinchApp
import SnapshotTesting
import XCTest

final class AppRunnerTests: XCTestCase {
    /// The bundled fixtures predate Conventional Commits, so run against the delimited config
    private var environment: Environment {
        ["FINCH_CONFIG": Bundle.module.url(forResource: "default_config", withExtension: "yml")!.path]
    }

    func testRunCompare() {
        let outputMock = OutputMock()

        AppRunner(
            environment: environment,
            meta: .mock,
            output: outputMock
        ).run(with: ["finch", "compare", "--git-log", defaultInputMock, "--versions", "6.20.0 5.3.0", "--build-number", "612"])

        assertSnapshot(of: outputMock.outputs, as: .dump)
    }

    /// `--commit-style` overrides the style the configuration resolved to
    func testCommitStyleOverride() {
        let outputMock = OutputMock()

        AppRunner(
            environment: environment,
            meta: .mock,
            output: outputMock
        ).run(with: [
            "finch",
            "compare",
            "--commit-style", "conventional",
            "--git-log", conventionalInputMock,
            "--versions", "6.20.0 5.3.0",
            "--no-show-version"
        ])

        // The config in `environment` is delimited, so parsing conventionally is the flag's doing
        XCTAssertTrue(outputMock.outputs.joined().contains("add analytics"))
        XCTAssertFalse(outputMock.outputs.joined().contains("feat(autocomplete)"))
    }

    func testRunConfigExample() {
        let outputMock = OutputMock()

        AppRunner(
            environment: environment,
            meta: .mock,
            output: outputMock
        ).run(with: ["finch", "config", "show-example"])

        assertSnapshot(of: outputMock.outputs, as: .dump)
    }
}
