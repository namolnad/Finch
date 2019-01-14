//
//  Mocks.swift
//  DiffFormatterTests
//
//  Created by Dan Loman on 12/28/18.
//  Copyright © 2018 DHL. All rights reserved.
//

@testable import DiffFormatterCore
import DiffFormatterRouting

extension Configuration {
    static let mock: Configuration = {
        var config: Configuration = .default(currentDirectory: "")
        config.update(with: TestHelper.model(for: "default_config"))

        return config
    }()

    static let mockExcludedSection: Configuration = {
        var config: Configuration = .mock
        config.update(with: TestHelper.model(for: "excluded_section_config"))

        return config
    }()

    static let mockBuildNumberCommand: Configuration = {
        var config: Configuration = .mock
        config.update(with: TestHelper.model(for: "build_number_command_config"))

        return config
    }()
}

extension ArgumentScheme {
    static let mock: ArgumentScheme = .nonDiffable(args: [])
}

extension App {
    static let mock: App = .init(buildNumber: "12345", name: "DiffFormatter", version: "1.0.1")
}

let inputMock = """
> &&&fce9cb800905de678a99577a64c8230e63f1cc37&&& - @@@[autocomplete-v3] add analytics (#1030)@@@###elvis1935+still-alive@theking.com###
> &&&2236c36e40c4409927fdcd2b6ebd29b18aa03e36&&& - @@@[express-placement] build error fix (#1025)@@@###jony.ive@apple.com###
> &&&9a33ff13804bcce98a4c81279cc1254e499e4932&&& - @@@[push-notificatons] Request for permission after user places an order with 90 day re-prompt (#1024)@@@###jony.ive@apple.com###
> &&&092510f3eb3f85592b6973858c2b9591dd78d692&&& - @@@[express-placement] additional clean-up for analytics and bugs (#1021)@@@###jony.ive@apple.com###
> &&&6e12ce047d1513a148456ede004ed4d89cedcec5&&& - @@@[codable] better supported for AnyEncodables (#1022)@@@###elvis1935+still-alive@theking.com###
> &&&97021013d7873f399a911f87568f02f359f2c6bd&&& - @@@[analytics] Current production express placements are missing subscription_id in express_start.purchase tracking events (#1020)@@@###jony.ive@apple.com###
> &&&e10fb1f08c6e139099eb74109e6372cd45958440&&& - @@@[bug] Don't show express placement every cold start (#1019)@@@###jony.ive@apple.com###
> &&&70fbd7117720f22ddd118f60add4b55238663703&&& - @@@Syncing express params across checkout modules (#1016)@@@###long_live_the_citadel@rick.com###
> &&&853bfd88f304d16a9caf817c39dda4f057160b04&&& - @@@[bug fix] fix LossyCodableArray (#1017)@@@###long_live_the_citadel@rick.com###
> &&&036a288658f1b4a11ed1d649394d1e049eb7c4e6&&& - @@@[tests] fix order snapshots (#1018)@@@###long_live_the_citadel@rick.com###
> &&&23ac4d92a5a735dc31c64197eddedd856cc85fcc&&& - @@@Order status V2.5 (#988)@@@###elvis1935+still-alive@theking.com###
> &&&18d8350f4dddbea42ba3acf752ad4325b8f13d9d&&& - @@@[search] consolidate searchBar cornerRadius to 4, increase autocomplete-v3 term height (#1011)@@@###elvis1935+still-alive@theking.com###
> &&&ab9406d731c18e6500c82e865034e87fdf7986e1&&& - @@@[bug fix] minor bug fixes for cubs/pbi (#1010)@@@###elvis1935+still-alive@theking.com###
> &&&f2a7e851e982e1d61a54dbea2f199e9d5d2404e8&&& - @@@Update all express placements to one screen (#975)@@@###jony.ive@apple.com###
> &&&b8a61e1fe83feabac08d3beda5237612e2d60d54&&& - @@@[carthage] move google places to internal carthage (#1008)@@@###elvis1935+still-alive@theking.com###
> &&&29cd90a5eb4bbad531e098f673eefe43d45d44a5&&& - @@@[platform] background actions (#955)@@@###elvis1935+still-alive@theking.com###
> &&&d157b78a5f440654ee243c676642466ff72912a6&&& - @@@[rollbar] update to v1.0.0 final (#1007)@@@###elvis1935+still-alive@theking.com###
> &&&a7586919f6b096d884958e3386e535ecc986cd57&&& - @@@Autocomplete V3 (#1004)@@@###elvis1935+still-alive@theking.com###
> &&&1c659ebb3dfde5b078894741a75eb0e3387656f2&&& - @@@[version] 6.13.0@@@###elvis1935+still-alive@theking.com###
"""
