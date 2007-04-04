//
// J3Filter.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol J3Filtering

- (NSAttributedString *) filter: (NSAttributedString *) string;

@end

@interface J3Filter : NSObject <J3Filtering>

+ (id) filter;

@end

@interface J3FilterQueue : NSObject
{
  NSMutableArray *filters;
}

- (NSAttributedString *) processAttributedString: (NSAttributedString *) string;
- (void) addFilter: (id <J3Filtering>) filter;
- (void) clearFilters;

@end
