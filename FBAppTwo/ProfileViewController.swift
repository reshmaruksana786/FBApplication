//
//  ProfileViewController.swift
//  FBAppTwo
//
//  Created by Manjunadh Bommisetty on 21/01/20.
//  Copyright © 2020 BRN. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FacebookShare

class ProfileViewController: UIViewController,SharingDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
        print("sharing success")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("sharing with error")
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        
        print("sharing cancel")
    }
    
    
    @IBOutlet weak var profileImgView: UIImageView!
    
    
    @IBOutlet weak var profileNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let myGraphRequest = GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, email, birthday, age_range, picture.width(400), gender"], tokenString: AccessToken.current?.tokenString, version: Settings.defaultGraphAPIVersion, httpMethod: .get)
         
        let connection = GraphRequestConnection()
        connection.add(myGraphRequest, completionHandler: { (connection, values, error) in
                if let responseDict = values as? [String:Any] {
                        
                    
                    let fullName = responseDict["name"] as! String
                    let firstName = responseDict["first_name"] as! String
                    let lastName = responseDict["last_name"] as! String
                    //let email = responseDict["email"] as! String
                    let idFb = responseDict["id"] as! String
                    let pictureDict = responseDict["picture"] as! [String:Any]
                    let imageDict = pictureDict["data"] as! [String:Any]
                    let imageUrl = imageDict["url"] as! String
                    
                    print("user id: \(idFb), firstName: \(firstName), fullname: \(fullName), lastname: \(lastName), picture: \(imageUrl)")
                    
                    do{
                        self.profileImgView.image = UIImage(data: try Data(contentsOf: URL(string: imageUrl)!))
                        
                        self.profileNameLbl.text = fullName
                    }catch
                    {
                        print("image something wrong")
                    }
                }
        })
        
        connection.start()
        
    }
    
    
    @IBAction func onShareLink(_ sender: Any) {
        
        
        let content = ShareLinkContent()
        content.contentURL = URL(string: "https://newsroom.fb.com/")!
        content.quote = "hahaha"
        
        
        let shareDialog = ShareDialog(fromViewController: self, content: content, delegate: self)
        
        shareDialog.mode = .automatic
        shareDialog.show()
        
    }
    
    
    @IBAction func onSharePhoto(_ sender: Any)
    {
        
               imagePickerController.delegate = self
               imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
                
               present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func onShareVideo(_ sender: Any)
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"] //[String(kUTTypeMovie)]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Use editedImage Here
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Use originalImage Here
            dismiss(animated: true){
                // if app is available
                if UIApplication.shared.canOpenURL(URL(string: "fb://")!){
                    let photo = SharePhoto(image: originalImage, userGenerated: true)
                    let content = SharePhotoContent()
                    
                    content.photos = [photo]
                    
                    let shareDialog = ShareDialog(fromViewController: self, content: content, delegate: self)
                    
                    shareDialog.mode = .automatic
                    shareDialog.show()

                }else {
                    print("app not installed")
                    //                    UIApplication.shared.open(URL(string: "itms://itunes.apple.com/in/app/facebook/id284882215")!, options: [ : ], completionHandler: nil)
                }
            }
        }
            
        else if let videoURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            picker.dismiss(animated: true){
                // if app is available
                if UIApplication.shared.canOpenURL(URL(string: "fb://")!){
                    let video = ShareVideo(videoURL: videoURL)
                    let myContent = ShareVideoContent()
                    
                    myContent.video = video
                    let shareDialog = ShareDialog(fromViewController: self, content: myContent, delegate: self)
                    
                    shareDialog.mode = .automatic
                    shareDialog.show()
                }else {
                    print("app not installed")
                    //                  UIApplication.shared.open(URL(string: "itms://itunes.apple.com/in/app/facebook/id284882215")!, options: [ : ], completionHandler: nil)
                }
            }
        }
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

