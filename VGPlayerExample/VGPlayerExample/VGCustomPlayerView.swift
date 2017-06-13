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
    var playRate: Float = 1.0
    var rateButton = UIButton(type: .custom)
    
    override func configurationUI() {
        super.configurationUI()
        self.topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.topView.addSubview(rateButton)
        rateButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalTo(closeButton)
        }
        rateButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rateButton.setTitle("x1.0", for: .normal)
        rateButton.titleLabel?.font   = UIFont.boldSystemFont(ofSize: 14.0)
        rateButton.addTarget(self, action: #selector(onRateButton), for: .touchUpInside)
        rateButton.isHidden = false
    }
    
    func onRateButton() {
        switch playRate {
        case 1.0:
            playRate = 1.5
        case 1.5:
            playRate = 2.0
        case 2.0:
            playRate = 0.5
        default:
            playRate = 1.0
        }
        rateButton.setTitle("x\(playRate)", for: .normal)
        self.vgPlayer?.player?.rate = playRate
    }
    
    override func playStateDidChange(_ state: VGPlayerState) {
        super.playStateDidChange(state)
        if state == .playing {
            self.vgPlayer?.player?.rate = playRate
        }
    }
    
    override func displayControlView(_ isDisplay: Bool) {
        super.displayControlView(isDisplay)
    }
    
    override func reloadPlayerView() {
        super.reloadPlayerView()
        self.playRate = 1.0
        self.rateButton.setTitle("x1.0", for: .normal)
    }

}
