#import "ExpectationList.h"

@implementation ExpectationList

- (id)initWithName:(NSString *)aName {
    self = [super initWithName:aName];
    expectedObjects = [[NSMutableArray alloc] init];
    actualObjects = [[NSMutableArray alloc] init];
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
    id expectedObject;
    
    [actualObjects addObject:object];
    if ([self hasExpectations] == NO) return;
    if ([self failsOnVerify] == YES) return;
    expectedObject = [expectedObjects objectAtIndex:([actualObjects count] - 1)];
    [self assert:object equals:expectedObject];
}

- (void)verify {
    if ([self hasExpectations] == NO) return;
    [self assert:actualObjects equals:expectedObjects];
}

@end
