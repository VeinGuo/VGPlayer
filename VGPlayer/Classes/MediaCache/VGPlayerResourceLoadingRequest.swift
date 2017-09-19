//
//  VGPlayerResourceLoadingRequest.swift
//  Pods
//
//  Created by Vein on 2017/6/28.
//
//

import Foundation
import AVFoundation

public protocol VGPlayerResourceLoadingRequestDelegate: class {
    func resourceLoadingRequest(_ resourceLoadingRequest: VGPlayerResourceLoadingRequest, didCompleteWithError error: Error?)
}

open class VGPlayerResourceLoadingRequest: NSObject {
    
    open fileprivate(set) var request: AVAssetResourceLoadingRequest
    open weak var delegate: VGPlayerResourceLoadingRequestDelegate?
    fileprivate var downloader: VGPlayerDownloader
    
    public init(_ downloader: VGPlayerDownloader, _ resourceLoadingRequest: AVAssetResourceLoadingRequest) {
        self.downloader = downloader
        request = resourceLoadingRequest
        super.init()
        downloader.delegate = self
        fillCacheMedia()
    }
    
    internal func fillCacheMedia() {
        if  downloader.cacheMedia != nil,
            let contentType = downloader.cacheMedia?.contentType {
            if let cacheMedia = downloader.cacheMedia {
                request.contentInformationRequest?.contentType = contentType
                request.contentInformationRequest?.contentLength = cacheMedia.contentLength
                request.contentInformationRequest?.isByteRangeAccessSupported = cacheMedia.isByteRangeAccessSupported
            }
        }
    }
    
    internal func loaderCancelledError() -> Error {
        let nsError = NSError(domain: "com.vgplayer.resourceloader", code: -3, userInfo: [NSLocalizedDescriptionKey: "Resource loader cancelled"])
        return nsError as Error
    }
    
    open func finish() {
        if !request.isFinished {
            request.finishLoading(with: loaderCancelledError())
        }
    }
    
    open func startWork() {
        if let dataRequest = request.dataRequest {
            var offset = dataRequest.requestedOffset
            let length = dataRequest.requestedLength
            if dataRequest.currentOffset != 0 {
                offset = dataRequest.currentOffset
            }
            var isEnd = false
            if #available(iOS 9.0, *) {
                if dataRequest.requestsAllDataToEndOfResource {
                    isEnd = true
                }
            }
            downloader.dowloaderTask(offset, length, isEnd)
        }
    }
    
    open func cancel() {
        downloader.cancel()
    }
}

// MARK: - VGPlayerDownloaderDelegate
extension VGPlayerResourceLoadingRequest: VGPlayerDownloaderDelegate {
    public func downloader(_ downloader: VGPlayerDownloader, didReceiveData data: Data) {
        request.dataRequest?.respond(with: data)
    }
    
    public func downloader(_ downloader: VGPlayerDownloader, didFinishedWithError error: Error?) {
        if error?._code == NSURLErrorCancelled { return }
        
        if (error == nil) {
            request.finishLoading()
        } else {
            request.finishLoading(with: error)
        }
        
        delegate?.resourceLoadingRequest(self, didCompleteWithError: error)
        
    }
    
    public func downloader(_ downloader: VGPlayerDownloader, didReceiveResponse response: URLResponse) {
        fillCacheMedia()
    }
}
