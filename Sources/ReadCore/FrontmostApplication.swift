import AppKit

public enum FrontmostApplication {
    public static func axElement() -> AccessibilityElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        return SystemAccessibilityElement.application(pid: app.processIdentifier)
    }
}
