#import <ObjcUnit/TestListener.h>

@protocol Test;
@class TestResult;
@class TestSuite;

@interface TestRunner : NSObject <TestListener> {
@private
    NSFileHandle *fileHandle;
}

+ (TestRunner *)runnerWithFileHandle:(NSFileHandle *)fileHandle;
- (id)initWithFileHandle:(NSFileHandle *)fileHandle;

- (void)addError:(NSException *)exception forTest:(id<Test>)test;
- (void)addFailure:(NSException *)exception forTest:(id<Test>)test;

- (void)startTest:(id<Test>)test;
- (void)endTest:(id<Test>)test;

- (TestResult *)doRun:(id<Test>)test;

- (void)writeResult:(TestResult *)result;
- (void)writeErrors:(TestResult *)result;
- (void)writeFailures:(TestResult *)result;
- (void)writeTestFailures:(NSEnumerator *)failureEnum;
- (void)writeHeader:(TestResult *)result;

@end

extern int TestRunnerMain(Class classThatCanReturnATestSuite);

#define NoFailuresOrErrorsOccurred 0
#define FailuresOccurred 100
#define ErrorsOccurred 101
