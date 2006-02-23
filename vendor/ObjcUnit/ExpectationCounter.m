#import "ExpectationCounter.h"

#import "AssertionFailedException.h"

@implementation ExpectationCounter

- (id)initWithName:(NSString *)aName {
    self = [super initWithName:aName];
    expectedCount = 0;
    actualCount = 0;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setExpectedCount:(int)count {
    expectedCount = count;
    [self setHasExpectations:YES];
}

- (void)increment {
    ++actualCount;
    if ([self hasExpectations] == NO) return;
    if ([self failsOnVerify] == YES) return;
    [self assertTrue:(actualCount <= expectedCount) message:[NSString stringWithFormat:@"expected no more than %d increments", expectedCount]];
}

- (void)verify {
    if ([self hasExpectations] == NO) return;
    [self assertInt:actualCount equals:expectedCount];
}

@end
