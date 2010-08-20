//
// MUFugueEditFilter.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUFugueEditFilter.h"

@implementation MUFugueEditFilter

@synthesize delegate;

+ (id) filterWithDelegate: (id) newDelegate
{
  return [[[self alloc] initWithDelegate: newDelegate] autorelease];
}

- (id) initWithDelegate: (id) newDelegate
{
  if (!(self = [super init]))
    return nil;
  
  self.delegate = newDelegate;
  return self;
}

- (id) init
{
  return [self initWithDelegate: nil];
}

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  NSString *plainString = [string string];
  NSString *fugueEditPrefix = @"FugueEdit > ";
  
  if ([plainString hasPrefix: fugueEditPrefix])
  {
    if ([self.delegate respondsToSelector: @selector (setInputViewString:)])
      [self.delegate setInputViewString: [[plainString substringFromIndex: [fugueEditPrefix length]] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    return [NSAttributedString attributedStringWithString: @""];
  }
  else
    return string;
}

@end
