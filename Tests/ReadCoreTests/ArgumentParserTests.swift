import XCTest
@testable import ReadCore

final class ArgumentParserTests: XCTestCase {
    func testNoArgumentsYieldsNilPID() {
        XCTAssertEqual(try ArgumentParser.parse([]).get(), Arguments(pid: nil))
    }

    func testParsesPIDFlag() {
        XCTAssertEqual(try ArgumentParser.parse(["--pid", "1234"]).get(), Arguments(pid: 1234))
    }

    func testMissingPIDValueFails() {
        XCTAssertEqual(ArgumentParser.parse(["--pid"]), .failure(.missingPIDValue))
    }

    func testNonNumericPIDValueFails() {
        XCTAssertEqual(ArgumentParser.parse(["--pid", "not-a-number"]), .failure(.invalidPIDValue("not-a-number")))
    }

    func testUnknownArgumentFails() {
        XCTAssertEqual(ArgumentParser.parse(["--bogus"]), .failure(.unknownArgument("--bogus")))
    }
}
