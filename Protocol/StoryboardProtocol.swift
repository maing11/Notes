//
//  StoryboardProtocol.swift
//  Things+
//
//  Created by Larry Nguyen on 4/2/19.
//  Copyright © 2019 Larry. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboardable: class {
    static var storyboardName: String { get }
}

extension Storyboardable where Self: UIViewController {
    static var storyboardName: String {
        return String(describing: self)
    }
    
    static func storyboardViewController<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: T.storyboardName, bundle: nil)
        
        guard let vc = storyboard.instantiateInitialViewController() as? T else {
            fatalError("failed to instantiate initial storyboard with name: \(T.storyboardName)")
        }
        
        return vc
    }
}

extension UIViewController: Storyboardable { }
