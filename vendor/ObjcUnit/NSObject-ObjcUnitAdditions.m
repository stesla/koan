#import "NSObject-ObjcUnitAdditions.h"
#import <objc/objc-class.h>

@interface NSObject (ObjcUnitAdditions_Privates)
+ (void)addInstanceMethodNamesForClass:(Class)aClass toArray:(NSMutableArray *)array;
+ (void)addInstanceMethodNamesForMethodList:(struct objc_method_list *)mlist toArray:(NSMutableArray *)array;
@end

@implementation NSObject (ObjcUnitAdditions)

+ (NSArray *)instanceMethodNames {
    NSMutableArray *instanceMethodNames = [NSMutableArray array];
    id each;
    NSEnumerator *enumerator;
    
    for (each = [self class]; each != nil; each = [each superclass]) {
        [self addInstanceMethodNamesForClass:each toArray:instanceMethodNames];
    }
    
    enumerator = [instanceMethodNames reverseObjectEnumerator];
    instanceMethodNames = [NSMutableArray array];
    while (each = [enumerator nextObject]) {
        [instanceMethodNames addObject:each];
    }
    return instanceMethodNames;
}

@end

@implementation NSObject (ObjcUnitAdditions_Privates)

+ (void)addInstanceMethodNamesForClass:(Class)aClass toArray:(NSMutableArray *)array {
    void *iterator = 0;
    struct objc_method_list *each;
    
    while (each = class_nextMethodList(aClass, &iterator)) {
        [self addInstanceMethodNamesForMethodList:each toArray:array];
    }
}

+ (void)addInstanceMethodNamesForMethodList:(struct objc_method_list *)mlist toArray:(NSMutableArray *)array {
    int i;
    Method aMethod;
    NSString *methodName;

    for (i = 0; i < mlist->method_count; i++) {
        aMethod = &(mlist->method_list[i]);
        if (aMethod == NULL) continue;
        methodName = NSStringFromSelector(aMethod->method_name);
        if ([array containsObject:methodName]) continue;
        [array addObject:methodName];
    }
}

@end
