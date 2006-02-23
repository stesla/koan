#import "TestResult.h"

#import "Test.h"
#import "TestCase.h"
#import "TestFailure.h"
#import "AssertionFailedException.h"

@implementation TestResult

- (id)init {
    self = [super init];
    errors = [[NSMutableArray alloc] init];
    failures = [[NSMutableArray alloc] init];
    numberOfTestsRun = 0;
    listeners = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    [errors release];
    [failures release];
    [listeners release];
    
    [super dealloc];
}

- (void)run:(TestCase *)test {
    [self startTest:test];

    NS_DURING
        [test runBare];
    NS_HANDLER
        if ([localException isKindOfClass:[AssertionFailedException class]]) {
            [self addFailure:localException forTest:test];
        } else {
            [self addError:localException forTest:test];
        }
    NS_ENDHANDLER
        
    [self endTest:test];
}

- (int)numberOfTestsRun {
    return numberOfTestsRun;
}

- (void)startTest:(id<Test>)test {
	int count = [test countTestCases];
    numberOfTestsRun += count;
    [listeners makeObjectsPerformSelector:@selector(startTest:) withObject:test];
}

- (void)endTest:(id<Test>)test {
    [listeners makeObjectsPerformSelector:@selector(endTest:) withObject:test];
}

- (void)addError:(NSException *)exception forTest:(id<Test>)test {
    NSEnumerator *listenerEnum = nil;
    id<TestListener> aListener = nil;
    
    TestFailure *error = [[TestFailure alloc] initWithTest:test exception:exception];
    [errors addObject:error];
    [error release];

    listenerEnum = [self listenerEnumerator];
    while (aListener = [listenerEnum nextObject]) {
        [aListener addError:exception forTest:test];
    }
}

- (void)addFailure:(NSException *)exception forTest:(id<Test>)test {
    NSEnumerator *listenerEnum = nil;
    id<TestListener> aListener = nil;

    TestFailure *failure = [[TestFailure alloc] initWithTest:test exception:exception];
    [failures addObject:failure];
    [failure release];

    listenerEnum = [self listenerEnumerator];
    while (aListener = [listenerEnum nextObject]) {
        [aListener addFailure:exception forTest:test];
    }
}

- (NSEnumerator *)listenerEnumerator {
    NSArray *array = [NSArray arrayWithArray:listeners];
    return [array objectEnumerator];
}

- (void)addListener:(id<TestListener>)listener {
    if ([listeners containsObject:listener] == NO) {
        [listeners addObject:listener];
    }
}

- (void)removeListener:(id<TestListener>)listener {
    [listeners removeObject:listener];
}

- (int)numberOfErrors {
    return [errors count];
}

- (NSEnumerator *)errorEnumerator {
    NSArray *array = [NSArray arrayWithArray:errors];
    return [array objectEnumerator];
}

- (int)numberOfFailures {
    return [failures count];
}

- (NSEnumerator *)failureEnumerator {
    NSArray *array = [NSArray arrayWithArray:failures];
    return [array objectEnumerator];
}

- (BOOL)wasSuccessful {
    return ([self numberOfErrors] == 0 && [self numberOfFailures] == 0);
}

- (NSString *)description {
    NSString *desc = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:errors forKey:@"errors"];
    [dict setObject:failures forKey:@"failures"];
    desc = [NSString stringWithFormat:@"TestResult = %@", dict];

    [dict release];
    return desc;
}

@end
