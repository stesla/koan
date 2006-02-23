#import <Foundation/Foundation.h>

@class ExpectationCounter;
@class ExpectationList;
@class ExpectationSet;
@class ExpectationValue;

@interface ExpectationGroup : NSObject {
@private
    NSString *name;
    NSMutableDictionary *expectations;
}

- (id)initWithName:(NSString *)name;

- (ExpectationCounter *)addedCounterWithName:(NSString *)name;
- (ExpectationCounter *)counterNamed:(NSString *)name;

- (ExpectationList *)addedListWithName:(NSString *)name;
- (ExpectationList *)listNamed:(NSString *)name;

- (ExpectationSet *)addedSetWithName:(NSString *)name;
- (ExpectationSet *)setNamed:(NSString *)name;

- (ExpectationValue *)addedValueWithName:(NSString *)name;
- (ExpectationValue *)valueNamed:(NSString *)name;

- (void)verify;

@end
