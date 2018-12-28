// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    func beforeAll() {
        setupCircleCi()
        setUpKeychain()
    }

    func testLane() {
        desc("Run tests")

        scan()
	}

    func setUpKeychain() {
        desc("Set up keychain for CircleCI")

        guard !environmentVariable(get: "CIRCLECI").isEmpty else {
            return
        }

        importCertificate(
            keychainName: environmentVariable(get: "MATCH_KEYCHAIN_NAME"),
            keychainPassword: environmentVariable(
                get: "MATCH_KEYCHAIN_PASSWORD"
            ),
            certificatePath: "Certificates.p12",
            certificatePassword: environmentVariable(
                get: "CERTIFICATE_PASSWORD"
            )
        )
    }
}
