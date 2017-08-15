//
//  ModalView.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 13-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit
import Foundation

class Modal:UIView {
    
    enum componentType {
        case message
        case textfield
    }
    
    // MARK: Constants
    
    var offset:CGFloat!
    var contentWidth:CGFloat!
    var modalWidth:CGFloat!
    
    // MARK: Outlets
    
    var buttonComponent: UIButton!
    var textfieldComponent: UITextField?
    var textfieldComponent2: UITextField?
    
    // MARK: Values
    
    var titleString: String = "Whoop Whoop"
    var buttonString: String = "OKAY!"
    var messageString: String = ""
    var textfieldString: String = ""
    var textfieldString2: String = ""
    
    // MARK: Initializers
    
    init(offset: CGFloat) {
        super.init(frame: UIApplication.shared.keyWindow!.frame)
        self.tag = 3
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        self.offset = offset
        self.modalWidth = self.frame.size.width - 100
        self.contentWidth = modalWidth - ( offset * 2 )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(with message:String) {
        self.init(offset: 20)
        
        messageString = message
        buttonString = "OKAY!"
        
        let components:[AnyObject] = load(for: [.message])
        let modal:UIView = create(with: components)
        self.addSubview(modal)
    }
    
    convenience init(with message:String, button:String) {
        self.init(offset: 20)
        
        messageString = message
        buttonString = button
        
        let components:[AnyObject] = load(for: [.message])
        let modal:UIView = create(with: components)
        self.addSubview(modal)
    }
    
    convenience init(warning:String, button:String) {
        self.init(offset: 20)
        
        messageString = warning
        buttonString = button
        
        let components:[AnyObject] = load(for: [.message])
        let modal:UIView = create(with: components)
        
        buttonComponent.backgroundColor = UIColor.customRed
        buttonComponent.setTitleColor(.white, for: .normal)
        
        self.addSubview(modal)
    }
    
    convenience init(with message:String, textfield:String, button:String) {
        self.init(offset: 20)
        
        messageString = message
        buttonString = button
        textfieldString = textfield
        
        let components:[AnyObject] = load(for: [.message, .textfield])
        let modal:UIView = create(with: components)
        self.addSubview(modal)
    }
    
    convenience init(with message:String, textfield:String, textfield2:String, button:String) {
        self.init(offset: 20)
        
        messageString = message
        buttonString = button
        textfieldString = textfield
        textfieldString2 = textfield2
        
        let components:[AnyObject] = load(for: [.message, .textfield, .textfield])
        let modal:UIView = create(with: components)
        self.addSubview(modal)
    }
    
        
    // MARK: Load components
    
    private func load(for types:[componentType]) -> [AnyObject] {
        var components:[AnyObject] = []
        let titleComponent:UILabel = createLabel(for: titleString)
        components.append(titleComponent)
        
        for (index, element) in types.enumerated() {
            guard components.count > index else { return components }
            
            let previousComponent:AnyObject = components[index]
            var newComponent:AnyObject!
            
            if element == .message {
                newComponent = createMessage(for: messageString, below: previousComponent)
            }
            if element == .textfield {
                newComponent = createTextfield(value: textfieldString, below: previousComponent)
            }
            
            components.append(newComponent)
        }
        
        let buttonFrame:CGRect = CGRect(x: modalWidth / 4, y: offset + components.last!.frame.origin.y + components.last!.frame.size.height, width: modalWidth / 2, height: 50)
        buttonComponent = createButton(for: buttonString, frame: buttonFrame)
        components.append(buttonComponent)
        
        let cancelFrame:CGRect = CGRect(x: modalWidth / 4, y: offset + buttonComponent.frame.origin.y + buttonComponent.frame.size.height, width: modalWidth / 2, height: 10)
        let cancelComponent = createCancelButton(for: "cancel", frame: cancelFrame)
        components.append(cancelComponent)
        
        return components
    }
    
    // MARK: createModalpreviousComponent
    
    private func create(with components:[AnyObject]) -> UIView {
        let wrapper:UIView = createWrapper()
        
        var modalHeight:CGFloat = 0
        components.forEach { (component) in
            let view = component as! UIView
            modalHeight += (offset + view.frame.size.height)
            wrapper.addSubview(view)
        }
        
        wrapper.frame = CGRect(x: 0, y: 0, width: modalWidth, height: modalHeight + offset )
        wrapper.center = self.center
        return wrapper
    }
    
    // MARK: Helpers
    
    private func createWrapper() -> UIView {
        let wrapper:UIView = UIView()
        wrapper.backgroundColor = .white
        wrapper.layer.cornerRadius = 8
        wrapper.center = self.center
        return wrapper
    }
    
    private func createLabel(for text: String) -> UILabel {
        let label:UILabel = UILabel(frame: CGRect(x: offset, y: offset, width: contentWidth, height: 30))
        label.text = text
        label.textColor = UIColor.customDarkGray
        label.font = UIFont(name: "HelveticaNeue-thin", size: 30)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
    
    private func createMessage(for text: String, below previous:AnyObject) -> UILabel {
        let frame = CGRect(x: offset, y: offset + previous.frame.origin.y + previous.frame.size.height, width: contentWidth , height: 80)
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.textColor = UIColor.customDarkGray
        label.font = UIFont(name: "HelveticaNeue-thin", size: 20)
        label.textAlignment = .center
        label.numberOfLines = 5
        label.sizeToFit()
        return label
    }
    
    private func createButton(for title: String, frame:CGRect) -> UIButton {
        let button:UIButton = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.customDarkGray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(self.hideModal), for: .touchUpInside)
        return button
    }
    
    private func createCancelButton(for title: String, frame:CGRect) -> UIButton {
        let button:UIButton = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "helveticaNeue", size: 12)
        button.tintColor = UIColor.customDarkGray
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(self.hideModal), for: .touchUpInside)
        return button
    }
    
    private func createTextfield(value: String, below previous: AnyObject) -> UIView {
        let frame = CGRect(x: offset, y: offset + previous.frame.origin.y + previous.frame.size.height, width: contentWidth , height: 50)
        let view:UIView = UIView(frame: frame)
        
        let top:UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 1))
        top.backgroundColor = .customGray
        view.addSubview(top)
        
        let bottom:UIView = UIView(frame: CGRect(x: 0, y: frame.size.height - 1, width: frame.size.width, height: 1))
        bottom.backgroundColor = .customGray
        view.addSubview(bottom)
        
        let tfComponent = UITextField(frame: CGRect(x: 10, y: 0, width: frame.size.width - 20, height: frame.size.height))
        tfComponent.text = value
        tfComponent.font = UIFont(name: "HelveticaNeue-thin", size: 20)
        tfComponent.textAlignment = .center
        tfComponent.tag = 1
        
        if textfieldComponent == nil {
            textfieldComponent = tfComponent
        }
        else {
            tfComponent.text = textfieldString2
            tfComponent.tag = 2
            textfieldComponent2 = tfComponent
        }
        
        view.addSubview(tfComponent)
        return view
    }
    
    @objc func hideModal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
    
    
}
