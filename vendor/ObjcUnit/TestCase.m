#import "TestCase.h"

#import "AssertionFailedException.h"
#import "TestResult.h"

@implementation TestCase

+ (id<Test>)testWithName:(NSString *)aName {
    TestCase *testCase = [[self alloc] initWithName:aName];
    return [testCase autorelease];
}

- (id)initWithName:(NSString *)aName {
    self = [super init];
    name = [[NSString alloc] initWithString:aName];
    return self;
}

- (void)dealloc {
    [name release];
    [super dealloc];
}

- (NSString *)name {
    return name;
}

- (int)countTestCases {
    return 1;
}

- (void)run:(TestResult *)result {
    [result run:self];
}

- (TestResult *)createResult {
    return [[[TestResult alloc] init] autorelease];
}

- (TestResult *)run {
    TestResult *result = [self createResult];
    [self run:result];
    return result;
}

- (void)runBare {
    NSException *runEx = nil;

    [self setUp];

    NS_DURING
        [self runTest];
    NS_HANDLER
        runEx = localException;
    NS_ENDHANDLER

    NS_DURING
        [self tearDown];
    NS_HANDLER
        if (runEx == nil) runEx = localException;
    NS_ENDHANDLER

    if (runEx != nil) {
        [runEx raise];
    }
}

- (void)runTest {
    SEL testSelector = NSSelectorFromString([self name]);
    [self performSelector:testSelector];
}

- (void)setUp {
}

- (void)tearDown {
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", [self name], [self class]];
}

@end

@implementation TestCase (WeWantNoSelectorNotRecognizedWarnings)

// NOTE: This is an interesting one. Unless you override this method, a warning
// will be printed to stdout (or stderr?) about a selector for which there is no
// method defined. But you HAVE to raise an exception in this method, or you
// will get a SIGBUS. Someone expects an exception to be raised, but what
// this exception is used for, we don't know. Mail objcunit@oops.se if you know!

- (void)doesNotRecognizeSelector:(SEL)selector {
    [NSException raise:NSInvalidArgumentException format:NSStringFromSelector(selector)];
}

@end

@interface TestCase (AssertPrivates)

- (void)fail:(id)actual doesntEqual:(id)expected message:(NSString *)message;

@end

@implementation TestCase (Assert)

- (void)fail {
    [self fail:nil];
}

- (void)fail:(NSString *)message {
    NSString *reason = (message != nil && [message length] > 0) ? message : @"";
    [AssertionFailedException raise:@"AssertionFailedException" format:reason];
}

- (void)assertTrue:(BOOL)condition {
    [self assertTrue:condition message:nil];
}

- (void)assertTrue:(BOOL)condition message:(NSString *)message {
    if (!condition) [self fail:message];
}

- (void)assertFalse:(BOOL)condition {
    [self assertFalse:condition message:nil];
}

- (void)assertFalse:(BOOL)condition message:(NSString *)message {
    [self assertTrue:!condition message:message];
}

- (void)assert:(id)actual equals:(id)expected {
    [self assert:actual equals:expected message:nil];
}

- (void)assert:(id)actual equals:(id)expected message:(NSString *)message {
    if (expected == nil && actual == nil) return;
    if ([expected isEqual:actual]) return;
    [self fail:actual doesntEqual:expected message:message];
}

- (void)assertString:(NSString *)actual equals:(NSString *)expected {
    [self assertString:actual equals:expected message:nil];
}

- (void)assertString:(NSString *)actual equals:(NSString *)expected message:(NSString *)message {
    if ([expected isEqualToString:actual]) return;
    [self fail:actual doesntEqual:expected message:message];
}

- (void)assertInt:(int)actual equals:(int)expected {
    [self assertInt:actual equals:expected message:nil];
}

- (void)assertInt:(int)actual equals:(int)expected message:(NSString *)message {
    [self assert:[NSNumber numberWithInt:actual] equals:[NSNumber numberWithInt:expected] message:message];
}

- (void)assertFloat:(float)actual equals:(float)expected precision:(float)delta {
    [self assertFloat:actual equals:expected precision:delta message:nil];
}

- (void)assertFloat:(float)actual equals:(float)expected precision:(float)delta message:(NSString *)message {
    if (isnan(expected) || isnan(actual)) {
        [self fail:[NSNumber numberWithDouble:actual] doesntEqual:[NSNumber numberWithDouble:expected] message:message];
    }
    if (fabs(expected - actual) > delta) {
        [self fail:[NSNumber numberWithDouble:actual] doesntEqual:[NSNumber numberWithDouble:expected] message:message];
    }
}

- (void)assertNil:(id)object {
    [self assertNil:object message:nil];
}

- (void)assertNil:(id)object message:(NSString *)message {
    if (object != nil) [self fail:object doesntEqual:@"nil" message:message];
}

- (void)assertNotNil:(id)object {
    [self assertNotNil:object message:nil];
}

- (void)assertNotNil:(id)object message:(NSString *)message {
    if (object == nil) [self fail:@"nil" doesntEqual:@"non-nil" message:message];
}

- (void)assert:(id)object1 same:(id)object2 {
    [self assert:object1 same:object2 message:nil];
}

- (void)assert:(id)object1 same:(id)object2 message:(NSString *)message {
    if (object1 != object2) [self fail:[NSString stringWithFormat:@"%@ & %@", object1, object2] doesntEqual:@"same" message:message];
}

@end

@implementation TestCase (AssertPrivates)

- (void)fail:(id)actual doesntEqual:(id)expected message:(NSString *)message {
    if (message == nil) {
        [self fail:[NSString stringWithFormat:@"expected %@ but was %@", expected, actual]];
    } else {
        [self fail:[NSString stringWithFormat:@"%@ expected %@ but was %@", message, expected, actual]];
    }
}

@end
