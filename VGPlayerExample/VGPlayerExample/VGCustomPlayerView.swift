//
//  VGCustomPlayerView.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/6/12.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer

class VGCustomPlayerView: VGPlayerView {
    var playRate : Float = 1.0
    let rateButton = UIButton(type: .custom)
    let bottomProgressView : UIProgressView = {
        let progress = UIProgressView()
        progress.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        progress.isHidden = true
        return progress
    }()
    let mirrorFlipButton = UIButton(type: .custom)
    
    override func configurationUI() {
        super.configurationUI()
        self.titleLabel.removeFromSuperview()
        self.timeSlider.progressView.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.closeButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
        self.topView.addSubview(rateButton)
        rateButton.snp.makeConstraints { (make) in
            make.right.equalTo(topView.snp.right).offset(-10)
            make.centerY.equalTo(closeButton)
        }
        rateButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rateButton.setTitle("x1.0", for: .normal)
        rateButton.titleLabel?.font   = UIFont.boldSystemFont(ofSize: 14.0)
        rateButton.addTarget(self, action: #selector(onRateButton), for: .touchUpInside)
        
        self.addSubview(bottomProgressView)
        bottomProgressView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(3)
        }
       
        
        mirrorFlipButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mirrorFlipButton.setTitle("开启镜像", for: .normal)
        mirrorFlipButton.setTitle("关闭镜像", for: .selected)
        mirrorFlipButton.titleLabel?.font   = UIFont.boldSystemFont(ofSize: 14.0)
        mirrorFlipButton.addTarget(self, action: #selector(onMirrorFlipButton(_:)), for: .touchUpInside)
        self.topView.addSubview(mirrorFlipButton)
        mirrorFlipButton.snp.makeConstraints { (make) in
            make.right.equalTo(rateButton.snp.left).offset(-10)
            make.centerY.equalTo(closeButton)
        }

    }
    
    override func playStateDidChange(_ state: VGPlayerState) {
        super.playStateDidChange(state)
        if state == .playing {
            self.vgPlayer?.player?.rate = playRate
        }
    }
    
    override func displayControlView(_ isDisplay: Bool) {
        super.displayControlView(isDisplay)
        self.bottomProgressView.isHidden = isDisplay
    }
    
    override func reloadPlayerView() {
        super.reloadPlayerView()
        self.playRate = 1.0
        self.rateButton.setTitle("x1.0", for: .normal)
    }
    
    override func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        self.bottomProgressView.setProgress(Float(currentDuration/totalDuration), animated: true)
    }

    
    func onRateButton() {
        switch playRate {
        case 1.0:
            playRate = 1.5
        case 1.5:
            playRate = 0.5
        default:
            playRate = 1.0
        }
        rateButton.setTitle("x\(playRate)", for: .normal)
        self.vgPlayer?.player?.rate = playRate
    }
    
    func onMirrorFlipButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
             self.playerLayer?.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 0), -1, 1, 1)
        } else {
             self.playerLayer?.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 0), 1, 1, 1)
        }
        updateDisplayerView(frame: self.bounds)
    }

}
