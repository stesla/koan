//
// MUKoanLog.m
//
// Copyright (c) 2007 3James Software
//

#import "MUKoanLog.h"

static NSString *MUKoanLogWorld = @"com_3james_koan_log_world";
static NSString *MUKoanLogPlayer = @"com_3james_koan_log_player";

@interface MUKoanLog (Private)

- (unsigned) findEndOfHeaderLocation:(NSString *)string lineEnding:(NSString * *)lineEnding;
- (BOOL) addKeyValuePairFromString:(NSString *)string toDictionary:(NSMutableDictionary *)dictionary;
- (BOOL) parse:(NSString *)string;

@end

#pragma mark -

@implementation MUKoanLog

+ (id) logWithContentsOfFile:(NSString *)path;
{
  return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+ (id) logWithString:(NSString *)string;
{
  return [[[self alloc] initWithString:string] autorelease];
}

- (NSString *) content;
{
  return content;
}

- (void) dealloc;
{
  [content release];
  [headers release];
  [super dealloc];
}

- (id) initWithContentsOfFile:(NSString *)path;
{
  return [self initWithString:[NSString stringWithContentsOfFile:path]];
}

- (id) initWithString:(NSString *)string;
{
  if (![super init])
    return nil;
  if (![self parse:string])
    return nil;
  return self;
}

- (void) fillDictionaryWithMetadata:(NSMutableDictionary *)dictionary;
{
  NSString *world = [self headerForKey:@"World"];
  NSString *player = [self headerForKey:@"Player"];
  NSDate *date = [NSDate dateWithNaturalLanguageString:[self headerForKey:@"Date"]];
  
  if (world)
    [dictionary setObject:world forKey:MUKoanLogWorld];
  if (player)
    [dictionary setObject:player forKey:MUKoanLogPlayer];
  if (date)
    [dictionary setObject:date forKey:(NSString *)kMDItemContentCreationDate];
  [dictionary setObject:[self content] forKey:(NSString *)kMDItemTextContent];  
}

- (NSString *) headerForKey:(NSString  *)string;
{
  return [headers objectForKey:string];
}

@end

#pragma mark -

@implementation MUKoanLog (Private)

- (BOOL) addKeyValuePairFromString:(NSString *)string toDictionary:(NSMutableDictionary *)dictionary;
{
  NSScanner *scanner = [NSScanner scannerWithString:string];
  NSString *header;
  BOOL result;
  
  [scanner scanUpToString:@":" intoString:&header];
  result = [string length] > [header length];
  if (result)
    [dictionary setObject:[string substringFromIndex:[scanner scanLocation] + 2] forKey:header]; 
  return result;
}

- (unsigned) findEndOfHeaderLocation:(NSString *)string lineEnding:(NSString * *)lineEnding;
{
  NSRange range;
  *lineEnding = @"\n";
  range = [string rangeOfString:@"\n\n"];
  if (range.location != NSNotFound)
    return range.location;
  *lineEnding = @"\r\n";
  range = [string rangeOfString:@"\r\n\r\n"];
  if (range.location != NSNotFound)
    return range.location;
  *lineEnding = @"\r";
  range = [string rangeOfString:@"\r\r"];
  return range.location; // if it is NSNotFound, that's what we want
}

- (BOOL) parse:(NSString *)string;
{
  NSMutableDictionary *workingHeaders = [NSMutableDictionary dictionary];
  unsigned endOfHeaders;
  NSString *lineEnding;
  NSArray *headerLines;
  NSEnumerator *headerEnumerator;
  NSString *line;
  
  endOfHeaders = [self findEndOfHeaderLocation:string lineEnding:&lineEnding];
  if (endOfHeaders == NSNotFound)
    return NO;
  headerLines = [[string substringToIndex:endOfHeaders] componentsSeparatedByString:lineEnding];
  headerEnumerator = [headerLines objectEnumerator];
  while (line = [headerEnumerator nextObject])
  {
    if (![self addKeyValuePairFromString:line toDictionary:workingHeaders])
      return NO;
  }
  
  headers = [workingHeaders retain];   
  content = [[string substringFromIndex:endOfHeaders + (2 * [lineEnding length])] retain];
  return YES;
}

@end
