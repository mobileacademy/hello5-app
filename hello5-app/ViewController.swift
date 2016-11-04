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

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var messageList: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var user_name:String?
    var user_id:String?
    var messages:[Message] = [Message]()
    
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
        
        Timer.scheduledTimer(timeInterval: 1, target: self,
                             selector: #selector(self.refreshMessages), userInfo: nil, repeats: true)
        //
        self.someKeyboardHooks()
        textField.delegate = self;
        messageList.dataSource = self;
    }
    
    func getFacebookUser (){
        FBSDKGraphRequest.init(graphPath: "me", parameters: nil).start(completionHandler: { (connection, result, error) in
            let dict = result as! [String : AnyObject]
            let user_id = dict["id"] as! String
            let name = dict["name"] as! String

            self.user_id = user_id
            self.user_name = name
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
    
    // MARK: - messages table/list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let message = self.messages[indexPath.row]
        (cell.viewWithTag(902) as! UILabel).text = message.user_name
        (cell.viewWithTag(903) as! UILabel).text = message.text
        let uiImageView = cell.viewWithTag(901) as! UIImageView
        if message.user_id != nil{
            let url = "https://graph.facebook.com/v2.8/"+message.user_id!+"/picture"
            uiImageView.sd_setImage(with: URL(string: url))
        }else{
            uiImageView.image = UIImage.init(named:"guest_user");
        }
        return cell;
    }
    
    func refreshMessages(){
        Messages.instance.fetchMessages { (messages) in
            self.messages = messages
            self.uiUpdateTable()
        }
    }
    
    func uiUpdateTable(){
        self.messageList.reloadData()
        if messages.count > 1 {
            self.messageList.scrollToRow(at: IndexPath.init(row: messages.count-1, section: 0), at: .top, animated: true)
        }
    }
    
    
    // MARK: - keyboard
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
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
        print(deltaHeight)
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let moveUp = (notification.name == NSNotification.Name.UIKeyboardWillShow)

        self.bottomConstraint.constant -= deltaHeight;
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
        })
        self.uiUpdateTable()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let message = Message()
        message?.user_name = self.user_name
        message?.text = textField.text
        message?.user_id = self.user_id
        Messages.instance.send(message!) { (message:Message) in
            self.messages.append(message)
            self.uiUpdateTable()
        }
        
        textField.text = ""
        return false;
    }


}

