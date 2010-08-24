//
// J3Formatter.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@protocol J3Formatter

- (NSColor *) background;
- (NSFont *) font;
- (NSColor *) foreground;

@end

#pragma mark -

@interface J3Formatter : NSObject <J3Formatter>
{
  NSColor *background;
  NSFont *font;
  NSColor *foreground;
}

+ (id) formatterForTesting;
+ (id) formatterWithForegroundColor: (NSColor *) fore backgroundColor: (NSColor *) back font: (NSFont *) font;
+ (NSColor *) testingBackground;
+ (NSFont *) testingFont;
+ (NSColor *) testingForeground;

- (id) initWithForegroundColor: (NSColor *) fore backgroundColor: (NSColor *) back font: (NSFont *) font;

@end
