@testable import FinchApp
import SnapshotTesting
import XCTest

final class ConfiguratorTests: XCTestCase {
    func testDefault() {
        assertSnapshot(
            of: Configurator(
                configPath: nil,
                projectDir: "current",
                meta: .mock,
                environment: [:],
                fileManager: .mock
            ).configuration,
            as: .dump
        )
    }

    func testProjectDirOption() {
        assertSnapshot(
            of: Configurator(
                configPath: nil,
                projectDir: "current",
                meta: .mock,
                environment: [:],
                fileManager: .mock
            ).configuration,
            as: .dump
        )
    }
}
