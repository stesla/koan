//
// J3Filter.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@protocol J3Filtering

- (NSAttributedString *) filter: (NSAttributedString *) string;

@end

#pragma mark -

@interface J3Filter : NSObject <J3Filtering>

+ (id) filter;

@end

#pragma mark -

@interface J3FilterQueue : NSObject
{
  NSMutableArray *filters;
}

+ (id) filterQueue;

- (NSAttributedString *) processAttributedString: (NSAttributedString *) string;
- (void) addFilter: (NSObject <J3Filtering> *) filter;
- (void) clearFilters;

@end
