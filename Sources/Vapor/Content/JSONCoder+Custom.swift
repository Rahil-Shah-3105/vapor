#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

extension JSONEncoder {
	var logger = Logger(label: "codes.vapor.app")
    /// Convenience for creating a customized ``Foundation/JSONEncoder``.
    ///
    ///     let encoder: JSONEncoder = .custom(dates: .millisecondsSince1970)
    ///
    /// - Parameters:
    ///   - dates: Date encoding strategy.
    ///   - data: Data encoding strategy.
    ///   - keys: Key encoding strategy.
    ///   - format: Output formatting.
    ///   - floats: Non-conforming float encoding strategy.
    ///   - userInfo: Coder userInfo.
    /// - Returns: Newly created ``Foundation/JSONEncoder``.
    public static func custom(
        dates dateStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        data dataStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keys keyStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        format outputFormatting: JSONEncoder.OutputFormatting? = nil,
        floats floatStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil,
        userInfo: [CodingUserInfoKey: any Sendable]? = nil
    ) -> JSONEncoder {
		print(">>> Entering custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo))")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json → \(json)")
        let json = JSONEncoder()
        if let dateStrategy = dateStrategy {
            json.dateEncodingStrategy = dateStrategy
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dateEncodingStrategy → \(json.dateEncodingStrategy)")
        }
        if let dataStrategy = dataStrategy {
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): dataStrategy → \(dataStrategy)")
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dataEncodingStrategy → \(json.dataEncodingStrategy)")
            json.dataEncodingStrategy = dataStrategy
        }
         if let keyStrategy = keyStrategy {
             json.keyEncodingStrategy = keyStrategy
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.keyEncodingStrategy → \(json.keyEncodingStrategy)")
         }
        if let outputFormatting = outputFormatting {
            json.outputFormatting = outputFormatting
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.outputFormatting → \(json.outputFormatting)")
        }
        if let floatStrategy = floatStrategy {
            json.nonConformingFloatEncodingStrategy = floatStrategy
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.nonConformingFloatEncodingStrategy → \(json.nonConformingFloatEncodingStrategy)")
        }
        if let userInfo = userInfo {
            json.userInfo = userInfo
			print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.userInfo → \(json.userInfo)")
        }
		print("<<< Exiting custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo))")
        return json
		print(">>> Entering custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo))")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json → \(json)")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dateDecodingStrategy → \(json.dateDecodingStrategy)")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): dataStrategy → \(dataStrategy)")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dataDecodingStrategy → \(json.dataDecodingStrategy)")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.keyDecodingStrategy → \(json.keyDecodingStrategy)")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.nonConformingFloatDecodingStrategy → \(json.nonConformingFloatDecodingStrategy)")
		print("custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.userInfo → \(json.userInfo)")
		print("<<< Exiting custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo))")
    }
}

extension JSONDecoder {
    /// Convenience for creating a customized ``Foundation/JSONDecoder``.
    ///
    ///     let decoder: JSONDecoder = .custom(dates: .millisecondsSince1970)
    ///
    /// - Parameters:
    ///   - dates: Date decoding strategy.
    ///   - data: Data decoding strategy.
    ///   - keys: Key decoding strategy.
    ///   - floats: Non-conforming float decoding strategy.
    ///   - userInfo: Coder userInfo.
    /// - Returns: Newly created ``JSONDecoder``.
    public static func custom(
        dates dateStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        data dataStrategy: JSONDecoder.DataDecodingStrategy? = nil,
        keys keyStrategy: JSONDecoder.KeyDecodingStrategy? = nil,
        floats floatStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil,
        userInfo: [CodingUserInfoKey: any Sendable]? = nil
    ) -> JSONDecoder {
        let json = JSONDecoder()
        if let dateStrategy = dateStrategy {
            json.dateDecodingStrategy = dateStrategy
        }
        if let dataStrategy = dataStrategy {
            json.dataDecodingStrategy = dataStrategy
        }
         if let keyStrategy = keyStrategy {
             json.keyDecodingStrategy = keyStrategy
         }
        if let floatStrategy = floatStrategy {
            json.nonConformingFloatDecodingStrategy = floatStrategy
        }
        if let userInfo = userInfo {
            json.userInfo = userInfo
        }
        return json
    }
}
