#import "ExpectationGroup.h"

#import "ExpectationCounter.h"
#import "ExpectationList.h"
#import "ExpectationSet.h"
#import "ExpectationValue.h"

@interface ExpectationGroup (Privates)

- (NSString *)privateNameForPublicName:(NSString *)name;

- (ExpectationCounter *)counterWithName:(NSString *)name;
- (ExpectationList *)listWithName:(NSString *)name;
- (ExpectationSet *)setWithName:(NSString *)name;
- (ExpectationValue *)valueWithName:(NSString *)name;

@end

@implementation ExpectationGroup

- (id)initWithName:(NSString *)aName {
    self = [super init];
    name = [aName retain];
    expectations = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc {
    [name release];
    [expectations release];
    [super dealloc];
}

- (ExpectationCounter *)addedCounterWithName:(NSString *)aName {
    ExpectationCounter *counter = [self counterWithName:aName];

    [expectations setObject:counter forKey:aName];
    return counter;
}

- (ExpectationCounter *)counterNamed:(NSString *)aName {
    ExpectationCounter *foundCounter = [expectations objectForKey:aName];

    if (foundCounter == nil) return [self counterWithName:aName];
    return foundCounter;
}

- (ExpectationList *)addedListWithName:(NSString *)aName {
    ExpectationList *list = [self listWithName:aName];

    [expectations setObject:list forKey:aName];
    return list;
}

- (ExpectationList *)listNamed:(NSString *)aName {
    ExpectationList *foundList = [expectations objectForKey:aName];

    if (foundList == nil) return [self listWithName:aName];
    return foundList;
}

- (ExpectationSet *)addedSetWithName:(NSString *)aName {
    ExpectationSet *set = [self setWithName:aName];

    [expectations setObject:set forKey:aName];
    return set;
}

- (ExpectationSet *)setNamed:(NSString *)aName {
    ExpectationSet *foundSet = [expectations objectForKey:aName];

    if (foundSet == nil) return [self setWithName:aName];
    return foundSet;
}

- (ExpectationValue *)addedValueWithName:(NSString *)aName {
    ExpectationValue *value = [self valueWithName:aName];

    [expectations setObject:value forKey:aName];
    return value;
}

- (ExpectationValue *)valueNamed:(NSString *)aName {
    ExpectationValue *foundValue = [expectations objectForKey:aName];

    if (foundValue == nil) return [self valueWithName:aName];
    return foundValue;
}

- (void)verify {
    NSEnumerator *enumerator = [expectations objectEnumerator];
    AbstractExpectation *each; 

    while (each = [enumerator nextObject]) {
        [each verify];
    }
}

@end

@implementation ExpectationGroup (Privates)

- (NSString *)privateNameForPublicName:(NSString *)aName {
    return [name stringByAppendingFormat:@".%@", aName];
}

- (ExpectationCounter *)counterWithName:(NSString *)aName {
    return [[[ExpectationCounter alloc] initWithName:[self privateNameForPublicName:aName]] autorelease];
}

- (ExpectationList *)listWithName:(NSString *)aName {
    return [[[ExpectationList alloc] initWithName:[self privateNameForPublicName:aName]] autorelease];
}

- (ExpectationSet *)setWithName:(NSString *)aName {
    return [[[ExpectationSet alloc] initWithName:[self privateNameForPublicName:aName]] autorelease];
}

- (ExpectationValue *)valueWithName:(NSString *)aName {
    return [[[ExpectationValue alloc] initWithName:[self privateNameForPublicName:aName]] autorelease];
}

@end
