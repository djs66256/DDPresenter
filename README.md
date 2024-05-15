# DDPresenter

A state-driven view system, with service and notification system. A power tool to develop composite page and list.

```ruby
pod 'DDPresenter'
```

If using custom collection view layout, you can use subspecs. Now, support `NECollectionViewLayout`, `CHTCollectionViewWaterfallLayout`.
```ruby
pod 'DDPresenter', :subspecs => ["Core", "NECollectionViewLayout", "CHTCollectionViewWaterfallLayout"]
```

# Usage

## Presenter

You should put all states here to driven view updating.
1. You can trigger updating by define a state type:
```swift
struct StateType {
    // all your states
}
@StateChecker
private var _state: StateType = StateType()
@MainActor var state: StateType {
    get {
        _state
    }
    set {
        // updating view only state changed
        if _state != newValue {
            setState {
                _state = newValue
            }
        }
    }
}
```
2. Or just using `setState`:
```swift
@MainActor var text: String = smallText {
    didSet {
        setState {}
    }
}
```
3. Using a `ViewStatePresenter` is a better choice for complex states. And update view by:
```swift
func updateState() {
    setState { state in
        state.count += 1
    }
}
```

#### Lifecycle

```text
        +------------+
        |   Create   |
        +------------+
              |
              v
        +------------+
   +----|  onAttach  |
   |    +------------+
   |          |
   |          v
   |    +------------+
   |    | onBindView |
   |    +------------+
   |          |
   |          v
   |    +------------+   <---\
   |    |  onUpdate  |        | setState
   |    +------------+   ----/
   |          |
   |          v
   |    +------------+
   |    |onUnbindView|
   |    +------------+
   |          |
   |          v
   |    +------------+
   +--->|  onDetach  |
        +------------+
              |
              v
        +------------+
        |   Destroy  |
        +------------+
```

#### Animations

You can perform animations when udpating view.

```
setState { $0.normalProgress = 1 - $0.normalProgress } context: { context in
    context.animated = true
    context.layoutIfNeeded = true
    context.animator = UIViewDefaultAnimator(duration: 1)
}
```

> An animator contains the animation params. You can custom animator to apply different animation params.

## Service

You can provide services in the view controller. Services can be used in the view controller and all presenter-tree in the view controller. When you `getService`, make sure the presenter has attached to root.

```swift 
func doSomething() {
    getService(MyBusinessService.self).doSomething()
}
```

When needs add listeners, here is the best practice:

```swift
override func onAttachToRoot(_ presenter: RootViewPresentable) {
    super.onAttachToRoot(presenter)
    
    getService(MyService.self)?.addListener(self)
}

override func onDetachFromRoot(_ presenter: RootViewPresentable) {
    super.onDetachFromRoot(presenter)
    
    getService(MyService.self)?.removeListener(self)
}
```

> Putting all business logics in a service is a best practice. Service is easy to reuse, and not acting with view updating.

Also, you can add your exists Service-System (IoC) by: 
```swift
public struct GlobalServiceConfig {
    /// If already have global service, `getService()` can use this to downgrade to global services.
    public static var serviceDowngrade: ServiceProviderDowngrade? = nil
}
```

## Notification

Notifying between presenters or services, may use `delegate`, `listener`, `NSNotificationCenter`. But it will be very complex when having lots of messages. Here provide a new notification system. You can notify other presenters below the same root presenter who implementing the `NotificationProtocol`. 

Notify:
```swift
func notify() {
    notifyGlobal(MyNotification.self) {
        $0.onMyMessage()
    }
}
```

And you can select notify scope as your needs.
```swift 
public enum NotifyScope {
    case global             // Notify from root to all children presenters
    case reusable           // Notify to nearest reusable parent presenter and its children
    case children           // Notify to its chidren
    case childrenAndSelf    // Notify to its children and itself
    case parents            // Notify to its parents, until to root presenter
    case manually           // Nofity to listeners that added manually
}
```

## UICollectionView / UITableView

`UICollectionView` / `UITableView` delegate by `Proxy`. It support many features:
- data source diff
- size caching and size calculating automatically
- updating view only in the dirty part

Presenters for `UICollectionView` with `UICollectionViewFlowLayout`:
- `UICollectionViewFlowPresenter` will bind `UICollectionView`
- `UICollectionViewFlowSectionPresenter` is section data source type
- `UICollectionViewFlowItemPresenterHolder` is item data source type
- `UICollectionViewFlowReusableItemPresenter` will bind `UICollectionViewCell`

> It will create more than one cell when animation or other situation. So seprate item to `holder` and `reusable presenter`. `holder` is unique, and `reusable presenter` will bind cell that create by UICollectionView. At last, may have more than one `resusable presenter` in a `holder`.

And the same as `UITableView`:
- `UITableViewPresenter` will bind `UICollectionView`
- `UITableViewSectionPresenter` is section data source type
- `UITableViewCellPresenterHolder` is item data source type
- `UITableViewReusableCellPresenter` will bind `UICollectionViewCell`

### Custom UICollectionViewLayout

When using custom `UICollectionViewLayout`, need use different presenters listed below:

| Layout         | UICollectionViewFlowLayout               | NECollectionViewLayout                    | CHTCollectionViewWaterfallLayout          |
|----------------|------------------------------------------|-------------------------------------------|-------------------------------------------|
| CollectionView | UICollectionViewFlowPresenter            | NECollectionViewFlowPresenter             | CHTCollectionViewWaterfallPresenter       |
| Section        | UICollectionViewFlowSectionPresenter     | NECollectionViewFlowSectionPresenter      | CHTCollectionViewWaterfallSectionPresenter|
| Item Holder    | UICollectionViewFlowItemPresenterHolder  | UICollectionViewReusablePresenterHolder   | UICollectionViewReusablePresenterHolder   |
| Item Reusable  | UICollectionViewFlowReusableItemPresenter | UICollectionViewFlowReusableItemPresenter | UICollectionViewFlowReusableItemPresenter |