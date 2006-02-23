#import "AbstractExpectationCollection.h"

@interface AbstractExpectationCollection (Privates)

- (NSString *)stringForSelector:(SEL)selector;

@end

@implementation AbstractExpectationCollection

- (void)addExpectedObject:(id)object {
}

- (void)addActualObject:(id)object {
}

@end

@implementation AbstractExpectationCollection (Convenience)

- (void)addExpectedSelector:(SEL)selector {
    [self addExpectedObject:[self stringForSelector:selector]];
}

- (void)addActualSelector:(SEL)selector {
    [self addActualObject:[self stringForSelector:selector]];
}

@end

@implementation AbstractExpectationCollection (Privates)

- (NSString *)stringForSelector:(SEL)selector {
    return [@"selector -" stringByAppendingString:NSStringFromSelector(selector)];
}

@end
