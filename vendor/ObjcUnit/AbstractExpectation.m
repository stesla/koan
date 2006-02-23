#import "AbstractExpectation.h"

#import "AssertionFailedException.h"

@implementation AbstractExpectation

- (id)initWithName:(NSString *)aName {
    self = [super init];
    name = [aName retain];
    failsOnVerify = NO;
    hasExpectations = NO;
    return self;
}

- (void)dealloc {
    [name release];
    [super dealloc];
}

- (NSString *)name {
    return name;
}

- (void)setFailsOnVerify:(BOOL)flag {
    failsOnVerify = flag;
}

- (BOOL)failsOnVerify {
    return failsOnVerify;
}

- (void)setHasExpectations:(BOOL)flag {
    hasExpectations = flag;
}

- (BOOL)hasExpectations {
    return hasExpectations;
}

- (void)verify {
}

@end

@implementation AbstractExpectation (Asserts)

- (void)assert:(id)actual equals:(id)expected {
    if ([actual isEqual:expected] == NO) {
        [AssertionFailedException raise:@"AssertionFailedException" format:@"%@ expected %@, was %@", name, expected, actual];
    }
}

- (void)assertTrue:(BOOL)condition message:(NSString *)message {
    if (!condition) {
        [AssertionFailedException raise:@"AssertionFailedException" format:[NSString stringWithFormat:@"%@ %@", name, message]];
    }
}

- (void)assertInt:(int)actual equals:(int)expected {
    if (actual != expected) {
        [AssertionFailedException raise:@"AssertionFailedException" format:@"%@ expected %d, was %d", name, expected, actual];
    }
}

@end
