//
//  ViewController.swift
//  ShieldApp
//
//  Created by Nirav Patel on 29/11/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let rootView = ContentView()
        let controller = UIHostingController(rootView: rootView)
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.didMove(toParent: self)
    }


}

