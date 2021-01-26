import XCTest
@testable import HTTPLib

final class HTTPLibTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HTTPLib().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
