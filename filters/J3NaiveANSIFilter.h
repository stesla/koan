//
//  J3NaiveANSIFilter.h
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

typedef enum _J3ANSICode
{
  J3ANSIReset = 0,
  J3ANSIBoldOn = 1,
  J3ANSIItalicsOn = 3,
  J3ANSIUnderlineOn = 4,
  J3ANSIInverseOn = 7,
  J3ANSIStrikeOn = 9,
  J3ANSIBoldOff = 22,
  J3ANSIItalicsOff = 23,
  J3ANSIUnderlineOff = 24,
  J3ANSIInverseOff = 27,
  J3ANSIStrikeOff = 29,
  J3ANSIForeBlack = 30,
  J3ANSIForeRed = 31,
  J3ANSIForeGreen = 32,
  J3ANSIForeYellow = 33,
  J3ANSIForeBlue = 34,
  J3ANSIForeMagenta = 35,
  J3ANSIForeCyan = 36,
  J3ANSIForeWhite = 37,
  J3ANSIForeDefault = 39,
  J4ANSIBackBlack = 40,
  J4ANSIBackRed = 41,
  J4ANSIBackGreen = 42,
  J4ANSIBackYellow = 43,
  J4ANSIBackBlue = 44,
  J4ANSIBackMagenta = 45,
  J4ANSIBackCyan = 46,
  J4ANSIBackWhite = 47,
  J4ANSIBackDefault = 49
} J3ANSICode;

@interface J3NaiveANSIFilter : J3Filter 
{
}


@end
