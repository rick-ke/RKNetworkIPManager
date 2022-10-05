//
//  RKNetworkIPUntil.swift
//
//  Created by Rick on 2022/9/26.
//

import Foundation

/// 1.新浪：http://pv.sohu.com/cityjson?ie=utf-8
///   範例：var returnCitySN = {"cip": "100.100.100.100", "cid": "710000", "cname": "台湾省"};
/// 2.淘宝：https://www.taobao.com/help/getip.php
///   範例：ipCallback({ip:"100.100.100.100"})
/// 3.http://ifconfig.me/ip
///   範例：100.100.100.100
class RKNetworkIPUntil {
    var targetLinks = [
        "http://pv.sohu.com/cityjson?ie=utf-8",
        "https://www.taobao.com/help/getip.php",
        "http://ifconfig.me/ip",
    ]
    
    /// IP正則
    let ipPattern = "((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}"

    
    func loadFastestIP() async -> String {
        return await withCheckedContinuation({ continuation in
            loadFastestIP { result in
                switch result {
                case .success(let ip):
                    continuation.resume(returning: ip)
                case .failure:
                    break
                }
            }
        })
    }
    
    func loadFastestIP(completion: ((Result<String, Error>) -> Void)?) {
        concurrentFastestLinks(for: targetLinks) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let content):
                let ip = content.match(as: self.ipPattern) ?? "0.0.0.0"
                completion?(.success(ip))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func concurrentFastestLinks(for links: [String], completion: ((Result<String, Error>) -> Void)?) {
        var requestURLs: [URL] = []
        for domain in links {
            if let requestURL = URL(string: domain) {
                requestURLs.append(requestURL)
            }
        }
        
        var errorDomainCount = 0
        var isWinnerGoal = false
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = requestURLs.count
        
        let configuration = URLSessionConfiguration.default
        
        let semaphore = DispatchSemaphore(value: 1)
        
        for requestURL in requestURLs {
            let request = NSMutableURLRequest(url: requestURL)
            request.timeoutInterval = 5
            
            let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
            let task = session.dataTask(with: requestURL) { (data, response, error) in
                semaphore.wait()
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      error.isNone,
                      let data = data,
                      let content = String(data: data, encoding: .utf8)
                else {
                    errorDomainCount += 1
                    if errorDomainCount == requestURLs.count {
                        print(error: "[IP] 獲取不到IP")
                        completion?(.failure(NSError(domain: "獲取不到IP", code: 0)))
                    }
                    semaphore.signal()
                    return
                }
                if !isWinnerGoal {
                    print(info: "[IP] 最快返回: \(content)")
                    isWinnerGoal = true
                    completion?(.success(content))
                } else {
                    print(info: "[IP] 較慢返回: \(content)")
                }
                semaphore.signal()
            }
            task.resume()
        }
    }
}

