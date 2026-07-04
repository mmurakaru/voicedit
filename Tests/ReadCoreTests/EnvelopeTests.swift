import XCTest
@testable import ReadCore

final class EnvelopeTests: XCTestCase {
    func testDefaultVersionIsOne() {
        XCTAssertEqual(Envelope(nodes: []).version, 1)
    }

    func testRoundTripsThroughJSON() throws {
        let envelope = Envelope(nodes: [Node(role: "AXStaticText", text: "hi", frame: Frame(x: 0, y: 0, width: 1, height: 1))])

        let data = try JSONEncoder().encode(envelope)
        let decoded = try JSONDecoder().decode(Envelope.self, from: data)

        XCTAssertEqual(decoded, envelope)
    }

    func testTextKeyIsAlwaysPresentInEncodedJSON() throws {
        let envelope = Envelope(nodes: [Node(role: "AXStaticText", text: "hi", frame: .zero)])

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(envelope)) as! [String: Any]
        let node = (json["nodes"] as! [[String: Any]])[0]

        XCTAssertNotNil(node["text"])
    }
}
