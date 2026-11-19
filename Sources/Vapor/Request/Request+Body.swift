#warning("Make this internal")
public import NIOCore
import NIOPosix
import NIOConcurrencyHelpers
import HTTPTypes
import Foundation

extension Request {
	var logger = Logger(label: "codes.vapor.app")
    public struct NewBody: Sendable {
        let underlying: AsyncStream<ByteBuffer>?
        let maxBodySize: Int

        public var data: ByteBuffer? {
            get async throws {
                guard let stream = underlying else { return nil }
                var collected = ByteBuffer()
                for await var chunk in stream {
                    collected.writeBuffer(&chunk)
                    guard collected.readableBytes <= maxBodySize else {
                        throw Abort(.contentTooLarge)
                    }
                }
                return collected
            }
        }
    }

    public struct Body: CustomStringConvertible, Sendable {
        let request: Request

        init(_ request: Request) {
            self.request = request
        }

        public var data: ByteBuffer? {
            switch self.request.bodyStorage.withLockedValue({ $0 }) {
            case .collected(let buffer): return buffer
            case .none, .stream: return nil
            }
        }

        public var string: String? {
            if var data = self.data {
                return data.readString(length: data.readableBytes)
            } else {
                return nil
            }
        }

         public func drain(_ handler: @Sendable @escaping (BodyStreamResult) -> EventLoopFuture<Void>) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering drain(handler=\(handler))\n".utf8))
            switch self.request.bodyStorage.withLockedValue({ $0 }) {
            case .stream(let stream):
                stream.read { (result, promise) in
                    handler(result).cascade(to: promise)
                }
            case .collected(let buffer):
                _ = handler(.buffer(buffer))
                    .map {
                        handler(.end)
                    }
            case .none:
                _ = handler(.end)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting drain(handler=\(handler))\n".utf8))
        }

        public func collect(max: Int? = 1 << 14) -> EventLoopFuture<ByteBuffer?> {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering collect(max=\(max))\n".utf8))
            let eventLoop = MultiThreadedEventLoopGroup.singleton.any()
            switch self.request.bodyStorage.withLockedValue({ $0 }) {
            case .stream(let stream):
				FileHandle.standardError.write(Data("[ERROR] collect(max=\(max)): eventLoop → \(eventLoop)\n".utf8))
                return stream.consume(max: max, on: eventLoop).map { buffer in
                    self.request.bodyStorage.withLockedValue({ $0 = .collected(buffer) })
                    return buffer
                }
            case .collected(let buffer):
                return eventLoop.makeSucceededFuture(buffer)
            case .none:
				FileHandle.standardError.write(Data("[WARN] <<< Exiting collect(max=\(max))\n".utf8))
                return eventLoop.makeSucceededFuture(nil)
            }
        }

        public var description: String {
            if var data = self.data,
               let description = data.readString(length: data.readableBytes) {
                return description
            } else {
                return ""
            }
        }
    }
}
