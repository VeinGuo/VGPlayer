//
//  VGVerticalViewController.swift
//  VGPlayer-Example
//
//  Created by Vein on 2017/6/9.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer
import SnapKit

class VGVerticalViewController: UIViewController {
    var player : VGPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8")
        if url != nil {
            player = VGPlayer(URL: url!)
        }
        player?.delegate = self
        view.addSubview((player?.displayView)!)
        player?.backgroundMode = .proceed
        player?.play()
        player?.displayView.delegate = self
        player?.displayView.titleLabel.text = "HLS Live"
        player?.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.edges.equalTo(strongSelf.view)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
}

extension VGVerticalViewController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        print(error)
    }
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        print("player State ",state)
    }
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        print("buffer State", state)
    }
    
}

extension VGVerticalViewController: VGPlayerViewDelegate {
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
        
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
