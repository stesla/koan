#import "TestRunner.h"

#import "Test.h"
#import "TestFailure.h"
#import "TestResult.h"
#import "TestSuite.h"

@interface TestRunner(Privates)
- (void)writeString:(NSString *)string;
@end

@implementation TestRunner

+ (TestRunner *)runnerWithFileHandle:(NSFileHandle *)handle {
    return [[[self alloc] initWithFileHandle:handle] autorelease];
}

- (id)initWithFileHandle:(NSFileHandle *)handle {
    [super init];
    fileHandle = [handle retain];
    return self;
}

- (id)init {
    return [self initWithFileHandle:[NSFileHandle fileHandleWithStandardOutput]];
}

- (void)dealloc {
    [fileHandle release];
    [super dealloc];
}

- (void)addError:(NSException *)exception forTest:(id<Test>)test {
    [self writeString:@"E"];
}

- (void)addFailure:(NSException *)exception forTest:(id<Test>)test {
    [self writeString:@"F"];
}

- (void)startTest:(id<Test>)test {
    [self writeString:@"."];
}

- (void)endTest:(id<Test>)test {
}

- (void)writeString:(NSString *)string {
    [fileHandle writeData:[string dataUsingEncoding:NSNonLossyASCIIStringEncoding]];
}

- (TestResult *)createTestResult {
    return [[TestResult alloc] init];
}

- (TestResult *)doRun:(id<Test>)test {
    TestResult *result = [self createTestResult];
    [(id)test retain];
    [result addListener:self];    
    // time.
    [test run:result];
    // time.
    // print time diffs.
    [self writeResult:result];
    [result removeListener:self];

    [(id)test release];
    return [result autorelease];
}

- (void)writeResult:(TestResult *)result {
    [self writeHeader:result];
    [self writeErrors:result];
    [self writeFailures:result];
}

- (void)writeErrors:(TestResult *)result {
    if ([result numberOfErrors] != 0) {
        [self writeString:[NSString stringWithFormat:@"There was %d", [result numberOfErrors]]];
        if ([result numberOfErrors] == 1) {
            [self writeString:@" error:\n"];
        } else {
            [self writeString:@" errors:\n"];
        }

        [self writeTestFailures:[result errorEnumerator]];
    }
}

- (void)writeFailures:(TestResult *)result {
    if ([result numberOfFailures] != 0) {
        [self writeString:[NSString stringWithFormat:@"There was %d", [result numberOfFailures]]];
        if ([result numberOfFailures] == 1) {
            [self writeString:@" failure:\n"];
        } else {
            [self writeString:@" failures:\n"];
        }

        [self writeTestFailures:[result failureEnumerator]];
        [self writeString:@"\n"];
    }
}

- (void)writeTestFailures:(NSEnumerator *)failureEnum {
    int i = 1;
    TestFailure *failure = nil;

    for (;failure = [failureEnum nextObject]; i++) {
        if (i>1) [self writeString:@"\n"];
        [self writeString:[NSString stringWithFormat:@"%d) %@", i, [failure failedTest]]];
        if ([[failure raisedException] reason] != nil && [[[failure raisedException] reason] length] > 0) {
            [self writeString:[NSString stringWithFormat:@"\"%@\"\n", [[failure raisedException] reason]]];
        } else {
            [self writeString:@"\n"];
        }
    }
}

- (void)writeHeader:(TestResult *)result {
    if ([result wasSuccessful]) {
        [self writeString:@"\n\n"];
        [self writeString:@"OK"];
        [self writeString:[NSString stringWithFormat:@" (%d tests)", [result numberOfTestsRun]]];

    } else {
        [self writeString:@"\n\n"];
        [self writeString:@"FAILURES!!!\n"];
        [self writeString:[NSString stringWithFormat:@"Tests run:%d,  Failures:%d,  Errors: %d", [result numberOfTestsRun], [result numberOfFailures], [result numberOfErrors]]];
    }

    [self writeString:@"\n"];
}

@end

int TestRunnerMain(Class classThatCanReturnATestSuite) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    TestRunner *runner = [[TestRunner alloc] init];
    TestResult *result = nil;
    int status;

    result = [runner doRun:[classThatCanReturnATestSuite performSelector:@selector(suite)]];

    if ([result wasSuccessful]) status = NoFailuresOrErrorsOccurred;
    if ([result numberOfErrors] > 0) status = ErrorsOccurred;
    if ([result numberOfFailures] > 0) status = FailuresOccurred;

    [runner release];
    [pool release];
    return status;
}
