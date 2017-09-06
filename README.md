## VGPlayer

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/VeinGuo/VGPlayer/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/Pastel.svg?style=flat)](https://github.com/VeinGuo/VGPlayer)
[![Cocoapod](https://img.shields.io/badge/pod-v0.1.5-blue.svg)](http://cocoadocs.org/docsets/VGPlayer/0.1.5/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![Banners](https://github.com/VeinGuo/VGPlayer/blob/master/Image/Banners.png)

Swift developed based on AVPlayer iOS player,support horizontal gestures Fast forward, pause, vertical gestures Support brightness and volume adjustment, support full screen, adaptive screen rotation direction.

[中文介绍](http://www.jianshu.com/p/1680978e1a7e)

## Demonstration
![demo1](https://github.com/VeinGuo/VGPlayer/blob/master/Image/demo1.gif)

![demo2](https://github.com/VeinGuo/VGPlayer/blob/master/Image/demo2.gif)

![demo3](http://ojaltanzc.bkt.clouddn.com/vgplayer_embed_in_cell.gif)

## Requirements
-	Swift 3
-	iOS 8.0+
-	Xcode 8

## Features
- [x] Support play local and network 
- [x] Background playback mode.
- [x] Gesture Adjusts the volume and brightness as well as fast forward and backward.
- [x] Support full screen
- [x] Slide fast forward and backward
- [x] Lock screen can also be rotated full screen
- [x] Support replay media
- [x] Support custom player view
- [x] Support subtitle (format: srt & ass)
- [x] Media Cache

## TODO
- [ ] Virtual reality

## Update
- 2017-6-13 v0.0.1
- 2017-6-17 Support subtitle (format: srt & ass) v0.0.2
- 2017-7-1 Media Cache v0.1.0
- 2017-7-3 	fix some compiler warning, support carthage. v0.1.1
- 2017-7-11 fix all compiler warning. v0.1.2
- 2017-7-16 fix URL resolution error. v0.1.3
- 2017-8-10 
  - fix iOS 9 can't play
  - fix exit Full Screen frame error
  - player slider thumb add highted
  - example add <embed to cell> demo
- 2017-9-6 v0.1.5
	- fix url param praser
	- fix pause play error 


## Usage
### Play Video
```swift
// init 
self.player = VGPlayer(URL: url)
// or
self.player.replaceVideo(url)
```

### Custom player view
- Subclass VGPlayerView
- Alloc VGPlaye when set up

```swift
let playeView = VGCustomPlayerView()
self.player = VGPlayer(playerView: playeView)

// customPlayerView
class VGCustomPlayerView: VGPlayerView {
    var playRate: Float = 1.0
    var rateButton = UIButton(type: .custom)
    
    override func configurationUI() {
        super.configurationUI()
        self.topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09701412671)
        self.bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09701412671)
        self.topView.addSubview(rateButton)
        rateButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalTo(closeButton)
        }
        rateButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rateButton.setTitle("x1.0", for: .normal)
        rateButton.titleLabel?.font   = UIFont.boldSystemFont(ofSize: 12.0)
        rateButton.addTarget(self, action: #selector(onRateButton), for: .touchUpInside)
        rateButton.isHidden = false
    }

// .....more

```

### AutoLayout use [SnapKit](https://github.com/SnapKit/SnapKit)

```swift
			self.player.replaceVideo(url)
        view.addSubview(self.player.displayView)
        
        self.player.play()
        self.player.backgroundMode = .proceed
        self.player.delegate = self
        self.player.displayView.delegate = self
        self.player.displayView.titleLabel.text = "China NO.1"
        self.player.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.left.right.equalToSuperview()
            make.height.equalTo(strongSelf.view.snp.width).multipliedBy(3.0/4.0) // you can 9.0/16.0
        }
```
### Media Cache  (Reference: [VIMediaCache](https://github.com/vitoziv/VIMediaCache))
- VGPlayer Cache Reference VIMediaCache implementation.
- AVAssetResourceLoader to control AVPlayer download media data.
- Cache usage range request data, you can cancel the download, fragment cache
- If you use Simulator debugging, you can view the VGPlayer cache file in the Simulator cache
![test](http://ojaltanzc.bkt.clouddn.com/MediaCache_test.png)

- Usage:

```Swift
// Settings maxCacheSize
VGPlayerCacheManager.shared.cacheConfig.maxCacheSize = 160000000

// Setting maxCacheAge   default one weak
VGPlayerCacheManager.shared.cacheConfig.maxCacheAge = 60 * 60 * 24 * 7

// clean all cache
VGPlayerCacheManager.shared.cleanAllCache()

// clean old disk cache. 
// This is an async operation.
VGPlayerCacheManager.shared.cleanOldFiles { }

```


### Background playback
- Project setting

![backgroundModes](https://github.com/VeinGuo/VGPlayer/blob/master/Image/backgroundModes.png)

- AppDelegate settings

```Swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError
        {
            print(error)
        }
        return true
    }
```

- VGPlayer Background playback mode to proceed

```swift
self.player.backgroundMode = .proceed
```

### Delegate methods optional
```swift
// player delegate
    // play state
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState)
    // playe Duration
    func vgPlayer(_ player: VGPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval)
    // buffer state
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate)
    // buffered Duration
    func vgPlayer(_ player: VGPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval)
    // play error
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError)
    
    
// player view delegate
    /// fullscreen
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool)
    /// close play view
    func vgPlayerView(didTappedClose playerView: VGPlayerView)
    /// displaye control
    func vgPlayerView(didDisplayControl playerView: VGPlayerView)
    
```
## Installation
- Download VGPlayer. Move to your project.

- Cocoapods

```
platform :ios, '8.0'
use_frameworks!
pod 'VGPlayer'
```
- Carthage

```
github "VeinGuo/VGPlayer"
```
Run carthage update. to build the framework and drag the built `VGPlayer.framework` and `SnapKit.framework` into your Xcode project.

## Reference
- https://techblog.toutiao.com/2017/03/28/fullscreen/
- https://developer.apple.com/library/content/qa/qa1668/_index.html
- https://developer.apple.com/documentation/avfoundation
- https://stackoverflow.com/questions/808503/uibutton-making-the-hit-area-larger-than-the-default-hit-area/13977921
- https://gist.github.com/onevcat/2d1ceff1c657591eebde
- Media Cache  [VIMediaCache](https://github.com/vitoziv/VIMediaCache)
- https://mp.weixin.qq.com/s/v1sw_Sb8oKeZ8sWyjBUXGA


## License
MIT

