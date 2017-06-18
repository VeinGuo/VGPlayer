//
//  VGCustomViewController.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/6/12.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer
import SnapKit

class VGCustomViewController: UIViewController {
    var player : VGPlayer = {
        let playeView = VGCustomPlayerView()
        let playe = VGPlayer(playerView: playeView)
        return playe
    }()
    var url : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.url = URL(string: "http://download.3g.joy.cn/video/236/60236853/1450837945724_hd.mp4")
        if  let srt = Bundle.main.url(forResource: "Despacito Remix Luis Fonsi ft.Daddy Yankee Justin Bieber Lyrics [Spanish]", withExtension: "srt") {
            let playerView = self.player.displayView as! VGCustomPlayerView
            playerView.setSubtitles(VGSubtitles(filePath: srt))
        }
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "2", ofType: "mp4")!)
        self.player.replaceVideo(url)
        view.addSubview(self.player.displayView)
        self.player.play()
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
    
    @IBAction func changeMedia(_ sender: Any) {
        player.replaceVideo(url!)
        player.play()
    }
}

extension VGCustomViewController: VGPlayerDelegate {
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

extension VGCustomViewController: VGPlayerViewDelegate {
    
    
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
