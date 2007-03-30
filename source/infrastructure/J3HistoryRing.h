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
- (NSString *) stringAtIndex: (int) ringIndex;

// These methods are all O(1).

- (void) saveString: (NSString *) string;
- (void) updateString: (NSString *) string;
- (NSString *) currentString;
- (NSString *) nextString;
- (NSString *) previousString;

- (void) resetSearchCursor;

// These methods are all O(n).

- (unsigned) numberOfUniqueMatchesForStringPrefix: (NSString *) prefix;
- (NSString *) searchForwardForStringPrefix: (NSString *) prefix;
- (NSString *) searchBackwardForStringPrefix: (NSString *) prefix;

@end
