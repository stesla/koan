#import "ExpectationSet.h"

#import "AssertionFailedException.h"

@implementation ExpectationSet

- (id)initWithName:(NSString *)aName {
    self = [super initWithName:aName];
    expectedObjects = [[NSMutableSet alloc] init];
    actualObjects = [[NSMutableSet alloc] init];
    return self;
}

- (void)dealloc {
    [expectedObjects release];
    [actualObjects release];
    [super dealloc];
}

- (void)addExpectedObject:(id)object {
    [expectedObjects addObject:object];
    [self setHasExpectations:YES];
}

- (void)addActualObject:(id)object {
    [actualObjects addObject:object];
    if ([self hasExpectations] == NO) return;
    if ([self failsOnVerify] == YES) return;
    [self assertTrue:[expectedObjects containsObject:object] message:[NSString stringWithFormat:@"didn't expect %@", object]];
}

- (void)verify {
    if ([self hasExpectations] == NO) return;
    [self assert:[actualObjects allObjects] equals:[expectedObjects allObjects]];
}

@end
