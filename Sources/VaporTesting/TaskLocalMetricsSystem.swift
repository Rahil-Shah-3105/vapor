public import Metrics
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import NIOConcurrencyHelpers
public import MetricsTestKit
public import Testing

public final class TaskLocalMetricsSystemWrapper: MetricsFactory {
	var logger = Logger(label: "codes.vapor.app")
    public init() {}

    public func makeCounter(label: String, dimensions: [(String, String)]) -> any CoreMetrics.CounterHandler {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeCounter(label=\(label),dimensions=\(dimensions))\n".utf8))
        metrics.makeCounter(label: label, dimensions: dimensions)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeCounter(label=\(label),dimensions=\(dimensions))\n".utf8))
    }

    public func makeFloatingPointCounter(label: String, dimensions: [(String, String)]) -> any CoreMetrics.FloatingPointCounterHandler {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeFloatingPointCounter(label=\(label),dimensions=\(dimensions))\n".utf8))
        metrics.makeFloatingPointCounter(label: label, dimensions: dimensions)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeFloatingPointCounter(label=\(label),dimensions=\(dimensions))\n".utf8))
    }

    public func makeMeter(label: String, dimensions: [(String, String)]) -> any CoreMetrics.MeterHandler {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeMeter(label=\(label),dimensions=\(dimensions))\n".utf8))
        metrics.makeMeter(label: label, dimensions: dimensions)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeMeter(label=\(label),dimensions=\(dimensions))\n".utf8))
    }

    public func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool) -> any CoreMetrics.RecorderHandler {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeRecorder(label=\(label),dimensions=\(dimensions),aggregate=\(aggregate))\n".utf8))
        metrics.makeRecorder(label: label, dimensions: dimensions, aggregate: aggregate)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeRecorder(label=\(label),dimensions=\(dimensions),aggregate=\(aggregate))\n".utf8))
    }

    public func makeTimer(label: String, dimensions: [(String, String)]) -> any CoreMetrics.TimerHandler {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeTimer(label=\(label),dimensions=\(dimensions))\n".utf8))
        metrics.makeTimer(label: label, dimensions: dimensions)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeTimer(label=\(label),dimensions=\(dimensions))\n".utf8))
    }

    public func destroyCounter(_ handler: any CoreMetrics.CounterHandler) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering destroyCounter(handler=\(handler))\n".utf8))
        metrics.destroyCounter(handler)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting destroyCounter(handler=\(handler))\n".utf8))
    }

    public func destroyFloatingPointCounter(_ handler: any CoreMetrics.FloatingPointCounterHandler) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering destroyFloatingPointCounter(handler=\(handler))\n".utf8))
        metrics.destroyFloatingPointCounter(handler)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting destroyFloatingPointCounter(handler=\(handler))\n".utf8))
    }

    public func destroyMeter(_ handler: any CoreMetrics.MeterHandler) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering destroyMeter(handler=\(handler))\n".utf8))
        metrics.destroyMeter(handler)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting destroyMeter(handler=\(handler))\n".utf8))
    }

    public func destroyRecorder(_ handler: any CoreMetrics.RecorderHandler) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering destroyRecorder(handler=\(handler))\n".utf8))
        metrics.destroyRecorder(handler)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting destroyRecorder(handler=\(handler))\n".utf8))
    }

    public func destroyTimer(_ handler: any CoreMetrics.TimerHandler) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering destroyTimer(handler=\(handler))\n".utf8))
        metrics.destroyTimer(handler)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting destroyTimer(handler=\(handler))\n".utf8))
    }
}

@TaskLocal public var metrics: TestMetrics = TestMetrics()

public struct MetricsTaskLocalTrait: TestTrait, SuiteTrait, TestScoping {
    fileprivate var implementation: @Sendable (_ body: @Sendable () async throws -> Void) async throws -> Void

    public func provideScope(for test: Testing.Test, testCase: Testing.Test.Case?, performing function: @Sendable @concurrent () async throws -> Void) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering provideScope(test=\(test),testCase=\(testCase),function=\(function))\n".utf8))
        try await implementation {
            try await function()
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting provideScope(test=\(test),testCase=\(testCase),function=\(function))\n".utf8))
    }

}

extension Trait where Self == MetricsTaskLocalTrait {
    public static func withMetrics(_ value: TestMetrics) -> Self {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering withMetrics(value=\(value))\n".utf8))
        Self { body in
            try await $metrics.withValue(value) {
                try await body()
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting withMetrics(value=\(value))\n".utf8))
    }
}
