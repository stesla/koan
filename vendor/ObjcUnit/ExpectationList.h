#import <ObjcUnit/AbstractExpectationCollection.h>

@interface ExpectationList : AbstractExpectationCollection {
@private
    NSMutableArray *expectedObjects;
    NSMutableArray *actualObjects;
}

- (id)initWithName:(NSString *)name;

- (void)addExpectedObject:(id)object;
- (void)addActualObject:(id)object;

- (void)verify;

@end
