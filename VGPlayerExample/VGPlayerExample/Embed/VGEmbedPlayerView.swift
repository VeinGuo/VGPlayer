//
//  VGEmbedPlayerView.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/8/10.
//  Copyright © 2017年 Vein. All rights reserved.
//

import VGPlayer
import UIKit

class VGEmbedPlayerView: VGPlayerView {

    var playRate : Float = 1.0
    let bottomProgressView : UIProgressView = {
        let progress = UIProgressView()
        progress.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        progress.isHidden = true
        return progress
    }()
    var isSmallMode = false {
        didSet{
            configureGesture()
            updateView()
        }
    }
    
    override func configurationUI() {
        super.configurationUI()
        titleLabel.removeFromSuperview()
        timeSlider.minimumTrackTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        closeButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
        
        self.addSubview(bottomProgressView)
        bottomProgressView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(3)
        }
        
    }
    
    public func configureGesture() {
        doubleTapGesture.isEnabled = !isSmallMode
        singleTapGesture.isEnabled = !isSmallMode
        panGesture.isEnabled = !isSmallMode
    }
    

    override func reloadPlayerView() {
        super.reloadPlayerView()
        bottomProgressView.setProgress(0, animated: false)
    }
    
    override func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        super.playerDurationDidChange(currentDuration, totalDuration: totalDuration)
        bottomProgressView.setProgress(Float(currentDuration/totalDuration), animated: true)
    }

    func updateView() {
        self.displayControlView(!isSmallMode)
        if isSmallMode {
            self.bottomProgressView.isHidden = false
            self.topView.removeFromSuperview()
            self.bottomView.removeFromSuperview()
        } else {
            addSubview(self.topView)
            addSubview(self.bottomView)
            topView.snp.makeConstraints { [weak self] (make) in
                guard let strongSelf = self else { return }
                make.left.equalTo(strongSelf)
                make.right.equalTo(strongSelf)
                make.top.equalTo(strongSelf)
                make.height.equalTo(64)
            }
            bottomView.snp.makeConstraints { [weak self] (make) in
                guard let strongSelf = self else { return }
                make.left.equalTo(strongSelf)
                make.right.equalTo(strongSelf)
                make.bottom.equalTo(strongSelf)
                make.height.equalTo(52)
            }
        }
    }
}
