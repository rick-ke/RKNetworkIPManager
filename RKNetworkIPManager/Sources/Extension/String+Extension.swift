//
//  String+Extension.swift
//
//  Created by Rick on 2022/9/26.
//

import Foundation

extension String {
    func match(as expression: String) -> String? {
        let range = NSRange(location: 0, length: self.utf16.count)
        do {
            let regex = try NSRegularExpression(pattern: expression, options: .init())
            let results = regex.matches(in: self, options: .init(), range: range)
            if let result = results.first, let matchRange = Range(result.range, in: self) {
                return String(self[matchRange])
            } else {
                return nil
            }
        } catch {
             return nil
        }
    }
}
