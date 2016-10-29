//
//  ViewController.swift
//  hello5-app
//
//  Created by Mihai Iancu on 29/10/2016.
//  Copyright © 2016 MA. All rights reserved.
//

import UIKit
import SCFacebook

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SCFacebook.initWithReadPermissions(["email","public_profile"], publishPermissions: [])
        
        
        var token:String?
        
        if FBSDKAccessToken.current() != nil {
            token = FBSDKAccessToken.current().tokenString
            FBSDKGraphRequest.init(graphPath: "me", parameters: nil).start(completionHandler: { (connection, result, error) in
                let dict = result as! [String : AnyObject]
                let user_id = dict["id"] as! String
                let name = dict["name"] as! String
                
                print(name)
            })
            return
        }
        
        SCFacebook.loginCallBack { (success, result) in
            SCFacebook.getUserFields("email", callBack: { (success, result) in
                if !success {
                    print("failed to login")
                    return
                }
                print(result)
                token = FBSDKAccessToken.current().tokenString
                print(token)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

