## VGPlayer

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
![Build](https://img.shields.io/badge/build-passing-green.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/VeinGuo/VGPlayer/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/Pastel.svg?style=flat)](https://github.com/VeinGuo/VGPlayer)
[![Cocoapod](https://img.shields.io/badge/pod-v0.0.2-blue.svg)](http://cocoadocs.org/docsets/VGPlayer/0.0.1/)

![Banners](https://github.com/VeinGuo/VGPlayer/blob/master/Image/Banners.png)

Swift developed based on AVPlayer iOS player,support horizontal gestures Fast forward, pause, vertical gestures Support brightness and volume adjustment, support full screen, adaptive screen rotation direction.

[中文介绍](http://www.jianshu.com/p/1680978e1a7e)

## Demonstration
![demo1](https://github.com/VeinGuo/VGPlayer/blob/master/Image/demo1.gif)

![demo2](https://github.com/VeinGuo/VGPlayer/blob/master/Image/demo2.gif)
## Requirements
-	Swift 3
-	iOS 8.0+
-	XCode 8

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
## TODO
- [ ] Media Cache
- [ ] Virtual reality

## Update
- 2017-6-13 v0.0.1
- 2017-6-17 Support subtitle (format: srt & ass)

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
            make.top.equalTo(strongSelf.view.snp.top)
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            make.height.equalTo(strongSelf.view.snp.width).multipliedBy(3.0/4.0) // you can 9.0/16.0
        }
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


## Reference
- https://techblog.toutiao.com/2017/03/28/fullscreen/
- https://developer.apple.com/library/content/qa/qa1668/_index.html
- https://developer.apple.com/documentation/avfoundation
- https://stackoverflow.com/questions/808503/uibutton-making-the-hit-area-larger-than-the-default-hit-area/13977921
- https://gist.github.com/onevcat/2d1ceff1c657591eebde

## License
MIT

