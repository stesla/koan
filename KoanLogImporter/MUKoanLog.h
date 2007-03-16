//
//  MUKoanLog.h
//  KoanLogImporter
//
//  Created by Samuel Tesla on 3/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MUKoanLog : NSObject 
{
  NSDictionary * headers;
  NSString * content;
}

+ (id) logWithContentsOfFile:(NSString *)path;
+ (id) logWithString:(NSString *)string;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithString:(NSString *)string;

- (NSString *) content;
- (void) fillDictionaryWithMetadata:(NSMutableDictionary *)dictionary;
- (NSString *) headerForKey:(NSString  *)string;

@end
