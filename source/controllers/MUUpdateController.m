//
// MUUpdateController.m
//
// Copyright (c) 2005 3James Software
//

#import "MUUpdateController.h"
#import "MacPADSocket.h"

enum MUUpdateIntervals
{
  MUUpdateAtLaunch = 0,
  MUUpdateDaily = 1,
  MUUpdateWeekly = 2,
  MUUpdateMonthly = 3
};

@interface MUUpdateController (Private)

- (void) checkForUpdatesAndShowDialogIfUpdateIsAvailable:(BOOL)isAvailable
                        showDialogIfUpdateIsNotAvailable:(BOOL)isNotAvailable
                                     showDialogForErrors:(BOOL)forErrors;
- (void) checkForUpdatesAutomatically:(NSTimer *)timer;
- (void) updateDisplayForSocket:(MacPADSocket *)socket
                       userinfo:(NSDictionary *)userinfo;

@end

#pragma mark -

@implementation MUUpdateController

- (void) awakeFromNib
{
  automaticCheckTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                         target:self
                                                       selector:@selector(checkForUpdatesAutomatically:)
                                                       userInfo:nil
                                                        repeats:YES];
  
  [progressIndicator setDisplayedWhenStopped:NO];
}

- (void) dealloc
{
  [automaticCheckTimer invalidate];
  [macPADSocket release];
  [updateLock release];
  [super dealloc];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  SEL menuItemAction = [menuItem action];
  
  if (menuItemAction == @selector(checkForUpdatesWithDialog:))
  {
    return updateLock ? NO : YES;
  }
  return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction) checkForUpdates:(id)sender
{
  [self checkForUpdatesAndShowDialogIfUpdateIsAvailable:NO
                       showDialogIfUpdateIsNotAvailable:NO
                                    showDialogForErrors:YES];
}

- (IBAction) checkForUpdatesWithDialog:(id)sender
{
  [self checkForUpdatesAndShowDialogIfUpdateIsAvailable:YES
                       showDialogIfUpdateIsNotAvailable:YES
                                    showDialogForErrors:YES];
}

- (IBAction) download:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:MUPMostRecentVersionURL]]];
}

- (IBAction) selectAutomaticCheckInterval:(id)sender
{
  [[NSUserDefaults standardUserDefaults] setInteger:[[(NSPopUpButton *) sender selectedItem] tag] forKey:MUPCheckForUpdatesInterval];
}

- (IBAction) toggleAutomaticChecking:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if ([checkAutomaticallyButton state] == NSOnState)
  {
    [defaults setBool:YES forKey:MUPCheckForUpdatesAutomatically];
    [checkAutomaticallyIntervalButton setEnabled:YES];
  }
  else
  {
    [defaults setBool:NO forKey:MUPCheckForUpdatesAutomatically];
    [checkAutomaticallyIntervalButton setEnabled:NO];
  }
}

#pragma mark -
#pragma mark MacPADSocket delegate

- (void) macPADErrorOccurred:(NSNotification *)notification
{
  if (showDialogForErrors)
  {
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString (MULErrorCheckingForUpdatesTitle, nil)
                                     defaultButton:NSLocalizedString (MULOkay, nil)
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:NSLocalizedString (MULErrorCheckingForUpdatesMessage, nil)];
    
    [alert runModal];
  }
  
  [self updateDisplayForSocket:[notification object] userinfo:[notification userInfo]];
}

- (void) macPADCheckFinished:(NSNotification *)notification
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *currentVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  id newestVersionString;
  id blarg = [macPADSocket productDownloadURL];
  
  NSLog (@"%@", blarg);
  
  if ([[macPADSocket newVersion] isEqualToString:@""])
    [defaults removeObjectForKey:MUPMostRecentVersion];
  else
    [defaults setObject:[macPADSocket newVersion] forKey:MUPMostRecentVersion];
  
  if ([[macPADSocket productDownloadURL] isEqualToString:@""])
    [defaults removeObjectForKey:MUPMostRecentVersionURL];
  else
    [defaults setObject:[macPADSocket productDownloadURL] forKey:MUPMostRecentVersionURL];
  
  [defaults setObject:[NSCalendarDate date] forKey:MUPMostRecentVersionCheckTime];
  
  newestVersionString = [defaults objectForKey:MUPMostRecentVersion];
  
  if ([defaults objectForKey:MUPMostRecentVersionURL] &&
      newestVersionString)
  {
    if ([macPADSocket compareVersion:(NSString *) newestVersionString toVersion:currentVersionString] == NSOrderedAscending)
    {
      if (showDialogIfUpdateIsAvailable)
      {
        
      }
    }
    else if (showDialogIfUpdateIsNotAvailable)
    {
      if ([macPADSocket compareVersion:(NSString *) newestVersionString toVersion:currentVersionString] == NSOrderedDescending)
      {
        
      }
      else
      {
        
      }
    }
  }
  
  [self updateDisplayForSocket:[notification object] userinfo:[notification userInfo]];
}

#pragma mark -
#pragma mark NSWindow delegate

- (void) windowDidBecomeKey:(NSNotification *)notification
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *currentVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *newestVersionString = [defaults objectForKey:MUPMostRecentVersion];
  NSCalendarDate *lastCheckedTime = [defaults objectForKey:MUPMostRecentVersionCheckTime];
  
  updateLock = [[NSLock alloc] init];
  macPADSocket = [[MacPADSocket alloc] init];
  
  [updateLock lock];
  
  [currentVersionField setStringValue:currentVersionString];
  
  if (!newestVersionString)
  {
    [newestVersionField setStringValue:NSLocalizedString (MULNone, nil)];
    [newestVersionField setTextColor:[NSColor disabledControlTextColor]];
  }
  else
  {
    [newestVersionField setStringValue:newestVersionString];
    [newestVersionField setTextColor:[NSColor textColor]];
  }
  
  if ([defaults objectForKey:MUPMostRecentVersionURL] &&
      newestVersionString &&
      [macPADSocket compareVersion:newestVersionString toVersion:currentVersionString] == NSOrderedAscending)
    [downloadButton setEnabled:YES];
  else
    [downloadButton setEnabled:NO];
  
  if (!lastCheckedTime)
  {
    [lastCheckedField setStringValue:NSLocalizedString (MULNever, nil)];
    [lastCheckedField setTextColor:[NSColor disabledControlTextColor]];
  }
  else
  {
    [lastCheckedField setObjectValue:lastCheckedTime];
    [lastCheckedField setTextColor:[NSColor textColor]];
  }
  
  if ([defaults boolForKey:MUPCheckForUpdatesAutomatically])
  {
    [checkAutomaticallyButton setState:NSOnState];
    [checkAutomaticallyIntervalButton setEnabled:YES];
  }
  else
  {
    [checkAutomaticallyButton setState:NSOffState];
    [checkAutomaticallyIntervalButton setEnabled:NO];
  }
  
  switch ([defaults integerForKey:MUPCheckForUpdatesInterval])
  {
    case MUUpdateDaily:
      [checkAutomaticallyIntervalButton selectItemAtIndex:1];
      break;
      
    case MUUpdateWeekly:
      [checkAutomaticallyIntervalButton selectItemAtIndex:2];
      break;
      
    case MUUpdateMonthly:
      [checkAutomaticallyIntervalButton selectItemAtIndex:3];
      break;
      
    case MUUpdateAtLaunch:
    default:
      [checkAutomaticallyIntervalButton selectItemAtIndex:0];
      break;
  }
  
  [checkNowButton setEnabled:YES];
  
  [macPADSocket release];
  macPADSocket = nil;
  
  [updateLock unlock];
  [updateLock release];
  updateLock = nil;  
}

@end

#pragma mark -

@implementation MUUpdateController (Private)

- (void) checkForUpdatesAndShowDialogIfUpdateIsAvailable:(BOOL)isAvailable
                        showDialogIfUpdateIsNotAvailable:(BOOL)isNotAvailable
                                     showDialogForErrors:(BOOL)forErrors
{
  if (!updateLock)
    updateLock = [[NSLock alloc] init];
  
  if ([updateLock tryLock])
  {
    [checkNowButton setEnabled:NO];
    
    showDialogIfUpdateIsAvailable = isAvailable;
    showDialogIfUpdateIsNotAvailable = isNotAvailable;
    showDialogForErrors = forErrors;
    [progressIndicator startAnimation:self];
    macPADSocket = [[MacPADSocket alloc] init];
    [macPADSocket setDelegate:self];
    [macPADSocket performCheck:[NSURL URLWithString:MUUpdateURL]
                   withVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  }
}

- (void) checkForUpdatesAutomatically:(NSTimer *)timer
{
  if (NO)
  {
    [self checkForUpdatesAndShowDialogIfUpdateIsAvailable:YES
                         showDialogIfUpdateIsNotAvailable:NO
                                      showDialogForErrors:NO];
  }
}

- (void) updateDisplayForSocket:(MacPADSocket *)socket userinfo:(NSDictionary *)userinfo
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *currentVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *newestVersionString = [defaults objectForKey:MUPMostRecentVersion];
  
  [progressIndicator stopAnimation:self];
  
  [newestVersionField setObjectValue:newestVersionString];
  [newestVersionField setTextColor:[NSColor textColor]];
  
  [lastCheckedField setObjectValue:[defaults objectForKey:MUPMostRecentVersionCheckTime]];
  [lastCheckedField setTextColor:[NSColor textColor]];
  
  if ([defaults objectForKey:MUPMostRecentVersionURL] &&
      newestVersionString &&
      [macPADSocket compareVersion:newestVersionString toVersion:currentVersionString] == NSOrderedAscending)
    [downloadButton setEnabled:YES];
  else
    [downloadButton setEnabled:NO];
  
  [checkNowButton setEnabled:YES];
  
  [macPADSocket release];
  macPADSocket = nil;
  
  [updateLock release];
  updateLock = nil;
}

@end
