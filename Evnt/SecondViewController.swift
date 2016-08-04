//
//  SecondViewController.swift
//  Evnt
//
//  Created by Zixuan Zhao on 7/22/16.
//  Copyright © 2016 Zixuan Zhao. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SecondViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var loginButton: FBSDKLoginButton! = {
        let button = FBSDKLoginButton()
        //button.readPermissions = ["email", "public_profile", "user_friends"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.delegate = self
        dumpProfile()
        fetchProfile()
    }

    func fetchProfile() {
        if FBSDKAccessToken.current() != nil {
            let parameters = ["fields": "id, email, first_name, last_name, picture.type(large)"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, user, requestError) -> Void in
                
                if requestError != nil {
                    print(requestError)
                    return
                }
                
                let id = user?["id"] as? String
                let email = user?["email"] as? String
                let firstName = user?["first_name"] as? String
                let lastName = user?["last_name"] as? String
                
                
                var pictureUrl = ""
                
                if let picture = user?["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
                    pictureUrl = url
                }
                
                let url = URL(string: pictureUrl)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.profilePicture.image = image
                    })
                    
                }).resume()
                
                print("id: \(id)")
                if(firstName != nil && lastName != nil)
                {
                    self.username.text = "\(firstName!) \(lastName!)"
                }
                if(email != nil)
                {
                    self.caption.text = "\(email!)"
                }
                self.showFriends()
            })
        }
    }
    
    struct Friend {
        var id, name, picture: String?
    }
    
    func showFriends() {
        FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name,picture.type(normal),gender"]).start(completionHandler: { (connection, user, requestError) -> Void in
            if requestError != nil {
                print(requestError)
                return
            }
            
            var friends = [Friend]()
            for friendDictionary in user?["data"] as! [NSDictionary] {
                let id = friendDictionary["id"] as? String
                let name = friendDictionary["name"] as? String
                if let picture = friendDictionary["picture"]?["data"]?!["url"] as? String {
                    let friend = Friend(id: id, name: name, picture: picture)
                    friends.append(friend)
                }
            }
            print(friends)
            
        })
        
    }
    
    func dumpProfile()
    {
        self.profilePicture.image = nil
        self.username.text = ""
        self.caption.text = ""
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        loginButton.readPermissions = ["email", "public_profile", "user_friends"]
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        fetchProfile()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        dumpProfile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

