//
// MUFilter.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol MUFiltering

- (NSAttributedString *) filter:(NSAttributedString *)string;

@end

@interface MUFilter : NSObject <MUFiltering> 

+ (MUFilter *) filter;

@end

@interface MUFilterQueue : NSObject
{
  NSMutableArray *filters;
}

- (NSAttributedString *) processAttributedString:(NSAttributedString *)string;
- (void) addFilter:(id <MUFiltering>)filter;

@end
