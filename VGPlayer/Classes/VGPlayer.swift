//
//  VGPlayer.swift
//  VGPlayer
//
//  Created by Vein on 2017/5/30.
//  Copyright © 2017年 Vein. All rights reserved.
//

import Foundation
import AVFoundation

/// play state
///
/// - none: none
/// - playing: playing
/// - paused: pause
/// - playFinished: finished
/// - error: play failed
public enum VGPlayerState: Int {
    case none            // default
    case playing
    case paused
    case playFinished
    case error
}

/// buffer state
///
/// - none: none
/// - readyToPlay: ready To Play
/// - buffering: buffered
/// - stop : buffer error stop
/// - bufferFinished: finished
public enum VGPlayerBufferstate: Int {
    case none           // default
    case readyToPlay
    case buffering
    case stop
    case bufferFinished
}

/// play video content mode
///
/// - resize: Stretch to fill layer bounds.
/// - resizeAspect: Preserve aspect ratio; fit within layer bounds.
/// - resizeAspectFill: Preserve aspect ratio; fill layer bounds.
public enum VGVideoGravityMode: Int {
    case resize
    case resizeAspect      // default
    case resizeAspectFill
}

/// play background mode
///
/// - suspend: suspend
/// - autoPlayAndPaused: auto play and Paused
/// - proceed: continue
public enum VGPlayerBackgroundMode: Int {
    case suspend
    case autoPlayAndPaused
    case proceed
}

public protocol VGPlayerDelegate: class {
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
}

// MARK: - delegate methods optional
public extension VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {}
    func vgPlayer(_ player: VGPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {}
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {}
    func vgPlayer(_ player: VGPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {}
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {}
}

open class VGPlayer: NSObject {
    
    open var state: VGPlayerState = .none {
        didSet {
            if state != oldValue {
                self.displayView.playStateDidChange(state)
                self.delegate?.vgPlayer(self, stateDidChange: state)
            }
        }
    }
    
    open var bufferState : VGPlayerBufferstate = .none {
        didSet {
            if bufferState != oldValue {
                self.displayView.bufferStateDidChange(bufferState)
                self.delegate?.vgPlayer(self, bufferStateDidChange: bufferState)
            }
        }
    }
    
    open var displayView : VGPlayerView
    
    open var gravityMode : VGVideoGravityMode = .resizeAspect
    open var backgroundMode : VGPlayerBackgroundMode = .autoPlayAndPaused
    open var bufferInterval : TimeInterval = 2.0
    open weak var delegate : VGPlayerDelegate?
    
    open fileprivate(set) var mediaFormat : VGPlayerMediaFormat
    open fileprivate(set) var totalDuration : TimeInterval = 0.0
    open fileprivate(set) var currentDuration : TimeInterval = 0.0
    open fileprivate(set) var buffering : Bool = false
    open fileprivate(set) var player : AVPlayer? {
        willSet{
            removePlayerObservers()
        }
        didSet {
            addPlayerObservers()
        }
    }
    private var timeObserver: Any?
    
    open fileprivate(set) var playerItem : AVPlayerItem? {
        willSet {
            removePlayerItemObservers()
            removePlayerNotifations()
        }
        didSet {
            addPlayerItemObservers()
            addPlayerNotifications()
        }
    }
    
    open fileprivate(set) var playerAsset : AVURLAsset?
    open fileprivate(set) var contentURL : URL?
    
    open fileprivate(set) var error : VGPlayerError
    
    fileprivate var seeking : Bool = false
    fileprivate var resourceLoaderManager = VGPlayerResourceLoaderManager()
    
    
    //MARK:- life cycle
    public init(URL: URL?, playerView: VGPlayerView?) {
        self.mediaFormat = VGPlayerUtils.decoderVideoFormat(URL)
        self.contentURL = URL
        self.error = VGPlayerError()
        if let view = playerView {
            self.displayView = view
        } else {
            self.displayView = VGPlayerView()
        }
        super.init()
        if self.contentURL != nil {
            configurationPlayer(contentURL!)
        }
    }
    
    public convenience init(URL: URL) {
        self.init(URL: URL, playerView: nil)
    }
    
    public convenience init(playerView: VGPlayerView) {
        self.init(URL: nil, playerView: playerView)
    }
    
    public override convenience init() {
        self.init(URL: nil, playerView: nil)
    }
    
    deinit {
        removePlayerNotifations()
        cleanPlayer()
        displayView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func configurationPlayer(_ URL: URL) {
        self.displayView.setvgPlayer(vgPlayer: self)
        self.playerAsset = AVURLAsset(url: URL, options: .none)
        if URL.absoluteString.hasPrefix("file:///") {
            let keys = ["tracks", "playable"];
            self.playerItem = AVPlayerItem(asset: self.playerAsset!, automaticallyLoadedAssetKeys: keys)
        } else {
            // remote add cache
            self.playerItem = resourceLoaderManager.playerItem(URL)
        }
        self.player = AVPlayer(playerItem: self.playerItem)
        self.displayView.reloadPlayerView()
    }
    
    // time KVO
    internal func addPlayerObservers() {
        self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] time in
            guard let strongSelf = self else { return }
            if let currentTime = strongSelf.player?.currentTime().seconds, let totalDuration = strongSelf.player?.currentItem?.duration.seconds{
                strongSelf.currentDuration = currentTime
                strongSelf.delegate?.vgPlayer(strongSelf, playerDurationDidChange: currentTime, totalDuration: totalDuration)
                strongSelf.displayView.playerDurationDidChange(currentTime, totalDuration: totalDuration)
            }
        })
    }
    
    internal func removePlayerObservers() {
        self.player?.removeTimeObserver(timeObserver!)
    }
    
}

//MARK: - public
extension VGPlayer {
    
    open func replaceVideo(_ URL: URL) {
        reloadPlayer()
        self.mediaFormat = VGPlayerUtils.decoderVideoFormat(URL)
        self.contentURL = URL
        configurationPlayer(URL)
    }
    
    open func reloadPlayer() {
        self.seeking = false
        self.totalDuration = 0.0
        self.currentDuration = 0.0
        self.error = VGPlayerError()
        self.state = .none
        self.buffering = false
        self.bufferState = .none
        self.cleanPlayer()
    }
    
    open func cleanPlayer() {
        self.player?.pause()
        self.player?.cancelPendingPrerolls()
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
        self.playerAsset?.cancelLoading()
        self.playerAsset = nil
        self.playerItem?.cancelPendingSeeks()
        self.playerItem = nil
    }
    
    open func play() {
        if contentURL == nil { return }
        player?.play()
        state = .playing
        displayView.play()
    }
    
    open func pause() {
        guard state == .paused else {
            self.player?.pause()
            self.state = .paused
            self.displayView.pause()
            return
        }
    }
    
    open func seekTime(_ time: TimeInterval) {
        seekTime(time, completion: nil)
    }
    
    open func seekTime(_ time: TimeInterval, completion: ((Bool) -> Swift.Void)?) {
        if time.isNaN || self.playerItem?.status != .readyToPlay {
            if completion != nil {
                completion!(false)
            }
            return
        }
        
        DispatchQueue.main.async { [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.seeking = true
            strongSelf.startPlayerBuffering()
            strongSelf.playerItem?.seek(to: CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)), completionHandler: { (finished) in
                DispatchQueue.main.async {
                    strongSelf.seeking = false
                    strongSelf.stopPlayerBuffering()
                    strongSelf.play()
                    if completion != nil {
                        completion!(finished)
                    }
                }
            })
        }
    }
    
}


//MARK: - private
extension VGPlayer {
    
    internal func startPlayerBuffering() {
        pause()
        self.bufferState = .buffering
        self.buffering = true
    }
    
    internal func stopPlayerBuffering() {
        self.bufferState = .stop
        self.buffering = false
    }
    
    internal func collectPlayerErrorLogEvent() {
        self.error.playerItemErrorLogEvent = playerItem?.errorLog()?.events
        self.error.error = playerItem?.error
        self.error.extendedLogData = playerItem?.errorLog()?.extendedLogData()
        self.error.extendedLogDataStringEncoding = playerItem?.errorLog()?.extendedLogDataStringEncoding
    }
}

//MARK: - Notifation Selector & KVO
private var playerItemContext = 0

extension VGPlayer {
    
    internal func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
    }
    
    internal func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: .playerItemDidPlayToEndTime, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationWillEnterForeground, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationDidEnterBackground, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    internal func removePlayerItemObservers() {
        self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
    }
    
    internal func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    
    internal func playerItemDidPlayToEnd(_ notification: Notification) {
        if self.state != .playFinished {
            self.state = .playFinished
        }
        
    }
    
    internal func applicationWillEnterForeground(_ notification: Notification) {
        
        if self.displayView.playerLayer != nil {
            self.displayView.playerLayer?.player = player
        }
        
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            play()
        case .proceed:
            break
        }
    }
    
    internal func applicationDidEnterBackground(_ notification: Notification) {
        if self.displayView.playerLayer != nil {
            self.displayView.playerLayer?.player = nil
        }
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            pause()
        case .proceed:
            break
        }
    }
}

extension VGPlayer {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &playerItemContext) {
            
            if keyPath == #keyPath(AVPlayerItem.status) {
                let status: AVPlayerItemStatus
                if let statusNumber = change?[.newKey] as? NSNumber {
                    status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
                } else {
                    status = .unknown
                }
                
                switch status {
                case AVPlayerItemStatus.unknown:
                    startPlayerBuffering()
                case AVPlayerItemStatus.readyToPlay:
                    self.bufferState = .readyToPlay
                case AVPlayerItemStatus.failed:
                    self.state = .error
                    collectPlayerErrorLogEvent()
                    stopPlayerBuffering()
                    self.delegate?.vgPlayer(self, playerFailed: error)
                    self.displayView.playFailed(error)
                }
                
            } else if keyPath == #keyPath(AVPlayerItem.playbackBufferEmpty){
                
                if let playbackBufferEmpty = change?[.newKey] as? Bool {
                    if playbackBufferEmpty {
                        startPlayerBuffering()
                    }
                }
            } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
                // 计算缓冲
                
                let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges
                if let bufferTimeRange = loadedTimeRanges?.first?.timeRangeValue {
                    let star = bufferTimeRange.start.seconds         // The start time of the time range.
                    let duration = bufferTimeRange.duration.seconds  // The duration of the time range.
                    let bufferTime = star + duration
                    
                    if let itemDuration = self.playerItem?.duration.seconds {
                        self.delegate?.vgPlayer(self, bufferedDidChange: bufferTime, totalDuration: itemDuration)
                        self.displayView.bufferedDidChange(bufferTime, totalDuration: itemDuration)
                        self.totalDuration = itemDuration
                        if itemDuration == bufferTime {
                            self.bufferState = .bufferFinished
                        }
                        
                    }
                    if let currentTime = self.playerItem?.currentTime().seconds{
                        if (bufferTime - currentTime) >= self.bufferInterval && self.state != .paused {
                            play()
                        }
                        
                        if (bufferTime - currentTime) < bufferInterval {
                            self.bufferState = .buffering
                            self.buffering = true
                        } else {
                            buffering = false
                            bufferState = .readyToPlay
                        }
                    }
                    
                } else {
                    play()
                }
            }
            
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Selecter
extension Selector {
    static let playerItemDidPlayToEndTime = #selector(VGPlayer.playerItemDidPlayToEnd(_:))
    static let applicationWillEnterForeground = #selector(VGPlayer.applicationWillEnterForeground(_:))
    static let applicationDidEnterBackground = #selector(VGPlayer.applicationDidEnterBackground(_:))
}


