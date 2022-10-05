//
//  Optional+Extension.swift
//
//  Created by Rick on 2022/9/26.
//

import Foundation

extension Optional {
    var isSome: Bool {
        switch self {
        case .none: return false
        case .some: return true
        }
    }
    
    var isNone: Bool {
        return !isSome
    }
}
