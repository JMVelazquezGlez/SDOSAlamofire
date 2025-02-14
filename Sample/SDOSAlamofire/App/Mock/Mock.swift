//
//  Mock.swift
//  SDOSAlamofireSample
//
//  Created by Antonio Jesús Pallares on 07/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

let kDefaultsJSONMalformedKey = "kDefaultsJSONMalformedKey"
let kDefaultsJSONErrorCodeResponseKey = "kDefaultsJSONErrorCodeResponseKey"

func setupServiceMock() throws {
    OHHTTPStubs.stubRequests(passingTest: { (request: URLRequest) -> Bool in
        guard
            let host = request.url?.host,
            let hostToStub = URLComponents(string: Constants.WS.wsUserURL)?.host
            else {
            return false
        }
        return hostToStub == host
    }) { _ -> OHHTTPStubsResponse in
        
        let responseData: Data
        if UserDefaults.standard.bool(forKey: kDefaultsJSONMalformedKey) {
            responseData = JSON.malformedJSONData
        } else {
            responseData = JSON.correctJSONData
        }
        
        let statusCode: Int32
        if UserDefaults.standard.bool(forKey: kDefaultsJSONErrorCodeResponseKey) {
            statusCode = 400
        } else {
            statusCode = 200
        }
        
        
        let response = OHHTTPStubsResponse(data: responseData, statusCode: statusCode, headers: nil)
        response.responseTime = TimeInterval.random(in: 0.3 ... 2)

        return response
    }
}
