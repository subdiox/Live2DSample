import UIKit
import SwiftUI
import Live2DMetal

struct Live2DView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController

    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }

    func updateUIViewController(
        _ uiViewController: ViewController,
        context: Context
    ) {}
}
