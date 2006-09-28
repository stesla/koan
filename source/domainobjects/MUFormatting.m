//
//  MUFormatting.m
//  Koan
//
//  Created by Samuel Tesla on 9/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MUFormatting.h"


@implementation MUFormatting

+ (id) formattingForTesting;
{
  return [self formattingWithForegroundColor:[MUFormatting testingForeground] backgroundColor:[MUFormatting testingBackground]];
}

+ (id) formattingWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back;
{
  return [[[self alloc] initWithForegroundColor:fore backgroundColor:back] autorelease];
}

+ (NSColor *) testingBackground;
{
  return [NSColor blackColor];
}

+ (NSColor *) testingForeground;
{
  return [NSColor lightGrayColor];
}

- (id) initWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back;
{
  if (!(self = [super init]))
    return nil;
  [self at:&foreground put:fore];
  [self at:&background put:back];
  return self;
}

- (NSColor *) background;
{
  return background;
}

- (NSColor *) foreground;
{
  return foreground;
}


@end
