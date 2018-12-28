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

        verbose(message: "hello \(environmentVariable(get: "CERTIFICATE_PASSWORD").suffix(4))")

        scan()
	}

    func setUpKeychain() {
        desc("Set up keychain for CircleCI")

        guard !environmentVariable(get: "CI").isEmpty else {
            log(message: "Not running on CI, skipping 'set_up_keychain'")
            return
        }

        verbose(message: "hello \(environmentVariable(get: "CERTIFICATE_PASSWORD").suffix(4))")

        importCertificate(
            keychainName: environmentVariable(get: "MATCH_KEYCHAIN_NAME"),
            keychainPassword: environmentVariable(get: "MATCH_KEYCHAIN_PASSWORD"),
            certificatePath: environmentVariable(get: "CERTIFICATE_PATH"),
            certificatePassword: environmentVariable(get: "CERTIFICATE_PASSWORD"),
            logOutput: true
        )
    }
}