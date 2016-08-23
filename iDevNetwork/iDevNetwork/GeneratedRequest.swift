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

/// Automatically generate a request based off the `APIRequest` values of a struct.
protocol GeneratedRequest: APIRequest {
    func constructRequest() -> URLRequest?
}

extension GeneratedRequest {
    func constructRequest() -> URLRequest? {
        guard let baseURL = baseURL else { return nil }
        guard let URLComponents = NSURLComponents(url: baseURL as URL, resolvingAgainstBaseURL: true) else { return nil }
        URLComponents.path = (URLComponents.path ?? "") + path
        URLComponents.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        guard let URL = URLComponents.url else { return nil }
        let request = NSMutableURLRequest(url: URL)
        
        if let body = httpBody {
            request.httpBody = body.encoded()
        }
        
        request.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: Constants.authorization)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.accept)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.contentType)
        request.httpMethod = method
        return request as URLRequest
    }
}
