//
//  Network.swift
//  Youth Bishopric Radio
//
//  Created by Petra Software on 15/08/2021.
//

import Foundation
import Alamofire
class Netwwork {
    let token = UserDefaults.standard.string(forKey: "token")
    typealias commentsCallBack 	= (_ comments:[Comment]? ,_ status: Bool,_ message: String) -> Void
    var callBack: commentsCallBack?
    fileprivate var baseUrl = ""
    init(baseUrl:String) {
        self.baseUrl = baseUrl
    }
    func getComments(){
        AF.request(self.baseUrl + "getcomments.php" , method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response
        { (response) in
//            print(response)
            print("We Got Response")
            guard let data = response.data else {
                self.callBack?(nil,	false, "")
                return
            }
            do {
                let comments = try JSONDecoder().decode([Comment].self,from: data)
                print("Comments\(comments)")
                self.callBack?(comments,true,"")
            }catch{
                print("Error Decoding Json")
                self.callBack?(nil,false,error.localizedDescription)
            }
        }
        
    }
    func completionHandler(callBack: @escaping commentsCallBack){
        self.callBack = callBack
    }
    func sendComment(text:String){
        let param : Parameters = ["comment_text":"\(text)","device_id":"0"]
        AF.request(self.baseUrl + "add_comment.php" , method: .post, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil).response
        { (response) in
//            print(response)
            print("We Got Response")
            guard let data = response.data else {
                self.callBack?(nil,    false, "")
                return
            }
            
            
        }
        
    }
    func likeOrUnlike(state:Int){
        
        let param : Parameters = ["state":"\(state)"]
        AF.request(self.baseUrl + "like_unlike.php" , method: .post, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil).response
        { (response) in
            print(response)
            print("We Got Response")
            guard let data = response.data else {
                self.callBack?(nil,    false, "")
                return
            }
        }
        
    }
    func sendToken(){
       
        if let valueToken = UserDefaults.standard.string(forKey: "token") {
                let token = valueToken
                print("TOKen Saved: \(token)")
                let param : Parameters = ["device_token":"\(token )"]
                AF.request(self.baseUrl + "add_token.php" , method: .post, parameters: param, encoding: URLEncoding.default, headers: nil, interceptor: nil).response
                { (response) in
                    
                    print("We Got Response")
                    guard let data = response.data else {
                        self.callBack?(nil, false, "")
                        return
                    }
                }
                
            
        }else {
            return
        }
        
    }
}
