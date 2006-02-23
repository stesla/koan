#import <ObjcUnit/AbstractExpectation.h>

@interface ExpectationValue : AbstractExpectation {
@private
    id expectedObject;
    id actualObject;
}

- (id)initWithName:(NSString *)name;

- (void)setExpectedObject:(id)object;
- (void)setActualObject:(id)object;

- (void)verify;

@end
