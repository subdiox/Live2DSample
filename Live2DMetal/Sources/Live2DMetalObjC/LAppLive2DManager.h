/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#ifndef LAppLive2DManager_h
#define LAppLive2DManager_h

#import <CubismFramework.hpp>
#import <Math/CubismViewMatrix.hpp>
#import <Type/csmVector.hpp>
#import <Type/csmString.hpp>
#import "LAppModel.h"
#import "LAppSprite.h"

@interface LAppLive2DManager : NSObject

@property (nonatomic) Csm::CubismMatrix44 *viewMatrix; //モデル描画に用いるView行列
@property (nonatomic) LAppModel* model; //モデルインスタンス
@property (nonatomic) MTLRenderPassDescriptor* renderPassDescriptor;
@property (nonatomic) NSString* resourcesPath;
@property (nonatomic) NSString* modelName;

- (id)initWithResourcesPath:(NSString*)resourcesPath modelName:(NSString*)modelName;

/**
 * @brief   画面をドラッグしたときの処理
 *
 * @param[in]   x   画面のX座標
 * @param[in]   y   画面のY座標
 */
- (void)onDragX:(Csm::csmFloat32)x y:(Csm::csmFloat32)y NS_SWIFT_NAME(onDrag(x:y:));

/**
 * @brief   画面をタップしたときの処理
 *
 * @param[in]   x   画面のX座標
 * @param[in]   y   画面のY座標
 */
- (void)onTapX:(Csm::csmFloat32)x y:(Csm::csmFloat32)y NS_SWIFT_NAME(onTap(x:y:));

/**
 * @brief   画面を更新するときの処理
 *          モデルの更新処理および描画処理を行う
 */
- (void)onUpdate:(id <MTLCommandBuffer>)commandBuffer currentDrawable:(id<CAMetalDrawable>)drawable depthTexture:(id<MTLTexture>)depthTarget frame:(CGRect)frame NS_SWIFT_NAME(onUpdate(commandBuffer:currentDrawable:depthTexture:frame:));

/**
 * @brief   シーンを切り替える
 *           サンプルアプリケーションではモデルセットの切り替えを行う。
 */
- (void)LoadScene;

/**
 * @brief   viewMatrixをセットする
 */
- (void)SetViewMatrix:(Csm::CubismViewMatrix*)m;

@end

#endif /* LAppLive2DManager_h */
