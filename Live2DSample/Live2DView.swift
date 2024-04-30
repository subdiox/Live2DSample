import UIKit
import SwiftUI
import Live2DMetal

struct Live2DView: UIViewControllerRepresentable {
    typealias UIViewControllerType = Live2DViewController

    func makeUIViewController(context: Context) -> Live2DViewController {
        Live2DViewController()
    }

    func updateUIViewController(
        _ uiViewController: Live2DViewController,
        context: Context
    ) {}
}
