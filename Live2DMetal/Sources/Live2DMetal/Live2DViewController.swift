import UIKit
import Metal
import QuartzCore
import Live2DMetalObjC
import CubismNativeFramework

public final class Live2DViewController: UIViewController {
    public var commandQueue: MTLCommandQueue?

    private let touchManager = TouchManager()
    private var depthTexture: MTLTexture?
    private var back: LAppSprite? // Sprite for Background image
    private var gear: LAppSprite? // Sprite for Setting icon
    private var deviceToScreen = Csm.CubismMatrix44() // A matrix from device to screen
    private var viewMatrix = Csm.CubismViewMatrix()

    public override func viewDidLoad() {
        super.viewDidLoad()

        let textureManager = LAppTextureManager.getInstance()
        textureManager?.delegate = self

        // Registering MTLDevice in the singleton object since the framework layer also refers to MTLDevice
        let device = MTLCreateSystemDefaultDevice()
        cubismRenderingInstance?.setMTLDevice(device)

        let view = MetalUIView()
        self.view = view

        // Set the device for the layer so the layer can create drawable textures that can be rendered to on this device.
        view.metalLayer.device = device

        // Set this class as the delegate to receive resize and render callbacks.
        view.delegate = self

        view.metalLayer.pixelFormat = .bgra8Unorm
        cubismRenderingInstance?.setMetalLayer(view.metalLayer)

        commandQueue = device?.makeCommandQueue()

        initializeScreen()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeSprite()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)

        touchManager?.touchesBegan(Float(point.x), deciveY: Float(point.y))
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)

        let viewX = transformViewX(touchManager?.lastX ?? 0.0)
        let viewY = transformViewY(touchManager?.lastY ?? 0.0)

        touchManager?.touchesMoved(Float(point.x), deviceY: Float(point.y))
        LAppLive2DManager.getInstance()?.onDrag(viewX, floatY: viewY)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let point = touch.location(in: view)
        let pointY = transformTapY(Float(point.y))

        // Touch ended
        let live2DManager = LAppLive2DManager.getInstance()
        live2DManager?.onDrag(0.0, floatY: 0.0)
        if let getX = touchManager?.lastX, let getY = touchManager?.lastY {
            let x = deviceToScreen.TransformX(getX)
            let y = deviceToScreen.TransformY(getY)
            live2DManager?.onTap(x ?? 0.0, floatY: y ?? 0.0)
            // Did tap on gear?
            if gear?.isHit(Float(point.x), pointY: pointY) ?? false {
                live2DManager?.nextScene()
            }
        }
    }
}

// Private methods, computed variables
extension Live2DViewController {
    private func initializeScreen() {
        let screenRect = UIScreen.main.bounds
        let width = Float(screenRect.size.width)
        let height = Float(screenRect.size.height)

        // Using vertical size as the standard
        let ratio = width / height
        let left = -ratio
        let right = ratio
        let bottom = Constant.viewLogicalLeft
        let top = Constant.viewLogicalRight

        // Screen range corresponding to the device. Left and right edges of X, lower and upper edges of Y
        viewMatrix.SetScreenRect(left, right, bottom, top)
        viewMatrix.Scale(Constant.viewScale, Constant.viewScale)

        deviceToScreen.LoadIdentity() // Must reset when size changes
        if width > height {
            let screenW = fabsf(right - left)
            deviceToScreen.ScaleRelative(screenW / Float(width), -screenW / Float(width))
        } else {
            let screenH = fabsf(top - bottom)
            deviceToScreen.ScaleRelative(screenH / Float(height), -screenH / Float(height))
        }
        deviceToScreen.TranslateRelative(-Float(width) * 0.5, -Float(height) * 0.5)

        // Setting the display range
        viewMatrix.SetMaxScale(Constant.viewMaxScale) // Maximum zoom limit
        viewMatrix.SetMinScale(Constant.viewMinScale) // Minimum zoom limit

        // Maximum displayable range
        viewMatrix.SetMaxScreenRect(
            Constant.viewLogicalMaxLeft,
            Constant.viewLogicalMaxRight,
            Constant.viewLogicalMaxBottom,
            Constant.viewLogicalMaxTop
        )
    }

    private func resizeScreen() {
        guard let view else { return }
        let width = Float(view.frame.width)
        let height = Float(view.frame.height)

        // Using vertical size as the standard
        let ratio = width / height
        let left = -ratio
        let right = ratio
        let bottom = Constant.viewLogicalLeft
        let top = Constant.viewLogicalRight

        // Screen range corresponding to the device. Left and right edges of X, lower and upper edges of Y
        viewMatrix.SetScreenRect(left, right, bottom, top)
        viewMatrix.Scale(Constant.viewScale, Constant.viewScale)

        deviceToScreen.LoadIdentity() // Must reset when size changes
        if width > height {
            let screenW = fabsf(right - left)
            deviceToScreen.ScaleRelative(screenW / width, -screenW / width)
        } else {
            let screenH = fabsf(top - bottom)
            deviceToScreen.ScaleRelative(screenH / height, -screenH / height)
        }
        deviceToScreen.TranslateRelative(-width * 0.5, -height * 0.5)

        // Setting the display range
        viewMatrix.SetMaxScale(Constant.viewMaxScale) // Maximum zoom limit
        viewMatrix.SetMinScale(Constant.viewMinScale) // Minimum zoom limit

        // Maximum displayable range
        viewMatrix.SetMaxScreenRect(Constant.viewLogicalMaxLeft, Constant.viewLogicalMaxRight, Constant.viewLogicalMaxBottom, Constant.viewLogicalMaxTop)
    }

    private func initializeSprite() {
        guard let view else { return }
        let width = Float(view.frame.width)
        let height = Float(view.frame.height)

        let resourcesPath = Constant.resourcesPath
        let textureManager = LAppTextureManager.getInstance()

        // Background
        if let backgroundTexture = textureManager?.createTexture(
            fromPngFile: std.string(resourcesPath + Constant.backImageName)
        ).pointee {
            back = LAppSprite(
                x: width * 0.5,
                y: height * 0.5,
                width: Float(backgroundTexture.width) * 2,
                height: height * 0.95,
                maxWidth: width,
                maxHeight: height,
                texture: backgroundTexture.id
            )
        }

        // Model change button
        if let gearTexture = textureManager?.createTexture(
            fromPngFile: std.string(resourcesPath + Constant.gearImageName)
        ).pointee {
            gear = LAppSprite(
                x: width - Float(gearTexture.width) * 0.5,
                y: height - Float(gearTexture.height) * 0.5,
                width: Float(gearTexture.width),
                height: Float(gearTexture.height),
                maxWidth: width,
                maxHeight: height,
                texture: gearTexture.id
            )
        }
    }

    private func resizeSprite(width: Float, height: Float) {
        guard let view else { return }
        let maxWidth = Float(view.frame.width)
        let maxHeight = Float(view.frame.height)

        // Background
        if let back {
            back.resizeImmidiate(
                width * 0.5,
                y: height * 0.5,
                width: Float(back.texture.width) * 2.0,
                height: height * 0.95,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        }

        // Model change button
        if let gear {
            gear.resizeImmidiate(
                width - Float(gear.texture.width) * 0.5,
                y: height - Float(gear.texture.height) * 0.5,
                width: Float(gear.texture.width),
                height: Float(gear.texture.height),
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        }
    }

    private func transformViewX(_ deviceX: Float) -> Float {
        viewMatrix.InvertTransformX(deviceToScreen.TransformX(deviceX))
    }

    private func transformViewY(_ deviceY: Float) -> Float {
        viewMatrix.InvertTransformY(deviceToScreen.TransformY(deviceY))
    }

    private func transformTapY(_ deviceY: Float) -> Float {
        guard let height = view?.frame.size.height else { return 0 }
        return deviceY * -1 + Float(height)
    }

    private var cubismRenderingInstance: CubismRenderingInstanceSingleton_Metal? {
        CubismRenderingInstanceSingleton_Metal.sharedManager() as? CubismRenderingInstanceSingleton_Metal
    }
}

extension Live2DViewController: MetalViewDelegate {
    public

 func drawableResize(_ size: CGSize) {
        guard let device = cubismRenderingInstance?.getMTLDevice() else { return }

        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(size.width), height: Int(size.height), mipmapped: false)
        depthTextureDescriptor.usage = [.renderTarget, .shaderRead]
        depthTextureDescriptor.storageMode = .private

        depthTexture = device.makeTexture(descriptor: depthTextureDescriptor)

        resizeScreen()
    }

    public func render(to layer: CAMetalLayer) {
        LAppPal.UpdateTime()

        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let currentDrawable = layer.nextDrawable()
        else { return }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor
        ) else { return }

        // Rendering other than the model
        back?.renderImmidiate(renderEncoder)
        gear?.renderImmidiate(renderEncoder)

        renderEncoder.endEncoding()

        let live2DManager = LAppLive2DManager.getInstance()
        live2DManager?.setViewMatrix(UnsafeMutablePointer(&viewMatrix))
        live2DManager?.onUpdate(
            commandBuffer,
            currentDrawable: currentDrawable,
            depthTexture: depthTexture,
            frame: view?.frame ?? .zero
        )

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}

extension Live2DViewController: TextureManagerDelegate {
    public var metalLayer: CAMetalLayer? {
        (view as? MetalUIView)?.metalLayer
    }
}

private enum Constant {
    static let viewScale: Csm.csmFloat32 = 1.0
    static let viewMaxScale: Csm.csmFloat32 = 2.0
    static let viewMinScale: Csm.csmFloat32 = 0.8

    static let viewLogicalLeft: Csm.csmFloat32 = -1.0
    static let viewLogicalRight: Csm.csmFloat32 = 1.0
    static let viewLogicalBottom: Csm.csmFloat32 = -1.0
    static let viewLogicalTop: Csm.csmFloat32 = 1.0

    static let viewLogicalMaxLeft: Csm.csmFloat32 = -2.0
    static let viewLogicalMaxRight: Csm.csmFloat32 = 2.0
    static let viewLogicalMaxBottom: Csm.csmFloat32 = -2.0
    static let viewLogicalMaxTop: Csm.csmFloat32 = 2.0

    static let resourcesPath = "res/"

    // Image file for the background behind the model
    static let backImageName = "back_class_normal.png"
    // Gear icon
    static let gearImageName = "icon_gear.png"
}
