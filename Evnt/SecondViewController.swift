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
        button.readPermissions = ["email"]
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
            let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, user, requestError) -> Void in
                
                if requestError != nil {
                    print(requestError)
                    return
                }
                
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
                
                print("\(firstName!) \(lastName!), \(email), \(pictureUrl)")
                self.username.text = "\(firstName!) \(lastName!)"
                self.caption.text = "\(email!)"
            })
        }
    }
    
    func dumpProfile()
    {
        self.profilePicture.image = nil
        self.username.text = ""
        self.caption.text = ""
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
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

