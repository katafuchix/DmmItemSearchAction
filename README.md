# DmmItemSearchAction

RxSwift + DMM API + APIKit + Action  Simple MVVM Sample

## Getting Started
create Constants.swift like this.
```
struct Constants {
    // APIID
    static let api_id           = " YOUR DMM API ID "
    // アフィリエイトID
    static let affiliate_id     = " YOUR DMM AFFILIATE ID "
    // 1ページに表示する件数
    static let hits             = 10
    // 出力形式
    static let output           = "json"
}
```
after put Constants.swift in this project, pod install.

### Examples in this xcode project
- getting items from DMM API with API Kit, Codable, Rx.
- creating CollectionView with RxDataSources
- extended MBProgressHUD with Reactive.
- example of Action, input/output parameters base.
- API call with paging in Rx, Action

### Screen capture
<div>
<img src="https://user-images.githubusercontent.com/6063541/72665368-3e46b180-3a4b-11ea-8c65-24922ac7cc70.png" width="250">
　
<img src="https://user-images.githubusercontent.com/6063541/72665419-a85f5680-3a4b-11ea-8c74-d9c65991665a.png" width="250">
</div>

<div>
<img src="https://user-images.githubusercontent.com/6063541/72665397-73530400-3a4b-11ea-95f1-48411756291d.png" width="250">
　
<img src="https://user-images.githubusercontent.com/6063541/72665436-d93f8b80-3a4b-11ea-8688-b00e54503242.png" width="250">
</div>
