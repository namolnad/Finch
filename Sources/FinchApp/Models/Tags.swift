import ArgumentParser

/// A space-separated set of commit tags, as received from the command line.
struct Tags: ExpressibleByArgument {
    let values: Set<String>

    init?(argument: String) {
        self.values = Set(
            argument
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
        )
    }
}
