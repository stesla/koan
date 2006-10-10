//
// MUTextLogger.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "categories/NSFileManager (Recursive).h"
#import "MUTextLogger.h"
#import "MUPlayer.h"
#import "MUWorld.h"

@interface MUTextLogger (Private)

- (void) log:(NSAttributedString *)editString;
- (NSOutputStream *) openStreamToPath:(NSString *)path withWorld:(MUWorld *)world andPlayer:(MUPlayer *)player onDate:(NSCalendarDate *)date;
- (void) writeToStream:(NSOutputStream *)stream withFormat:(NSString *)format,...;
@end

#pragma mark -

@implementation MUTextLogger

+ (J3Filter *) filter
{
  return [[[MUTextLogger alloc] init] autorelease];
}

+ (J3Filter *) filterWithWorld:(MUWorld *)world
{
  return [[[MUTextLogger alloc] initWithWorld:world] autorelease];
}

+ (J3Filter *) filterWithWorld:(MUWorld *)world player:(MUPlayer *)player
{
  return [[[MUTextLogger alloc] initWithWorld:world player:player] autorelease];
}

- (id) initWithOutputStream:(NSOutputStream *)stream
{
  if (!stream || ![super init])
    return nil;
  
  output = [stream retain];
  [output open];
  
  return self;
}

- (id) init
{
  NSCalendarDate *today = [NSCalendarDate date];
  NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/Koan/%04d-%02d-%02d.koanlog",
    [today yearOfCommonEra],
    [today monthOfYear],
    [today dayOfMonth]] stringByExpandingTildeInPath];
  [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                             attributes:nil
                                              recursive:YES];
  NSOutputStream *stream = [self openStreamToPath:path withWorld:nil andPlayer:nil onDate:today];
  return [self initWithOutputStream:stream];
}

- (id) initWithWorld:(MUWorld *)world
{
  NSCalendarDate *today = [NSCalendarDate date];
  NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/Koan/%@-%04d-%02d-%02d.koanlog",
    [world name],
    [today yearOfCommonEra],
    [today monthOfYear],
    [today dayOfMonth]] stringByExpandingTildeInPath];
  [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                             attributes:nil
                                              recursive:YES];
  
  NSOutputStream *stream = [self openStreamToPath:path withWorld:world andPlayer:nil onDate:today];
  return [self initWithOutputStream:stream];
}

- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player
{
  NSCalendarDate *today = [NSCalendarDate date];
  NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/Koan/%@-%@-%04d-%02d-%02d.koanlog",
    [world name],
    [player name],
    [today yearOfCommonEra],
    [today monthOfYear],
    [today dayOfMonth]] stringByExpandingTildeInPath];
  [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                             attributes:nil
                                              recursive:YES];
  NSOutputStream *stream = [self openStreamToPath:path withWorld:world andPlayer:player onDate:today];
  return [self initWithOutputStream:stream];
}

- (void) dealloc
{
  [output close];
  [output release];
  [super dealloc];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  if ([string length] > 0)
    [self log:string];
  
  return string;
}

@end

#pragma mark -

@implementation MUTextLogger (Private)

- (void) log:(NSAttributedString *)string
{
  [self writeToStream:output withFormat:[string string]];
}

- (NSOutputStream *) openStreamToPath:(NSString *)path withWorld:(MUWorld *)world andPlayer:(MUPlayer *)player onDate:(NSCalendarDate *)date;
{
  if (![[NSFileManager defaultManager] fileExistsAtPath:path])
  {
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
    [stream open];
    @try
    {
      if (world)
        [self writeToStream:stream withFormat:@"World: %@\n",[world name]];
      if (player)
        [self writeToStream:stream withFormat:@"Player: %@\n",[player name]];
      [self writeToStream:stream withFormat:@"Date: %04d-%02d-%02d\n",[date yearOfCommonEra],[date monthOfYear],[date dayOfMonth]];
      [self writeToStream:stream withFormat:@"\n"];      
    }
    @finally
    {
      [stream close];      
    }
  }
  return [NSOutputStream outputStreamToFileAtPath:path append:YES];
}

- (void) writeToStream:(NSOutputStream *)stream withFormat:(NSString *)format,...;
{
  va_list args;
  NSString *string;
  const char *buffer;
  
  va_start (args, format);
  string = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
  va_end (args);
  buffer = [string UTF8String];
  [stream write:(uint8_t *) buffer maxLength:strlen (buffer)];  
}

@end
