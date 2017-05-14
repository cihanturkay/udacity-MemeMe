//
//  ViewController.swift
//  MemeMe
//
//  Created by Cihan Turkay on 04/05/2017.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit
import AVFoundation

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var topTextField: UITextField = UITextField()
    var bottomTextField: UITextField = UITextField()
    let defaultFontSize:CGFloat = 40
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topTextField)
        view.addSubview(bottomTextField)
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
        if sender.tag == UIImagePickerControllerSourceType.camera.rawValue || sender.tag == UIImagePickerControllerSourceType.photoLibrary.rawValue {
            imagePicker.sourceType = UIImagePickerControllerSourceType(rawValue: sender.tag)!
        }
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
        textField.defaultTextAttributes = getTextAttributes(1)
        textField.delegate = self
        textField.textAlignment = NSTextAlignment.center
        textField.frame.size.height = (textField.text?.size(attributes: textField.defaultTextAttributes).height)!
        textField.autocapitalizationType = .allCharacters
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
    }
    
    func setInitialViewState(){
        imagePickerView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        initTextField(topTextField)
        initTextField(bottomTextField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func save(_ memedImage:UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!,
                        originalImage: imagePickerView.image!, memedImage: memedImage)
        //save to photo lib
        UIImageWriteToSavedPhotosAlbum(meme.memedImage, nil, nil, nil)
    }
    
    
    func generateMemedImage() -> UIImage {
        //Render view to an image
        let inImage:UIImage = imagePickerView.image!
        let scaledFrame = AVMakeRect(aspectRatio: inImage.size, insideRect: imagePickerView.bounds)
        let scale = max(inImage.size.width/scaledFrame.width,inImage.size.height/scaledFrame.height)
        
        UIGraphicsBeginImageContext(inImage.size)
        inImage.draw(in: CGRect.init(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        var memeTextAttributes = getTextAttributes(scale * (topTextField.font?.pointSize)! / defaultFontSize)
        var textSize = topTextField.text?.size(attributes: memeTextAttributes)
        var rect:CGRect = CGRect.init(x: (inImage.size.width - (textSize?.width)!)/2, y: (inImage.size.height * 0.05), width: (textSize?.width)!, height: (textSize?.height)!)
        topTextField.text?.draw(in: rect, withAttributes: memeTextAttributes)
        
        memeTextAttributes = getTextAttributes(scale * (bottomTextField.font?.pointSize)! / defaultFontSize)
        textSize = bottomTextField.text?.size(attributes: memeTextAttributes)
        rect = CGRect.init(x: (inImage.size.width - (textSize?.width)!)/2, y: (inImage.size.height * 0.95 - (textSize?.height)!), width: (textSize?.width)!, height: (textSize?.height)!)
        bottomTextField.text?.draw(in: rect, withAttributes: memeTextAttributes)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
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
        view.layoutIfNeeded()
        if imagePickerView.image?.size != nil{
            let aspectRatioSize = imagePickerView.image?.size
            let scaledFrame = AVMakeRect(aspectRatio: aspectRatioSize!, insideRect: imagePickerView.frame)
            let margin = scaledFrame.size.height * 0.05
            topTextField.frame.size.width = scaledFrame.width
            bottomTextField.frame.size.width = scaledFrame.width
            topTextField.frame.origin.x = scaledFrame.origin.x
            bottomTextField.frame.origin.x = scaledFrame.origin.x
            topTextField.frame.origin.y = scaledFrame.origin.y + margin
            bottomTextField.frame.origin.y = scaledFrame.maxY - margin - bottomTextField.frame.height
        } else {
            let margin = imagePickerView.frame.size.height * 0.05
            topTextField.frame.size.width = imagePickerView.frame.width
            bottomTextField.frame.size.width = imagePickerView.frame.width
            topTextField.frame.origin.x = imagePickerView.frame.origin.x
            bottomTextField.frame.origin.x = imagePickerView.frame.origin.x
            topTextField.frame.origin.y = imagePickerView.frame.origin.y + margin
            bottomTextField.frame.origin.y = imagePickerView.frame.maxY - margin - bottomTextField.frame.height
        }
        view.layoutIfNeeded()
        
    }
    
    func getTextAttributes(_ scale:CGFloat) -> [String:Any]{
        return [
            NSStrokeColorAttributeName : UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: scale * defaultFontSize)!,
            NSForegroundColorAttributeName : UIColor.white,
            NSStrokeWidthAttributeName : -2.0] as [String : Any]
    }
    
    
}

