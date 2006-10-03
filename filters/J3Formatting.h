//
//  J3Formatting.h
//  Koan
//
//  Created by Samuel Tesla on 9/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol J3Formatting
- (NSColor *) background;
- (NSFont *) activeFont;
- (NSColor *) foreground;
@end

@interface J3Formatting : NSObject <J3Formatting>
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
