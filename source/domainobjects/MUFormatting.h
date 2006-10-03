//
//  MUFormatting.h
//  Koan
//
//  Created by Samuel Tesla on 9/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MUFormatting
- (NSColor *) background;
- (NSFont *) activeFont;
- (NSColor *) foreground;
@end

@interface MUFormatting : NSObject <MUFormatting>
{
  NSColor * background;
  NSFont * font;
  NSColor * foreground;
}

+ (id) formattingForTesting;
+ (id) formattingWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back font:(NSFont *)font;
+ (NSColor *) testingBackground;
+ (NSFont *) testingFont;
+ (NSColor *) testingForeground;

- (id) initWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back font:(NSFont *)font;

@end
