import AppKit
import ApplicationServices

public enum FrontmostApplication {
    /// Fail fast against an unresponsive app rather than blocking on the OS default
    /// (commonly several seconds) for every one of the many AX calls a full tree walk makes.
    private static let messagingTimeoutSeconds: Float = 1.0

    public static func axElement() -> AccessibilityElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        AXUIElementSetMessagingTimeout(axApp, messagingTimeoutSeconds)
        return SystemAccessibilityElement(element: axApp)
    }
}
