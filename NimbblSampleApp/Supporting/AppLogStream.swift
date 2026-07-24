/*
Created by Sandeep Y. on 15/05/26.
Copyright (c) 2026 Bigital Technologies Pvt. Ltd. All rights reserved.

Captures stdout + stderr into a bounded ring buffer for `DebugLogsViewController`.

Pipe capture (dup2) is disabled while the Xcode debugger is attached — it conflicts
with libLogRedirect and causes SIGPIPE when the SDK prints during checkout.
Use `DebugLog.log(...)` for in-app viewer output under Xcode; use the Xcode console
for raw SDK `print` output.
*/

import Foundation

@objc public final class AppLogStream: NSObject {

    @objc public static let shared = AppLogStream()

    @objc public static let didAppendNotification = Notification.Name("AppLogStream.didAppend")

    private let queue = DispatchQueue(label: "biz.nimbbl.AppLogStream", qos: .utility)
    private let lock = NSLock()

    private var buffer: String = ""
    private let maxChars = 200_000
    private var isPipeInstalled: Bool = false

    @objc public var isPaused: Bool = false

    private var originalStdout: Int32 = -1
    private var originalStderr: Int32 = -1

    private override init() {
        super.init()
    }

    @objc public static var isXcodeDebugSession: Bool {
        ProcessInfo.processInfo.environment["IDE_DISABLED_OS_ACTIVITY_DT_MODE"] != nil
    }

    /// Append a line to the in-app buffer (safe under Xcode; does not touch stdout).
    @objc public func appendLog(_ line: String) {
        let chunk = line.hasSuffix("\n") ? line : line + "\n"
        append(chunk)
    }

    /// Redirect stdout/stderr into the buffer. No-op under the Xcode debugger.
    @objc public func install() {
        lock.lock()
        defer { lock.unlock() }
        guard !isPipeInstalled else { return }
        guard !Self.isXcodeDebugSession else { return }
        isPipeInstalled = true

        originalStdout = dup(fileno(stdout))
        originalStderr = dup(fileno(stderr))

        let outPipe = Pipe()
        let errPipe = Pipe()

        setvbuf(stdout, nil, _IONBF, 0)
        setvbuf(stderr, nil, _IONBF, 0)

        dup2(outPipe.fileHandleForWriting.fileDescriptor, fileno(stdout))
        dup2(errPipe.fileHandleForWriting.fileDescriptor, fileno(stderr))

        let originalOut = originalStdout
        let originalErr = originalStderr

        outPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            data.withUnsafeBytes { _ = write(originalOut, $0.baseAddress, data.count) }
            self?.queue.async {
                if let s = String(data: data, encoding: .utf8) { self?.append(s) }
            }
        }
        errPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            data.withUnsafeBytes { _ = write(originalErr, $0.baseAddress, data.count) }
            self?.queue.async {
                if let s = String(data: data, encoding: .utf8) { self?.append(s) }
            }
        }
    }

    @objc public func snapshot() -> String {
        lock.lock()
        defer { lock.unlock() }
        return buffer
    }

    @objc public func clear() {
        lock.lock()
        defer { lock.unlock() }
        buffer.removeAll(keepingCapacity: false)
    }

    private func append(_ chunk: String) {
        guard !chunk.isEmpty else { return }
        lock.lock()
        if isPaused {
            lock.unlock()
            return
        }
        if buffer.count + chunk.count > maxChars {
            let keep = max(maxChars / 2, 10_000)
            if buffer.count > keep {
                buffer.removeFirst(buffer.count - keep)
            }
        }
        buffer.append(chunk)
        lock.unlock()

        NotificationCenter.default.post(
            name: AppLogStream.didAppendNotification,
            object: self,
            userInfo: ["chunk": chunk]
        )
    }
}
