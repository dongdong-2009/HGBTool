//
//  File.swift
//  atsdemo
//
//  Created by qing on 16/12/28.
//  Copyright © 2016年 juxinli. All rights reserved.
//

import Foundation

/**
 * 认证
 */
// SessionManager.default.delegate.sessionDidReceiveChallenge = serverTrust
func serverTrust(session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
    
    if challenge.protectionSpace.authenticationMethod
        == NSURLAuthenticationMethodServerTrust {
        let i = 0
        repeat {
            
            let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
            let cerPath = Bundle.main.path(forResource: "www.51jubaobao.com", ofType: "cer")!
            let cerUrl = URL(fileURLWithPath:cerPath)
            let caCert = try! Data(contentsOf: cerUrl)
            
            let caRef = SecCertificateCreateWithData(nil, caCert as CFData)!
            var status: OSStatus = SecTrustSetAnchorCertificates(serverTrust, [caRef] as CFArray)
            if !(status == errSecSuccess) {
                print(">>>>>>>>>>fail")
                break
            }
            
            var result: SecTrustResultType = .invalid
            status = SecTrustEvaluate(serverTrust, &result)
            if !(status == errSecSuccess) {
                print(">>>>>>>>>>fail")
                break
            }
            let allowConnect = result == .unspecified || result == .proceed
            if allowConnect {
                print(">>>>>>>>>>success")
            }
            else {
                print(">>>>>>>>>>error")
            }
            if !allowConnect {
                break
            }
            
            let disposition = URLSession.AuthChallengeDisposition.useCredential
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            return (disposition, credential)
        } while i == 0
    }
    
    let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
    challenge.sender?.use(credential, for: challenge)
    return (.cancelAuthenticationChallenge, credential)
    
    
    //        var disposition: URLSession.AuthChallengeDisposition = .cancelAuthenticationChallenge
    //        var credential: URLCredential?
    //
    //
    //        //grab remote certificate
    //        let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
    //
    //        let cerPath = Bundle.main.path(forResource: "www.51jubaobao.com", ofType: "cer")!
    //        let cerUrl = URL(fileURLWithPath:cerPath)
    //        let caCert = try! Data(contentsOf: cerUrl)
    //
    //        let caRef = SecCertificateCreateWithData(nil, caCert as CFData)!
    //        var status: OSStatus = SecTrustSetAnchorCertificates(serverTrust, [caRef] as CFArray)
    //        if !(status == errSecSuccess) {
    //            print(">>>>>>>>>>fail")
    //        }
    //        var result: SecTrustResultType = .invalid
    //        status = SecTrustEvaluate(serverTrust, &result)
    //        if !(status == errSecSuccess) {
    //            print(">>>>>>>>>>fail")
    //        }
    //        let allowConnect = result == .unspecified || result == .proceed
    //        if allowConnect {
    //            print(">>>>>>>>>>success")
    //        }
    //        else {
    //            print(">>>>>>>>>>error")
    //        }
    //        if !allowConnect {
    //        }
    //
    //        if allowConnect {
    //            disposition = URLSession.AuthChallengeDisposition.useCredential
    //            credential = URLCredential(trust: serverTrust)
    //        }
    //        else {
    //            disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
    //        }
    //
    //        challenge.sender?.use(credential!, for: challenge)
    //        return (disposition, credential)
}
