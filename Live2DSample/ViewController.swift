import UIKit
import MetalKit
import Live2DMetalObjC
import Live2DMetalSwift

final class ViewController: MetalViewController {
    private var model: L2DModel?
    private weak var renderer: L2DRenderer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let path = Bundle.main.path(
            forResource: "hiyori_pro/hiyori_pro.model3",
            ofType: "json"
        ) {
            load(model: path)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesChanged(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesChanged(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesChanged(touches, with: event)
    }

    private func touchesChanged(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer, let touch = touches.first else { return }

        let location = touch.location(in: view)

        // Origin of window in screen.
        let origin = self.view.window?.frame.origin ?? .zero

        // Size of view.
        let size = self.view.frame.size

        // Origin in NDC coordinate.
        let ndcOrigin = renderer.origin

        // NDC to screen ratio.
        let scale = max(size.width, size.height)

        // Vector difference from model center.
        let v = CGPoint(
            x: location.x - origin.x - scale * (0.5 + ndcOrigin.x),
            y: location.y - origin.y - scale * (0.5 + ndcOrigin.y)
        )

        self.model?.setModelParameterNamed(
            "ParamAngleX",
            withValue: Float(2.0 * v.x / size.width) * 30.0
        )

        self.model?.setModelParameterNamed(
            "ParamAngleY",
            withValue: Float(-2.0 * v.y / size.height) * 30.0
        )
    }

    private func load(model path: String) {
        self.model = L2DModel(jsonPath: path)

        if let renderer = self.renderer {
            self.removeRenderer(renderer: renderer)
        }

        let renderer = L2DRenderer()
        renderer.model = model

        self.renderer = renderer

        self.addRenderer(renderer: renderer)
    }
}
