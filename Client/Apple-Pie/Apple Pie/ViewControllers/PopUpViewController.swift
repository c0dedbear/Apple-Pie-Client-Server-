//
//  PopUpViewController.swift
//  Apple Pie
//
//  Created by Михаил Медведев on 01/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var categories: [Category]!
    var selectedCategory: Category?
    
    let networkController = NetworkController()
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        
        //popover vc setup
        popoverPresentationController?.sourceView = doneButton
        popoverPresentationController?.sourceRect = doneButton.bounds
        preferredContentSize = CGSize(width: categoryPicker.frame.width , height: categoryPicker.frame.height + doneButton.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryPicker.selectRow(0, inComponent: 0, animated: false)
        selectedCategory = categories[0]
        networkController.fetchWords(for: selectedCategory!) { words in
            guard let words = words else { return }
            self.selectedCategory?.words = words
        }
    }
}

// MARK: - Navigation
extension PopUpViewController {

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindPopover" {
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.setAlphaOfBackgroundViews(alpha: 1.0)
            networkController.fetchWords(for: selectedCategory!) { words in
                guard let words = words else { return }
                self.selectedCategory?.words = words
                settingsViewController.currentCategory = self.selectedCategory
                DispatchQueue.main.async {
                settingsViewController.categoryNameLabel.text = self.selectedCategory?.name
                }
            }

        } 
     }
    
}


// MARK: - UIPickerViewDelegate
extension PopUpViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
}

// MARK: - UIPickerViewDataSource
extension PopUpViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    
}
