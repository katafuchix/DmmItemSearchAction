//
//  StatusCode.swift
//  DmmItemSearchAction
//
//  Created by cano on 2020/01/18.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation

enum StatusCode: Int {

    // MARK: - HTTP Status Code
    case ok         = 200,
        created     = 201,
        accepted    = 202,
        noContent   = 204

    case seeOther = 303

    case badRequest         = 400,
        unauthorized        = 401,
        forbidden           = 403,
        notFound            = 404,
        notAcceptable       = 406,
        requestTimeout      = 408,
        conflict            = 409,
        unprocessableEntity = 422,
        locked              = 423

    case internalServerError    = 500,
        badGateway              = 502,
        serviceUnavailable      = 503,
        gatewayTimeout          = 504

    case networkError   = 0

    // MARK: - Pochi Status Code (40xxx)
    case parseError = 40400

    // MARK: - Common Error
    case unknownStatus  = -1

    // MARK: - Initialize
    init(code: Int?) {
        if let code = code {
            self = StatusCode(rawValue: code) ?? .unknownStatus
        } else {
            self = .networkError
        }
    }

}
