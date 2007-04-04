//
// J3ANSIFormattingFilter.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

@protocol J3Formatting;

@interface J3ANSIFormattingFilter : J3Filter
{
  BOOL inCode;
  NSString *ansiCode;
  NSObject <J3Formatting> *formatting;
  NSMutableDictionary *currentAttributes;
}

+ (J3Filter *) filterWithFormatting: (NSObject <J3Formatting> *) format;

- (id) initWithFormatting: (NSObject <J3Formatting> *) format;

@end

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
  J3ANSIForegroundDefault = 39,
  J3ANSIBackgroundBlack = 40,
  J3ANSIBackgroundRed = 41,
  J3ANSIBackgroundGreen = 42,
  J3ANSIBackgroundYellow = 43,
  J3ANSIBackgroundBlue = 44,
  J3ANSIBackgroundMagenta = 45,
  J3ANSIBackgroundCyan = 46,
  J3ANSIBackgroundWhite = 47,
  J3ANSIBackgroundDefault = 49
} J3ANSICode;
