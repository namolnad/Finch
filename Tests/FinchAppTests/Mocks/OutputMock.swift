import FinchUtilities

final class OutputMock: OutputType {
    var outputs: [String] = []

    func print(_ value: String, kind: Output.Kind, verbose: Bool) {
        outputs.append(value)
    }
}
