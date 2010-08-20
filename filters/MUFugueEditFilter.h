//
// MUFugueEditFilter.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <J3Filter.h>

@interface MUFugueEditFilter : J3Filter
{
  id delegate;
}

@property (assign, nonatomic) id delegate;

+ (id) filterWithDelegate: (id) newDelegate;

- (id) initWithDelegate: (id) newDelegate;

@end

#pragma mark -

@interface NSObject (MUFugueEditFilterDelegate)

- (void) setInputViewString: (NSString *) text;

@end
