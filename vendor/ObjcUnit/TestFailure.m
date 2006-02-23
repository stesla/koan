#import "TestFailure.h"

#import "Test.h"

@implementation TestFailure

- (id)initWithTest:(id<Test>)aTest exception:(NSException *)anException {
    self = [super init];
    test = [(NSObject *)aTest retain];
    exception = [anException retain];
    return self;
}

- (void)dealloc {
    [(NSObject *)test release];
    [exception release];
    [super dealloc];
}

- (id<Test>)failedTest {
    return test;
}

- (NSException *)raisedException {
    return exception;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [self failedTest], [self raisedException]];
}

@end
