//
// J3TextLogger.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "Categories/NSFileManager (Recursive).h"
#import "J3TextLogger.h"
#import "MUPlayer.h"
#import "MUWorld.h"

@interface J3TextLogger (Private)

- (void) log:(NSAttributedString *)editString;

@end

#pragma mark -

@implementation J3TextLogger

+ (J3Filter *) filter
{
  return [[[J3TextLogger alloc] init] autorelease];
}

+ (J3Filter *) filterWithWorld:(MUWorld *)world
{
  return [[[J3TextLogger alloc] initWithWorld:world] autorelease];
}

+ (J3Filter *) filterWithWorld:(MUWorld *)world player:(MUPlayer *)player
{
  return [[[J3TextLogger alloc] initWithWorld:world player:player] autorelease];
}

- (id) initWithOutputStream:(NSOutputStream *)stream
{
  if (self = [super init])
  {
    if (!stream)
      return nil;
    
    output = [stream retain];
    [output open];
  }
  return self;
}

- (id) init
{
  NSCalendarDate *today = [NSCalendarDate date];
  NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/Koan/Unknown/%d/%d/%d.txt",
    [today yearOfCommonEra],
    [today monthOfYear],
    [today dayOfMonth]] stringByExpandingTildeInPath];
  [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                             attributes:nil
                                              recursive:YES];
  NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path
                                                             append:YES];
  return [self initWithOutputStream:stream];
}

- (id) initWithWorld:(MUWorld *)world
{
  NSCalendarDate *today = [NSCalendarDate date];
  NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/Koan/%@/Unknown/%d/%d/%d.txt",
    [world worldName],
    [today yearOfCommonEra],
    [today monthOfYear],
    [today dayOfMonth]] stringByExpandingTildeInPath];
  [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                             attributes:nil
                                              recursive:YES];
  NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path
                                                             append:YES];
  return [self initWithOutputStream:stream];
}

- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player
{
  NSCalendarDate *today = [NSCalendarDate date];
  NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/Koan/%@/%@/%d/%d/%d.txt",
    [world worldName],
    [player name],
    [today yearOfCommonEra],
    [today monthOfYear],
    [today dayOfMonth]] stringByExpandingTildeInPath];
  [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                             attributes:nil
                                              recursive:YES];
  NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path
                                                             append:YES];
  return [self initWithOutputStream:stream];
}

- (void) dealloc
{
  [output close];
  [output release];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  if ([string length] > 0)
    [self log:string];
  
  return string;
}

@end

#pragma mark -

@implementation J3TextLogger (Private)

- (void) log:(NSAttributedString *)string
{
  const char *buffer = [[string string] UTF8String];
  
  [output write:(uint8_t *) buffer maxLength:strlen (buffer)];
}

@end
