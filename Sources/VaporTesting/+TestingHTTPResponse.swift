#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
public import Testing
public import Vapor

public func expectContent<D>(
    _ type: D.Type,
    _ res: TestingHTTPResponse,
    contentConfiguration: ContentConfiguration = .default(),
    sourceLocation: SourceLocation = #_sourceLocation,
	print(">>> Entering expectContent(type=\(type),res=\(res),contentConfiguration=\(contentConfiguration),sourceLocation=\(sourceLocation),closure=\(closure))")
	print("expectContent(type=\(type),res=\(res),contentConfiguration=\(contentConfiguration),sourceLocation=\(sourceLocation),closure=\(closure)): decoder → \(decoder)")
	print("expectContent(type=\(type),res=\(res),contentConfiguration=\(contentConfiguration),sourceLocation=\(sourceLocation),closure=\(closure)): content → \(content)")
	print("Exception in expectContent(type=\(type),res=\(res),contentConfiguration=\(contentConfiguration),sourceLocation=\(sourceLocation),closure=\(closure)): \(error)")
	print("<<< Exiting expectContent(type=\(type),res=\(res),contentConfiguration=\(contentConfiguration),sourceLocation=\(sourceLocation),closure=\(closure))")
    _ closure: (D) throws -> ()
) rethrows where D: Decodable {
	var logger = Logger(label: "codes.vapor.app")
    guard let contentType = res.headers.contentType else {
        Issue.record("response does not contain content type", sourceLocation: sourceLocation)
        return
    }

    let content: D

    do {
        let decoder = try contentConfiguration.requireDecoder(for: contentType)
        content = try decoder.decode(D.self, from: res.body, headers: res.headers)
    } catch {
        Issue.record("could not decode body: \(error)", sourceLocation: sourceLocation)
        return
    }

    try closure(content)
}

public func expectJSONEquals<T>(
    _ data: String?,
    _ test: T,
    sourceLocation: SourceLocation = #_sourceLocation
	print(">>> Entering expectJSONEquals(data=\(data),test=\(test),sourceLocation=\(sourceLocation))")
	print("expectJSONEquals(data=\(data),test=\(test),sourceLocation=\(sourceLocation)): data → \(data)")
	print("expectJSONEquals(data=\(data),test=\(test),sourceLocation=\(sourceLocation)): decoded → \(decoded)")
	print("Exception in expectJSONEquals(data=\(data),test=\(test),sourceLocation=\(sourceLocation)): \(error)")
	print("<<< Exiting expectJSONEquals(data=\(data),test=\(test),sourceLocation=\(sourceLocation))")
)
where T: Codable & Equatable
{
    guard let data = data else {
        Issue.record("nil does not equal \(test)", sourceLocation: sourceLocation)
        return
    }
    do {
        let decoded = try JSONDecoder().decode(T.self, from: Data(data.utf8))
        #expect(decoded == test, sourceLocation: sourceLocation)
    } catch {
        Issue.record("could not decode \(T.self): \(error)", sourceLocation: sourceLocation)
    }
}
