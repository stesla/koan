#import <ObjcUnit/Test.h>

@interface TestSuite : NSObject <Test> {
@private
    NSMutableArray *tests;
    NSString *name;
}

+ (TestSuite *)suiteWithClass:(Class)aClass;

+ (id<Test>)testWithName:(NSString *)name;

+ (TestSuite *)suiteWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;
- (id)initWithClass:(Class)aClass;

- (void)runTest:(id<Test>)test result:(TestResult *)result;

- (void)addTest:(id<Test>)test;
- (void)addTestSuite:(Class)aClass;
- (NSEnumerator *)testEnumerator;
- (int)numberOfTests;

@end
