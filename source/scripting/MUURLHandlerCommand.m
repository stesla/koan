//
// MUURLHandlerCommand.m
//
// Copyright (c) 2005, 2007 3James Software
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
