import Foundation
import ReadCore

func writeStderr(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

let arguments: Arguments
switch ArgumentParser.parse(Array(CommandLine.arguments.dropFirst())) {
case .success(let parsed):
    arguments = parsed
case .failure(let error):
    writeStderr("ve: \(error)")
    exit(1)
}

guard PermissionCheck.isTrusted(promptIfNeeded: false) else {
    writeStderr("""
    ve requires Accessibility permission.

    Open System Settings > Privacy & Security > Accessibility, add this binary, \
    and enable it. Re-run `ve` once granted.
    """)
    exit(1)
}

let root: AccessibilityElement
if let pid = arguments.pid {
    root = SystemAccessibilityElement.application(pid: pid)
} else {
    guard let frontmost = FrontmostApplication.axElement() else {
        writeStderr("ve: no frontmost application found")
        exit(1)
    }
    root = frontmost
}

// role is always non-empty for an app ve succeeds on; empty means every AX call on
// this app is failing outright (not AX-enabled, invalid pid, or it quit mid-read), not
// that its on-screen text is genuinely absent.
guard !root.role.isEmpty else {
    writeStderr("ve: could not read the target application's accessibility tree")
    exit(1)
}

let nodes = RetryingTreeWalker().collect(from: root)
let envelope = Envelope(nodes: nodes)

do {
    let data = try JSONEncoder().encode(envelope)
    FileHandle.standardOutput.write(data)
    FileHandle.standardOutput.write(Data("\n".utf8))
} catch {
    writeStderr("ve: failed to encode output: \(error)")
    exit(1)
}
