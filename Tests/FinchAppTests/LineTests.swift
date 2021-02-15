@testable import FinchCore
import SnapshotTesting
import XCTest

final class LineTests: TestCase {
    func testLineComponentParsing() {
        let sha = "5a544059e165f0703843d1c6c509cc853ad6afa4"

        let sample = "&&&\(sha)&&& - @@@[tag1][tag2] fixing something somewhere (#1234)@@@###author@email.com###"

        assertSnapshot(
            matching: LineComponents(
                rawLine: sample,
                configuration: .mock,
                normalizeTags: false
            ),
            as: .dump
        )

        let sample2 = "&&&\(sha)&&& - @@@[tag1]fixing something somewhere@@@###author+1234@email.com###"

        assertSnapshot(
            matching: LineComponents(
                rawLine: sample2,
                configuration: .mock,
                normalizeTags: false
            ),
            as: .dump
        )
    }
}
