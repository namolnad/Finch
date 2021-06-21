/// :nodoc:
public struct Section {
    public let configuration: Configuration
    public let info: SectionInfo
    public let linesComponents: [LineComponents]

    public init(configuration: Configuration, info: SectionInfo, linesComponents: [LineComponents]) {
        self.configuration = configuration
        self.info = info
        self.linesComponents = linesComponents
    }
}

/// :nodoc:
extension Section {
    var lines: [Line] {
        linesComponents.map { components -> Line in
            .from(
                components: components,
                context: .init(
                    configuration: configuration,
                    sectionInfo: info
                )
            )
        }
    }

    /// :nodoc:
    public func inserting(lineComponents: LineComponents) -> Section {
        .init(
            configuration: configuration,
            info: info,
            linesComponents: linesComponents + [lineComponents]
        )
    }
}

/// :nodoc:
extension Section: Outputtable {
    public func output(markup: FormatConfiguration.Markup) -> String {
        switch markup {
        case .html:
            return """

            <h3>\(info.title)<h3>
            <ul>\(lines.output(markup: markup))</ul>

            """
        case .markdown:
            return """

            ### \(info.title)
            \(lines.output(markup: markup))

            """
        }
    }
}
