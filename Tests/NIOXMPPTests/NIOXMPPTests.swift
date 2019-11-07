import XCTest
@testable import NIOXMPP

final class NIOXMPPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NIOXMPP().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
