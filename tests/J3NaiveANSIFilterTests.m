//
//  J3NaiveANSIFilterTests.m
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NaiveANSIFilterTests.h"

#import "J3NaiveANSIFilter.h"


@implementation J3NaiveANSIFilterTests

- (void) testInCode
{
  J3NaiveANSIFilter *filter = (J3NaiveANSIFilter *)[J3NaiveANSIFilter filter];
  char inChar = '\x1B';
  
  [self assertFalse:[filter inCode] message:@"Before"];
  [filter parseChar:inChar];
  [self assertTrue:[filter inCode] message:@"After"];
}

@end
