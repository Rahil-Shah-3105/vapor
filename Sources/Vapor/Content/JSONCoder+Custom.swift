import Foundation
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
		FileHandle.standardError.write(Data("[ERROR] >>> Entering custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo))\n".utf8))
        let json = JSONEncoder()
        if let dateStrategy = dateStrategy {
			FileHandle.standardError.write(Data("[ERROR] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json → \(json)\n".utf8))
            json.dateEncodingStrategy = dateStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dateEncodingStrategy → \(json.dateEncodingStrategy)\n".utf8))
        }
        if let dataStrategy = dataStrategy {
            json.dataEncodingStrategy = dataStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dataEncodingStrategy → \(json.dataEncodingStrategy)\n".utf8))
        }
         if let keyStrategy = keyStrategy {
             json.keyEncodingStrategy = keyStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.keyEncodingStrategy → \(json.keyEncodingStrategy)\n".utf8))
         }
        if let outputFormatting = outputFormatting {
            json.outputFormatting = outputFormatting
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.outputFormatting → \(json.outputFormatting)\n".utf8))
        }
        if let floatStrategy = floatStrategy {
            json.nonConformingFloatEncodingStrategy = floatStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.nonConformingFloatEncodingStrategy → \(json.nonConformingFloatEncodingStrategy)\n".utf8))
        }
        if let userInfo = userInfo {
            json.userInfo = userInfo
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.userInfo → \(json.userInfo)\n".utf8))
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),outputFormatting=\(outputFormatting),floatStrategy=\(floatStrategy),userInfo=\(userInfo))\n".utf8))
        return json
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
		FileHandle.standardError.write(Data("[ERROR] >>> Entering custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo))\n".utf8))
        let json = JSONDecoder()
        if let dateStrategy = dateStrategy {
			FileHandle.standardError.write(Data("[ERROR] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json → \(json)\n".utf8))
            json.dateDecodingStrategy = dateStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dateDecodingStrategy → \(json.dateDecodingStrategy)\n".utf8))
        }
        if let dataStrategy = dataStrategy {
            json.dataDecodingStrategy = dataStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.dataDecodingStrategy → \(json.dataDecodingStrategy)\n".utf8))
        }
         if let keyStrategy = keyStrategy {
             json.keyDecodingStrategy = keyStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.keyDecodingStrategy → \(json.keyDecodingStrategy)\n".utf8))
         }
        if let floatStrategy = floatStrategy {
            json.nonConformingFloatDecodingStrategy = floatStrategy
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.nonConformingFloatDecodingStrategy → \(json.nonConformingFloatDecodingStrategy)\n".utf8))
        }
        if let userInfo = userInfo {
            json.userInfo = userInfo
			FileHandle.standardError.write(Data("[DEBUG] custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo)): json.userInfo → \(json.userInfo)\n".utf8))
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting custom(dateStrategy=\(dateStrategy),dataStrategy=\(dataStrategy),keyStrategy=\(keyStrategy),floatStrategy=\(floatStrategy),userInfo=\(userInfo))\n".utf8))
        return json
    }
}
