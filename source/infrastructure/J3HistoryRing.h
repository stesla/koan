//
// J3HistoryRing.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@interface J3HistoryRing : NSObject
{
  NSString *buffer;
  NSMutableArray *ring;
  NSMutableDictionary *updates;
  int cursor;
  int searchCursor;
}

- (unsigned) count;
- (NSString *) stringAtIndex:(unsigned)index;

- (void) saveString:(NSString *)string;
- (void) updateString:(NSString *)string;
- (NSString *) currentString;
- (NSString *) nextString;
- (NSString *) previousString;

- (void) resetSearchCursor;
- (NSString *) searchForwardForStringPrefix:(NSString *)prefix;
- (NSString *) searchBackwardForStringPrefix:(NSString *)prefix;

@end
