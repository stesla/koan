#import <ObjcUnit/AbstractExpectation.h>

@interface ExpectationCounter : AbstractExpectation {
@private
    int expectedCount;
    int actualCount;
}

- (id)initWithName:(NSString *)name;

- (void)setExpectedCount:(int)count;

- (void)increment;

- (void)verify;

@end
