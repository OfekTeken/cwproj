//
//  ViewController.swift
//  cwproj
//
//  Created by cloud-wise on 10/03/2022.
//

import UIKit

class ViewController: UIViewController {
    
    let KPL_TO_MPG: Float = 2.352
    let FUEL_TYPE_KEY = "fuel_type"
    enum FuelType: String {
        case kpl, mpg
    }
    let EMAIL_REGEX = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
    @IBOutlet weak var emailField: AutoSaveTextField!
    @IBOutlet weak var passwordField: AutoSaveTextField!
    @IBOutlet weak var fullNameField: AutoSaveTextField!
    @IBOutlet weak var phoneField: AutoSaveTextField!
    @IBOutlet weak var vehicleField: AutoSaveTextField!
    @IBOutlet weak var fuelField: AutoSaveTextField!
    
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var fullNameError: UILabel!
    @IBOutlet weak var phoneError: UILabel!
    @IBOutlet weak var vehicleError: UILabel!
    @IBOutlet weak var fuelError: UILabel!
    
    @IBOutlet weak var convertButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        readFromUserDefaults()
        validateForm() //Initially set all error labels
    }
    
    func readFromUserDefaults() {
        //Read from UserDefaults (couldn't find a way to call read() on custom field init)
        for subview in view.subviews {
            if subview is AutoSaveTextField {
                (subview as! AutoSaveTextField).read()
            }
        }
        
        //Read fuel convert button state
        let type = FuelType(rawValue: UserDefaults.standard.string(forKey: FUEL_TYPE_KEY) ?? "")
        let nextType = type == FuelType.kpl || type == nil ? FuelType.mpg : FuelType.kpl
        convertButton.setTitle(nextType.rawValue, for: .normal)
        
        //Visually convert to mpg value when needed
        if(type == FuelType.mpg) {
            let fuel = Float(UserDefaults.standard.string(forKey: "FuelConsumtion") ?? "") ?? 0 //Get as kpl
            fuelField.text = String(fuel * KPL_TO_MPG)
        }
    }
    
    @IBAction func onFuelConvert() {
        guard fuelField.text != nil else { return }
        let fuel = Float(fuelField.text!) ?? 0
        let type = FuelType(rawValue: UserDefaults.standard.string(forKey: FUEL_TYPE_KEY) ?? "")
        
        fuelField.text = String(type == FuelType.kpl || type == nil
            ? Float(fuel) * KPL_TO_MPG
            : Float(fuel) / KPL_TO_MPG) //Visually convert
        
        let nextType = type == FuelType.kpl || type == nil ? FuelType.mpg : FuelType.kpl
        UserDefaults.standard.set(nextType.rawValue, forKey: FUEL_TYPE_KEY)
        convertButton.setTitle((type ?? FuelType.kpl).rawValue, for: .normal)
    }

    @IBAction func onSubmit() {
        guard validateForm() else { return }
                
        sendRequest { res in
            DispatchQueue.main.async {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "res_vc") as? ResponseViewController else { return }
                vc.responseData = res
                    
                self.present(vc, animated: true)
            }
        }
    }
    
    func sendRequest(onResponse: @escaping ((String) -> Void)) {
        guard let url = URL(string: "https://www.cloud-wise.net/CloudApps/Server/api/log") else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: getFormData())
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let str = String(data: data, encoding: String.Encoding.utf8) else { return }
            
            onResponse(str)
        }
        task.resume()
    }
    
    func validateForm() -> Bool {
        let isValidEmail = isValidRegex(str: emailField.text ?? "", pattern: EMAIL_REGEX)
        emailError.isHidden = isValidEmail
        
        let isValidPassword = (passwordField.text ?? "").count >= 8
        passwordError.isHidden = isValidPassword
        
        let isValidName = (fullNameField.text ?? "").count >= 2
        fullNameError.isHidden = isValidName
        
        let text = phoneField.text
        let isValidPhone = phoneField.text == "" || (phoneField.text != nil && phoneField.text!.count == 10)
        phoneError.isHidden = isValidPhone
        
        let vehicleNumber = (vehicleField.text ?? "")
        let isValidVehicle = vehicleNumber.count == 7 || vehicleNumber.count == 8
        vehicleError.isHidden = isValidVehicle
        
        let isValidFuel = fuelField.text != "" && calcFuel() < 100
        fuelError.isHidden = isValidFuel
        
        return isValidEmail && isValidPassword &&
                isValidName && isValidPhone &&
                isValidVehicle && isValidFuel
    }
    
    func getFormData() -> [String: AnyHashable] {
        var bodyTest: [String: AnyHashable] = [:]
        for subview in view.subviews {
            if subview is AutoSaveTextField {
                let textField = (subview as! AutoSaveTextField)
                if textField.userDefaultsKey == "FuelConsumtion" {
                    bodyTest[textField.userDefaultsKey!] = calcFuel()
                } else {
                    bodyTest[textField.userDefaultsKey!] = textField.text
                }
            }
        }
        return bodyTest
    }

    func isValidRegex(str: String, pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsStr = str as NSString
            let res = regex.matches(in: str, range: NSRange(location: 0, length: nsStr.length))
            return res.count != 0
        } catch let error as NSError {
            return false
        }
    }
    
    func calcFuel() -> Float {
        let type = FuelType(rawValue: UserDefaults.standard.string(forKey: FUEL_TYPE_KEY) ?? "")
        let fuel = Float(fuelField.text ?? "") ?? 0
        return type == FuelType.kpl || type == nil ? fuel : fuel / KPL_TO_MPG
    }
}
