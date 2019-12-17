//
//  SignInAppleManager.swift
//  SignInWithAppleTest
//
//  Created by lirui on 2019/12/10.
//  Copyright © 2019 wsjp. All rights reserved.
//

import UIKit
import AuthenticationServices

class SignInAppleManager: NSObject {
    
    @objc static let shareInstance = SignInAppleManager()
    
    private override init() {}
}



// MARK: - 对外接口
extension SignInAppleManager {
    
    //处理授权
    func handleAuthorizationAppleIDButtonPress() {
        
        let request = ASAuthorizationAppleIDProvider().createRequest()//创建一个请求
        //  let request2 = ASAuthorizationPasswordProvider().createRequest()
        request.requestedScopes = [.email, .fullName] //可不填
        
        let controller = ASAuthorizationController(authorizationRequests: [request]) //授权弹窗
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    
    //如果存在iCloud Keychain凭证或者AppleID凭证,则提示用户
    func perfomExistingAccountSetupFlows() {
        print("///已经认证过了////")
        
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
    }
    
    //状态监听
    func addUserRevokeNotification() {
        let name = ASAuthorizationAppleIDProvider.credentialRevokedNotification
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { (Notification) in
            // Sign the user out, optionally guide them to sign in again
            
        }
    }
}



// MARK: - Delegate Method

extension SignInAppleManager: ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            //苹果用户唯一标识符，该值在同一个开发者账号下的所有App下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来
            let userIdentifier = appleIdCredential.user
            _ = appleIdCredential.fullName
            _ = appleIdCredential.email
            //验证数据，用于传给开发者后台服务器，然后开发者服务器再向苹果的身份验证服务端验证，本次授权登录请求数据的有效性和真实性
            if let identityToken = appleIdCredential.identityToken {
                _ = NSString.init(data: identityToken, encoding: String.Encoding.utf8.rawValue)
            }
                
            print("\(#function) appleIdCredential:\(appleIdCredential)")
            
            //保存至钥匙串
            do {
                try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(userIdentifier)
            } catch {
                print("Unable to save userIdentifier to keychain.")
            }
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            // 这个获取的是iCloud记录的账号密码，需要输入框支持iOS 12 记录账号密码的新特性，如果不支持，可以忽略
            print("ASPasswordCredential \(passwordCredential.user) \(passwordCredential.password)")
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //回到登录页面
        print("错误信息---\(error.localizedDescription)")
    }
    
    // 需要返回一个window 用于展示授权界面
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
    
}
