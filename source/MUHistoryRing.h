//
// MUHistoryRing.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUHistoryRing : NSObject
{
  NSString *buffer;
  NSMutableArray *ring;
  NSMutableDictionary *updates;
  int cursor;
}

- (void) saveString:(NSString *)string;
- (void) updateString:(NSString *)string;
- (NSString *) nextString;
- (NSString *) previousString;

@end
