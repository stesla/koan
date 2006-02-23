#import <ObjcUnit/Test.h>

@interface TestCase : NSObject <Test> {
@private
    NSString *name;
}

- (id)initWithName:(NSString *)name;

- (NSString *)name;

- (TestResult *)run;
- (void)runBare;
- (void)runTest;

- (void)setUp;
- (void)tearDown;

@end

@interface TestCase (Assert)

- (void)fail;
- (void)fail:(NSString *)message;

- (void)assertTrue:(BOOL)condition;
- (void)assertTrue:(BOOL)condition message:(NSString *)message;

- (void)assertFalse:(BOOL)condition;
- (void)assertFalse:(BOOL)condition message:(NSString *)message;

- (void)assert:(id)actual equals:(id)expected;
- (void)assert:(id)actual equals:(id)expected message:(NSString *)message;

- (void)assertString:(NSString *)actual equals:(NSString *)expected;
- (void)assertString:(NSString *)actual equals:(NSString *)expected message:(NSString *)message;

- (void)assertInt:(int)actual equals:(int)expected;
- (void)assertInt:(int)actual equals:(int)expected message:(NSString *)message;

- (void)assertFloat:(float)actual equals:(float)expected precision:(float)delta;
- (void)assertFloat:(float)actual equals:(float)expected precision:(float)delta message:(NSString *)message;

- (void)assertNil:(id)object;
- (void)assertNil:(id)object message:(NSString *)message;

- (void)assertNotNil:(id)object;
- (void)assertNotNil:(id)object message:(NSString *)message;

- (void)assert:(id)object1 same:(id)object2;
- (void)assert:(id)object1 same:(id)object2 message:(NSString *)message;

@end
