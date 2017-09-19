//
//  VGPlayerDownloadURLSessionManager.swift
//  Pods
//
//  Created by Vein on 2017/6/27.
//
//

import Foundation

public protocol VGPlayerDownloadeURLSessionManagerDelegate: NSObjectProtocol {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}

open class VGPlayerDownloadURLSessionManager: NSObject, URLSessionDataDelegate {
    
    fileprivate let kBufferSize = 10 * 1024
    fileprivate var bufferData = NSMutableData()
    fileprivate let bufferDataQueue = DispatchQueue(label: "com.vgplayer.bufferDataQueue")
    
    open weak var delegate: VGPlayerDownloadeURLSessionManagerDelegate?
    
    public init(delegate: VGPlayerDownloadeURLSessionManagerDelegate?) {
        self.delegate = delegate
        super.init()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        delegate?.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bufferDataQueue.sync {
            bufferData.append(data)
            if self.bufferData.length > kBufferSize {
                let chunkRange = NSRange(location: 0, length: self.bufferData.length)
                let chunkData = bufferData.subdata(with: chunkRange)
                bufferData.replaceBytes(in: chunkRange, withBytes: nil, length: 0)
                delegate?.urlSession(session, dataTask: dataTask, didReceive: chunkData)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        bufferDataQueue.sync {
            if bufferData.length > 0 && error == nil {
                let chunkRange = NSRange(location: 0, length: bufferData.length)
                let chunkData = bufferData.subdata(with: chunkRange)
                bufferData.replaceBytes(in: chunkRange, withBytes: nil, length: 0)
                delegate?.urlSession(session, dataTask: task as! URLSessionDataTask, didReceive: chunkData)
            }
        }
        delegate?.urlSession(session, task: task, didCompleteWithError: error)
    }
}
