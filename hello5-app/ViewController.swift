//
//  ViewController.swift
//  hello5-app
//
//  Created by Mihai Iancu on 29/10/2016.
//  Copyright © 2016 MA. All rights reserved.
//

import UIKit
import SCFacebook
import SDWebImage

class ViewController: UIViewController, UITextFieldDelegate {
    
    var name:String?
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textField: UITextField!
    
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
        
        Messages.instance.fetchMessages { (messages) in
            print(messages)
            print(messages.count)
            print(messages[0].text)
        }
        
        self.someKeyboardHooks()
        textField.delegate = self;
    }
    
    
    func getFacebookUser (){
        FBSDKGraphRequest.init(graphPath: "me", parameters: nil).start(completionHandler: { (connection, result, error) in
            let dict = result as! [String : AnyObject]
            let user_id = dict["id"] as! String
            let name = dict["name"] as! String
            
            print(name)
            self.name = name
            self.labelName.text = name;
            
            let url = "https://graph.facebook.com/v2.8/"+user_id+"/picture"
            self.imageUser.sd_setImage(with: URL(string: url))
        })
        
        print(FBSDKAccessToken.current().tokenString)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - keyboard 
    func someKeyboardHooks(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillChange),
                                               name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillChange),
                                               name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func keyboardWillChange(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let begin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue)
        let end = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue)
        let deltaHeight = (end.cgRectValue.origin.y+end.cgRectValue.height) - (begin.cgRectValue.origin.y+begin.cgRectValue.height)
        //print(deltaHeight)
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        self.bottomConstraint.constant -= deltaHeight;
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
        })
        //self.uiUpdateTable()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let message = Message()
//        message?.user_name = self.user_name
//        message?.text = textField.text
//        message?.user_id = self.user_id
//        Messages.instance.send(message!) { (message:Message) in
//            self.messages.append(message)
//            self.uiUpdateTable()
//        }
        
        print(textField.text)
        
        textField.text = ""
        return false;
    }

}

