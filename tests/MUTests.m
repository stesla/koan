//
// MUTests.m
//
// Copyright (C) 2004 3James Software
//

#import "MUTests.h"

#import "MUFilterTests.h"
#import "MUAnsiRemovingFilterTests.h"
#import "MUTextLogFilterTests.h"
#import "MUHistoryRingTests.h"

int
main (int argc, const char *argv[])
{
  TestRunnerMain ([MUTests class]);
  return 0;
}

@implementation MUTests

+ (TestSuite *) suite
{
  TestSuite *suite = [TestSuite suiteWithName:@"Koan Tests"];
  
  // Add tests here.
  [suite addTestSuite:[MUFilterTests class]];
  [suite addTestSuite:[MUFilterQueueTests class]];
  [suite addTestSuite:[MUAnsiRemovingFilterTests class]];
  [suite addTestSuite:[MUHistoryRingTests class]];
  [suite addTestSuite:[MUTextLogFilterTests class]];
  return suite;
}

@end
