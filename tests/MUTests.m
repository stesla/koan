//
// MUTests.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "MUTests.h"

#import "TestCase (NSAttributedStringAssertions).h"

#import "J3FilterTests.h"
#import "J3ANSIRemovingFilterTests.h"
#import "J3TextLoggerTests.h"
#import "J3HistoryRingTests.h"
#import "J3NaiveANSIFilterTests.h"
#import "J3NaiveURLFilterTests.h"
#import "MUProfileRegistryTests.h"
#import "MUWorldTests.h"
#import "MUProfileTests.h"
#import "MUPlayerTests.h"

int
main (int argc, const char *argv[])
{
  TestRunnerMain ([MUTests class]);
  return 0;
}

#pragma mark -

@implementation MUTests

+ (TestSuite *) suite
{
  TestSuite *suite = [TestSuite suiteWithName:@"Koan Tests"];
  
  // Add tests here.
  [suite addTestSuite:[J3FilterTests class]];
  [suite addTestSuite:[J3FilterQueueTests class]];
  [suite addTestSuite:[J3ANSIRemovingFilterTests class]];
  [suite addTestSuite:[J3HistoryRingTests class]];
  [suite addTestSuite:[J3NaiveURLFilterTests class]];
  [suite addTestSuite:[J3TextLoggerTests class]];
  [suite addTestSuite:[MUProfileRegistryTests class]];
  [suite addTestSuite:[MUWorldTests class]];
  [suite addTestSuite:[MUProfileTests class]];
  [suite addTestSuite:[MUPlayerTests class]];
  [suite addTestSuite:[J3NaiveANSIFilterTests class]];
  return suite;
}

@end
