#import <ObjcUnit/AbstractExpectation.h>

@interface AbstractExpectationCollection : AbstractExpectation

- (void)addExpectedObject:(id)object;
- (void)addActualObject:(id)object;

@end

@interface AbstractExpectationCollection (Convenience)

- (void)addExpectedSelector:(SEL)selector;
- (void)addActualSelector:(SEL)selector;

@end
