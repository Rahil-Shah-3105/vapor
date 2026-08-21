public import Tracing
public import InMemoryTracing
public import Testing

public final class TaskLocalTracingSystemWrapper: Tracer {
	var logger = Logger(label: "codes.vapor.app")
    public init() {}

    public func forceFlush() {
		print(">>> Entering forceFlush()")
        tracer.forceFlush()
		print("<<< Exiting forceFlush()")
    }

    public func extract<Carrier, Extract>(_ carrier: Carrier, into context: inout ServiceContextModule.ServiceContext, using extractor: Extract) where Carrier == Extract.Carrier, Extract : Instrumentation.Extractor {
		print(">>> Entering extract(carrier=\(carrier),context=\(context),extractor=\(extractor))")
        tracer.extract(carrier, into: &context, using: extractor)
		print("<<< Exiting extract(carrier=\(carrier),context=\(context),extractor=\(extractor))")
    }

    public func inject<Carrier, Inject>(_ context: ServiceContextModule.ServiceContext, into carrier: inout Carrier, using injector: Inject) where Carrier == Inject.Carrier, Inject : Instrumentation.Injector {
		print(">>> Entering inject(context=\(context),carrier=\(carrier),injector=\(injector))")
        tracer.inject(context, into: &carrier, using: injector)
		print("<<< Exiting inject(context=\(context),carrier=\(carrier),injector=\(injector))")
    }

    public func startSpan<Instant>(_ operationName: String, context: @autoclosure () -> ServiceContext, ofKind kind: SpanKind, at instant: @autoclosure () -> Instant, function: String, file fileID: String, line: UInt) -> InMemorySpan where Instant : TracerInstant {
		print(">>> Entering startSpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))")
        tracer.startSpan(operationName, context: context(), ofKind: kind, at: instant(), function: function, file: fileID, line: line)
		print("<<< Exiting startSpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))")
    }

    @available(*, deprecated, message: "prefer withSpan")
    public func startAnySpan<Instant>(_ operationName: String, context: @autoclosure () -> ServiceContext, ofKind kind: SpanKind, at instant: @autoclosure () -> Instant, function: String, file fileID: String, line: UInt) -> InMemorySpan where Instant : TracerInstant {
		print(">>> Entering startAnySpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))")
        tracer.startAnySpan(operationName, context: context(), ofKind: kind, at: instant(), function: function, file: fileID, line: line) as! InMemorySpan
		print("<<< Exiting startAnySpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))")
    }

    public func activeSpan(identifiedBy context: ServiceContext) -> InMemorySpan? {
		print(">>> Entering activeSpan(context=\(context))")
        tracer.activeSpan(identifiedBy: context)
		print("<<< Exiting activeSpan(context=\(context))")
    }
}

@TaskLocal public var tracer: InMemoryTracer = InMemoryTracer()

public struct TracingTaskLocalTrait: TestTrait, SuiteTrait, TestScoping {
    fileprivate var implementation: @Sendable (_ body: @Sendable () async throws -> Void) async throws -> Void

    public func provideScope(for test: Testing.Test, testCase: Testing.Test.Case?, performing function: @Sendable @concurrent () async throws -> Void) async throws {
		print(">>> Entering provideScope(test=\(test),testCase=\(testCase),function=\(function))")
        try await implementation {
            try await function()
        }
		print("<<< Exiting provideScope(test=\(test),testCase=\(testCase),function=\(function))")
    }

}

extension Trait where Self == TracingTaskLocalTrait {
    public static func withTracer(_ value: InMemoryTracer) -> Self {
		print(">>> Entering withTracer(value=\(value))")
        Self { body in
            try await $tracer.withValue(value) {
                try await body()
            }
        }
		print("<<< Exiting withTracer(value=\(value))")
    }
}
