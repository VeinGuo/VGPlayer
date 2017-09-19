//
//  VGPlayerCacheSession.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation

open class VGPlayerCacheSession: NSObject {
    public fileprivate(set) var downloadQueue: OperationQueue
    static let shared = VGPlayerCacheSession()
    
    public override init() {
        let queue = OperationQueue()
        queue.name = "com.vgplayer.downloadSession"
        downloadQueue = queue
    }
}
