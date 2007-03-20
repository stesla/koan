//
// MUKoanLog.h
//
// Copyright (c) 2007 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUKoanLog : NSObject 
{
  NSDictionary *headers;
  NSString *content;
}

+ (id) logWithContentsOfFile:(NSString *)path;
+ (id) logWithString:(NSString *)string;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithString:(NSString *)string;

- (NSString *) content;
- (void) fillDictionaryWithMetadata:(NSMutableDictionary *)dictionary;
- (NSString *) headerForKey:(NSString  *)string;

@end
