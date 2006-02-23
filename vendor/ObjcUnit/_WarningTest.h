#import <ObjcUnit/TestCase.h>

@interface _WarningTest : TestCase {
    NSString *message;
}
- (id)initWithName:(NSString *)name message:(NSString *)message;
- (void)runTest;
@end
