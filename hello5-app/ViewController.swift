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
    
    var name:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SCFacebook.initWithReadPermissions(["email","public_profile"], publishPermissions: [])
        
        if FBSDKAccessToken.current() != nil {
            self.getFacebookUser()
        }else{
        
            SCFacebook.loginCallBack { (success, result) in
            SCFacebook.getUserFields("email", callBack: { (success, result) in
                if !success {
                    print("failed to login")
                    return
                }
                self.getFacebookUser()
            })
            }
        }
    }
    
    func getFacebookUser (){
        FBSDKGraphRequest.init(graphPath: "me", parameters: nil).start(completionHandler: { (connection, result, error) in
            let dict = result as! [String : AnyObject]
            let user_id = dict["id"] as! String
            let name = dict["name"] as! String
            
            print(name)
            self.name = name
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

