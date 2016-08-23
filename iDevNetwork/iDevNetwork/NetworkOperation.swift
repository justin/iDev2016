//  The MIT License (MIT)
//
//  Copyright (c) 2016 Justin Williams
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
#if os(iOS)
import UIKit
#endif

import Freddy
import iDevData
import iDevCore

/**
 Completion handler that fires at the end of a `NetworkOperation`
 
 - Parameter Result<[MediumContent]>: A `Result` enum that will return a value type that conforms to `MediumContent` on success or an `Error` on failure.
 
 - Returns: Nothing
 
 - Note: See `Result` for how to work with the `Result` type.
 */
public typealias NetworkOperationCompletionHandler = (Result<JSON>) -> Void

/**
 Operation to send a request to the network. Currently tied to the TED API.
 */
internal final class NetworkOperation: Operation {
    /// The actions you want to happen at the end of the network operation.
    var completionHandler: NetworkOperationCompletionHandler?
    /// The template for the `NSURLRequest` you want to dispatch to the internet tubes.
    fileprivate var requestTemplate: GeneratedRequest?
    /// The `URLSession` instance you are using.
    fileprivate var session: URLSession!
    fileprivate var sessionTask: URLSessionTask?
    
    /// The raw data returned from the generated template.
    fileprivate let incomingData = NSMutableData()
    
    // MARK: Operation Property Overrides
    override var isAsynchronous: Bool {
        return true
    }
    
    private var internalFinished: Bool = false
    override dynamic var isFinished: Bool {
        get {
            return internalFinished
        }
        set (newValue) {
            willChangeValue(forKey: "isFinished")
            internalFinished = newValue
            
            if (newValue == true) {                
                #if os(iOS)
                    networkIndicatorOff()
                #endif
            }
            
            didChangeValue(forKey: "isFinished")
        }
    }
    
    // MARK: Initializers
    // ====================================
    // Initializers
    // ====================================
    
    /**
     Initialize an `NetworkOperation` based off an `APIRequest`
     
     - Parameter requestTemplate: The request you want to fire off.
     - Parameter session: The `URLSession` you want to use for the request.
     - Parameter qos: The quality of service the operation should receive.
     
     - Note: .low and .veryLow priority operations will be put on a lower priority background queue.
     */
    init(requestTemplate: GeneratedRequest, session: URLSession, qos: QualityOfService = .default) {
        super.init()
        self.requestTemplate = requestTemplate
        self.qualityOfService = qos
        self.session = session
    }
    
    // MARK: Operation
    // ====================================
    // Operation
    // ====================================
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        guard let request = requestTemplate?.constructRequest() else {
            // No request passed in.
            isFinished = true
            return
        }
        
        sessionTask = session.dataTask(with: request, completionHandler: { [weak session=sessionTask](data, response, error) in            
            if self.isCancelled {
                self.isFinished = true
                session?.cancel()
                return
            }
            if Thread.isMainThread {
                print("You're accessing your networking operations on the main thread. You might not want to do that?")
            }
            
            if let e = error {
                print("Received error from Medium servers: \(e)")
                // We got an error, so pass back `Failure`
                if let completion = self.completionHandler {
                    completion(Result.failure(e))
                }
                
                self.isFinished = true
                return
            }
            
            
            // If we have a completion handler, we should go ahead and parse the JSON and show
            // pass the results back.
            if let completion = self.completionHandler,
               let data = data,
               let json = try? JSON(data: data) {
                completion( Result.success(json) )
            }
            
            self.isFinished = true

        })
        sessionTask?.resume()
        
        #if os(iOS)
            networkIndicatorOn()
        #endif
    }
}

// MARK: Private/Convenience
// ====================================
// Private/Convenience
// ====================================
private extension NetworkOperation {
    /// Turn the network indicator in the status bar on.
    @available(iOS 9.0, *)
    @available(OSX, unavailable, message: "Not available on macOS")
    @available(watchOS, unavailable, message: "Not available on watchOS")
    func networkIndicatorOn() {
        #if os(iOS)
            DispatchQueue.main.async { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        #endif
    }
    
    /// Turn the network indicator in the status bar off.
    @available(iOS 9.0, *)
    @available(OSX, unavailable, message: "Not available on macOS")
    @available(watchOS, unavailable, message: "Not available on watchOS")
    func networkIndicatorOff() {
        #if os(iOS)
            DispatchQueue.main.async { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        #endif
    }
}

