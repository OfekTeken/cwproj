//
//  AutoSaveTextField.swift
//  cwproj
//
//  Created by cloud-wise on 11/03/2022.
//

import UIKit

class AutoSaveTextField: UITextField {
    
    @IBInspectable var userDefaultsKey: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //TODO: How to improve saving? currently, it saves only when tapping out of the field bounds
        self.addTarget(self, action: #selector(save(_:)), for: .editingDidEnd)
    }
    
    @objc func save(_ sender: AutoSaveTextField) {
        if(self.userDefaultsKey == nil) { return }
        
        UserDefaults.standard.set(sender.text ?? "", forKey: self.userDefaultsKey!)
    }
    
    func read() {
        if self.userDefaultsKey == nil { return }
        guard let udValue = UserDefaults.standard.string(forKey: self.userDefaultsKey!) else { return }
        
        self.text = udValue
    }
}
