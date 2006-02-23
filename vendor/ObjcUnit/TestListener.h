#import <Foundation/Foundation.h>

@protocol Test;

@protocol TestListener

- (void)startTest:(id<Test>)test;
- (void)endTest:(id<Test>)test;

- (void)addError:(NSException *)exception forTest:(id<Test>)test;
- (void)addFailure:(NSException *)exception forTest:(id<Test>)test;

@end
