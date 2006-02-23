#import "TestSuite.h"

#import "NSObject-ObjcUnitAdditions.h"
#import "_WarningTest.h"

@interface NSMethodSignature (ObjcUnitAdditions)
- (BOOL)methodReturnsVoid;
@end

@implementation TestSuite

+ (TestSuite *)suiteWithClass:(Class)aClass {
    return [[[self alloc] initWithClass:aClass] autorelease];
}

+ (id<Test>)testWithName:(NSString *)aName {
    TestSuite *testSuite = [[self alloc] initWithName:aName];
    return [testSuite autorelease];
}

- (id)init {
    return [self initWithName:@"Unnamed test suite"];
}

+ (TestSuite *)suiteWithName:(NSString *)aName {
    return [[[self alloc] initWithName:aName] autorelease];
}

- (id)initWithName:(NSString *)aName {
    self = [super init];
    tests = [[NSMutableArray alloc] init];
    name = [[NSString alloc] initWithString:aName];
    return self;
}

- (id)createWarning:(NSString *)message {
    return [[[_WarningTest alloc] initWithName:@"warning" message:message] autorelease];
}

- (BOOL)validateTestMethodNamed:(NSString *)aMethodName inClass:(Class)aClass {
    NSMethodSignature *signature = nil;
    SEL aSelector;
    
    if ([aMethodName hasPrefix:@"test"] == NO) return NO;

    aSelector = NSSelectorFromString(aMethodName);
    if (aSelector == NULL) return NO;

    signature = [aClass instanceMethodSignatureForSelector:aSelector];
    if (signature == nil) return NO;
    if ([signature numberOfArguments] != 2) return NO;
    if (![signature methodReturnsVoid]) return NO;
    
    return YES;
}

- (id)initWithClass:(Class)aClass {
    NSString *className = NSStringFromClass(aClass);
    NSEnumerator *methodEnum = nil;
    NSString *aMethod = nil;
    
    [self initWithName:className];

    if (![aClass conformsToProtocol:@protocol(Test)]) {
        NSString *warning = [NSString stringWithFormat:@"The class %@ does not conform to Test protocol", className];
        [self addTest:[self createWarning:warning]];
        return self;
    }

    methodEnum = [[aClass instanceMethodNames] objectEnumerator];
    while (aMethod = [methodEnum nextObject]) {
        if ([self validateTestMethodNamed:aMethod inClass:aClass]) {
            id<Test> aTest = [[aClass class] testWithName:aMethod];
            [self addTest:aTest];
        }
    }

    if ([tests count] == 0) {
        NSString *warning = [NSString stringWithFormat:@"No tests found in %@", className];
        [self addTest:[self createWarning:warning]];
    }

    return self;
}

- (void)dealloc {
    [tests release];
    [name release];
    [super dealloc];
}

- (int)countTestCases {
    int count = 0;
    NSEnumerator *testEnum = [self testEnumerator];
    id<Test> test = nil;

    while (test = [testEnum nextObject]) {
        count = count + [test countTestCases];
    }

    return count;
}

- (void)run:(TestResult *)result {
    NSEnumerator *testEnum = [self testEnumerator];
    id<Test> test = nil;

    while (test = [testEnum nextObject]) {
        [self runTest:test result:result];
    }
}

- (void)runTest:(id<Test>)test result:(TestResult *)result {
    [test run:result];
}

- (void)addTest:(id<Test>)test {
    [tests addObject:test];
}

- (void)addTestSuite:(Class)aClass {
    TestSuite *suite = [[TestSuite alloc] initWithClass:aClass];
    [self addTest:suite];
    [suite release];
}

- (NSEnumerator *)testEnumerator {
    NSArray *array = [NSArray arrayWithArray:tests];
    return [array objectEnumerator];
}

- (int)numberOfTests {
    return [tests count];
}

@end

@implementation NSMethodSignature (ObjcUnitAdditions)

- (BOOL)methodReturnsVoid {
    return [self methodReturnLength] == 0;
}

@end
