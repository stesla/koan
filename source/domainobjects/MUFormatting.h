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
- (NSColor *) foreground;
@end

@interface MUFormatting : NSObject <MUFormatting>
{
  NSColor * background;
  NSColor * foreground;
}

+ (id) formattingForTesting;
+ (id) formattingWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back;
+ (NSColor *) testingBackground;
+ (NSColor *) testingForeground;

- (id) initWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back;

@end
