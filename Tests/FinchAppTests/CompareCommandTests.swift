@testable import FinchApp
import SnapshotTesting
import XCTest

final class CompareCommandTests: TestCase {
    func testCommandName() {
        let command = CompareCommand(appGenerator: { _, _, _ in .mock() })

        XCTAssertEqual(command.name, "compare")
    }
}
