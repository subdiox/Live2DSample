import Foundation
import Metal
import QuartzCore
import CubismNativeFramework
import Live2DMetalObjC

final class Live2DManager {
    var viewMatrix: Csm.CubismMatrix44 = .init()    // View matrix used for model rendering
    var model: LAppModel? = .init()      // Container of model instances
    var sceneIndex: Int = 0            // Index of the current scene to display
    let renderPassDescriptor = MTLRenderPassDescriptor()
    var sprite: LAppSprite?
    var clearColorR: Float = 0.0
    var clearColorG: Float = 0.0
    var clearColorB: Float = 0.0
    var modelDirectories: [String] = []   // Container for model directory names

    init() {
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.clearDepth = 1.0
        
        setupModel()
        changeScene(to: sceneIndex)
    }

    func setupModel() {
        let bundlePaths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: Constant.resourcesPath)

        modelDirectories = bundlePaths.compactMap { path in
            let modelName = URL(fileURLWithPath: path).lastPathComponent
            let modelDirPath = Constant.resourcesPath + "/" + modelName + "/"
            guard Bundle.main.paths(forResourcesOfType: ".model3.json", inDirectory: modelDirPath).count == 1 else { return nil }
            return modelName
        }.sorted()
    }

    func onDrag(x: Float, y: Float) {
        model?.SetActualDragging(x, y)
    }

    func onTap(x: Float, y: Float) {
        if model?.HitTest(Constant.hitAreaNameHead, x, y) == true {
            if Constant.debugLogEnable {
                LAppPal.PrintMessageLn("[APP]hit area: [\(Constant.hitAreaNameHead)]")
            }
            model?.SetRandomExpression()
        } else if model?.HitTest(Constant.hitAreaNameBody, x, y) == true {
            if Constant.debugLogEnable {
                LAppPal.PrintMessageLn("[APP]hit area: [\(Constant.hitAreaNameBody)]")
            }
            model?.TryRandomMotion(Constant.motionGroupTapBody, MotionPriority.force.rawValue) { motion in
                LAppPal.PrintMessageLn("Motion Finished: \(motion)")
            }
        }
    }

    func onUpdate(
        commandBuffer: MTLCommandBuffer,
        currentDrawable: CAMetalDrawable,
        depthTexture: MTLTexture?,
        frame: CGRect
    ) {
        let width = Float(frame.width)
        let height = Float(frame.height)

        let device = cubismRenderingInstance?.getMTLDevice()

        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.depthAttachment.texture = depthTexture

        CubismNativeProxy.startFrameInMetalRenderer(
            with: device,
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor
        )

        var projection = Csm.CubismMatrix44()
        projection.Scale(height / width, 1.0)
        projection.MultiplyByMatrix(&viewMatrix)

        model?.Update()
        model?.Draw(&projection)
    }

    func nextScene() {
        sceneIndex = (sceneIndex + 1) % modelDirectories.count
        changeScene(to: sceneIndex)
    }

    func changeScene(to index: Int) {
        sceneIndex = index

        if Constant.debugLogEnable {
            LAppPal.PrintMessageLn("[APP]model index: \(sceneIndex)")
        }

        let modelDir = modelDirectories[index]
        let modelPath = Constant.resourcesPath + modelDir + "/"
        let modelJsonName = modelDir + ".model3.json"

        model?.Destroy()
        model?.LoadAssets(modelPath, modelJsonName)
    }

    func setViewMatrix(_ viewMatrix: inout Csm.CubismViewMatrix) {
        for i in 0..<16 {
            self.viewMatrix.GetArray()![i] = viewMatrix.GetArray()![i];
        }
    }

    private var cubismRenderingInstance: CubismRenderingInstanceSingleton_Metal? {
        CubismRenderingInstanceSingleton_Metal.sharedManager() as? CubismRenderingInstanceSingleton_Metal
    }
}
