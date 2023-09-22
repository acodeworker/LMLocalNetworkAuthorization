//
//  demo.swift
//  LoginDemo
//
//  Created by jeremy on 2022/9/15.
//  Copyright © 2022 aqara. All rights reserved.
//

import Foundation
import Network

@available(iOS 14.0, *)
@objcMembers open class LMLocalNetworkAuthorization: NSObject{
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    
    open func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        
        // Create parameters, and allow browsing over peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
      if(nil == self.browser){
        let browser = NWBrowser(for: .bonjour(type: "_aqara._tcp", domain: nil), using: parameters)
        self.browser = browser
      }
        // Browse for a custom service type.
      self.browser?.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                print(error.localizedDescription)
            case .ready, .cancelled:
                break
            case let .waiting(error):
                print("Local network permission has been denied: \(error)")
                self.reset()
                self.completion?(false)
            default:
                break
            }
        }
      if(nil == self.netService){
        self.netService = NetService(domain: "local.", type:"_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
      }
        self.netService?.delegate = self
        self.netService?.schedule(in: .current, forMode: .common)
        self.netService?.publish()
        self.browser?.start(queue: .main)
    }
    
    private func reset() {
        self.browser?.cancel()
        self.browser = nil
        self.netService?.stop()
        self.netService?.delegate = nil
        self.netService = nil
    }
}

@available(iOS 14.0, *)
extension LMLocalNetworkAuthorization : NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        self.reset()
        print("Local network permission has been granted")
        completion?(true)
    }
}
