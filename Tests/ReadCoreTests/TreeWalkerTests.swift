import XCTest
@testable import ReadCore

private struct MockElement: AccessibilityElement {
    let role: String
    let value: String?
    let title: String?
    let accessibilityDescription: String?
    let frame: Frame
    let children: [AccessibilityElement]

    init(
        role: String,
        value: String? = nil,
        title: String? = nil,
        accessibilityDescription: String? = nil,
        frame: Frame = .zero,
        children: [AccessibilityElement] = []
    ) {
        self.role = role
        self.value = value
        self.title = title
        self.accessibilityDescription = accessibilityDescription
        self.frame = frame
        self.children = children
    }
}

private final class FlakyElement: AccessibilityElement {
    let role = "AXApplication"
    let value: String? = nil
    let title: String? = nil
    let accessibilityDescription: String? = nil
    let frame = Frame.zero
    private(set) var accessCount = 0
    private var remainingEmptyAttempts: Int
    private let eventualChildren: [AccessibilityElement]

    init(emptyAttempts: Int, eventualChildren: [AccessibilityElement]) {
        self.remainingEmptyAttempts = emptyAttempts
        self.eventualChildren = eventualChildren
    }

    var children: [AccessibilityElement] {
        accessCount += 1
        if remainingEmptyAttempts > 0 {
            remainingEmptyAttempts -= 1
            return []
        }
        return eventualChildren
    }
}

/// A single element whose children property is self-referential, simulating a
/// malformed/cyclic AX tree (documented as a real Electron/Chromium AX bug class).
private final class CyclicElement: AccessibilityElement {
    let role = "AXGroup"
    let value: String? = nil
    let title: String? = nil
    let accessibilityDescription: String? = nil
    let frame = Frame.zero

    var children: [AccessibilityElement] { [self] }
}

final class TreeWalkerTests: XCTestCase {
    func testCollectsNodesWithNonEmptyValue() {
        let leaf = MockElement(role: "AXStaticText", value: "hello", frame: Frame(x: 0, y: 0, width: 10, height: 10))
        let root = MockElement(role: "AXGroup", children: [leaf])

        XCTAssertEqual(RetryingTreeWalker.walk(root), [Node(role: "AXStaticText", text: "hello", frame: leaf.frame)])
    }

    func testFallsBackToTitleWhenValueIsMissing() {
        let button = MockElement(role: "AXButton", title: "Delete", frame: Frame(x: 1, y: 1, width: 2, height: 2))

        XCTAssertEqual(RetryingTreeWalker.walk(button), [Node(role: "AXButton", text: "Delete", frame: button.frame)])
    }

    func testFallsBackToAccessibilityDescriptionWhenValueAndTitleAreMissing() {
        let button = MockElement(role: "AXButton", accessibilityDescription: "Percent", frame: Frame(x: 3, y: 3, width: 4, height: 4))

        XCTAssertEqual(RetryingTreeWalker.walk(button), [Node(role: "AXButton", text: "Percent", frame: button.frame)])
    }

    func testValueTakesPriorityOverTitleAndDescription() {
        let element = MockElement(role: "AXTextField", value: "draft", title: "ignored title", accessibilityDescription: "ignored description")

        XCTAssertEqual(RetryingTreeWalker.walk(element).map(\.text), ["draft"])
    }

    func testSkipsElementWithNoTextFromAnySource() {
        let group = MockElement(role: "AXGroup")

        XCTAssertTrue(RetryingTreeWalker.walk(group).isEmpty)
    }

    func testSkipsEmptyStringsFromEverySource() {
        let element = MockElement(role: "AXButton", value: "", title: "", accessibilityDescription: "")

        XCTAssertTrue(RetryingTreeWalker.walk(element).isEmpty)
    }

    func testStaticTextWithNoTextFromAnySourceIsNotIncluded() {
        // A plain role check used to unconditionally include AXStaticText even with
        // no real text, which also defeated the retry loop - see testRetriesOnEmptyResultUpToMaxAttempts.
        let emptyStaticText = MockElement(role: "AXStaticText")

        XCTAssertTrue(RetryingTreeWalker.walk(emptyStaticText).isEmpty)
    }

    func testWalksNestedChildrenInOrder() {
        let a = MockElement(role: "AXStaticText", value: "a")
        let b = MockElement(role: "AXStaticText", value: "b")
        let root = MockElement(role: "AXGroup", children: [a, b])

        XCTAssertEqual(RetryingTreeWalker.walk(root).map(\.text), ["a", "b"])
    }

    func testStopsRecursingPastMaxDepthInsteadOfOverflowingTheStack() {
        var element: AccessibilityElement = MockElement(role: "AXStaticText", value: "deepest")
        for _ in 0..<(RetryingTreeWalker.maxDepth + 10) {
            element = MockElement(role: "AXGroup", children: [element])
        }

        XCTAssertTrue(RetryingTreeWalker.walk(element).isEmpty)
    }

    func testCyclicTreeDoesNotOverflowTheStack() {
        let cyclic = CyclicElement()

        XCTAssertTrue(RetryingTreeWalker.walk(cyclic).isEmpty)
    }

    func testRetriesOnEmptyResultUpToMaxAttempts() {
        let text = MockElement(role: "AXStaticText", value: "hi")
        let flaky = FlakyElement(emptyAttempts: 2, eventualChildren: [text])
        var sleeps: [TimeInterval] = []
        let walker = RetryingTreeWalker(maxAttempts: 3, backoff: 0.15, sleep: { sleeps.append($0) })

        let nodes = walker.collect(from: flaky)

        XCTAssertEqual(nodes.map(\.text), ["hi"])
        XCTAssertEqual(sleeps, [0.15, 0.15])
        XCTAssertEqual(flaky.accessCount, 3)
    }

    func testGivesUpAfterMaxAttemptsIfStillEmpty() {
        let flaky = FlakyElement(emptyAttempts: 10, eventualChildren: [])
        var sleepCount = 0
        let walker = RetryingTreeWalker(maxAttempts: 3, backoff: 0.15, sleep: { _ in sleepCount += 1 })

        let nodes = walker.collect(from: flaky)

        XCTAssertTrue(nodes.isEmpty)
        XCTAssertEqual(sleepCount, 2)
        XCTAssertEqual(flaky.accessCount, 3)
    }

    func testDoesNotSleepWhenFirstAttemptSucceeds() {
        let text = MockElement(role: "AXStaticText", value: "hi")
        let flaky = FlakyElement(emptyAttempts: 0, eventualChildren: [text])
        var sleepCount = 0
        let walker = RetryingTreeWalker(maxAttempts: 3, backoff: 0.15, sleep: { _ in sleepCount += 1 })

        _ = walker.collect(from: flaky)

        XCTAssertEqual(sleepCount, 0)
        XCTAssertEqual(flaky.accessCount, 1)
    }

    func testNonPositiveMaxAttemptsIsClampedToOneInsteadOfCrashing() {
        let flaky = FlakyElement(emptyAttempts: 0, eventualChildren: [])

        let zero = RetryingTreeWalker(maxAttempts: 0, sleep: { _ in })
        let negative = RetryingTreeWalker(maxAttempts: -5, sleep: { _ in })

        XCTAssertEqual(zero.maxAttempts, 1)
        XCTAssertEqual(negative.maxAttempts, 1)
        XCTAssertEqual(zero.collect(from: flaky), [])
    }
}
