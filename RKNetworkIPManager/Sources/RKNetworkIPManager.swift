//
//  RKNetworkIPManager.swift
//
//  Created by Rick on 2022/9/26.
//

import Combine
import Foundation

/// 用法直接取 RKNetworkIPManager.shared.loadAdressIP()
/// 會等待有值才繼續執行
/// NetworkReachabilityManager 依據 Alamofire
/// 如果有導入 Alamofire 就免用該檔案
class RKNetworkIPManager: NSObject {
    static let shared = RKNetworkIPManager()
    
    private var adressIP: String?
    private let ipUntil = RKNetworkIPUntil()
    private var cancellables: Set<AnyCancellable> = []
    

    override init() {
        super.init()
        addListeningReachable()
        addNotification()
    }
    
    deinit {
        removeNotification()
    }
    
    func addListeningReachable() {
        NetworkReachabilityManager()?
            .startListening(onQueue: .global(), onUpdatePerforming: { _ in
                print(info: "[IP] 網路狀態改變")
                self.adressIP = nil
            })
    }
    
    func addNotification() {
        NotificationCenter.default
            .publisher(for: .appWillEnterForeground)
            .sink { _ in
                print(info: "[IP] App背景回到前景")
                self.adressIP = nil
            }
            .store(in: &cancellables)
    }
    
    private func removeNotification() {
        cancellables.removeAll()
    }

    func reloadAdressIP() {
        let isReachable = NetworkReachabilityManager()?.isReachable ?? false
        if isReachable {
            print(info: "[IP] 刷新IP位置")
            Task {
                adressIP = await ipUntil.loadFastestIP()
            }
        }
    }
    
    func loadAdressIP() -> String {
        if let adressIP = adressIP {
            return adressIP
        }
        
        var ip = ""
        let semaphore = DispatchSemaphore(value: 0)
        ipUntil.loadFastestIP { [weak self] result in
            switch result {
            case .success(let resIP):
                ip = resIP
                self?.adressIP = resIP
            case .failure:
                ip = "0.0.0.0"
                self?.adressIP = nil
            }
            semaphore.signal()
        }
        semaphore.wait()
        return ip
    }
}
