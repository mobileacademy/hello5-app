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
    @IBOutlet weak var textField: UITextField!
    var messages:[Message] = [Message]()
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
            self.messages = messages
        }
        
        //
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
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    func someKeyboardHooks(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow),
                                               name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide),
                                               name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant += keyboardSize.height
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant -= keyboardSize.height
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let message = Message()
        message?.user_name = self.name
        message?.text = textField.text
        Messages.instance.send(message!) { (message:Message) in
            print(message)
        }
        
        textField.text = ""
        return false;
    }


}

