import Foundation

public struct RetryingTreeWalker {
    /// Bounds recursion against a malformed/cyclic AX tree (some Electron/Chromium
    /// accessibility bridges have shipped aria-owns cycle bugs) rather than crashing.
    static let maxDepth = 64

    public let maxAttempts: Int
    public let backoff: TimeInterval
    public let sleep: (TimeInterval) -> Void

    public init(
        maxAttempts: Int = 3,
        backoff: TimeInterval = 0.15,
        sleep: @escaping (TimeInterval) -> Void = { Thread.sleep(forTimeInterval: $0) }
    ) {
        self.maxAttempts = max(1, maxAttempts)
        self.backoff = backoff
        self.sleep = sleep
    }

    public func collect(from root: AccessibilityElement) -> [Node] {
        for attempt in 1...maxAttempts {
            let nodes = Self.walk(root)
            if !nodes.isEmpty || attempt == maxAttempts {
                return nodes
            }
            sleep(backoff)
        }
        return []
    }

    public static func walk(_ element: AccessibilityElement, depth: Int = 0) -> [Node] {
        guard depth < maxDepth else {
            return []
        }

        var nodes: [Node] = []
        if let text = extractText(element) {
            nodes.append(Node(role: element.role, text: text, frame: element.frame))
        }
        for child in element.children {
            nodes.append(contentsOf: walk(child, depth: depth + 1))
        }
        return nodes
    }

    /// A node's text is whichever of value, title, or accessibility description is
    /// non-empty first - the same generic rule for every app, no role special-casing.
    static func extractText(_ element: AccessibilityElement) -> String? {
        if let value = element.value, !value.isEmpty {
            return value
        }
        if let title = element.title, !title.isEmpty {
            return title
        }
        if let description = element.accessibilityDescription, !description.isEmpty {
            return description
        }
        return nil
    }
}
