//
//  Messages.swift
//  hello5-app
//
//  Created by Mihai Iancu on 29/10/2016.
//  Copyright © 2016 MA. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class Message : Mappable{
    var id:Int?
    var text:String?
    var user_id:String?
    var user_name:String?
    
    required init?(map: Map){
    }
    
    init?(){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        user_id <- map["user_id"]
        user_name <- map["user_name"]
    }
}

class Messages {
    static let instance = Messages()
    
    var myPushToken:String?
    
    func fetchMessages(_ callback:@escaping (_ messages:[Message]) -> Void){
        let url = "https://hello6.herokuapp.com/messages.json"
        var headers:HTTPHeaders = [:]
        if self.myPushToken != nil {
            headers["X-Push-Token"] = self.myPushToken!
        }
        Alamofire.request(url, headers:headers).responseArray {(response:DataResponse<[Message]>) in
            guard let messages = response.result.value else {
                callback([]);
                return;
            }
            callback(messages)
        }
    }
    
    func send(_ message:Message, callback:@escaping (_ message:Message)->Void) {
        let url = "https://hello6.herokuapp.com/messages.json"
        let parameters = message.toJSON()
        Alamofire.request(url, method: .post, parameters:parameters, encoding: JSONEncoding.default).responseObject {
            (response: DataResponse<Message>) in
            callback(response.result.value!)
        }
    }
}
