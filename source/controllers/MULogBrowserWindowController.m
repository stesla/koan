//
// MULogBrowserWindowController.m
//
// Copyright (c) 2007 3James Software.
//

#import "MULogBrowserWindowController.h"
#import "MUTextLogDocument.h"

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
  if (![super initWithWindowNibName: @"MULogBrowser"])
    return nil;
  
  (void) [self window];
  
  return self;
}

#pragma mark -
#pragma mark NSWindowController overrides

- (void) setDocument: (NSDocument *) newDocument
{
  [super setDocument: newDocument];
  
  [textView setString: [(MUTextLogDocument *) newDocument content]];
  
  [self showWindow: nil];
}

@end
