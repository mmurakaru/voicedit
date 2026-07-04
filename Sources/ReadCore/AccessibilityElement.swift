public protocol AccessibilityElement {
    var role: String { get }
    var value: String? { get }
    var title: String? { get }
    var accessibilityDescription: String? { get }
    var frame: Frame { get }
    var children: [AccessibilityElement] { get }
}
