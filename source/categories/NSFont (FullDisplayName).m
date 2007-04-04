//
// NSFont (FullDisplayName).m
//
// Copyright (c) 2007 3James Software. All rights reserved.
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
