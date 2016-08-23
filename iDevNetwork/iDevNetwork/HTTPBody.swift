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

internal struct HTTPBody {
    var values: [String: String]
    
    internal init(values: [String: String]) {
        self.values = values
    }
    
    mutating func add(key: String, value: String) {
        values[key] = value
    }
    
    func toJSON() -> String? {
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: values, options: JSONSerialization.WritingOptions.prettyPrinted)
            return String(data: theJSONData, encoding: String.Encoding.utf8)
        }
        catch {
            return nil
        }
    }
    
    func encoded() -> Data? {
        guard let json = self.toJSON() else { return nil }
        
        return json.data(using: String.Encoding.utf8)
    }
}
