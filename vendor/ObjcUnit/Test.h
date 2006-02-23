#import <Foundation/Foundation.h>

@class TestResult;

@protocol Test

+ (id<Test>)testWithName:(NSString *)name;

- (int)countTestCases;

- (void)run:(TestResult *)result;

@end
