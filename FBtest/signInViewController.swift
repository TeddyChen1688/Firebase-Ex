//
//  signiIViewController.swift
//  FBtest
//
//  Created by eva on 2018/5/24.
//  Copyright © 2018年 Lextronic. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class signInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        print("使用者已經登入: \(Auth.auth().currentUser)")
//        try! Auth.auth().signOut()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0), NSAttributedStringKey.font: customFont ]
        }
        
        self.title = ""
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        print("開始登錄了")
        
        guard let email = emailField.text, let password = passwordField.text else {
            print ("Email 或密碼登入錯誤")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            
            if let error = error {
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Email verification
            guard let currentUser = user, currentUser.isEmailVerified else {
                let alertController = UIAlertController(title: "Login Error", message: "You haven't confirmed your email address yet. Please click the verification link in that email. If you need us to send the confirmation email again, please tap Resend Email.", preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: "Resend email", style: .default, handler: { (action) in
                    user?.sendEmailVerification(completion: nil)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Present the main view
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainFlow") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
            print (" 使用者 \(user?.email) 登入成功")
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        print (" 使用者登出")
        try! Auth.auth().signOut()
    }
    
    // MARK: - Action methods
    
    @IBAction func unwindtoWelcomeView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // Present the main view
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainFlow") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
            
        }
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        // Validate the input
        guard let emailAddress = emailField.text,
            emailAddress != "" else {
                
                let alertController = UIAlertController(title: "Input Error", message: "Please provide your email address for password reset.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Send password reset email
        Auth.auth().sendPasswordReset(withEmail: emailAddress, completion: { (error) in
            
            let title = (error == nil) ? "Password Reset Follow-up" : "Password Reset Error"
            let message = (error == nil) ? "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password." : error?.localizedDescription
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                
                if error == nil {
                    
                    // Dismiss keyboard
                    self.view.endEditing(true)
                    
                    // Return to the login screen
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            })
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
        
    }

    
    @IBAction func googleLogin(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
}

extension signInViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Present the main view
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainFlow") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

