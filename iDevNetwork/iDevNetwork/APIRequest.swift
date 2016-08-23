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

protocol APIRequest {
    var baseURL: NSURL? { get }
    var method: String { get }
    var path: String { get }
    var parameters: Dictionary<String, String> { get }
    var headers: Dictionary<String, String> { get }
    var httpBody: HTTPBody? { get }
    var accessToken: String { get }
}

extension APIRequest {
    var baseURL: NSURL? { return NSURL(string: Constants.APIServer) }
    var method: String { return HTTPMethod.GET.toString() }
    var path: String { return "" }
    var parameters: Dictionary<String, String> { return Dictionary<String, String>() }
    var headers: Dictionary<String, String> { return Dictionary<String, String>() }
    var httpBody: HTTPBody? { return nil }
    var accessToken: String { return "" }
}
