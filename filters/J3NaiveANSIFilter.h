//
// J3NaiveANSIFilter.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

typedef enum J3ANSICode
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
  J3ANSIForegroundBlack = 30,
  J3ANSIForegroundRed = 31,
  J3ANSIForegroundGreen = 32,
  J3ANSIForegroundYellow = 33,
  J3ANSIForegroundBlue = 34,
  J3ANSIForegroundMagenta = 35,
  J3ANSIForegroundCyan = 36,
  J3ANSIForegroundWhite = 37,
  J3ANSIForegroundDefault = 39,
  J3ANSIBackBlack = 40,
  J3ANSIBackRed = 41,
  J3ANSIBackGreen = 42,
  J3ANSIBackYellow = 43,
  J3ANSIBackBlue = 44,
  J3ANSIBackMagenta = 45,
  J3ANSIBackCyan = 46,
  J3ANSIBackWhite = 47,
  J3ANSIBackDefault = 49
} J3ANSICode;

#pragma mark -

@interface J3NaiveANSIFilter : J3Filter 
{
  NSColor *defaultForeground;
}

@end
