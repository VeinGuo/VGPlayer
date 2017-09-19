//
//  VGPlayerCacheMediaConfiguration.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation

open class VGPlayerCacheMediaConfiguration:NSObject, NSCoding, NSCopying {
    
    public fileprivate(set) var filePath: String?
    public fileprivate(set) var cacheSegments = [NSValue]()
    public var cacheMedia: VGPlayerCacheMedia?
    public var url: URL?
    
    fileprivate let cacheSegmentQueue = DispatchQueue(label: "com.vgplayer.CacheSegmentQueue")
    fileprivate let cacheDownloadInfoQueue = DispatchQueue(label: "com.vgplayer.CacheDownloadInfoQueue")
    fileprivate var fileName: String?
    fileprivate var downloadInfo = [Any]()
    
    public fileprivate(set) var progress: Double = 0.0 {
        didSet {
            if let contentLength = cacheMedia?.contentLength,
                let downloadedBytes = downloadedBytes  {
                progress = Double(downloadedBytes / contentLength)
            }
        }
    }
    
    public fileprivate(set) var downloadedBytes: Int64? {
        didSet {
            var bytes = 0
            
            cacheSegmentQueue.sync {
                for range in cacheSegments {
                    bytes += range.rangeValue.length
                }
            }
            downloadedBytes = Int64(bytes)
        }
    }
    
    public fileprivate(set) var downloadSpeed: Double? { // kb/s
        didSet {
            var bytes: UInt64 = 0
            var time = 0.0
            if downloadInfo.count > 0 {
                cacheDownloadInfoQueue.sync {
                    for a in downloadInfo {
                        if let arr = a as? Array<Any>{
                            bytes += arr.first as! UInt64
                            time += arr.last as! TimeInterval
                        } else {
                            break
                        }
                    }
                }
            }
            downloadSpeed = Double(bytes) / 1024.0 / time
        }
    }
    
    // NSCoding & NSCoying
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let fileName = aDecoder.decodeObject(forKey: "fileName") as? String,
            let cacheSegments = aDecoder.decodeObject(forKey:"cacheSegments") as? Array<NSValue>,
            let downloadInfo = aDecoder.decodeObject(forKey:"downloadInfo") as? Array<Any>,
            let cacheMedia = aDecoder.decodeObject(forKey:"cacheMedia") as? VGPlayerCacheMedia,
            let url = aDecoder.decodeObject(forKey:"url") as? URL
            else { return nil }
        self.init()
        self.fileName = fileName
        self.cacheSegments = cacheSegments
        self.downloadInfo = downloadInfo
        self.cacheMedia = cacheMedia
        self.url = url
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(fileName, forKey: "fileName")
        aCoder.encode(cacheSegments, forKey: "cacheSegments")
        aCoder.encode(downloadInfo, forKey: "downloadInfo")
        aCoder.encode(cacheMedia, forKey: "cacheMedia")
        aCoder.encode(url, forKey: "url")
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        let confi = VGPlayerCacheMediaConfiguration()
        confi.filePath = filePath
        confi.fileName = fileName
        confi.cacheSegments = cacheSegments
        confi.cacheMedia = cacheMedia
        confi.url = url
        confi.fileName = fileName
        confi.downloadInfo = downloadInfo
        return confi
    }
    
    open override var debugDescription: String {
        return "filePath: \(String(describing: filePath))\n cacheMedia: \(String(describing: cacheMedia))\n url: \(String(describing: url))\n cacheSegments: \(cacheSegments) \n"
    }
    
    public static func filePath(for filePath: String) -> String {
        let nsString = filePath as NSString
        return nsString.appendingPathExtension("conf")!
    }
    
    public static func configuration(filePath: String) -> VGPlayerCacheMediaConfiguration {
        let path = self.filePath(for: filePath)
        
        guard let configuration = NSKeyedUnarchiver.unarchiveObject(withFile: path) else {
            let defaultConfiguration = VGPlayerCacheMediaConfiguration()
            defaultConfiguration.filePath = path
            defaultConfiguration.fileName = (filePath as NSString).lastPathComponent
            return defaultConfiguration
        }
        let confi = configuration as! VGPlayerCacheMediaConfiguration
        confi.filePath = path
        return confi
    }
}

// MARK: - Update
extension VGPlayerCacheMediaConfiguration {
    open func save() {
        self.cacheSegmentQueue.sync {
            let _ = NSKeyedArchiver.archiveRootObject(self, toFile: filePath!)
        }
    }
    
    
    open func addCache(_ segment: NSRange) {
        if segment.location == NSNotFound || segment.length == 0 {
            return
        }
        
        self.cacheSegmentQueue.sync {
            var cacheSegments = self.cacheSegments
            let segmentValue = NSValue(range: segment)
            let count = self.cacheSegments.count
            
            if count == 0 {
                cacheSegments.append(segmentValue)
            } else {
                let indexSet = NSMutableIndexSet()
                for (index, value) in cacheSegments.enumerated() {
                    let range = value.rangeValue
                    if (segment.location + segment.length) <= range.location {
                        if (indexSet.count == 0) {
                            indexSet.add(index)
                        }
                        break
                    } else if (segment.location <= (range.location + range.length) && (segment.location + segment.length) > range.location) {
                        indexSet.add(index)
                    } else if (segment.location >= range.location + range.length) {
                        if index == count - 1 {
                            indexSet.add(index)
                        }
                    }
                    
                }
                
                if indexSet.count > 1 {
                    let firstRange = self.cacheSegments[indexSet.firstIndex].rangeValue
                    let lastRange = self.cacheSegments[indexSet.lastIndex].rangeValue
                    let location = min(firstRange.location, segment.location)
                    let endOffset = max(lastRange.location + lastRange.length, segment.location + segment.length)
                    
                    let combineRange = NSMakeRange(location, endOffset - location)
                    let _ = indexSet.sorted(by: >).map {cacheSegments.remove(at: $0)}
                    cacheSegments.insert(NSValue(range:combineRange), at: indexSet.firstIndex)
                } else if indexSet.count == 1 {
                    let firstRange = self.cacheSegments[indexSet.firstIndex].rangeValue
                    let expandFirstRange = NSMakeRange(firstRange.location, firstRange.length + 1)
                    let expandSegmentRange = NSMakeRange(segment.location, segment.length + 1)
                    let intersectionRange = NSIntersectionRange(expandFirstRange, expandSegmentRange)
                    
                    if intersectionRange.length > 0 {
                        let location = min(firstRange.location, segment.location)
                        let endOffset = max(firstRange.location + firstRange.length, segment.location + segment.length)
                        let combineRange = NSMakeRange(location, endOffset - location)
                        cacheSegments.remove(at: indexSet.firstIndex)
                        cacheSegments.insert(NSValue(range:combineRange), at: indexSet.firstIndex)
                    } else {
                        if firstRange.location > segment.location {
                            cacheSegments.insert(segmentValue, at: indexSet.lastIndex)
                        } else {
                            cacheSegments.insert(segmentValue, at: indexSet.lastIndex + 1)
                        }
                    }
                }
            }
            self.cacheSegments = cacheSegments
        }
        
    }
    
    open func add(_ downloadedBytes: UInt64, time: TimeInterval) {
        self.cacheDownloadInfoQueue.sync {
            var downloadInfo = self.downloadInfo
            downloadInfo.append([downloadedBytes, time])
            self.downloadInfo = downloadInfo
        }
    }
    
}

