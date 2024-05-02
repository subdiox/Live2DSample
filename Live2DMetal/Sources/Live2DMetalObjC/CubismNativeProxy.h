#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface CubismNativeProxy: NSObject

+ (void)startFrameInMetalRendererWithDevice:(id<MTLDevice>)device
                              commandBuffer:(id<MTLCommandBuffer>)commandBuffer
                       renderPassDescriptor:(MTLRenderPassDescriptor*)renderPassDescriptor;

@end
