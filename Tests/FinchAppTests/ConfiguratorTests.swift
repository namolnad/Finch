@testable import FinchApp
import SnapshotTesting

final class ConfiguratorTests: TestCase {
    func testDefault() {
        assertSnapshot(
            matching: Configurator(
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
            matching: Configurator(
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
