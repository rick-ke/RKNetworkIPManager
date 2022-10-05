//
//  NotificationName+Extension.swift
//  RKNetworkIPProvider
//
//  Created by Rick on 2022/9/26.
//

import UIKit

extension Notification.Name {
    static let appWillEnterForeground: NSNotification.Name = {
        return UIApplication.willEnterForegroundNotification
    }()
}
