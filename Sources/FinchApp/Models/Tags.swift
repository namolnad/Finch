import SwiftCLI

/// A space-separated set of commit tags, as received from the command line.
struct Tags: ConvertibleFromString {
    let values: Set<String>

    init?(input: String) {
        self.values = Set(
            input
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
        )
    }
}
