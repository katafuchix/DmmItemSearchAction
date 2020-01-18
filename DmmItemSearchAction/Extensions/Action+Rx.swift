//
//  Action+Rx.swift
//  DmmItemSearchAction
//
//  Created by cano on 2020/01/18.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

extension ObservableType where Element == ActionError {
    func flatMapDMMAPIError() -> Observable<DMMAPIError> {
        return flatMap { e -> Observable<DMMAPIError> in
            switch e {
            case .underlyingError(let error):
                return Observable.just(DMMAPIError(error: error))
            case .notEnabled:
                return Observable.empty()
            }
        }
    }

    func flatMapError() -> Observable<Error> {
        return flatMap { e -> Observable<Error> in
            switch e {
            case .underlyingError(let error):
                return Observable.just(error)
            case .notEnabled:
                return Observable.empty()
            }
        }
    }
}

protocol ActionErrorType {
    var actionError: ActionError { get }
}

extension ActionError: ActionErrorType {
    var actionError: ActionError { return self }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Element: ActionErrorType {
    func flatMapDMMAPIError() -> Driver<DMMAPIError> {
        return flatMap { e -> Driver<DMMAPIError> in
            switch e.actionError {
            case .underlyingError(let error):
                return Driver.just(DMMAPIError(error: error))
            case .notEnabled:
                return Driver.empty()
            }
        }
    }

    func flatMapError() -> Driver<Error> {
        return flatMap { e -> Driver<Error> in
            switch e.actionError {
            case .underlyingError(let error):
                return Driver.just(error)
            case .notEnabled:
                return Driver.empty()
            }
        }
    }
}
