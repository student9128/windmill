#import "WindmillPlugin.h"
#if __has_include(<windmill/windmill-Swift.h>)
#import <windmill/windmill-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "windmill-Swift.h"
#endif

@implementation WindmillPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWindmillPlugin registerWithRegistrar:registrar];
}
@end
