//
//  AppDelegate.swift
//  SignInWithAppleTest
//
//  Created by lirui on 2019/12/10.
//  Copyright © 2019 wsjp. All rights reserved.
//

import UIKit
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //苹果推荐将判断用户逻辑状态放在这里
        
        if  KeychainItem.currentUserIdentifier != "" {
            let provider = ASAuthorizationAppleIDProvider()
            provider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
                
                switch(credentialState){
                    
                case .authorized: //授权状态有效
                    print("Apple ID Credential is valid")
                    
                case .revoked:    //上次使用苹果账号登录的凭据已被移除，需解除绑定并重新引导用户使用苹果登录
                    print("Apple ID Credential revoked, handle unlink")
                    fallthrough
                    
                case .notFound:   //未登录授权，直接弹出登录页面，引导用户登录
                    DispatchQueue.main.async {
                        print("Credential not found, show login UI")
                    }
                default:
                    break
                }
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

