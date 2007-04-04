//
// J3Formatting.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol J3Formatting

- (NSColor *) background;
- (NSFont *) font;
- (NSColor *) foreground;

@end

#pragma mark -

@interface J3Formatting : NSObject <J3Formatting>
{
  NSColor *background;
  NSFont *font;
  NSColor *foreground;
}

+ (id) formattingForTesting;
+ (id) formattingWithForegroundColor: (NSColor *) fore backgroundColor: (NSColor *) back font: (NSFont *) font;
+ (NSColor *) testingBackground;
+ (NSFont *) testingFont;
+ (NSColor *) testingForeground;

- (id) initWithForegroundColor: (NSColor *) fore backgroundColor: (NSColor *) back font: (NSFont *) font;

@end
