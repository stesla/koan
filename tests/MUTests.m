//
// MUTests.m
//
// Copyright (C) 2004 3James Software
//

#import "MUTests.h"

#import "J3FilterTests.h"
#import "J3ANSIRemovingFilterTests.h"
#import "J3TextLoggerTests.h"
#import "J3HistoryRingTests.h"
#import "J3URLLinkFilterTests.h"

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
  [suite addTestSuite:[J3FilterTests class]];
  [suite addTestSuite:[J3FilterQueueTests class]];
  [suite addTestSuite:[J3ANSIRemovingFilterTests class]];
  [suite addTestSuite:[J3HistoryRingTests class]];
  [suite addTestSuite:[J3TextLoggerTests class]];
  [suite addTestSuite:[J3URLLinkFilterTests class]];
  return suite;
}

@end
