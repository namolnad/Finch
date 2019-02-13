//
//  SectionsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 2/12/19.
//

public protocol Mergeable {
    func merge(into other: inout Self)
}

public struct FormatConfiguration {
    public private(set) var delimiterConfig: DelimiterConfiguration
    public private(set) var footer: String?
    public private(set) var formatTemplate: FormatTemplate?
    public private(set) var header: String?
    public private(set) var sectionInfos: [SectionInfo]
}

extension FormatConfiguration: Decodable {
    enum CodingKeys: String, CodingKey {
        case delimiterConfig
        case footer
        case formatString
        case header
        case sectionInfos
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.delimiterConfig = container.decode(forKey: .delimiterConfig, default: .blank)
        self.footer = container.optionalDecode(forKey: .footer)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.header = container.optionalDecode(forKey: .header)
        self.sectionInfos = container.decode(forKey: .sectionInfos, default: [])
    }
}

extension FormatConfiguration: SubConfiguration {
    public static var blank: FormatConfiguration = .init(
        delimiterConfig: .blank,
        footer: nil,
        formatTemplate: nil,
        header: nil,
        sectionInfos: []
    )

    public static var `default`: FormatConfiguration = .init(
        delimiterConfig: .default,
        footer: nil,
        formatTemplate: .default,
        header: nil,
        sectionInfos: .default
    )
}

extension FormatConfiguration: Mergeable {
    public func merge(into other: inout FormatConfiguration) {
        if other.sectionInfos.isEmpty {
            other.sectionInfos = sectionInfos
        }

        if other.formatTemplate == nil {
            other.formatTemplate = formatTemplate
        }

        if other.header == nil {
            other.header = header
        }

        if other.footer == nil {
            other.footer = footer
        }

        delimiterConfig.merge(into: &other.delimiterConfig)
    }
}
