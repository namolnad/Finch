/// :nodoc:
protocol LineOutputtable {
    func output(components: LineComponents, context: LineContext) -> String
}
