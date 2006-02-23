#import <Foundation/Foundation.h>

@interface AbstractExpectation : NSObject {
@private
    NSString *name;
    BOOL failsOnVerify;
    BOOL hasExpectations;
}

- (id)initWithName:(NSString *)name;

- (NSString *)name;

- (void)setFailsOnVerify:(BOOL)flag;
- (BOOL)failsOnVerify;

- (void)setHasExpectations:(BOOL)flag;
- (BOOL)hasExpectations;

- (void)verify;

@end

@interface AbstractExpectation (Asserts)

- (void)assert:(id)actual equals:(id)expected;
- (void)assertTrue:(BOOL)condition message:(NSString *)message;
- (void)assertInt:(int)actual equals:(int)expected;

@end
