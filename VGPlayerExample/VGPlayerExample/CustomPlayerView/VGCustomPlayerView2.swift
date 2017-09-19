//
//  VGCustomPlayerView2.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/6/19.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer

class VGCustomPlayerView2: VGPlayerView {
    var isAds = true {
        didSet{
            configureGesture()
            updateView()
        }
    }
    let skipButton = UIButton(type: .custom)
    let nextButton = UIButton(type: .custom)
    let bottomProgressView : UIProgressView = {
        let progress = UIProgressView()
        progress.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        progress.isHidden = false
        return progress
    }()
    
    var nextCallBack:(() -> Swift.Void)?
    var skipCallBack:(() -> Swift.Void)?
    
    override func configurationUI() {
        super.configurationUI()
        self.titleLabel.removeFromSuperview()
        self.timeSlider.minimumTrackTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.closeButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
        
        addSubview(bottomProgressView)
        bottomProgressView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(3)
        }
        
        nextButton.setImage(#imageLiteral(resourceName: "player_next"), for: .normal)
        nextButton.isHidden = true
        nextButton.addTarget(self, action: #selector(onNextButton(_:)), for: .touchUpInside)
        self.bottomView.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.left.equalTo(playButtion.snp.right).offset(10)
            make.centerY.equalTo(playButtion)
        }
        
        skipButton.setTitle(" Skip Ads 😄 ", for: .normal)
        skipButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        skipButton.layer.cornerRadius = 2
        skipButton.isHidden = true
        skipButton.addTarget(self, action: #selector(onSkipButton(_:)), for: .touchUpInside)
        addSubview(skipButton)
        skipButton.titleLabel?.adjustsFontSizeToFitWidth = true
        skipButton.snp.makeConstraints {
            $0.right.equalTo(self.snp.right).offset(-20)
            $0.bottom.equalTo(self.snp.bottom).offset(-30)
        }

    }
    
    override func displayControlView(_ isDisplay: Bool) {
        super.displayControlView(isDisplay)
        if self.isAds {
            self.bottomProgressView.isHidden = false
        } else {
            self.bottomProgressView.isHidden = isDisplay
        }
    }
    override func reloadPlayerView() {
        super.reloadPlayerView()
        self.bottomProgressView.setProgress(0, animated: false)
    }
    
    override func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        super.playerDurationDidChange(currentDuration, totalDuration: totalDuration)
        self.bottomProgressView.setProgress(Float(currentDuration/totalDuration), animated: true)
    }

}


// MARK: - Event
extension VGCustomPlayerView2 {
    @objc func onNextButton(_ sender: UIButton) {
        if let callBack = nextCallBack {
            callBack()
        }
    }
    @objc func onSkipButton(_ sender: UIButton) {
        if let callBack = skipCallBack {
            callBack()
        }
    }
}

// MARK: - update View
extension VGCustomPlayerView2 {
    public func configureGesture() {
        self.doubleTapGesture.isEnabled = !isAds
        self.singleTapGesture.isEnabled = !isAds
        self.panGesture.isEnabled = !isAds
    }
    
    func updateView() {
        updateAdsCustomView()
        updateCustomView()
    }
    
    public func updateCustomView() {
        if self.isAds { return }
        self.nextButton.isHidden = !self.isFullScreen
        if self.isFullScreen {
            self.timeSlider.snp.remakeConstraints { (make) in
                make.left.equalTo(nextButton.snp.right).offset(10)
                make.centerY.equalTo(playButtion)
                make.right.equalTo(timeLabel.snp.left).offset(-10)
                make.height.equalTo(25)
            }
        } else {
            self.timeSlider.snp.remakeConstraints({ (make) in
                make.centerY.equalTo(playButtion)
                make.right.equalTo(timeLabel.snp.left).offset(-10)
                make.left.equalTo(playButtion.snp.right).offset(25)
                make.height.equalTo(25)
            })
        }
        
    }
    public func updateAdsCustomView() {
        if isAds {
            self.bottomProgressView.isHidden = false
            self.skipButton.isHidden = false
            self.topView.removeFromSuperview()
            self.bottomView.removeFromSuperview()
        } else {
            self.skipButton.isHidden = true
            displayControlView(true)
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
