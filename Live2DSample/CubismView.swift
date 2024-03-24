//
//  CubismView.swift
//  Live2DSample
//
//  Created by subdiox on 2024/03/24.
//

import UIKit
import SwiftUI

struct CubismView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController

    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }

    func updateUIViewController(
        _ uiViewController: ViewController,
        context: Context
    ) {}
}
