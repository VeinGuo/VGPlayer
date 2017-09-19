//
//  VGPlayerResourceLoader.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation
import AVFoundation

public protocol VGPlayerResourceLoaderDelegate: class {
    func resourceLoader(_ resourceLoader: VGPlayerResourceLoader, didFailWithError  error:Error?)
}

open class VGPlayerResourceLoader: NSObject {
    open fileprivate(set) var url: URL
    open weak var delegate: VGPlayerResourceLoaderDelegate?
    
    fileprivate var downloader: VGPlayerDownloader
    fileprivate var pendingRequestWorkers = Dictionary<String ,VGPlayerResourceLoadingRequest>()
    fileprivate var isCancelled: Bool = false
    
    deinit {
        downloader.invalidateAndCancel()
    }
    
    public init(url: URL) {
        self.url = url
        downloader = VGPlayerDownloader(url: url)
        super.init()
    }
    
    open func add(_ request: AVAssetResourceLoadingRequest) {
        for (_, value) in pendingRequestWorkers {
            value.cancel()
            value.finish()
        }
        pendingRequestWorkers.removeAll()
        startWorker(request)
    }
    
    open func remove(_ request: AVAssetResourceLoadingRequest) {
        let key = self.key(forRequest: request)
        let loadingRequest = VGPlayerResourceLoadingRequest(downloader, request)
        loadingRequest.finish()
        pendingRequestWorkers.removeValue(forKey: key)
    }
    
    open func cancel() {
        downloader.cancel()
    }
    
    internal func startWorker(_ request: AVAssetResourceLoadingRequest) {
        let key = self.key(forRequest: request)
        let loadingRequest = VGPlayerResourceLoadingRequest(downloader, request)
        loadingRequest.delegate = self
        pendingRequestWorkers[key] = loadingRequest
        loadingRequest.startWork()
    }
    
    internal func key(forRequest request: AVAssetResourceLoadingRequest) -> String {
        
        if let range = request.request.allHTTPHeaderFields!["Range"]{
            return String(format: "%@%@", (request.request.url?.absoluteString)!, range)
        }
        
        return String(format: "%@", (request.request.url?.absoluteString)!)
    }
}

// MARK: - VGPlayerResourceLoadingRequestDelegate
extension VGPlayerResourceLoader: VGPlayerResourceLoadingRequestDelegate {
    public func resourceLoadingRequest(_ resourceLoadingRequest: VGPlayerResourceLoadingRequest, didCompleteWithError error: Error?) {
        remove(resourceLoadingRequest.request)
        if error != nil {
            delegate?.resourceLoader(self, didFailWithError: error)
        }
    }
    
}

