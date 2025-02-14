//
//  Examples.swift
//  LoafExamples
//
//  Created by Mat Schmid on 2019-02-24.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit
import Loaf

class Examples: UITableViewController {
    
    private enum Example: String, CaseIterable {
        case success  = "An action was successfully completed"
        case error    = "An error has occured"
        case warning  = "A warning has occured"
        case info     = "This is some information which should be displayed in multiple raws!"
        
        case bottom   = "This will be shown at the bottom of the view"
        case top      = "This will be shown at the top of the view"
        
        case vertical = "The loaf will be presented and dismissed vertically"
        case left     = "The loaf will be presented and dismissed from the left"
        case right    = "The loaf will be presented and dismissed from the right"
        case mix      = "The loaf will be presented from the left and dismissed vertically"
        
        case custom1  = "This will showcase using custom colors and font"
        case custom2  = "This will showcase using right icon alignment"
        case custom3  = "This will showcase using no icon and 90% screen size width, content inset for safe area"
		
        static let grouped: [[Example]] = [[.success, .error, .warning, .info],
                                           [.bottom, .top],
                                           [.vertical, .left, .right, .mix],
                                           [.custom1, .custom2, .custom3]]
    }
    
    private var isDarkMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "moon"), style: .done, target: self, action: #selector(toggleDarkMode))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(dismissLoaf))
    }
    
    @objc private func toggleDarkMode() {
        navigationController?.navigationBar.tintColor    = isDarkMode ? .black : .white
        navigationController?.navigationBar.barTintColor = isDarkMode ? .white : .black
        navigationController?.navigationBar.barStyle     = isDarkMode ? .default : .black
        tableView.backgroundColor                        = isDarkMode ? .groupTableViewBackground : .black
        
        if isDarkMode {
            Loaf("Switched to light mode", action: "Switch", style: .init(backgroundColor: .black, icon: UIImage(named: "moon")), sender: self).show(.short)
        } else {
            Loaf("Switched to dark mode", action: "Switch", style: .init(backgroundColor: .white, textColor: .black, tintColor: .black, icon: UIImage(named: "moon")), sender: self).show(.short)
        }
        
        tableView.reloadData()
        isDarkMode = !isDarkMode
    }
	
	@objc private func dismissLoaf() {
		// Manually dismisses the currently presented Loaf
		Loaf.dismiss(sender: self)
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Example.grouped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Example.grouped[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = Example.grouped[indexPath.section][indexPath.row]
        switch example {
        case .success:
            Loaf(example.rawValue, action: "Action", style: .init(backgroundColor: .blue, width: .screenPercentage(0.9)), sender: self).show()
        case .error:
            Loaf(example.rawValue, action: "Action", style: .error, sender: self).show()
        case .warning:
            Loaf(example.rawValue, action: "Action", style: .warning, sender: self).show()
        case .info:
            Loaf(example.rawValue, action: "Action", style: .default, sender: self).show()
            
        case .bottom:
            Loaf(example.rawValue, action: "Action", sender: self).show { dismissalType in
                switch dismissalType {
                case .tapped: print("Tapped!")
                case .performedAction: print("Action!")
                case .timedOut: print("Timmed out!")
                }
            }
        case .top:
            Loaf(example.rawValue, action: "Action", location: .top, sender: self).show()
            
        case .vertical:
            Loaf(example.rawValue, action: "Action", sender: self).show(.short)
        case .left:
            Loaf(example.rawValue, action: "Action", presentingDirection: .left, dismissingDirection: .left, sender: self).show(.short)
        case .right:
            Loaf(example.rawValue, action: "Action", presentingDirection: .right, dismissingDirection: .right, sender: self).show(.short)
        case .mix:
            Loaf(example.rawValue, action: "Action", presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.short)
            
        case .custom1:
            Loaf(example.rawValue, action: "Action", style: .init(backgroundColor: .purple, textColor: .yellow, tintColor: .green, font: .systemFont(ofSize: 18, weight: .bold), icon: Icon.success), sender: self).show()
        case .custom2:
            Loaf(example.rawValue, action: "Action", style: .init(backgroundColor: .purple, contentAlignment: .rightToLeft), sender: self).show()
        case .custom3:
            Loaf(example.rawValue, action: "Action", style: .init(backgroundColor: .black, icon: nil, textAlignment: .center, width: .screenPercentage(0.9), contentOffset: view.safeAreaInsets), sender: self).show(.custom(10000))
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = isDarkMode ? .black : .white
        cell.textLabel?.textColor = isDarkMode ? .white : .darkGray
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = isDarkMode ? .white : .darkGray
    }
}

public extension Loaf.Style {
    static let success = Loaf.Style(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Icon.success)
    static let warning = Loaf.Style(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Icon.warning)
    static let error = Loaf.Style(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Icon.error)
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public enum Icon {
    public static let success = Icons.imageOfSuccess().withRenderingMode(.alwaysTemplate)
    public static let error = Icons.imageOfError().withRenderingMode(.alwaysTemplate)
    public static let warning = Icons.imageOfWarning().withRenderingMode(.alwaysTemplate)
    public static let info = Icons.imageOfInfo().withRenderingMode(.alwaysTemplate)
}
