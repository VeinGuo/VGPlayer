//
//  VGPlayerError.swift
//  VGPlayer
//
//  Created by Vein on 2017/5/30.
//  Copyright © 2017年 Vein. All rights reserved.
//


import Foundation
import AVFoundation

public struct VGPlayerError: CustomStringConvertible {
    var error : Error?
    var playerItemErrorLogEvent : [AVPlayerItemErrorLogEvent]?
    var extendedLogData : Data?
    var extendedLogDataStringEncoding : UInt?
    
   public var description: String {
        return "VGPlayer Log -------------------------- \n error: \(String(describing: error))\n playerItemErrorLogEvent: \(String(describing: playerItemErrorLogEvent))\n extendedLogData: \(String(describing: extendedLogData))\n extendedLogDataStringEncoding \(String(describing: extendedLogDataStringEncoding))\n --------------------------"
    }
}
