import ApplicationServices
import CoreGraphics

public final class SystemAccessibilityElement: AccessibilityElement {
    private let element: AXUIElement

    public init(element: AXUIElement) {
        self.element = element
    }

    public var role: String {
        Self.copyAttribute(element, kAXRoleAttribute) as? String ?? ""
    }

    public var value: String? {
        Self.copyAttribute(element, kAXValueAttribute) as? String
    }

    public var title: String? {
        Self.copyAttribute(element, kAXTitleAttribute) as? String
    }

    public var accessibilityDescription: String? {
        Self.copyAttribute(element, kAXDescriptionAttribute) as? String
    }

    public var frame: Frame {
        var point = CGPoint.zero
        var size = CGSize.zero

        if let positionValue = Self.copyAttribute(element, kAXPositionAttribute), CFGetTypeID(positionValue) == AXValueGetTypeID() {
            AXValueGetValue(positionValue as! AXValue, .cgPoint, &point)
        }
        if let sizeValue = Self.copyAttribute(element, kAXSizeAttribute), CFGetTypeID(sizeValue) == AXValueGetTypeID() {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        }

        return Frame(x: point.x, y: point.y, width: size.width, height: size.height)
    }

    public var children: [AccessibilityElement] {
        guard let children = Self.copyAttribute(element, kAXChildrenAttribute) as? [AXUIElement] else {
            return []
        }
        return children.map { SystemAccessibilityElement(element: $0) }
    }

    private static func copyAttribute(_ element: AXUIElement, _ attribute: String) -> AnyObject? {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        return result == .success ? value : nil
    }
}
