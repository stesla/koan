//
// MUTests.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "MUTests.h"
#import "categories/NSObject (Subclasses).h"
#import <objc/objc-runtime.h>

int
main (int argc, const char *argv[])
{
  TestRunnerMain ([MUTests class]);
  return 0;
}

#pragma mark -

@class _WarningTest;

@implementation MUTests
+ (void) addTestsToSuite:(TestSuite *)suite;
{
  NSArray * testCases = [TestCase subclasses];
  unsigned i, count = [testCases count];
  Class testCaseClass;
  
  for (i = 0; i < count; i++)
  {
    testCaseClass = [[testCases objectAtIndex:i] class];
    if (testCaseClass == [_WarningTest class])
      continue;
    [suite addTestSuite:testCaseClass];    
  }
}

+ (TestSuite *) suite
{
  TestSuite * suite = [TestSuite suiteWithName:@"Koan Tests"];
  [self addTestsToSuite:suite];
  return suite;
}

@end
