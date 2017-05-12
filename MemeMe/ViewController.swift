//
//  ViewController.swift
//  MemeMe
//
//  Created by Cihan Turkay on 04/05/2017.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var topTextConstraint: NSLayoutConstraint!
    var bottomTextConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialViewState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK : ACTIONS
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType(rawValue: sender.tag)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        setInitialViewState()
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage = generateMemedImage()
        let shareViewController: UIActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareViewController.completionWithItemsHandler = { activity, success, items, error in
            if(success){
                self.save(memedImage)
            }
            shareViewController.dismiss(animated: true, completion: nil)
        }
        self.present(shareViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField.text?.characters.count == 0){
            if(textField == topTextField){
                textField.text = "TOP"
            }else{
                textField.text = "BOTTOM"
            }
        }
        
        return true
    }
    
    //MARK : Helpers
    
    func initTextField(_ textField: UITextField){
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSForegroundColorAttributeName : UIColor.white,
            NSStrokeWidthAttributeName : -2.0] as [String : Any]
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = NSTextAlignment.center
    }
    
    func setInitialViewState(){
        imagePickerView.image = nil
        initTextField(topTextField)
        initTextField(bottomTextField)
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(imagePickerView.frame)
        return true
    }
    
    
    func save(_ memedImage:UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!,
                        originalImage: imagePickerView.image!, memedImage: memedImage)
        //TODO: save will be available for the next version
    }
    

    func generateMemedImage() -> UIImage {
        //Render view to an image
        // Setup the font specific variables
        let inImage:UIImage = imagePickerView.image!
        let textColor: UIColor = UIColor.white
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 12)!
        print(inImage.size)
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        //Put the image into a rectangle as large as the original image.
        inImage.draw(in: CGRect.init(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect:CGRect = CGRect.init(x: 0, y: 0, width: 50, height: 250)
        
        //Now Draw the text into an image.
        "ASSSSSSS".draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
        
//        let scaledFrame = AVMakeRect(aspectRatio: (imagePickerView.image?.size)!, insideRect: imagePickerView.bounds)
//        UIGraphicsBeginImageContext(scaledFrame)
//        imagePickerView.drawHierarchy(in: self.imagePickerView.frame, afterScreenUpdates: true)
//        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        
//        return memedImage
    }
    
    //MARK : Keyboard Helpers
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Text Positioning
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        repositionTexts()
    }
    
    func repositionTexts(){
        var aspectRatioSize:CGSize!
        if imagePickerView.image?.size != nil{
            aspectRatioSize = imagePickerView.image?.size
        } else {
            aspectRatioSize = imagePickerView.bounds.size
        }
        
        self.view.layoutIfNeeded()
        let scaledFrame = AVMakeRect(aspectRatio: aspectRatioSize, insideRect: imagePickerView.bounds)
        if topTextConstraint != nil {
            view.removeConstraint(topTextConstraint)
        }
        
        if bottomTextConstraint != nil {
            view.removeConstraint(bottomTextConstraint)
        }
        
        let margin = scaledFrame.origin.y + scaledFrame.size.height * 0.05
        
        
        //Create and add the new constraints
        topTextConstraint = NSLayoutConstraint(
            item: topTextField,
            attribute: .top,
            relatedBy: .equal,
            toItem: imagePickerView,
            attribute: .top,
            multiplier: 1.0,
            constant: margin)
        view.addConstraint(topTextConstraint)
        
        bottomTextConstraint = NSLayoutConstraint(
            item: bottomTextField,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: imagePickerView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -margin)
        view.addConstraint(bottomTextConstraint)
        
        self.view.layoutIfNeeded()
        
    }

    
}

