public struct Frame: Codable, Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public static let zero = Frame(x: 0, y: 0, width: 0, height: 0)
}

public struct Node: Codable, Equatable {
    public let role: String
    public let text: String
    public let frame: Frame

    public init(role: String, text: String, frame: Frame) {
        self.role = role
        self.text = text
        self.frame = frame
    }
}

public struct Envelope: Codable, Equatable {
    public let version: Int
    public let nodes: [Node]

    public init(version: Int = 1, nodes: [Node]) {
        self.version = version
        self.nodes = nodes
    }
}
