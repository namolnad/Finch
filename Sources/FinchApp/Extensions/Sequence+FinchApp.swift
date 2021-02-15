/// :nodoc:
extension Sequence {
    func firstMap<T>(_ transform: (Element) throws -> T?) rethrows -> T? {
        for element in self {
            if let transformed = try transform(element) {
                return transformed
            }
        }

        return nil
    }
}
