//
// MUAcknowledgementsController.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUAcknowledgementsController.h"

@implementation MUAcknowledgementsController

- (id) init
{
  if (!(self = [super initWithWindowNibName: @"MUAcknowledgements"]))
    return nil;

  return self;
}
  
- (IBAction) openGrowlWebPage: (id) sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://growl.info/"]];
}

- (IBAction) openOpenSSLWebPage: (id) sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.openssl.org/"]];
}

- (IBAction) openRBSplitViewWebPage: (id) sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.brockerhoff.net/src/rbs.html"]];
}

- (IBAction) openSparkleWebPage: (id) sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://sparkle.andymatuschak.org/"]];
}

- (IBAction) openUKPrefsPanelWebPage: (id) sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://zathras.de/angelweb/sourcecode.htm"]];
}

@end
