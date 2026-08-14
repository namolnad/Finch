// Temporary: proves the named_multiline_condition rule fires. Removed before merge.
enum RuleProbe {
    static func probe(parts: [String]) -> Bool {
        if
            parts.isEmpty,
            let first = parts.first,
            first.isEmpty {
            return true
        }

        return false
    }
}
