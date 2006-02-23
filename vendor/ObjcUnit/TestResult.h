#import <ObjcUnit/TestListener.h>

@protocol Test;
@class TestCase;

@interface TestResult : NSObject <TestListener> {
@private
    NSMutableArray *errors;
    NSMutableArray *failures;
    int numberOfTestsRun;
    NSMutableArray *listeners;
}

- (void)run:(TestCase *)test;
- (int)numberOfTestsRun;

- (void)startTest:(id<Test>)test;
- (void)endTest:(id<Test>)test;

- (void)addError:(NSException *)exception forTest:(id<Test>)test;
- (void)addFailure:(NSException *)exception forTest:(id<Test>)test;

- (NSEnumerator *)listenerEnumerator;
- (void)addListener:(id<TestListener>)listener;
- (void)removeListener:(id<TestListener>)listener;

- (int)numberOfErrors;
- (NSEnumerator *)errorEnumerator;

- (int)numberOfFailures;
- (NSEnumerator *)failureEnumerator;

- (BOOL)wasSuccessful;

@end
