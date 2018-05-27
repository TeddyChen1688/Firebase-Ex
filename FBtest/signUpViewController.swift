//
//  signUpViewController.swift
//  FBtest
//
//  Created by eva on 2018/5/24.
//  Copyright © 2018年 Lextronic. All rights reserved.
//

import UIKit
import Firebase

class signUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        print("註冊了")
        
        guard let email = emailField.text, let password = passwordField.text,let confirmPassword = confirmPasswordField.text else {
            print ("資料登入錯誤")
            return
        }
        
        if password != confirmPassword {
            print("兩次輸入不一樣")
            return
        }
        
        // Register the user account on Firebase
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            guard let user = user else { //FIRuser
                print("註冊失敗!! \(error)")
                return
            }
            
//            // Save the name of the user
//            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
//                changeRequest.displayName = name
//                changeRequest.commitChanges(completion: { (error) in
//                    if let error = error {
//                        print("Failed to change the display name: \(error.localizedDescription)")
//                    }
//                })
//            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Send verification email
            user.sendEmailVerification(completion: nil)
            
            let alertController = UIAlertController(title: "Email Verification", message: "A confirmation email is sent to your mailbox. Please check it and click the verification link to complete the sign up.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                // Dismiss the current view controller
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            
            print (" 使用者 \(user.email) 註冊成功 ！！")
        })
    }
    
    @IBAction func backToSgnInTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
