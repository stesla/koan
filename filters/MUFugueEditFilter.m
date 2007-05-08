//
// MUFugueEditFilter.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUFugueEditFilter.h"

@implementation MUFugueEditFilter

+ (id) filterWithDelegate: (id) newDelegate
{
  return [[[self alloc] initWithDelegate: newDelegate] autorelease];
}

- (id) initWithDelegate: (id) newDelegate
{
  if (![super init])
    return nil;
  
  [self setDelegate: newDelegate];
  return self;
}

- (id) init
{
  return [self initWithDelegate: nil];
}

- (id) delegate
{
  return delegate;
}

- (void) setDelegate: (id) newDelegate
{
  delegate = newDelegate;
}

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  NSString *plainString = [string string];
  NSString *fugueEditPrefix = @"FugueEdit > ";
  
  if ([plainString hasPrefix: fugueEditPrefix])
  {
    if ([delegate respondsToSelector: @selector (setInputViewString:)])
      [delegate setInputViewString: [[plainString substringFromIndex: [fugueEditPrefix length]] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    return [NSAttributedString attributedStringWithString: @""];
  }
  else
    return string;
}

@end
