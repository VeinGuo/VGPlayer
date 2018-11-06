//
//  Timer+VGPlayer.swift
//  VGPlayer
//
//  Created by Vein on 2017/6/12.
//  Copyright © 2017年 Vein. All rights reserved.
//  https://gist.github.com/onevcat/2d1ceff1c657591eebde
//  Timer break retain cycle

import Foundation

extension Timer {
    class func vgPlayer_scheduledTimerWithTimeInterval(_ timeInterval: TimeInterval, block: @escaping ()->(), repeats: Bool) -> Timer {
        return self.scheduledTimer(timeInterval: timeInterval, target:
            self, selector: #selector(self.vgPlayer_blcokInvoke(_:)), userInfo: block, repeats: repeats)
    }
    
    @objc class func vgPlayer_blcokInvoke(_ timer: Timer) {
        let block: ()->() = timer.userInfo as! ()->()
        block()
    }

}
