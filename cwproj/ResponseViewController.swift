//
//  ResponseViewController.swift
//  cwproj
//
//  Created by cloud-wise on 11/03/2022.
//

import UIKit

class ResponseViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var responseData: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = responseData
    }
}
