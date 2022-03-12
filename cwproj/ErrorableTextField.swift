//
//  ErrorableTextField.swift
//  cwproj
//
//  Created by cloud-wise on 11/03/2022.
//

import UIKit

//Unsuccessful attempt at making a general purpose "ErrorableTextField"
@IBDesignable
class ErrorableTextField: UIView {

    @IBOutlet var rootView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        myInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        myInit()
        rootView?.prepareForInterfaceBuilder()
    }
    
    func myInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        rootView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let nibName = String(describing: ErrorableTextField.self)
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self,options: nil).first as? UIView
    }

}
