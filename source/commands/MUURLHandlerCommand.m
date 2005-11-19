//
// MUURLHandlerCommand.m
//
// Copyright (c) 2005 3James Software
//

#import "MUURLHandlerCommand.h"

#import "Controllers/MUApplicationController.h"

@implementation MUURLHandlerCommand

- (id) performDefaultImplementation
{
  MUApplicationController *appController = [NSApp delegate];
  NSURL *url;
  
  url = [NSURL URLWithString:[self directParameter]];
  
  [appController connectToURL:url];
  
  return nil;
}

@end
