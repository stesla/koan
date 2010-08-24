//
// J3ANSIFormattingFilter.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

@protocol J3Formatter;

// All of the below codes are supported except for italics and strike.
// I am merely documenting them here for completeness.  They are not
// implemented because my survey of mushes indicates that they are
// not used.

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
  J3ANSIForeground256 = 38,
  J3ANSIForegroundDefault = 39,
  J3ANSIBackgroundBlack = 40,
  J3ANSIBackgroundRed = 41,
  J3ANSIBackgroundGreen = 42,
  J3ANSIBackgroundYellow = 43,
  J3ANSIBackgroundBlue = 44,
  J3ANSIBackgroundMagenta = 45,
  J3ANSIBackgroundCyan = 46,
  J3ANSIBackgroundWhite = 47,
  J3ANSIBackground256 = 48,
  J3ANSIBackgroundDefault = 49
} J3ANSICode;

typedef enum J3ANSI256ColorCode
{
  J3ANSI256Black = 0,
  J3ANSI256Red = 1,
  J3ANSI256Green = 2,
  J3ANSI256Yellow = 3,
  J3ANSI256Blue = 4,
  J3ANSI256Magenta = 5,
  J3ANSI256Cyan = 6,
  J3ANSI256White = 7,
  J3ANSI256BrightBlack = 8,
  J3ANSI256BrightRed = 9,
  J3ANSI256BrightGreen = 10,
  J3ANSI256BrightYellow = 11,
  J3ANSI256BrightBlue = 12,
  J3ANSI256BrightMagenta = 13,
  J3ANSI256BrightCyan = 14,
  J3ANSI256BrightWhite = 15,
} J3ANSI256ColorCode;

@interface J3ANSIFormattingFilter : J3Filter
{
  BOOL inCode;
  NSString *ansiCode;
  NSObject <J3Formatter> *formatter;
  NSMutableDictionary *currentAttributes;
}

+ (J3Filter *) filterWithFormatter: (NSObject <J3Formatter> *) newFormatter;

- (id) initWithFormatter: (NSObject <J3Formatter> *) newFormatter;

@end
