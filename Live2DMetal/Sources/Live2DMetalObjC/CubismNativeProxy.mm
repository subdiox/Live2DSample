#import "CubismNativeProxy.h"
#import <Rendering/Metal/CubismRenderer_Metal.hpp>

@implementation CubismNativeProxy

+ (void)startFrameInMetalRendererWithDevice:(id<MTLDevice>)device
                              commandBuffer:(id<MTLCommandBuffer>)commandBuffer
                       renderPassDescriptor:(MTLRenderPassDescriptor*)renderPassDescriptor
{
    Csm::Rendering::CubismRenderer_Metal::StartFrame(device, commandBuffer, renderPassDescriptor);
}


@end
