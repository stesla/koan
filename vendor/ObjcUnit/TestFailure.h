#import <Foundation/Foundation.h>

@protocol Test;

@interface TestFailure : NSObject {
@private
    id<Test> test;
    NSException *exception;
}

- (id)initWithTest:(id<Test>)test exception:(NSException *)exception;

- (id<Test>)failedTest;
- (NSException *)raisedException;

@end
