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
        self.dataScource = ["http://fs.mv.web.kugou.com/201706192321/387a7ef728119c6c3f5bf97afe701f13/G055/M05/05/10/dw0DAFah0UiAJXcHAqnSlVWqvNg118.mp4",
                            "http://fs.mv.web.kugou.com/201706192327/fb268e711a9103db62f5cdf6d22c6b6a/G043/M04/1B/19/C5QEAFZBlwOAO6IlAZyj3gQKvHw686.mp4",
                            "http://fs.mv.web.kugou.com/201706192328/58a4f04781fb5e1cee24ebfa9a3d4f79/G089/M02/0F/19/OZQEAFiukt2AeIiTAhvk1UDVlGI483.mp4",
                            "http://fs.mv.web.kugou.com/201706192329/c11705a7c87966af4b52e3b5082c7847/G106/M03/08/03/qg0DAFlCBLiAIQexAgk9oPDwCWA813.mp4",
                            "http://fs.mv.web.kugou.com/201706192330/1ac86a8f96087f3ccede66ddde91099d/G040/M00/0D/09/CJQEAFZHvzaAfjO5Ah2L8CmEfWg666.mp4",
                            "http://fs.mv.web.kugou.com/201706192330/97c5b3cbe7b032471801d31485ac5657/G104/M03/1D/01/CIcBAFk2UleAHdYMAeRaBz9FrSs010.mp4",
                            "http://fs.mv.web.kugou.com/201706192331/c061614808df09f60bf7735c8d893c2e/G066/M04/04/01/gg0DAFfXuuyAEg3bA1rqy7Yj2HE017.mp4",
                            "http://fs.mv.web.kugou.com/201706192332/76df0c16df5b0ad52372a366019c6525/G042/M05/1E/19/yoYBAFXw6taANvBNAe1M7UxZ0lk950.mp4"]
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
