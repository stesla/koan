//
//  J3NaiveANSIFilter.h
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

@interface J3NaiveANSIFilter : J3Filter 
{
  BOOL inCodeFlag;
}

- (void) parseChar:(char)inChar;
- (BOOL) inCode;
- (void) setInCode:(BOOL)newValue;

@end
