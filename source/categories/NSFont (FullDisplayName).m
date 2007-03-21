//
// NSFont (FullDisplayName).m
//
// Copyright (c) 2005 3James Software
//
// This file is in the public domain.
//

#import "NSFont (FullDisplayName).h"

@implementation NSFont (FullDisplayName)

- (NSString *) fullDisplayName
{
  return [NSString stringWithFormat: @"%@ - %@pt", [self displayName], [NSNumber numberWithFloat: [self pointSize]]];
}

@end
