#import "ImageSaverPlugin.h"
#if __has_include(<image_saver/image_saver-Swift.h>)
#import <image_saver/image_saver-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "image_saver-Swift.h"
#endif

@implementation ImageSaverPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageSaverPlugin registerWithRegistrar:registrar];
}
@end
