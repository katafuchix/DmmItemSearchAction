//
//  ViewController.swift
//  DmmItemSearchAction
//
//  Created by cano on 2020/01/17.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - ViewModel
    let viewModel = ViewModel()
    
    // RxDataSource Object
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<ItemSectionDomainModel> = setupDataSources()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.bind()
    }
    
    // DataSource準備
    private func setupDataSources() -> RxCollectionViewSectionedReloadDataSource<ItemSectionDomainModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<ItemSectionDomainModel>(configureCell:
        { (dataSource, collectionView, indexPath, item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.itemCollectionViewCell, for: indexPath)!
            cell.configure(item)
            return cell
        })
        return dataSource
    }

    func bind() {
        // 検索バー
        self.searchBar.rx.text.asObservable()
            .map { $0 ?? "" }
            .bind(to: self.viewModel.searchWord)
            .disposed(by: rx.disposeBag)
        
        // 検索ボタン
        self.searchBar.rx.searchButtonClicked.asDriver()
            .drive(onNext :{ [unowned self] in
                self.viewModel.resetParams()
                self.viewModel.searchTrigger.onNext(())
                self.searchBar.resignFirstResponder()
                self.searchBar.showsCancelButton = false
            })
            .disposed(by: rx.disposeBag)
        
        // キャンセルボタン
        self.searchBar.rx.cancelButtonClicked.asDriver()
            .drive(onNext :{ [unowned self] in
                self.searchBar.resignFirstResponder()
                self.searchBar.showsCancelButton = false
            }).disposed(by: rx.disposeBag)

        // 入力が終わったらキャンセルボタン表示
        self.searchBar.rx.textDidBeginEditing
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.searchBar.showsCancelButton = true
            })
            .disposed(by: rx.disposeBag)
        
        // デリゲート
        self.collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)

        // 検索結果
        self.viewModel.outputs.sectionItems.asDriver()
            .drive(self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: rx.disposeBag)
        
        // セルタップ時
        self.collectionView.rx.itemSelected.asDriver()
            .drive(onNext:{ [unowned self] indexPath in
                let item = self.viewModel.sectionItems.value[indexPath.section].items[indexPath.row]
                if let affiliateURL = item.item.affiliateURL, let url = URL(string: affiliateURL) {
                    UIApplication.shared.open(url)
                }
            }).disposed(by: rx.disposeBag)
        
        // ページング
        self.collectionView.rx.willDisplayCell.subscribe(onNext: { [unowned self] (cell, indexPath) in
            if self.viewModel.isEndOfSections(indexPath) {
                self.viewModel.searchTrigger.onNext(())
            }
        }).disposed(by: rx.disposeBag)
        
        // ローディング エラーならfalse
        self.viewModel.isLoading.asDriver(onErrorJustReturn: false)
            .drive(MBProgressHUD.rx.isAnimating(view: self.view))
            .disposed(by: rx.disposeBag)
        
        // エラー表示
        self.viewModel.outputs.error
            .subscribe(onNext: { [unowned self] error in
                let alert = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.sectionItems.asObservable().subscribe(onNext: { [unowned self] items in
            self.collectionView.backgroundColor = items.count > 0 ? .lightGray : .white
        }).disposed(by: rx.disposeBag)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width / 2) 
            return CGSize(width: width, height: width + 80)
    }
}

