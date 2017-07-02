//
//  VGPlayerCacheMedia.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation

open class VGPlayerCacheMedia: NSObject, NSCoding {
    open var contentType: String?
    open var isByteRangeAccessSupported: Bool = false
    open var contentLength: Int64 = Int64.allZeros
    open var downloadedLength: UInt64 = UInt64.allZeros
    
    public override init() {
        
    }
    
    open override var description: String {
        return "contentType: \(String(describing: contentType))\n isByteRangeAccessSupported: \(isByteRangeAccessSupported)\n contentLength: \(contentLength)\n downloadedLength: \(downloadedLength)\n"
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.contentType, forKey: "contentType")
        aCoder.encode(self.isByteRangeAccessSupported, forKey: "isByteRangeAccessSupported")
        aCoder.encode(self.contentLength, forKey: "contentLength")
        aCoder.encode(self.downloadedLength, forKey: "downloadedLength")
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init()
        self.contentType = aDecoder.decodeObject(forKey: "contentType") as? String
        self.isByteRangeAccessSupported = aDecoder.decodeBool(forKey: "isByteRangeAccessSupported")
        self.contentLength = aDecoder.decodeInt64(forKey: "contentLength")
        if let downloadedLength = aDecoder.decodeObject(forKey: "downloadedLength") as? UInt64 {
            self.downloadedLength = downloadedLength
        } else {
            self.downloadedLength = UInt64.allZeros
        }
        
    }
}
