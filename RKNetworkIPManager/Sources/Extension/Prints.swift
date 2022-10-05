//
//  Prints.swift
//
//  Created by Rick on 2022/9/26.
//

import Foundation

public func print(info object: Any?, file: String = #file, line: Int = #line ) {
    let message = object ?? "nil"
#if DEBUG
    print("🟩🟩🟩\((file as NSString).lastPathComponent) line\(line): \(message)")
#endif
}

public func print(warning object: Any?, file: String = #file, line: Int = #line ) {
    let message = object ?? "nil"
#if DEBUG
    print("🟨🟨🟨\((file as NSString).lastPathComponent) line\(line): \(message)")
#endif
}

public func print(error object: Any?, file: String = #file, line: Int = #line ) {
    let message = object ?? "nil"
#if DEBUG
    print("🟥🟥🟥\((file as NSString).lastPathComponent) line\(line): \(message)")
#endif
}
