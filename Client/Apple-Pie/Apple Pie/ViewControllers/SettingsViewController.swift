//
//  SettingsViewController.swift
//  Apple Pie
//
//  Created by Михаил Медведев on 01/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController {
    
    let networkController = NetworkController()
    
    var categories: [Category]?
    var currentCategory: Category!
    
    @IBOutlet weak var changeCategoryButton: UIButton!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryNameLabel.text = currentCategory.name

        networkController.fetchCategories { categories in
            if let categories = categories {
                self.categories = categories
                self.changeCategoryButton.isEnabled = true
            } else {
                self.changeCategoryButton.isEnabled = false
            }
        }
    }
    
}

// MARK: - Navigation
extension SettingsViewController {
    @IBAction func unwind(_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destination as! PopUpViewController
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.categories = categories
            popoverViewController.selectedCategory = currentCategory
            
        } else if segue.identifier == "confirmSegue" {
            let mainViewController = segue.destination as! MainViewController
            mainViewController.currentCategory = currentCategory
        }
    }
}


// MARK: - UIPopoverPresentationControllerDelegate
extension SettingsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Tells iOS that we do NOT want to adapt the presentation style for iPhone
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 1.0)
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 0.7)
    }
}

// MARK: - setAlphaOfBackgroundViews
extension SettingsViewController {
    func setAlphaOfBackgroundViews(alpha: CGFloat) {
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        UIView.animate(withDuration: 0.2) {
            statusBarWindow?.alpha = alpha;
            self.view.alpha = alpha;
            self.navigationController?.navigationBar.alpha = alpha;
        }
    }
}
