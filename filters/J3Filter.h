//
// J3Filter.h
//
// Copyright (C) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3Filtering

- (NSAttributedString *) filter:(NSAttributedString *)string;

@end

@interface J3Filter : NSObject <J3Filtering> 

+ (J3Filter *) filter;

@end

@interface J3FilterQueue : NSObject
{
  NSMutableArray *filters;
}

- (NSAttributedString *) processAttributedString:(NSAttributedString *)string;
- (void) addFilter:(id <J3Filtering>)filter;

@end
