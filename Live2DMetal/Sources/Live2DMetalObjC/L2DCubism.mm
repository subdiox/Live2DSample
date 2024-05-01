#import "L2DCubism.h"
#import "LAppAllocator.h"

using namespace Csm;

static LAppAllocator allocator;

@implementation L2DCubism

+ (void)initialize {
    CubismFramework::StartUp(&allocator, NULL);
    CubismFramework::Initialize();
}

+ (void)dispose {
    CubismFramework::Dispose();
}

@end
