//
//  J3NaiveANSIFilter.m
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NaiveANSIFilter.h"


@implementation J3NaiveANSIFilter

- (void) parseChar:(char)inChar
{
  switch (inChar)
  {
    case '\x1B':
      [self setInCode:YES];
      break;
      
    default:
      break;
  }
}

- (BOOL) inCode
{
  return inCodeFlag;
}

- (void) setInCode:(BOOL)newValue
{
  inCodeFlag = newValue;
}

@end
