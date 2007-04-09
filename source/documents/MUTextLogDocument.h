//
// MUTextLogDocument.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface MUTextLogDocument : NSDocument
{
  NSDictionary *headers;
  NSString *content;
}

- (id) mockInitWithString: (NSString *) string;

- (NSString *) content;
- (void) fillDictionaryWithMetadata: (NSMutableDictionary *) dictionary;
- (NSString *) headerForKey: (id) key;

@end
