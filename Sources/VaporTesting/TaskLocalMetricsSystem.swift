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
		print(">>> Entering makeCounter(label=\(label),dimensions=\(dimensions))")
        metrics.makeCounter(label: label, dimensions: dimensions)
		print("<<< Exiting makeCounter(label=\(label),dimensions=\(dimensions))")
    }

    public func makeFloatingPointCounter(label: String, dimensions: [(String, String)]) -> any CoreMetrics.FloatingPointCounterHandler {
		print(">>> Entering makeFloatingPointCounter(label=\(label),dimensions=\(dimensions))")
        metrics.makeFloatingPointCounter(label: label, dimensions: dimensions)
		print("<<< Exiting makeFloatingPointCounter(label=\(label),dimensions=\(dimensions))")
    }

    public func makeMeter(label: String, dimensions: [(String, String)]) -> any CoreMetrics.MeterHandler {
		print(">>> Entering makeMeter(label=\(label),dimensions=\(dimensions))")
        metrics.makeMeter(label: label, dimensions: dimensions)
		print("<<< Exiting makeMeter(label=\(label),dimensions=\(dimensions))")
    }

    public func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool) -> any CoreMetrics.RecorderHandler {
		print(">>> Entering makeRecorder(label=\(label),dimensions=\(dimensions),aggregate=\(aggregate))")
        metrics.makeRecorder(label: label, dimensions: dimensions, aggregate: aggregate)
		print("<<< Exiting makeRecorder(label=\(label),dimensions=\(dimensions),aggregate=\(aggregate))")
    }

    public func makeTimer(label: String, dimensions: [(String, String)]) -> any CoreMetrics.TimerHandler {
		print(">>> Entering makeTimer(label=\(label),dimensions=\(dimensions))")
        metrics.makeTimer(label: label, dimensions: dimensions)
		print("<<< Exiting makeTimer(label=\(label),dimensions=\(dimensions))")
    }

    public func destroyCounter(_ handler: any CoreMetrics.CounterHandler) {
		print(">>> Entering destroyCounter(handler=\(handler))")
        metrics.destroyCounter(handler)
		print("<<< Exiting destroyCounter(handler=\(handler))")
    }

    public func destroyFloatingPointCounter(_ handler: any CoreMetrics.FloatingPointCounterHandler) {
		print(">>> Entering destroyFloatingPointCounter(handler=\(handler))")
        metrics.destroyFloatingPointCounter(handler)
		print("<<< Exiting destroyFloatingPointCounter(handler=\(handler))")
    }

    public func destroyMeter(_ handler: any CoreMetrics.MeterHandler) {
		print(">>> Entering destroyMeter(handler=\(handler))")
        metrics.destroyMeter(handler)
		print("<<< Exiting destroyMeter(handler=\(handler))")
    }

    public func destroyRecorder(_ handler: any CoreMetrics.RecorderHandler) {
		print(">>> Entering destroyRecorder(handler=\(handler))")
        metrics.destroyRecorder(handler)
		print("<<< Exiting destroyRecorder(handler=\(handler))")
    }

    public func destroyTimer(_ handler: any CoreMetrics.TimerHandler) {
		print(">>> Entering destroyTimer(handler=\(handler))")
        metrics.destroyTimer(handler)
		print("<<< Exiting destroyTimer(handler=\(handler))")
    }
}

@TaskLocal public var metrics: TestMetrics = TestMetrics()

public struct MetricsTaskLocalTrait: TestTrait, SuiteTrait, TestScoping {
    fileprivate var implementation: @Sendable (_ body: @Sendable () async throws -> Void) async throws -> Void

    public func provideScope(for test: Testing.Test, testCase: Testing.Test.Case?, performing function: @Sendable @concurrent () async throws -> Void) async throws {
		print(">>> Entering provideScope(test=\(test),testCase=\(testCase),function=\(function))")
        try await implementation {
            try await function()
        }
		print("<<< Exiting provideScope(test=\(test),testCase=\(testCase),function=\(function))")
    }

}

extension Trait where Self == MetricsTaskLocalTrait {
    public static func withMetrics(_ value: TestMetrics) -> Self {
		print(">>> Entering withMetrics(value=\(value))")
        Self { body in
            try await $metrics.withValue(value) {
                try await body()
            }
        }
		print("<<< Exiting withMetrics(value=\(value))")
    }
}
