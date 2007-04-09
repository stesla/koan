//
// MULogBrowserWindowController.m
//
// Copyright (c) 2007 3James Software.
//

#import "MULogBrowserWindowController.h"

static MULogBrowserWindowController *sharedLogBrowserWindowController = nil;

@implementation MULogBrowserWindowController

+ (id) sharedLogBrowserWindowController
{
  if (!sharedLogBrowserWindowController)
    sharedLogBrowserWindowController = [[MULogBrowserWindowController alloc] init];
  
  return sharedLogBrowserWindowController;
}

- (id) init
{
  if (![super initWithWindowNibName: @"MULogBrowserWindow"])
    return nil;
  
  return self;
}

@end
