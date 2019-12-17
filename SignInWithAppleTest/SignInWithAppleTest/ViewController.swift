//
//  ViewController.swift
//  SignInWithAppleTest
//
//  Created by lirui on 2019/12/10.
//  Copyright © 2019 wsjp. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSignInBtn()
    }
    
    func addSignInBtn() {
        if #available(iOS 13.0, *) {
            let btn = ASAuthorizationAppleIDButton.init(type: .signIn, style: .black)
            btn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
            btn.center = self.view.center
            btn.bounds = CGRect(x: 0,y: 0,width: 130,height: 40)
            self.view.addSubview(btn)
        }
    }
    
    // MARK: - 点击事件
    
    @objc
    func signInWithApple() {
        
        if KeychainItem.currentUserIdentifier == "" {
            
           SignInAppleManager.shareInstance.handleAuthorizationAppleIDButtonPress()
            
        } else {
            //苹果还把 iCloud KeyChain password 集成到了这套 API 里，我们在使用的时候，只需要在创建 request 的时候，多创建一个 ASAuthorizationPasswordRequest，这样如果 KeyChain 里面也有登录信息的话，可以直接使用里面保存的用户名和密码进行登录。
            SignInAppleManager.shareInstance.perfomExistingAccountSetupFlows()
        }
    }
}

