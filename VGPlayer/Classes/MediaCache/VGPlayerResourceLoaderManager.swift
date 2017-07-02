//
//  VGPlayerResourceLoaderManager.swift
//  Pods
//
//  Created by Vein on 2017/6/28.
//
//

import Foundation
import AVFoundation

public protocol VGPlayerResourceLoaderManagerDelegate: class {
    func resourceLoaderManager(_ loadURL: URL, didFailWithError error: Error?)
}

open class VGPlayerResourceLoaderManager: NSObject {
    
    open weak var delegate: VGPlayerResourceLoaderManagerDelegate?
    fileprivate var loaders = Dictionary<String, VGPlayerResourceLoader>()
    fileprivate let kCacheScheme = "VGPlayerMideaCache"
    
    public override init() {
        super.init()
    }
    
    open func cleanCache() {
        self.loaders.removeAll()
    }
    
    open func cancelLoaders() {
        for (_, value) in self.loaders {
            value.cancel()
        }
        self.loaders.removeAll()
    }
    
    internal func key(forResourceLoaderWithURL url: URL) -> String? {
        if let scheme = url.scheme {
            if scheme == kCacheScheme {
                return url.absoluteString
            }
            return nil
        }
        return nil
    }
    
    internal func loader(forRequest request: AVAssetResourceLoadingRequest) -> VGPlayerResourceLoader? {
        let requestKey = key(forResourceLoaderWithURL: request.request.url!)
        let loader = self.loaders[requestKey!]
        return loader
    }
    
    open func assetURL(_ url: URL?) -> URL? {
        if url == nil {
            return nil
        }
        
        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        components?.scheme = kCacheScheme
        var appendStr = "?"
        if (components?.query?.characters.count) != nil {
            appendStr = "&"
        }
        
        let urlStr = String(format: "%@%@MCurl=%@", (components?.url?.absoluteString)!, appendStr, (url?.absoluteString)!)
        let assetURL = URL(string: urlStr)
        return assetURL
    }
    
    open func playerItem(_ url: URL) -> AVPlayerItem {
        let assetURL = self.assetURL(url)
        let urlAsset = AVURLAsset(url: assetURL!, options: nil)
        urlAsset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        let playerItem = AVPlayerItem(asset: urlAsset)
        if #available(iOS 9.0, *) {
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        }
        
        return playerItem
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension VGPlayerResourceLoaderManager: AVAssetResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let resourceURL = loadingRequest.request.url {
            if resourceURL.scheme == kCacheScheme {
                var loader = self.loader(forRequest: loadingRequest)
                
                if loader == nil {
                    var originURL: URL?
                    
                    if let components = URLComponents(string: resourceURL.absoluteString) {
                        if let queryItem = components.queryItems {
                            let lastQueryItem = queryItem.last
                            originURL = URL(string: (lastQueryItem?.value)!)
                        } else {
                            let url = components.query?.components(separatedBy: "=").last
                            originURL = URL(string: url!)
                        }
                        loader = VGPlayerResourceLoader(url: originURL!)
                        loader?.delegate = self
                        let key = self.key(forResourceLoaderWithURL: resourceURL)
                        self.loaders[key!] = loader
                    }
                }
                loader?.add(loadingRequest)
                return true
            }
        }
        return false
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        let loader = self.loader(forRequest: loadingRequest)
        loader?.cancel()
        loader?.remove(loadingRequest)
    }
    
}

// MARK: - VGPlayerResourceLoaderDelegate
extension VGPlayerResourceLoaderManager: VGPlayerResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: VGPlayerResourceLoader, didFailWithError error: Error?) {
        resourceLoader.cancel()
        self.delegate?.resourceLoaderManager(resourceLoader.url, didFailWithError: error)
    }
}

