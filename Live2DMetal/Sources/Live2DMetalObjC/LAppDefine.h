/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#ifndef LAppDefine_h
#define LAppDefine_h

#import <Foundation/Foundation.h>
#import <CubismFramework.hpp>

/**
 * @brief  Sample Appで使用する定数
 *
 */
namespace LAppDefine {
    using namespace Csm;

    extern const csmChar* ResourcesPath;            ///< 素材パス
    // モデル定義--------------------------------------------
    // 外部定義ファイル(json)と合わせる
    extern const csmChar* MotionGroupIdle;          ///< アイドリング時に再生するモーションのリスト
    extern const csmChar* MotionGroupTapBody;       ///< 体をタップした時に再生するモーションのリスト

    // 外部定義ファイル(json)と合わせる
    extern const csmChar* HitAreaNameHead;          ///< 当たり判定の[Head]タグ
    extern const csmChar* HitAreaNameBody;          ///< 当たり判定の[Body]タグ

    // モーションの優先度定数
    extern const csmInt32 PriorityNone;             ///< モーションの優先度定数: 0
    extern const csmInt32 PriorityIdle;             ///< モーションの優先度定数: 1
    extern const csmInt32 PriorityNormal;           ///< モーションの優先度定数: 2
    extern const csmInt32 PriorityForce;            ///< モーションの優先度定数: 3

    extern const csmBool MocConsistencyValidationEnable; ///< MOC3の整合性検証機能の有効・無効

    // デバッグ用ログの表示
    extern const csmBool DebugLogEnable;            ///< デバッグ用ログ表示の有効・無効
    extern const csmBool DebugTouchLogEnable;       ///< タッチ処理のデバッグ用ログ表示の有効・無効

    // Frameworkから出力するログのレベル設定
    extern const CubismFramework::Option::LogLevel CubismLoggingLevel;
}

#endif /* LAppDefine_h */
