//
//  VGMediaViewController.swift
//  Example
//
//  Created by Vein on 2017/5/29.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer
import SnapKit

class VGMediaViewController: UIViewController {
    
    var player = VGPlayer()
    var url1 : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.url1 = URL(fileURLWithPath: Bundle.main.path(forResource: "2", ofType: "mp4")!)
        let url = URL(string: "http://106.122.250.200/v.cctv.com/flash/mp4video6/TMS/2011/01/05/cf752b1c12ce452b3040cab2f90bc265_h264818000nero_aac32-1.mp4?wsiphost=local")!
        
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
        player.replaceVideo(url1!)
        player.play()
    }
}

extension VGMediaViewController: VGPlayerDelegate {
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

extension VGMediaViewController: VGPlayerViewDelegate {
    
    
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {

    }
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        if playerView.fullScreen {
            playerView.exitFullscreen()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
        UIApplication.shared.setStatusBarHidden(!playerView.isDisplayControl, with: .fade)
    }
}
