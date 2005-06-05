//
// MUUpdateController.m
//
// Copyright (c) 2005 3James Software
//

#import "MUUpdateController.h"
#import "MacPADSocket.h"

@interface MUUpdateController (Private)

- (void) updateDisplayForSocket:(MacPADSocket *)socket
                       userinfo:(NSDictionary *)userinfo;

@end

#pragma mark -

@implementation MUUpdateController

- (void) awakeFromNib
{
  macPAD = nil;
  [progressIndicator setDisplayedWhenStopped:NO];
}

- (void) dealloc
{
  [macPAD release];
  [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction) checkForUpdates:(id)sender
{
  [progressIndicator startAnimation:self];
  macPAD = [[MacPADSocket alloc] init];
  [macPAD setDelegate:self];
  [macPAD performCheck:[NSURL URLWithString:MUUpdateURL]
           withVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

#pragma mark -
#pragma mark MacPADSocket delegate

- (void) macPADErrorOccurred:(NSNotification *)notification
{
  NSAlert *alert;
  int choice;
  
  [self updateDisplayForSocket:[notification object] userinfo:[notification userInfo]];
  
  alert = [NSAlert alertWithMessageText:NSLocalizedString (MULErrorCheckingForUpdatesTitle, nil)
                          defaultButton:NSLocalizedString (MULOkay, nil)
                        alternateButton:nil
                            otherButton:nil
              informativeTextWithFormat:NSLocalizedString (MULErrorCheckingForUpdatesMessage, nil)];
  
  choice = [alert runModal];
}

- (void) macPADCheckFinished:(NSNotification *)notification
{
  [self updateDisplayForSocket:[notification object] userinfo:[notification userInfo]];
}

@end

#pragma mark -

@implementation MUUpdateController (Private)

- (void) updateDisplayForSocket:(MacPADSocket *)socket userinfo:(NSDictionary *)userinfo
{
  [progressIndicator stopAnimation:self];
  [versionText setStringValue:[socket newVersion]];
  [codeText setIntValue:[[userinfo objectForKey:MacPADErrorCode] intValue]];
  [msgText setStringValue:[userinfo objectForKey:MacPADErrorMessage]];
  [releaseNotesText setString:[socket releaseNotes]];
  [productURLText setStringValue:[socket productPageURL]];
  [downloadURLText setStringValue:[socket productDownloadURL]];
  
  [macPAD release];
  macPAD = nil;
}

@end
