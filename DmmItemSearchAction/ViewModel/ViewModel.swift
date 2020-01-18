//
//  ViewModel.swift
//  DmmItemSearchAction
//
//  Created by cano on 2020/01/18.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import APIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Action

protocol ListViewModelInputs {
    var searchTrigger: PublishSubject<Void> { get }
    var searchWord: BehaviorRelay<String>{ get }
}

protocol ListViewModelOutputs {
    var sectionItems: BehaviorRelay<[ItemSectionDomainModel]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<DMMAPIError> { get }
}

protocol ListViewModelType {
    var inputs: ListViewModelInputs { get }
    var outputs: ListViewModelOutputs { get }
}

class ViewModel: ListViewModelType, ListViewModelInputs, ListViewModelOutputs {

    var inputs: ListViewModelInputs { return self }
    var outputs: ListViewModelOutputs { return self }

    // MARK: - Inputs
    let searchTrigger = PublishSubject<Void>()
    let searchWord   = BehaviorRelay<String>(value: "")

    // MARK: - Outputs
    let sectionItems: BehaviorRelay<[ItemSectionDomainModel]>
    let isLoading: Observable<Bool>
    let error: Observable<DMMAPIError>

    // 内部変数
    private let page = BehaviorRelay<Int>(value: 1)
    private let total_count = BehaviorRelay<Int>(value:20)
    private let searchAction: Action<(String, Int), ItemsResponse>
    private let disposeBag = DisposeBag()
    
    init() {
        // Actionを定義
        self.searchAction = Action { string, page in
            return Session.rx_sendRequest(ItemsRequest(searchConditions: ["keyword": string], page: page))
        }
        
        // ローディング 初期値はfalse
        self.isLoading = searchAction.executing.startWith(false)
        // エラー
        self.error = searchAction.errors.flatMapDMMAPIError()
        
        // ページングで検索結果が来るので、合成できるように変数を準備しておく
        let response = BehaviorRelay<[ItemDomainModel]>(value: [])
        
        // 検索結果
        self.sectionItems = BehaviorRelay<[ItemSectionDomainModel]>(value: [])
        
        // 検索結果をresponseに格納 一度に書くとなぜかエラーが出るので分けて書く
        self.searchAction.elements
            .compactMap { respone in
                    return respone.object?.items.map { ItemDomainModel(item: $0) }
                }
            .bind(to: response)
            .disposed(by: disposeBag)
        
        // ItemSectionDomainModelに変換
        response.filter { $0.count > 0 }
            .compactMap { items in
                return [ItemSectionDomainModel(items: items)!]
            }
            .withLatestFrom(self.sectionItems) { ($0, $1) } // 新旧の配列を取得
            .map { $0.1 + $0.0 }    // 配列を結合
            .bind(to: self.sectionItems)
            .disposed(by: disposeBag)
        
        // トータルカウント
        self.searchAction.elements
            .compactMap { $0.object?.total_count }
            .bind(to: total_count)
            .disposed(by: disposeBag)

        // 検索結果が来るたびにページ数をカントアップ
        self.searchAction.elements
            .withLatestFrom(page)
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        // 検索トリガ
        self.searchTrigger
            .withLatestFrom(total_count)
            .filter { self.page.value * Constants.hits < $0 } // 取得件数がトータル数を超えていない場合のみ実行
            .withLatestFrom(Observable.combineLatest(self.searchWord, page))
            .bind(to: self.searchAction.inputs)
            .disposed(by: disposeBag)
    }
    
    // セクション配列・セクション内UserDataの末尾位置か調べる
    // - return: Bool (true -> End of Sections and Rows)
    func isEndOfSections(_ indexPath: IndexPath) -> Bool {
        let lastSection = sectionItems.value.lastIndex
        let lastRow = sectionItems.value[lastSection].items.lastIndex
        return (indexPath.section == lastSection && indexPath.row == lastRow)
    }
    
    // ページング用の変数初期化
    func resetParams() {
        self.page.accept(1)
        self.total_count.accept(20)
        self.sectionItems.accept([])
    }
}
