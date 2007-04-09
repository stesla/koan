//
// MUTextLogDocument.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUTextLogDocument.h"

static NSString *MUKoanLogWorld = @"com_3james_koan_log_world";
static NSString *MUKoanLogPlayer = @"com_3james_koan_log_player";

@interface MUTextLogDocument (Private)

- (unsigned) findEndOfHeaderLocation: (NSString *)string lineEnding: (NSString **) lineEnding;
- (BOOL) addKeyValuePairFromString: (NSString *) string toDictionary: (NSMutableDictionary *) dictionary;
- (BOOL) parse: (NSString *) string;

@end

#pragma mark -

@implementation MUTextLogDocument

- (id) init
{
  if (![super init])
    return nil;
  
  content = nil;
  headers = nil;
  
  return self;
}

- (void) dealloc
{
  [content release];
  [headers release];
  [super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (NSString *) content
{
  return content;
}

- (void) fillDictionaryWithMetadata: (NSMutableDictionary *) dictionary
{
  if ([self headerForKey: @"World"])
    [dictionary setObject: [self headerForKey: @"World"]
                   forKey: MUKoanLogWorld];
  
  if ([self headerForKey: @"Player"])
    [dictionary setObject: [self headerForKey: @"Player"]
                   forKey: MUKoanLogPlayer];
  
  if ([self headerForKey: @"Date"])
    [dictionary setObject: [NSDate dateWithNaturalLanguageString: [self headerForKey: @"Date"]]
                   forKey: (NSString *) kMDItemContentCreationDate];
  
  [dictionary setObject: [self content] forKey: (NSString *) kMDItemTextContent];  
}

- (NSString *) headerForKey: (id) key
{
  return [headers objectForKey: key];
}

#pragma mark -
#pragma mark NSDocument overrides

- (NSData *) dataOfType: (NSString *) typeName error: (NSString **) error
{
  // TODO: should this be a read-only type?
  return nil;
}

- (void) makeWindowControllers
{
  // TODO: hook this document up into the singleton MULogBrowserWindowController.
}

- (BOOL) readFromData: (NSData *) data ofType: (NSString *) typeName error: (NSError **) error
{
  NSString *fileDataAsString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  
  if ([self parse: fileDataAsString])
    return YES;
  
  *error = @"TODO: give a reasonable error here";
  return NO;
}

@end

#pragma mark -

@implementation MUTextLogDocument (Private)

- (BOOL) addKeyValuePairFromString: (NSString *) string toDictionary: (NSMutableDictionary *) dictionary
{
  NSScanner *scanner = [NSScanner scannerWithString: string];
  NSString *header;
  
  [scanner scanUpToString: @":" intoString: &header];
  
  BOOL result = [string length] > [header length];
  if (result)
    [dictionary setObject: [string substringFromIndex: [scanner scanLocation] + 2] forKey: header]; 
  return result;
}

- (unsigned) findEndOfHeaderLocation: (NSString *) string lineEnding: (NSString **) lineEnding
{
  *lineEnding = nil;
  
  NSRange range = [string rangeOfString: @"\n\n"];
  if (range.location != NSNotFound)
  {
    *lineEnding = @"\n";
    return range.location;
  }
  
  range = [string rangeOfString: @"\r\n\r\n"];
  if (range.location != NSNotFound)
  {
    *lineEnding = @"\r\n";
    return range.location;
  }
  
  range = [string rangeOfString: @"\r\r"];
  if (range.location != NSNotFound)
  {
    *lineEnding = @"\r";
    return range.location;
  }
  
  return NSNotFound;
}

- (BOOL) parse: (NSString *) string
{
  // TODO: this should have an error field.
  NSMutableDictionary *workingHeaders = [NSMutableDictionary dictionary];
  NSString *lineEnding;
  
  unsigned endOfHeaders = [self findEndOfHeaderLocation: string lineEnding: &lineEnding];
  if (endOfHeaders == NSNotFound)
    return NO;
  
  NSArray *headerLines = [[string substringToIndex:endOfHeaders] componentsSeparatedByString: lineEnding];
  NSEnumerator *headerEnumerator = [headerLines objectEnumerator];
  
  NSString *line;
  while ((line = [headerEnumerator nextObject]))
  {
    if (![self addKeyValuePairFromString: line toDictionary: workingHeaders])
      return NO;
  }
  
  if (headers)
    [headers release];
  headers = [workingHeaders retain];
  
  if (content)
    [content release];
  content = [[string substringFromIndex: endOfHeaders + (2 * [lineEnding length])] copy];
  
  return YES;
}

@end
