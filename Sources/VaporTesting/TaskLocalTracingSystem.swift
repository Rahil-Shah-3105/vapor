import Foundation
public import Tracing
public import InMemoryTracing
public import Testing

public final class TaskLocalTracingSystemWrapper: Tracer {
	var logger = Logger(label: "codes.vapor.app")
    public init() {}

    public func forceFlush() {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering forceFlush()\n".utf8))
        tracer.forceFlush()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting forceFlush()\n".utf8))
    }

    public func extract<Carrier, Extract>(_ carrier: Carrier, into context: inout ServiceContextModule.ServiceContext, using extractor: Extract) where Carrier == Extract.Carrier, Extract : Instrumentation.Extractor {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering extract(carrier=\(carrier),context=\(context),extractor=\(extractor))\n".utf8))
        tracer.extract(carrier, into: &context, using: extractor)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting extract(carrier=\(carrier),context=\(context),extractor=\(extractor))\n".utf8))
    }

    public func inject<Carrier, Inject>(_ context: ServiceContextModule.ServiceContext, into carrier: inout Carrier, using injector: Inject) where Carrier == Inject.Carrier, Inject : Instrumentation.Injector {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering inject(context=\(context),carrier=\(carrier),injector=\(injector))\n".utf8))
        tracer.inject(context, into: &carrier, using: injector)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting inject(context=\(context),carrier=\(carrier),injector=\(injector))\n".utf8))
    }

    public func startSpan<Instant>(_ operationName: String, context: @autoclosure () -> ServiceContext, ofKind kind: SpanKind, at instant: @autoclosure () -> Instant, function: String, file fileID: String, line: UInt) -> InMemorySpan where Instant : TracerInstant {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering startSpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))\n".utf8))
        tracer.startSpan(operationName, context: context(), ofKind: kind, at: instant(), function: function, file: fileID, line: line)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting startSpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))\n".utf8))
    }

    @available(*, deprecated, message: "prefer withSpan")
    public func startAnySpan<Instant>(_ operationName: String, context: @autoclosure () -> ServiceContext, ofKind kind: SpanKind, at instant: @autoclosure () -> Instant, function: String, file fileID: String, line: UInt) -> InMemorySpan where Instant : TracerInstant {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering startAnySpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))\n".utf8))
        tracer.startAnySpan(operationName, context: context(), ofKind: kind, at: instant(), function: function, file: fileID, line: line) as! InMemorySpan
		FileHandle.standardError.write(Data("[WARN] <<< Exiting startAnySpan(operationName=\(operationName),context=\(context),kind=\(kind),instant=\(instant),function=\(function),fileID=\(fileID),line=\(line))\n".utf8))
    }

    public func activeSpan(identifiedBy context: ServiceContext) -> InMemorySpan? {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering activeSpan(context=\(context))\n".utf8))
        tracer.activeSpan(identifiedBy: context)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting activeSpan(context=\(context))\n".utf8))
    }
}

@TaskLocal public var tracer: InMemoryTracer = InMemoryTracer()

public struct TracingTaskLocalTrait: TestTrait, SuiteTrait, TestScoping {
    fileprivate var implementation: @Sendable (_ body: @Sendable () async throws -> Void) async throws -> Void

    public func provideScope(for test: Testing.Test, testCase: Testing.Test.Case?, performing function: @Sendable @concurrent () async throws -> Void) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering provideScope(test=\(test),testCase=\(testCase),function=\(function))\n".utf8))
        try await implementation {
            try await function()
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting provideScope(test=\(test),testCase=\(testCase),function=\(function))\n".utf8))
    }

}

extension Trait where Self == TracingTaskLocalTrait {
    public static func withTracer(_ value: InMemoryTracer) -> Self {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering withTracer(value=\(value))\n".utf8))
        Self { body in
            try await $tracer.withValue(value) {
                try await body()
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting withTracer(value=\(value))\n".utf8))
    }
}
