@testable import FinchApp
import XCTest

final class CompareCommandTests: XCTestCase {
    func testCommandName() {
        XCTAssertEqual(CompareCommand.configuration.commandName, "compare")
    }
}
