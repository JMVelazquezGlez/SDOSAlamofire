//
//  SDOSJSONResponseSerializer.swift
//  SDOSAlamofire
//
//  Created by Antonio Jesús Pallares on 07/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import Alamofire

public class SDOSJSONResponseSerializer<R: Decodable, E: AbstractErrorDTO>: ResponseSerializer {
    
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>
    public let jsonResponseRootKey: String?
    public let jsonErrorRootKey: String?
    
    private lazy var responseSerializer: DecodableResponseSerializer<R> = {
        let decoder = JSONDecoder()
        return DecodableResponseSerializer<R>(decoder: decoder, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods)
    }()
    
    private lazy var responseErrorSerializer: DecodableResponseSerializer<E> = {
        let decoder = JSONDecoder()
        return DecodableResponseSerializer<E>(decoder: decoder, emptyResponseCodes: [], emptyRequestMethods: [])
    }()
    
    private lazy var decodableRootResponseSerializer: DecodableResponseSerializer<DecodableRoot<R>> = {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.jsonDecoderRootKeyName] = jsonResponseRootKey
        return DecodableResponseSerializer<DecodableRoot<R>>(decoder: decoder, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods)
    }()
    
    private lazy var decodableRootResponseErrorSerializer: DecodableResponseSerializer<DecodableRoot<E>> = {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.jsonDecoderRootKeyName] = jsonErrorRootKey
        return DecodableResponseSerializer<DecodableRoot<E>>(decoder: decoder, emptyResponseCodes: [], emptyRequestMethods: [])
    }()
    
    /// QUE APAREZCA --> "16 en 1"
    ///
    /// - Parameters:
    ///   - emptyResponseCodes: <#emptyResponseCodes description#>
    ///   - emptyRequestMethods: <#emptyRequestMethods description#>
    ///   - jsonResponseRootKey: <#jsonResponseRootKey description#>
    ///   - jsonErrorRootKey: <#jsonErrorRootKey description#>
    public init(emptyResponseCodes: Set<Int> = DecodableResponseSerializer<R>.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<R>.defaultEmptyRequestMethods,
                jsonResponseRootKey: String? = nil,
                jsonErrorRootKey: String? = nil) {
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        self.jsonResponseRootKey = jsonResponseRootKey
        self.jsonErrorRootKey = jsonErrorRootKey
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> R {
        if let error = error as? AFError.ResponseValidationFailureReason,
            case AFError.ResponseValidationFailureReason.unacceptableStatusCode(let code) = error {
            if let parsedError = try? parseError(request: request, response: response, data: data) {
                throw parsedError
            } else {
                throw SDOSAFError.badErrorResponse(code: code)
            }
        } else {
            return try parseResponse(request: request, response: response, data: data, error: error)
        }
    }
    
    internal final func parseError(request: URLRequest?, response: HTTPURLResponse?, data: Data?) throws -> E {
        if let _ = jsonErrorRootKey {
            let decodableRoot: DecodableRoot<E> = try decodableRootResponseErrorSerializer.serialize(request: request, response: response, data: data, error: nil)
            return decodableRoot.value
        } else {
            return try responseErrorSerializer.serialize(request: request, response: response, data: data, error: nil)
        }
    }
    
    internal final func parseResponse(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> R {
        if let _ = jsonResponseRootKey {
            let decodableRoot: DecodableRoot<R> = try decodableRootResponseSerializer.serialize(request: request, response: response, data: data, error: error)
            return decodableRoot.value
        } else {
            return try responseSerializer.serialize(request: request, response: response, data: data, error: error)
        }
    }
    
}
