//
//  DMMAPIError.swift
//  DmmItemSearchAction
//
//  Created by cano on 2020/01/18.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import APIKit
import SwiftyJSON

struct DMMAPIError: Error {

    // MARK: - Properties
    let domain: String
    let statusCode: StatusCode
    let responseObject: Any?
    var responseJSON: JSON? {
        guard let object = responseObject else { return nil }
        return JSON(object)
    }

    // swiftlint:disable variable_name
    var _domain: String {
        return domain
    }
    var _code: Int {
        return statusCode.rawValue
    }

    // swiftlint:enable variable_name
    // MARK: - Initialize
    init(error: Error) {
        if let error = error as? DMMAPIError {
            self.domain = error.domain
            self.statusCode = error.statusCode
            self.responseObject = error.responseObject
        } else if let error = error as? SessionTaskError {
            switch error {
            case .connectionError:
                // ネットワーク接続エラー
                self.domain = "Cann't connect server"
                self.statusCode = .networkError
                self.responseObject = nil
            case .requestError:
                // URL生成エラー
                self.domain = "Cann'r create urls"
                self.statusCode = .networkError
                self.responseObject = nil
            case .responseError(let responseError as DMMAPIError):
                // ニコナビレスポンスエラー
                self.domain = responseError.domain
                self.statusCode = responseError.statusCode
                self.responseObject = responseError.responseObject
            case .responseError(let responseError):
                // レスポンスエラー
                self.domain = responseError._domain
                self.statusCode = StatusCode(code: responseError._code)
                self.responseObject = nil
            }
        } else {
            self.domain = error._domain
            self.statusCode = StatusCode(code: error._code)
            self.responseObject = nil
        }
    }

    init(domain: String, statusCode: StatusCode, responseObject: Any?) {
        self.domain = domain
        self.statusCode = statusCode
        self.responseObject = responseObject
    }

}

// MARK: - Custom Error
extension DMMAPIError {
    static func parseError(object responseObject: Any? = nil) -> DMMAPIError {
        return DMMAPIError(domain: "Cann't parse object.", statusCode: .parseError, responseObject: responseObject)
    }

    static func emptyError(object responseObject: Any? = nil) -> DMMAPIError {
        return DMMAPIError(domain: "Cann't  find items.", statusCode: .parseError, responseObject: responseObject)
    }
}
