#import "L2DCubism.h"
#import "LAppAllocator.h"
#import "LAppPal.h"
#import "LAppDefine.h"

using namespace Csm;

static LAppAllocator allocator;
static Csm::CubismFramework::Option cubismOption;

@implementation L2DCubism

+ (void)initialize {
    cubismOption.LogFunction = LAppPal::PrintMessageLn;
    cubismOption.LoggingLevel = LAppDefine::CubismLoggingLevel;

    CubismFramework::StartUp(&allocator, &cubismOption);
    CubismFramework::Initialize();
}

+ (void)dispose {
    CubismFramework::Dispose();
}

@end
