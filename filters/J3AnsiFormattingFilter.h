//
// J3AnsiFormattingFilter.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

@protocol J3Formatting;

@interface J3AnsiFormattingFilter : J3Filter
{
  NSString *ansiCode;
  NSObject <J3Formatting> *formatting;
  NSMutableDictionary *currentAttributes;
}

+ (J3Filter *) filterWithFormatting:(NSObject <J3Formatting> *)format;

- (id) initWithFormatting:(NSObject <J3Formatting> *)format;

@end


typedef enum J3AnsiCode
{
  J3AnsiReset = 0,
  J3AnsiBoldOn = 1,
  J3AnsiItalicsOn = 3,
  J3AnsiUnderlineOn = 4,
  J3AnsiInverseOn = 7,
  J3AnsiStrikeOn = 9,
  J3AnsiBoldOff = 22,
  J3AnsiItalicsOff = 23,
  J3AnsiUnderlineOff = 24,
  J3AnsiInverseOff = 27,
  J3AnsiStrikeOff = 29,
  J3AnsiForegroundBlack = 30,
  J3AnsiForegroundRed = 31,
  J3AnsiForegroundGreen = 32,
  J3AnsiForegroundYellow = 33,
  J3AnsiForegroundBlue = 34,
  J3AnsiForegroundMagenta = 35,
  J3AnsiForegroundCyan = 36,
  J3AnsiForegroundWhite = 37,
  J3AnsiForegroundDefault = 39,
  J3AnsiBackgroundBlack = 40,
  J3AnsiBackgroundRed = 41,
  J3AnsiBackgroundGreen = 42,
  J3AnsiBackgroundYellow = 43,
  J3AnsiBackgroundBlue = 44,
  J3AnsiBackgroundMagenta = 45,
  J3AnsiBackgroundCyan = 46,
  J3AnsiBackgroundWhite = 47,
  J3AnsiBackgroundDefault = 49
} J3AnsiCode;
