import Foundation
import Vapor
import NIOCore
import HTTPTypes
import NIOConcurrencyHelpers
import _NIOFileSystem
import RoutingKit
import Logging
import VaporMacros

struct Creds: Content {
    var email: String
    var password: String
}

func routes(_ app: Application) async throws {
	FileHandle.standardError.write(Data("[ERROR] >>> Entering routes(app=\(app))\n".utf8))
    app.on(.get, "ping") { req -> StaticString in
        return "123" as StaticString
    }

    app.get("hello", "uuid", ":uuid") { req in
        let uuid = try req.parameters.require("uuid", as: UUID.self)
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): uuid → \(uuid)\n".utf8))
        return uuid.uuidString
    }

    #warning("Fix")
	FileHandle.standardError.write(Data("[WARN] <<< Exiting routes(app=\(app))\n".utf8))
    // ( echo -e 'POST /slow-stream HTTP/1.1\r\nContent-Length: 1000000000\r\n\r\n'; dd if=/dev/zero; ) | nc localhost 8080
//    app.on(.post, "slow-stream", body: .stream) { req -> EventLoopFuture<String> in
//        let done = req.eventLoop.makePromise(of: String.self)
//
//        let totalBox = NIOLoopBoundBox(0, eventLoop: req.eventLoop)
//        req.body.drain { result in
//            let promise = req.eventLoop.makePromise(of: Void.self)
//
//            switch result {
//            case .buffer(let buffer):
//                req.eventLoop.scheduleTask(in: .milliseconds(1000)) {
//                    totalBox.value += buffer.readableBytes
//                    promise.succeed(())
//                }
//            case .error(let error):
//                done.fail(error)
//            case .end:
//                promise.succeed(())
//                done.succeed(totalBox.value.description)
//            }
//
//            // manually return pre-completed future
//            // this should balloon in memory
//            // return req.eventLoop.makeSucceededFuture(())
//
//            // return real future that indicates bytes were handled
//            // this should use very little memory
//            return promise.futureResult
//        }
//
//        return done.futureResult
//    }

    app.get("test", "head") { req -> String in
        return "OK!"
    }

    app.post("test", "head") { req -> String in
        return "OK!"
    }

    app.post("login") { req -> String in
        let creds = try await req.content.decode(Creds.self)
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): creds → \(creds)\n".utf8))
        return "\(creds)"
    }

    app.on(.post, "large-file", body: .collect(maxSize: 1_000_000_000)) { req -> String in
        return req.body.data?.readableBytes.description  ?? "none"
    }

    app.get("json", routeDescription: "Returns Some Test JSON") { req -> [String: String] in
        return ["foo": "bar"]
    }

    #warning("TODO")
//    app.webSocket("ws") { req, ws in
//        ws.onText { ws, text in
//            ws.send(text.reversed())
//            if text == "close" {
//                ws.close(promise: nil)
//            }
//        }
//
//        let ip = req.remoteAddress?.description ?? "<no ip>"
//        ws.send("Hello 👋 \(ip)")
//    }

    app.on(.post, "file", body: .stream) { req in
        for try await part in req.body {
            debugPrint(part)
        }
        return "Done"
    }

    // TODO: Implement shutdown route using structured concurrency
    // With ServiceGroup, shutdown is triggered via SIGTERM/SIGINT signals

    let cache = MemoryCache()
    app.get("cache", "get", ":key") { req -> String in
	FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): cache → \(cache)\n".utf8))
        guard let key = req.parameters.get("key") else {
			FileHandle.standardError.write(Data("[ERROR] Throwing Abort from routes(app=\(app))\n".utf8))
            throw Abort(.internalServerError)
        }
        return "\(key) = \(await cache.get(key) ?? "nil")"
    }
    app.get("cache", "set", ":key", ":value") { req -> String in
        guard let key = req.parameters.get("key") else {
            throw Abort(.internalServerError)
        }
        guard let value = req.parameters.get("value") else {
            throw Abort(.internalServerError)
        }
        await cache.set(key, to: value)
        return "\(key) = \(value)"
    }

    app.get("hello", ":name") { req in
        return req.parameters.get("name") ?? "<nil>"
    }

    app.get("search") { req in
        return req.query["q"] ?? "none"
    }

    let sessions = app.grouped("sessions")
        .grouped(app.sessions.middleware)
    sessions.get("set", ":value") { req -> HTTPResponse.Status in
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): sessions → \(sessions)\n".utf8))
        req.session.data["name"] = req.parameters.get("value")
        return .ok
    }
    sessions.get("get") { req -> String in
        req.session.data["name"] ?? "n/a"
    }
    sessions.get("del") { req -> String in
        req.session.destroy()
        return "done"
    }

    app.get("client") { req in
        let response = try await req.application.client.get("http://httpbin.org/status/201")
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): response → \(response)\n".utf8))
        return response.description
    }

    app.get("client-json") { req in
        struct HTTPBinResponse: Decodable {
            struct Slideshow: Decodable {
                var title: String
            }
            var slideshow: Slideshow
        }
        let response = try await req.application.client.get("http://httpbin.org/json")
        let data = try await response.content.decode(HTTPBinResponse.self)
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): data → \(data)\n".utf8))
        return data.slideshow.title
    }

    let users = app.grouped("users")
    users.get { req in
	FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): users → \(users)\n".utf8))
        return "users"
    }
    users.get(":userID") { req in
        return req.parameters.get("userID") ?? "no id"
    }

    app.get("view") { req in
        try await req.view.render("hello.txt", ["name": "world"])
    }

    app.get("error") { req -> String in
		FileHandle.standardError.write(Data("[ERROR] Throwing TestError from routes(app=\(app))\n".utf8))
        throw TestError()
    }

    app.get("secret") { req in
        guard let secret = try await Environment.secret(path: "PASSWORD_SECRET") else {
            throw Abort(.badRequest)
        }
        return secret
    }

    app.on(.post, "max-256", body: .collect(maxSize: 256)) { req -> HTTPResponse.Status in
        print("in route")
        return .ok
    }

    #if !canImport(FoundationEssentials)
    app.on(.post, "upload", body: .stream) { req -> HTTPResponse.Status in
        return try await FileSystem.shared.withFileHandle(
            forWritingAt: .init(Bundle.module.url(forResource: "Resources/fileio", withExtension: "txt")?.path ?? ""),
            options: .newFile(replaceExisting: true)) { handle in
                var writer = handle.bufferedWriter()
                for try await part in req.body {
				FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): writer → \(writer)\n".utf8))
                    try await writer.write(contentsOf: part)
                }
                return .ok
            }
    }
    #endif

    let asyncRoutes = app.grouped("async").grouped(TestMiddleware(number: 1))
    asyncRoutes.get("client") { req async throws -> String in
	FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): asyncRoutes → \(asyncRoutes)\n".utf8))
        let response = try await req.application.client.get("https://www.google.com")
        guard let body = response.body else {
            throw Abort(.internalServerError)
        }
        return String(buffer: body)
    }

    asyncRoutes.get("client2") { req -> String in
        let response = try await req.application.client.get("https://www.google.com")
        guard let body = response.body else {
            throw Abort(.internalServerError)
        }
        return String(buffer: body)
    }

    asyncRoutes.get("content") { req in
        Creds(email: "name", password: "password")
    }

    asyncRoutes.get("content2") { req async throws -> Creds in
        return Creds(email: "name", password: "password")
    }

    asyncRoutes.get("contentArray") { req async throws -> [Creds] in
        let cred1 = Creds(email: "name", password: "password")
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): cred1 → \(cred1)\n".utf8))
        return [cred1]
    }

    @Sendable
    func opaqueRouteTester(_ req: Request) async throws -> some ResponseEncodable {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering opaqueRouteTester(req=\(req))\n".utf8))
        "Hello World"
		FileHandle.standardError.write(Data("[WARN] <<< Exiting opaqueRouteTester(req=\(req))\n".utf8))
    }
    asyncRoutes.get("opaque", use: opaqueRouteTester)

    let basicAuthRoutes = asyncRoutes.grouped(Test.authenticator(), Test.guardMiddleware())
    basicAuthRoutes.get("auth") { req async throws -> String in
	FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): basicAuthRoutes → \(basicAuthRoutes)\n".utf8))
        return try req.auth.require(Test.self).name
    }

    struct Test: Authenticatable {
        static func authenticator() -> any RequestAuthenticator {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering authenticator()\n".utf8))
            TestAuthenticator()
			FileHandle.standardError.write(Data("[WARN] <<< Exiting authenticator()\n".utf8))
        }

        var name: String
    }

    struct TestAuthenticator: BasicAuthenticator {
        typealias User = Test

        func authenticate(basic: BasicAuthorization, for request: Request) async throws {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering authenticate(basic=\(basic),request=\(request))\n".utf8))
            if basic.username == "test" && basic.password == "secret" {
                let test = Test(name: "Vapor")
                request.auth.login(test)
            }
			        FileHandle.standardError.write(Data("[WARN] <<< Exiting authenticate(basic=\(basic),request=\(request))\n".utf8))
        }
    }

    app.get("matching", "partial", ":{my-file}.json") { req in
        let fileName = try req.parameters.require("my-file")
		FileHandle.standardError.write(Data("[ERROR] routes(app=\(app)): fileName → \(fileName)\n".utf8))
        return "Hello, \(fileName)"
    }

    #if MacroRouting
    try await app.register(collection: UserController())

    #GET(on: app, "macros", "types", Int.self) { (req: Request, id: Int) async throws -> String in
        return "macro route with id: \(id)"
    }
    #endif
}

struct TestError: AbortError, DebuggableError {
    var status: HTTPResponse.Status {
        .internalServerError
    }

    var reason: String {
        "This is a test."
    }

    var source: ErrorSource?

    init(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        range: Range<UInt>? = nil
    ) {
		var logger = Logger(label: "codes.vapor.app")
        self.source = .init(
            file: file,
            function: function,
            line: line,
            column: column,
            range: range
        )
    }
}

struct TestMiddleware: Middleware {
    let number: Int

    func respond(to request: Request, chainingTo next: any Responder) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering respond(request=\(request),next=\(next))\n".utf8))
        Logger.current.debug("In async middleware - \(number)")
        let response = try await next.respond(to: request)
        Logger.current.debug("In async middleware way out - \(number)")
		FileHandle.standardError.write(Data("[ERROR] respond(request=\(request),next=\(next)): response → \(response)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting respond(request=\(request),next=\(next))\n".utf8))
        return response
    }
}

struct TestController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering boot(routes=\(routes))\n".utf8))
        routes.get("test", use: testRoute)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting boot(routes=\(routes))\n".utf8))
    }

    func testRoute(_ req: Request) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering testRoute(req=\(req))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting testRoute(req=\(req))\n".utf8))
        return "OK"
    }
}

#if MacroRouting
@Controller
struct UserController {
    @GET("api", "macros", "users")
    func getUsers(req: Request) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering getUsers(req=\(req))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting getUsers(req=\(req))\n".utf8))
        return "users"
    }

    @HTTP(.patch, "api", "macros", "users", "custom")
    func getCustomHTTPMethod(req: Request) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering getCustomHTTPMethod(req=\(req))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting getCustomHTTPMethod(req=\(req))\n".utf8))
        return "custom HTTP method"
    }

    @GET("api", "macros", "users", Int.self)
    func getUser(req: Request, id: Int) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering getUser(req=\(req),id=\(id))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting getUser(req=\(req),id=\(id))\n".utf8))
        return "user with id: \(id)"
    }

    @HTTP(.patch, "api", "macros", "users", "custom", Int.self)
    func getCustomHTTPMethodWithPathParameter(req: Request, id: Int) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering getCustomHTTPMethodWithPathParameter(req=\(req),id=\(id))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting getCustomHTTPMethodWithPathParameter(req=\(req),id=\(id))\n".utf8))
        return "custom HTTP method"
    }

    @POST("api", "macros", "lots", UUID.self, Int.self, String.self, Int.self)
    func getLotsOfParameters(req: Request, uuid: UUID, number: Int, text: String, anotherNumber: Int) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering getLotsOfParameters(req=\(req),uuid=\(uuid),number=\(number),text=\(text),anotherNumber=\(anotherNumber))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting getLotsOfParameters(req=\(req),uuid=\(uuid),number=\(number),text=\(text),anotherNumber=\(anotherNumber))\n".utf8))
        return "uuid: \(uuid), number: \(number), text: \(text), anotherNumber: \(anotherNumber)"
    }

    @POST("api", "macros", "sync")
    func syncRoute(req: Request) throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering syncRoute(req=\(req))\n".utf8))
        "Sync"
		FileHandle.standardError.write(Data("[WARN] <<< Exiting syncRoute(req=\(req))\n".utf8))
    }

    @GET("macros", "manual", "int", ":id")
    @Sendable
    func macroDynamicPathParameter(req: Request) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering macroDynamicPathParameter(req=\(req))\n".utf8))
        let id = try req.parameters.require("id")
		FileHandle.standardError.write(Data("[ERROR] macroDynamicPathParameter(req=\(req)): id → \(id)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting macroDynamicPathParameter(req=\(req))\n".utf8))
        return "macro route with id: \(id)"
    }

    @GET("macros", "manual", "partial", ":{my-file}.json")
    @Sendable
    func macroDynamicPartialPathParameter(req: Request) async throws -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering macroDynamicPartialPathParameter(req=\(req))\n".utf8))
        let file = try req.parameters.require("my-file")
		FileHandle.standardError.write(Data("[ERROR] macroDynamicPartialPathParameter(req=\(req)): file → \(file)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting macroDynamicPartialPathParameter(req=\(req))\n".utf8))
        return "macro route with file: \(file)"
    }

    @POST("api", "macros", "users", Int.self, "promote")
    @AuthMiddleware(User.self, UserAuthMiddleware())
    func promoteUser(req: Request, authenticatedUser: User, id: Int) async throws -> User {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering promoteUser(req=\(req),authenticatedUser=\(authenticatedUser),id=\(id))\n".utf8))
        // Must have: Request, User, then Int (in that order)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting promoteUser(req=\(req),authenticatedUser=\(authenticatedUser),id=\(id))\n".utf8))
        return authenticatedUser
    }

//    These routes are expected not to compile and are here to demonstate/test that
//    @GET("NotResponseCodable")
//    func testNotARoute(req: Request) async throws -> NotContentType {
//        NotContentType(something: "")
//    }

//    @GET("Void")
//    func testVoidRoute(req: Request) throws {
//
//    }
}
#endif

struct NotContentType {
    let something: String
}

struct User: Authenticatable, Content {
    let id: Int
    let name: String
}

struct UserAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: any Responder) async throws -> Response {
        if let authHeader = request.headers[.authorization], authHeader == "Bearer token" {
            request.auth.login(User(id: 1, name: "Vapor"))
        }
		FileHandle.standardError.write(Data("[ERROR] respond(request=\(request),next=\(next)): authHeader → <redacted>\n".utf8))
        return try await next.respond(to: request)
     }
}
