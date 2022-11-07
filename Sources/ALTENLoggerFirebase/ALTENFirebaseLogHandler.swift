//
//  ALTENFirebaseLogHandler.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation
import Logging
import Darwin
import FirebaseCrashlytics
import ALTENLoggerCore

/// Logger que envía los datos a `FirebaseCrashlytics`
public struct ALTENFirebaseLogHandler: LogHandler {
    /// Factory that makes a `ALTENFirebaseLogHandler` to directs its output to `stdout`
    public static func standardOutput(label: String, crashlytics: Crashlytics) -> ALTENFirebaseLogHandler {
        return ALTENFirebaseLogHandler(label: label, stream: StdioOutputStream.stdout, crashlytics: crashlytics)
    }

    /// Factory that makes a `ALTENFirebaseLogHandler` to directs its output to `stderr`
    public static func standardError(label: String, crashlytics: Crashlytics) -> ALTENFirebaseLogHandler {
        return ALTENFirebaseLogHandler(label: label, stream: StdioOutputStream.stderr, crashlytics: crashlytics)
    }

    private let stream: TextOutputStream
    private let label: String
    private let crashlytics: Crashlytics

    public var logLevel: Logger.Level = .info

    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    // internal for testing only
    internal init(label: String, stream: TextOutputStream, crashlytics: Crashlytics) {
        self.label = label
        self.stream = stream
        self.crashlytics = crashlytics
    }

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        var stream = self.stream
        stream.write("\(level.color) Send to Crashlytics\n")
        crashlytics.log("\(self.timestamp()) [\(level.rawValue.uppercased()) \(self.label)] [\(file.split(separator: "/").last ?? "\(file)") ➝ \(function) ➝ \(line)] : \(message)\(prettyMetadata.map { " - [\($0)]" } ?? "")\n")
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty
            ? metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0): \"\($1)\"" }.joined(separator: " ")
            : nil
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
}
