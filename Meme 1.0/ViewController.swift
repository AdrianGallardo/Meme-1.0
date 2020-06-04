//
//  ViewController.swift
//  ImageSelector
//
//  Created by Adrian Gallardo on 29/05/20.
//  Copyright © 2020 adriangallardo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	//MARK: - Outlets
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var btnFile: UIBarButtonItem!
	@IBOutlet weak var btnCamera: UIBarButtonItem!
	@IBOutlet weak var txtfTop: UITextField!
	@IBOutlet weak var txtfBottom: UITextField!
	@IBOutlet weak var btnShare: UIBarButtonItem!
	@IBOutlet weak var btnCancel: UIBarButtonItem!
	@IBOutlet weak var bottomToolbar: UIToolbar!
	@IBOutlet weak var upperToolbar: UIToolbar!
	
	//MARK: - Life cycle
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		subscribeToKeyboardNotifications()
		
		btnCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
		btnShare.isEnabled = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let paragraph = NSMutableParagraphStyle()
		paragraph.alignment = .center
		
		let memeTextAttributes: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.strokeColor: UIColor.black,
			NSAttributedString.Key.foregroundColor: UIColor.white,
			NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
			NSAttributedString.Key.strokeWidth: -3.0
			
		]
		txtfTop.defaultTextAttributes = memeTextAttributes
		txtfBottom.defaultTextAttributes = memeTextAttributes
		
		txtfTop.textAlignment = NSTextAlignment.center
		txtfBottom.textAlignment = NSTextAlignment.center
		
		txtfTop.attributedText = NSAttributedString(string: "TOP",
																									 attributes: [.paragraphStyle: paragraph])
		txtfBottom.attributedText = NSAttributedString(string: "BOTTOM",
																								 attributes: [.paragraphStyle: paragraph])
	}
	
	//MARK: - Delegate Methods
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			self.image.image = image
		}
		
		dismiss(animated: true, completion: nil)
		btnShare.isEnabled = true
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
		
		btnShare.isEnabled = false
	}
	
	//MARK: - Actions
	@IBAction func pickAnImageFromFile(_ sender: Any) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func pickAnImageFromCamera(_ sender: Any) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .camera
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func shareMeme(_ sender: Any) {
		let memedImage: UIImage = generateMemedImage()
		let ac = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
		
		ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
			if completed == true{
				self.save()
				self.dismiss(animated: true, completion: nil)
			}
		}
		
		self.present(ac, animated: true, completion: nil)
	}
	
	@IBAction func cancel(_ sender: Any) {
		self.image.image = nil
		self.txtfTop.text = "TOP"
		self.txtfBottom.text = "BOTTOM"
		self.btnShare.isEnabled = false
	}
	

	//MARK: - Auxiliar Functions
	func subscribeToKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func keyboardWillShow(_ notification:Notification) {
		guard txtfBottom.isEditing else{
			return
		}
		if self.view.frame.origin.y == 0 {
				self.view.frame.origin.y -= getKeyboardHeight(notification)
		}
	}
	
	@objc func keyboardWillHide(_ notification:Notification) {
		if self.view.frame.origin.y != 0 {
			self.view.frame.origin.y = 0
		}
	}
	
	func getKeyboardHeight(_ notification:Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.cgRectValue.height
	}
	
	func generateMemedImage() -> UIImage {
		upperToolbar.isHidden = true
		bottomToolbar.isHidden = true
		
		// Render view to an image
		UIGraphicsBeginImageContext(self.view.frame.size)
		view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
		let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		upperToolbar.isHidden = false
		bottomToolbar.isHidden = false
			
		return memedImage
	}
	
	func save() {
		let meme = Meme(originalImage: image.image!, topText:  txtfTop.text!, bottomText: txtfBottom.text!, memedImage: generateMemedImage())
	}
	
}

