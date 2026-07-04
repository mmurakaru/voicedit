import Foundation
import ReadCore

func writeStderr(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

guard PermissionCheck.isTrusted(promptIfNeeded: false) else {
    writeStderr("""
    read requires Accessibility permission.

    Open System Settings > Privacy & Security > Accessibility, add this binary, \
    and enable it. Re-run `read` once granted.
    """)
    exit(1)
}

guard let root = FrontmostApplication.axElement() else {
    writeStderr("read: no frontmost application found")
    exit(1)
}

// role is always non-empty for an app read succeeds on; empty means every AX call on
// this app is failing outright (not AX-enabled, or it quit mid-read), not that its
// on-screen text is genuinely absent.
guard !root.role.isEmpty else {
    writeStderr("read: could not read the frontmost application's accessibility tree")
    exit(1)
}

let nodes = RetryingTreeWalker().collect(from: root)
let envelope = Envelope(nodes: nodes)

do {
    let data = try JSONEncoder().encode(envelope)
    FileHandle.standardOutput.write(data)
    FileHandle.standardOutput.write(Data("\n".utf8))
} catch {
    writeStderr("read: failed to encode output: \(error)")
    exit(1)
}
