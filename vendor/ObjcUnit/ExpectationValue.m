#import "ExpectationValue.h"

#import "AssertionFailedException.h";

@implementation ExpectationValue

- (id)initWithName:(NSString *)aName {
    self = [super initWithName:aName];
    return self;
}

- (void)dealloc {
    [expectedObject release];
    [actualObject release];
    [super dealloc];
}

- (void)setExpectedObject:(id)object {
    [expectedObject release];
    expectedObject = [object retain];
    [self setHasExpectations:YES];
}

- (void)setActualObject:(id)object {
    [actualObject release];
    actualObject = [object retain];
    if ([self failsOnVerify] == NO) {
        [self verify];
    }
}

- (void)verify {
    if ([self hasExpectations] == NO) return;
    [self assert:actualObject equals:expectedObject];
}

@end
