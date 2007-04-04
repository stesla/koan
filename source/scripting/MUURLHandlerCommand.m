//
// MUURLHandlerCommand.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "MUURLHandlerCommand.h"

#import "Controllers/MUApplicationController.h"

@implementation MUURLHandlerCommand

- (id) performDefaultImplementation
{
  [[NSApp delegate] connectToURL: [NSURL URLWithString: [self directParameter]]];
  
  return nil;
}

@end
