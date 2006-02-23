#import <ObjcUnit/AbstractExpectationCollection.h>

@interface ExpectationSet : AbstractExpectationCollection {
@private
    NSMutableSet *expectedObjects;
    NSMutableSet *actualObjects;
}

- (id)initWithName:(NSString *)name;

- (void)addExpectedObject:(id)object;
- (void)addActualObject:(id)object;

- (void)verify;

@end
