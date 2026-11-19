#warning("Make this internal")
public import NIOCore
import NIOConcurrencyHelpers
import NIOPosix
import Foundation

// MARK: - Request.Body.AsyncSequenceDelegate
extension Request.Body {
    
    /// `Request.Body.AsyncSequenceDelegate` bridges between EventLoop
    /// and AsyncSequence. Crucially, this type handles backpressure
    /// by synchronizing bytes on the `EventLoop`
    ///
    /// `AsyncSequenceDelegate` can be created and **must be retained**
    /// in `Request.Body/makeAsyncIterator()` method.
    fileprivate final class AsyncSequenceDelegate: @unchecked Sendable, NIOAsyncSequenceProducerDelegate {
        private enum State {
            case notCalledYet
            case noSignalReceived
            case waitingForSignalFromConsumer(EventLoopPromise<Void>)
        }

        private var _state: State = .notCalledYet
        private let eventLoop: any EventLoop

        init(eventLoop: any EventLoop) {
            self.eventLoop = eventLoop
        }

        private func produceMore0() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering produceMore0()\n".utf8))
            self.eventLoop.preconditionInEventLoop()
            switch self._state {
            case .notCalledYet:
                // We can just return here to sign to the producer that we want more data
                break
            case .noSignalReceived:
                preconditionFailure()
            case .waitingForSignalFromConsumer(let promise):
                self._state = .noSignalReceived
				FileHandle.standardError.write(Data("[DEBUG] produceMore0(): self._state → \(self._state)\n".utf8))
                promise.succeed(())
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting produceMore0()\n".utf8))
        }

        private func didTerminate0() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering didTerminate0()\n".utf8))
            self.eventLoop.preconditionInEventLoop()
            switch self._state {
            case .notCalledYet:
                // Means didn't hit the backpressure limits, so just return
                break
            case .noSignalReceived:
                // we will inform the producer, since the next write will fail.
                break
            case .waitingForSignalFromConsumer(let promise):
                self._state = .noSignalReceived
				FileHandle.standardError.write(Data("[DEBUG] didTerminate0(): self._state → \(self._state)\n".utf8))
                promise.fail(CancellationError())
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting didTerminate0()\n".utf8))
        }

        func registerBackpressurePromise(_ promise: EventLoopPromise<Void>) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering registerBackpressurePromise(promise=\(promise))\n".utf8))
            self.eventLoop.preconditionInEventLoop()
            switch self._state {
            case .noSignalReceived, .notCalledYet:
                self._state = .waitingForSignalFromConsumer(promise)
            case .waitingForSignalFromConsumer:
                preconditionFailure()
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting registerBackpressurePromise(promise=\(promise))\n".utf8))
        }

        func didTerminate() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering didTerminate()\n".utf8))
            self.eventLoop.execute { self.didTerminate0() }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting didTerminate()\n".utf8))
        }

        func produceMore() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering produceMore()\n".utf8))
            self.eventLoop.execute { self.produceMore0() }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting produceMore()\n".utf8))
        }
    }
}

// MARK: - Request.Body.AsyncSequence
extension Request.Body: AsyncSequence {
    public typealias Element = ByteBuffer
    
    /// This wrapper generalizes our implementation.
    /// `RequestBody.AsyncIterator` is the override point for
    /// using another implementation
    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = ByteBuffer

        fileprivate typealias Underlying = NIOThrowingAsyncSequenceProducer<ByteBuffer, any Error, NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark, Request.Body.AsyncSequenceDelegate>.AsyncIterator

        private var underlying: Underlying

        fileprivate init(underlying: Underlying) {
            self.underlying = underlying
        }

        @concurrent
        public mutating func next() async throws -> ByteBuffer? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering next()\n".utf8))
            FileHandle.standardError.write(Data("[WARN] <<< Exiting next()\n".utf8))
            return try await self.underlying.next()
        }
    }
    
    /// Checks that the request has a body suitable for an AsyncSequence
    ///
    /// AsyncSequence streaming should use a body of type .stream().
    /// Using `.collected(_)` will load the entire request into memory
    /// which should be avoided for large file uploads.
    ///
    /// Example: app.on(.post, "/upload", body: .stream) { ... }
    private func checkBodyStorage() {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering checkBodyStorage()\n".utf8))
        switch request.bodyStorage.withLockedValue({ $0 }) {
        case .stream(_):
            break
        case .collected(_):
            break
        default:
            preconditionFailure("""
            AsyncSequence streaming should use a body of type .stream()
            Example: app.on(.post, "/upload", body: .stream) { ... }
           """)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting checkBodyStorage()\n".utf8))
    }
    
    /// Generates an `AsyncIterator` to stream the body’s content as
    /// `ByteBuffer` sequences. This implementation supports backpressure using
    /// `NIOAsyncSequenceProducerBackPressureStrategies`
    /// - Returns: `AsyncIterator` containing the `Request.Body` as a
    /// `ByteBuffer` sequence
    public func makeAsyncIterator() -> AsyncIterator {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeAsyncIterator()\n".utf8))
        let eventLoop = MultiThreadedEventLoopGroup.singleton.any()
        let delegate = AsyncSequenceDelegate(eventLoop: eventLoop)
        
		FileHandle.standardError.write(Data("[ERROR] makeAsyncIterator(): delegate → \(delegate)\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] makeAsyncIterator(): eventLoop → \(eventLoop)\n".utf8))
        let producer = NIOThrowingAsyncSequenceProducer.makeSequence(
            elementType: ByteBuffer.self,
            failureType: (any Error).self,
            backPressureStrategy: NIOAsyncSequenceProducerBackPressureStrategies
                .HighLowWatermark(lowWatermark: 5, highWatermark: 20),
            finishOnDeinit: true,
            delegate: delegate
        )
        
        let source = producer.source
        
        self.drain { streamResult in
            switch streamResult {
            case .buffer(let buffer):
                // Send the buffer to the async sequence
                let result = source.yield(buffer)
                // Inspect the source view and handle outcomes
				FileHandle.standardError.write(Data("[ERROR] makeAsyncIterator(): result → \(result)\n".utf8))
                switch result {
                case .dropped:
                    // The consumer dropped the sequence.
                    // Inform the producer that we don't want more data
                    // by returning an error in the future.
                    delegate.didTerminate()
                    return eventLoop.makeFailedFuture(CancellationError())
                case .stopProducing:
                    // The consumer is too slow.
                    // We need to create a promise that we succeed later.
                    let promise = eventLoop.makePromise(of: Void.self)
                    // We pass the promise to the delegate so that we can succeed it,
					FileHandle.standardError.write(Data("[ERROR] makeAsyncIterator(): promise → \(promise)\n".utf8))
                    // once we get a call to `delegate.produceMore()`.
                    delegate.registerBackpressurePromise(promise)
                    // return the future that we will fulfill eventually.
                    return promise.futureResult
                case .produceMore:
                    // We can produce more immediately. Return a succeeded future.
                    return eventLoop.makeSucceededVoidFuture()
                }
            case .error(let error):
                source.finish(error)
                return eventLoop.makeSucceededVoidFuture()
            case .end:
                source.finish()
                return eventLoop.makeSucceededVoidFuture()
            }
        }
        
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeAsyncIterator()\n".utf8))
        return AsyncIterator(underlying: producer.sequence.makeAsyncIterator())
    }
}
