import UIKit
import Metal
import QuartzCore
import Live2DMetalObjC
import CubismNativeFramework

public final class Live2DViewController: UIViewController, MetalViewDelegate {

    var anotherTarget: Bool = false
    var spriteColorR: Float = 0.0
    var spriteColorG: Float = 0.0
    var spriteColorB: Float = 0.0
    var spriteColorA: Float = 0.0
    var clearColorR: Float = 0.0
    var clearColorG: Float = 0.0
    var clearColorB: Float = 0.0
    var clearColorA: Float = 0.0
    public var commandQueue: MTLCommandQueue?
    var depthTexture: MTLTexture?

    var back: LAppSprite? //背景画像
    var gear: LAppSprite? //歯車画像
    var power: LAppSprite? //電源画像
    var renderSprite: LAppSprite? //レンダリングターゲット描画用
    var touchManager: TouchManager? // タッチマネージャー
    var deviceToScreen: Csm.CubismMatrix44? // デバイスからスクリーンへの行列
    var viewMatrix: Csm.CubismViewMatrix?

    public override func loadView() {
        let textureManager = LAppTextureManager.getInstance()
        textureManager?.delegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        //Fremework層でもMTLDeviceを参照するためシングルトンオブジェクトに登録
        let single = CubismRenderingInstanceSingleton_Metal.sharedManager() as! CubismRenderingInstanceSingleton_Metal
        let device = MTLCreateSystemDefaultDevice()
        single.setMTLDevice(device)

        let view = MetalUIView()
        self.view = view

        // Set the device for the layer so the layer can create drawable textures that can be rendered to
        // on this device.
        view.metalLayer.device = device

        // Set this class as the delegate to receive resize and render callbacks.
        view.delegate = self

        view.metalLayer.pixelFormat = .bgra8Unorm
        single.setMetalLayer(view.metalLayer)

        commandQueue = device?.makeCommandQueue()

        anotherTarget = false
        clearColorR = 1.0
        clearColorG = 1.0
        clearColorB = 1.0
        clearColorA = 0.0

        // タッチ関係のイベント管理
        touchManager = TouchManager()

        // デバイス座標からスクリーン座標に変換するための
        deviceToScreen = Csm.CubismMatrix44()

        // 画面の表示の拡大縮小や移動の変換を行う行列
        viewMatrix = Csm.CubismViewMatrix()

        initializeScreen()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeSprite()
    }

    func initializeScreen() {
        let screenRect = UIScreen.main.bounds
        let width = screenRect.size.width
        let height = screenRect.size.height

        // 縦サイズを基準とする
        let ratio = Float(width) / Float(height)
        let left = -ratio
        let right = ratio
        let bottom = Constant.viewLogicalLeft
        let top = Constant.viewLogicalRight

        // デバイスに対応する画面の範囲。 Xの左端, Xの右端, Yの下端, Yの上端
        viewMatrix?.SetScreenRect(left, right, bottom, top)
        viewMatrix?.Scale(Constant.viewScale, Constant.viewScale)

        deviceToScreen?.LoadIdentity() // サイズが変わった際などリセット必須
        if width > height {
            let screenW = fabsf(right - left)
            deviceToScreen?.ScaleRelative(screenW / Float(width), -screenW / Float(width))
        } else {
            let screenH = fabsf(top - bottom)
            deviceToScreen?.ScaleRelative(screenH / Float(height), -screenH / Float(height))
        }
        deviceToScreen?.TranslateRelative(-Float(width) * 0.5, -Float(height) * 0.5)

        // 表示範囲の設定
        viewMatrix?.SetMaxScale(Constant.viewMaxScale) // 限界拡大率
        viewMatrix?.SetMinScale(Constant.viewMinScale) // 限界縮小率

        // 表示できる最大範囲
        viewMatrix?.SetMaxScreenRect(Constant.viewLogicalMaxLeft, Constant.viewLogicalMaxRight, Constant.viewLogicalMaxBottom, Constant.viewLogicalMaxTop)
    }

    func resizeScreen() {
        guard let width = view?.frame.size.width, let height = view?.frame.size.height else { return }

        // 縦サイズを基準とする
        let ratio = Float(width) / Float(height)
        let left = -ratio
        let right = ratio
        let bottom = Constant.viewLogicalLeft
        let top = Constant.viewLogicalRight

        // デバイスに対応する画面の範囲。 Xの左端, Xの右端, Yの下端, Yの上端
        viewMatrix?.SetScreenRect(left, right, bottom, top)
        viewMatrix?.Scale(Constant.viewScale, Constant.viewScale)

        deviceToScreen?.LoadIdentity() // サイズが変わった際などリセット必須
        if width > height {
            let screenW = fabsf(right - left)
            deviceToScreen?.ScaleRelative(screenW / Float(width), -screenW / Float(width))
        } else {
            let screenH = fabsf(top - bottom)
            deviceToScreen?.ScaleRelative(screenH / Float(height), -screenH / Float(height))
        }
        deviceToScreen?.TranslateRelative(-Float(width) * 0.5, -Float(height) * 0.5)

        // 表示範囲の設定
        viewMatrix?.SetMaxScale(Constant.viewMaxScale) // 限界拡大率
        viewMatrix?.SetMinScale(Constant.viewMinScale) // 限界縮小率

        // 表示できる最大範囲
        viewMatrix?.SetMaxScreenRect(Constant.viewLogicalMaxLeft, Constant.viewLogicalMaxRight, Constant.viewLogicalMaxBottom, Constant.viewLogicalMaxTop)
    }

    func initializeSprite() {
        guard let view else { return }
        let width = Float(view.frame.size.width)
        let height = Float(view.frame.size.height)

        let resourcesPath = Constant.resourcesPath
        let textureManager = LAppTextureManager.getInstance()

        //背景
        if let backgroundTexture = textureManager?.createTexture(
            fromPngFile: std.string(resourcesPath + Constant.backImageName)
        ).pointee {
            back = LAppSprite(
                myVar: width * 0.5,
                y: height * 0.5,
                width: Float(backgroundTexture.width) * 2,
                height: height * 0.95,
                maxWidth: width,
                maxHeight: height,
                texture: backgroundTexture.id
            )
        }

        //モデル変更ボタン
        if let gearTexture = textureManager?.createTexture(
            fromPngFile: std.string(resourcesPath + Constant.gearImageName)
        ).pointee {
            gear = LAppSprite(
                myVar: width - Float(gearTexture.width) * 0.5,
                y: height - Float(gearTexture.height) * 0.5,
                width: Float(gearTexture.width),
                height: Float(gearTexture.height),
                maxWidth: width,
                maxHeight: height,
                texture: gearTexture.id
            )
        }

        //電源ボタン
        if let powerTexture = textureManager?.createTexture(
            fromPngFile: std.string(resourcesPath + Constant.powerImageName)
        ).pointee {
            power = LAppSprite(
                myVar: width - Float(powerTexture.width) * 0.5,
                y: Float(powerTexture.height) * 0.5,
                width: Float(powerTexture.width),
                height: Float(powerTexture.height),
                maxWidth: width,
                maxHeight: height,
                texture: powerTexture.id
            )
        }
    }

    func resizeSprite(width: Float, height: Float) {
        guard let view else { return }
        let maxWidth = Float(view.frame.size.width)
        let maxHeight = Float(view.frame.size.height)

        //背景
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

        //モデル変更ボタン
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

        //電源ボタン
        if let power {
            power.resizeImmidiate(
                width - Float(power.texture.width) * 0.5,
                y: Float(power.texture.height) * 0.5,
                width: Float(power.texture.width),
                height: Float(power.texture.height),
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self.view)

        touchManager?.touchesBegan(Float(point.x), deciveY: Float(point.y))
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self.view)

        let viewX = transformViewX(touchManager?.lastX ?? 0.0)
        let viewY = transformViewY(touchManager?.lastY ?? 0.0)

        touchManager?.touchesMoved(Float(point.x), deviceY: Float(point.y))
        LAppLive2DManager.getInstance()?.onDrag(viewX, floatY: viewY)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        print(touch.view as Any)

        let point = touch.location(in: self.view)
        let pointY = transformTapY(Float(point.y))

        // タッチ終了
        let live2DManager = LAppLive2DManager.getInstance()
        live2DManager?.onDrag(0.0, floatY: 0.0)
        if let getX = touchManager?.lastX, let getY = touchManager?.lastY {
            let x = deviceToScreen?.TransformX(getX)
            let y = deviceToScreen?.TransformY(getY)
            live2DManager?.onTap(x ?? 0.0, floatY: y ?? 0.0)
            // 歯車にタップしたか
            if gear?.isHit(Float(point.x), pointY: pointY) ?? false {
                live2DManager?.nextScene()
            }
        }
    }

    func transformViewX(_ deviceX: Float) -> Float {
        guard let screenX = deviceToScreen?.TransformX(deviceX) else { return 0.0 }
        return viewMatrix?.InvertTransformX(screenX) ?? 0.0
    }

    func transformViewY(_ deviceY: Float) -> Float {
        guard let screenY = deviceToScreen?.TransformY(deviceY) else { return 0.0 }
        return viewMatrix?.InvertTransformY(screenY) ?? 0.0
    }

    func transformScreenX(_ deviceX: Float) -> Float {
        return deviceToScreen?.TransformX(deviceX) ?? 0.0
    }

    func transformScreenY(_ deviceY: Float) -> Float {
        return deviceToScreen?.TransformY(deviceY) ?? 0.0
    }

    func transformTapY(_ deviceY: Float) -> Float {
        guard let height = view?.frame.size.height else { return 0.0 }
        return deviceY * -1 + Float(height)
    }

    public func drawableResize(_ size: CGSize) {
        guard let device = cubismRenderingInstance?.getMTLDevice() else { return }

        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(size.width), height: Int(size.height), mipmapped: false)
        depthTextureDescriptor.usage = [.renderTarget, .shaderRead]
        depthTextureDescriptor.storageMode = .private

        depthTexture = device.makeTexture(descriptor: depthTextureDescriptor)

        resizeScreen()
    }

    func renderSprite(_ renderEncoder: MTLRenderCommandEncoder) {
        back?.renderImmidiate(renderEncoder)
        gear?.renderImmidiate(renderEncoder)
        power?.renderImmidiate(renderEncoder)
    }

    public func render(to layer: CAMetalLayer) {
        LAppPal.UpdateTime()

        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let currentDrawable = layer.nextDrawable() else { return }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        //モデル以外の描画
        renderSprite(renderEncoder)

        renderEncoder.endEncoding()

        if let live2DManager = LAppLive2DManager.getInstance() {
            live2DManager.setViewMatrix(UnsafeMutablePointer(&viewMatrix!))
            live2DManager.onUpdate(commandBuffer, currentDrawable: currentDrawable, depthTexture: depthTexture, frame: view?.frame ?? .zero)
        }

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

    private var cubismRenderingInstance: CubismRenderingInstanceSingleton_Metal? {
        CubismRenderingInstanceSingleton_Metal.sharedManager() as? CubismRenderingInstanceSingleton_Metal
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

    // モデルの後ろにある背景の画像ファイル
    static let backImageName = "back_class_normal.png"
    // 歯車
    static let gearImageName = "icon_gear.png"
    // 終了ボタン
    static let powerImageName = "close.png"
}
