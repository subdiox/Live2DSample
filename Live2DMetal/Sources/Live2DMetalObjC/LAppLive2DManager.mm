/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "LAppLive2DManager.h"
#import "LAppModel.h"
#import "LAppDefine.h"
#import "LAppPal.h"
#import <Rendering/Metal/CubismRenderer_Metal.hpp>
#import "Rendering/Metal/CubismRenderingInstanceSingleton_Metal.h"

@implementation LAppLive2DManager

static LAppLive2DManager* s_instance = nil;

void FinishedMotion(Csm::ACubismMotion* self)
{
    LAppPal::PrintLogLn("Motion Finished: %x", self);
}

- (id)initWithResourcesPath:(NSString*)resourcesPath modelName:(NSString*)modelName
{
    self = [super init];
    if ( self ) {
        _viewMatrix = new Csm::CubismMatrix44();
        _model = new LAppModel();

        _renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        _renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        _renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.f, 0.f, 0.f, 0.f);
        _renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
        _renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
        _renderPassDescriptor.depthAttachment.clearDepth = 1.0;

        _resourcesPath = resourcesPath;
        _modelName = modelName;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self LoadScene];
        });
    }
    return self;
}

- (void)onDragX:(Csm::csmFloat32)x y:(Csm::csmFloat32)y
{
    _model->SetDragging(x,y);
}

- (void)onTapX:(Csm::csmFloat32)x y:(Csm::csmFloat32)y;
{
    if (LAppDefine::DebugLogEnable)
    {
        LAppPal::PrintLogLn("[APP]tap point: {x:%.2f y:%.2f}", x, y);
    }

    if (_model->HitTest(LAppDefine::HitAreaNameHead,x,y))
    {
        if (LAppDefine::DebugLogEnable)
        {
            LAppPal::PrintLogLn("[APP]hit area: [%s]", LAppDefine::HitAreaNameHead);
        }
        _model->SetRandomExpression();
    }
    else if (_model->HitTest(LAppDefine::HitAreaNameBody, x, y))
    {
        if (LAppDefine::DebugLogEnable)
        {
            LAppPal::PrintLogLn("[APP]hit area: [%s]", LAppDefine::HitAreaNameBody);
        }
        _model->StartRandomMotion(LAppDefine::MotionGroupTapBody, LAppDefine::PriorityNormal, FinishedMotion);
    }
}

- (void)onUpdate:(id <MTLCommandBuffer>)commandBuffer currentDrawable:(id<CAMetalDrawable>)drawable depthTexture:(id<MTLTexture>)depthTarget frame:(CGRect)frame;
{
    float width = frame.size.width;
    float height = frame.size.height;

    Csm::CubismMatrix44 projection;

    CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
    id<MTLDevice> device = [single getMTLDevice];

    _renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    _renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    _renderPassDescriptor.depthAttachment.texture = depthTarget;

    Csm::Rendering::CubismRenderer_Metal::StartFrame(device, commandBuffer, _renderPassDescriptor);

    if (_model->GetModel() == NULL)
    {
        LAppPal::PrintLogLn("Failed to model->GetModel().");
        return;
    }

    if (_model->GetModel()->GetCanvasWidth() > 1.0f && width < height)
    {
        // 横に長いモデルを縦長ウィンドウに表示する際モデルの横サイズでscaleを算出する
        _model->GetModelMatrix()->SetWidth(2.0f);
        projection.Scale(1.0f, static_cast<float>(width) / static_cast<float>(height));
    }
    else
    {
        projection.Scale(static_cast<float>(height) / static_cast<float>(width), 1.0f);
    }

    // 必要があればここで乗算
    if (_viewMatrix != NULL)
    {
        projection.MultiplyByMatrix(_viewMatrix);
    }

    _model->Update();
    _model->Draw(projection);///< 参照渡しなのでprojectionは変質する
}

- (void)LoadScene
{
    // model3.jsonのパスを決定する.
    // ディレクトリ名とmodel3.jsonの名前を一致させておくこと.
    const Csm::csmString& model = [_modelName UTF8String];

    Csm::csmString modelPath([_resourcesPath UTF8String]);
    modelPath += model;
    modelPath.Append(1, '/');

    Csm::csmString modelJsonName(model);
    modelJsonName += ".model3.json";

    _model->LoadAssets(modelPath.GetRawString(), modelJsonName.GetRawString());
}

- (void)SetViewMatrix:(Csm::CubismViewMatrix*)m;
{
    for (int i = 0; i < 16; i++) {
        _viewMatrix->GetArray()[i] = m->GetArray()[i];
    }
}

@end
