//
// MUTests.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUTests.h"

#import "MUTelnetConnectionTests.h"
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
  [suite addTestSuite:[MUTelnetConnectionTests class]];
  [suite addTestSuite:[MUFilterTests class]];
  [suite addTestSuite:[MUFilterQueueTests class]];
  [suite addTestSuite:[MUAnsiRemovingFilterTests class]];
  [suite addTestSuite:[MUHistoryRingTests class]];
  [suite addTestSuite:[MUTextLogFilterTests class]];
  return suite;
}

@end