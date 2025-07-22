# Swift Coding Style

## 變數
### 區域變數
直接初始化不需要指定變數型別
``` Swift
let device = UIDevice.current
```
接受回傳值的情況需要指定型別
``` Swift
let state: UIDevice.BatteryState = device.batteryState
```
### 全域變數
使用時必定要加上 self
``` Swift
self.titleLabel.text = "Title"
```
初始化時，無法一行完成時，獨立出變數進行初始化設定，

完成設定後再給予全域變數
``` Swift
let statusLabel = UILabel()
statusLabel.text = "請選擇一個顏色傳送給 Apple Watch"
statusLabel.textAlignment = .center
statusLabel.numberOfLines = 0
statusLabel.translatesAutoresizingMaskIntoConstraints = false

self.view.addSubview(statusLabel)
self.statusLabel = statusLabel
```

### 命名
- 使用 camelCase
- 偏好完整的描述性名稱
- 避免縮寫

```swift
var applicationHostId: UInt32
var versionNumber: UInt32
var keyboardObserver: DTKeyboardObserver
```

## Closure
變數名稱必定上下有獨立的換行，提升變數的辨識度，

並且優先使用 unowend self，除非有實體消失的疑慮，才使用 weak self
``` Swift
let replyHandler: ([String : Any]) -> Void) = {
    
    [weak self] reply in

    DispatchQueue.main.async {

        self?.statusLabel.text = "顏色 \(name) 已成功傳送給 Apple Watch"
    }
}
```

## 方法
### 實作方法
方法起始的大掛號一律在新一行
``` Swift
public override
init
{
    self = [super init]
}

private 
func setupWatchConnectivity() 
{
    gaurd WCSession.isSupported() else {
        
        return
    }

    let session = WCSession.default
    session.delegate = self
    session.activate()
}
```

### 附叫方法
方法中的參數禁止直接在裡面初始化
``` Swift
button.addAction(UIAction { [weak self] _ in
    self?.sendColorToWatch(color: color, name: title)
}, for: .touchUpInside)
```
一定要在外部宣告，再給予變數的方式
``` Swift
let action = UIAction { 
    
    [weak self] _ in

    self?.sendColorToWatch(color: color, name: title)
}

button.addAction(action, for: .touchUpInside)
```
使用 closure 的情況則是，只有一個 closure 參數的話，允許直接使用，

但是有一個 closure 以上時，必須獨立宣告成兩個變數
``` Swift
DispatchQueue.main.async { 
    
    [weak self] in

    self?.statusLabel.text = "已連接到 Apple Watch，請選擇顏色"
}

let replyHandler: ([String : Any]) -> Void) = {
    
    [weak self] reply in

    DispatchQueue.main.async {

        self?.statusLabel.text = "顏色 \(name) 已成功傳送給 Apple Watch"
    }
}

let errorHandler: (any Error) -> Void = {

    [weak self] error in

    DispatchQueue.main.async {

        self?.statusLabel.text = "傳送失敗：\(error.localizedDescription)"
    }
}

WCSession.default.sendMessage("Send message to watch", replyHandler: replyHandler, errorHandler: errorHandler)
```

## class 與 struct
與方法實作一樣，大掛號一律在新一行
```swift
class MyClass
{
    var property: String {
        
        get {
            
            return value
        }
        
        set {
            
            value = newValue
        }
    }
    
    func method()
    {
        if condition {
            
        }
    }
}
```

### 屬性宣告
計算屬性的大括號與方法做區分，因此無需獨立一行
```swift
var x: CGFloat {

    get {
        
        self.frame.x
    }
    
    set {
        
        var frame: CGRect = self.frame
        frame.x = newValue
        
        self.frame = frame
    }
}
```

## 修飾符
### 優先順序
1. ObjC 相容控制（`@objc`, `@objcMembers`）
2. 屬性包裝器（如 `@MainActor`、`@propertyWrapper`）
3. 存取控制（`public`、`private`、`fileprivate`）
4. 其他修飾符（`static`、`final`、`nonmutating`）
   * 存取控制只有一個的情況下，可放置在同一行中
5. 繼承修飾符（`override`）
```swift
@propertyWrapper
public 
struct Wrapper
{
    public private(set)
    static
    var value: Int {
        // implementation
    }

    static
    func someMethod()
    {
        
    }
}
```

## 程式區塊
### MARK
標記 property 與 method 的起始位置
```Swift
class ViewController: UIViewController
{
    // MARK: - Properties -

    private
    var ownerId: String?

    // MARK: - Methods -
    // MARK: Initial Method

    private
    override
    init()
    {
        super.init()
        
    }
}
```

### Extension
區分按鈕事件與私有方法，會使用 extension 將程式區分開來，增加可讀性
```Swift
public
class ViewController: UIViewController
{

}

// MARK: - Actions -

private
extension ViewController
{
    @objc
    func someAction(_ sender: UIButton)
    {

    }
}

// MARK: - Private Methods -
private
extension ViewController
{
    func somePrivateMethod()
    {

    }
}
```

### Delegate
每一個 Delegate 都要獨立一個 extension，除了以下例外:
* UITableViewDataSource 與 UITableViewDelegate
* UICollectionViewDataSource 與 UICollectionViewDelegate
```Swift
// MARK: - Delegate Methods -
// MARK: #UITableViewDataSource, UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate
{

}

// MARK: #UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate
{

}
```