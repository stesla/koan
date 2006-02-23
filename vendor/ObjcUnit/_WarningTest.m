#import "_WarningTest.h"

@implementation _WarningTest

- (id)initWithName:(NSString *)aName message:(NSString *)aMessage {
    [super initWithName:aName];
    message = [aMessage retain];
    return self;
}

- (void)dealloc {
    [message release];
    [super dealloc];
}

- (void)runTest {
    [self fail:message];
}

@end
