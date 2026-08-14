/// :nodoc:
protocol LineOutputtable: Sendable {
    func output(components: LineComponents, context: LineContext) -> String
}
