//
//  VGCustomViewController2.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/6/19.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer
import SnapKit

class VGCustomViewController2: UIViewController {
    
    var nextCount = 0
    var player : VGPlayer!
    var playerView : VGCustomPlayerView2!
    var dataScource : [String] = []
    
    @IBOutlet weak var adsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        self.player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        self.player.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVideos() -> URL{
        self.dataScource = ["http://baobab.wdjcdn.com/1451826889080C.mp4",
                            "http://baobab.wdjcdn.com/14399887845852_x264.mp4",
                            "http://baobab.wdjcdn.com/1442142801331138639111.mp4",
                            "http://baobab.wdjcdn.com/143625320119607.mp4",
                            "http://baobab.wdjcdn.com/145345719887961975219.mp4",
                            "http://baobab.wdjcdn.com/1442142801331138639111.mp4",
                            "http://baobab.wdjcdn.com/143323298510702.mp4"]
        nextCount = nextCount % self.dataScource.count
        let url = URL(string: self.dataScource[nextCount])!
        nextCount += 1
        return url
    }
    
    @IBAction func addAdsAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.playerView.isAds = sender.isSelected
    }
}

// MARK: - player
extension VGCustomViewController2 {
    func configurePlayer() {
        self.playerView = VGCustomPlayerView2()
        self.player = VGPlayer(playerView: playerView)
        self.player.replaceVideo(getVideos())
        view.addSubview(self.player.displayView)
        self.player.backgroundMode = .suspend
        self.player.delegate = self
        self.player.displayView.delegate = self
        self.player.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.equalTo(strongSelf.view.snp.top)
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            make.height.equalTo(strongSelf.view.snp.width).multipliedBy(9.0/16.0) // you can 9.0/16.0
        }
        self.playerView.nextCallBack =  ({ [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.player.replaceVideo(strongSelf.getVideos())
            strongSelf.player.play()
        })
        
        self.playerView.skipCallBack =  ({ [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.adsButton.isSelected = false
            strongSelf.player.replaceVideo(strongSelf.getVideos())
            strongSelf.player.play()
            strongSelf.playerView.isAds = false
        })

        // Default,  the first for the ads
        self.playerView.isAds = true
    }
}

// MARK: - VGPlayerDelegate
extension VGCustomViewController2: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        print(error)
    }
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        // aotu play next
        if state == .playFinished {
            self.player.replaceVideo(getVideos())
            self.player.play()
        }
    }
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        print("buffer State", state)
    }
    
}


// MARK: - VGPlayerViewDelegate
extension VGCustomViewController2: VGPlayerViewDelegate {
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
            self.playerView.updateCustomView()
    }
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        if playerView.isFullScreen {
            playerView.exitFullscreen()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
        UIApplication.shared.setStatusBarHidden(!playerView.isDisplayControl, with: .fade)
    }
}
