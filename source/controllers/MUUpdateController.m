//
// MUUpdateController.m
//
// Copyright (c) 2005 3James Software
//

#import "MUUpdateController.h"
#import "MacPADSocket.h"

#import "MUUpdateInterval.h"

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
                                     showDialogForErrors:(BOOL)forErrors
                           overrideExistingIgnoreRequest:(BOOL)overrideIgnore;
- (void) checkForUpdatesAtIntervals:(NSTimer *)timer;
- (void) updateDisplayForSocket:(MacPADSocket *)socket
                       userinfo:(NSDictionary *)userinfo;

@end

#pragma mark -

@implementation MUUpdateController

- (void) awakeFromNib
{
  NSMenuItem *menuItem;
  
  automaticCheckTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                         target:self
                                                       selector:@selector(checkForUpdatesAtIntervals:)
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
  else if (menuItemAction == @selector(selectAutomaticCheckInterval:))
    return YES;
  else
    return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction) checkForUpdates:(id)sender
{
  [progressIndicator startAnimation:self];
  [self checkForUpdatesAndShowDialogIfUpdateIsAvailable:NO
                       showDialogIfUpdateIsNotAvailable:NO
                                    showDialogForErrors:YES
                          overrideExistingIgnoreRequest:NO];
}

- (IBAction) checkForUpdatesAutomatically
{
  [self checkForUpdatesAndShowDialogIfUpdateIsAvailable:YES
                       showDialogIfUpdateIsNotAvailable:NO
                                    showDialogForErrors:NO
                          overrideExistingIgnoreRequest:NO];
}

- (IBAction) checkForUpdatesWithDialog:(id)sender
{
  [self checkForUpdatesAndShowDialogIfUpdateIsAvailable:YES
                       showDialogIfUpdateIsNotAvailable:YES
                                    showDialogForErrors:YES
                          overrideExistingIgnoreRequest:YES];
}

- (IBAction) download:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:MUPMostRecentVersionURL]]];
}

- (IBAction) selectAutomaticCheckInterval:(id)sender
{
  [[NSUserDefaults standardUserDefaults] setInteger:[[(NSPopUpButton *) sender selectedItem] tag]
                                             forKey:MUPCheckForUpdatesInterval];
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
  NSDictionary *userInfo = [notification userInfo];
  
  if (showDialogForErrors)
  {
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString (MULErrorCheckingForUpdatesTitle, nil)
                                     defaultButton:NSLocalizedString (MULOkay, nil)
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:[userInfo objectForKey:MacPADErrorMessage]];
    
    [alert runModal];
  }
  
  [self updateDisplayForSocket:[notification object] userinfo:[notification userInfo]];
}

- (void) macPADCheckFinished:(NSNotification *)notification
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *currentVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *ignoredVersionString = [defaults objectForKey:MUPNewestVersionToIgnore];
  id newestVersionString;
  
  if ([[macPADSocket newVersion] isEqualToString:@""])
    [defaults removeObjectForKey:MUPMostRecentVersion];
  else
    [defaults setObject:[macPADSocket newVersion] forKey:MUPMostRecentVersion];
  
  if ([[macPADSocket productDownloadURL] isEqualToString:@""])
    [defaults removeObjectForKey:MUPMostRecentVersionURL];
  else
    [defaults setObject:[macPADSocket productDownloadURL] forKey:MUPMostRecentVersionURL];
  
  [defaults setObject:[NSDate date] forKey:MUPMostRecentVersionCheckTime];
  
  newestVersionString = [defaults objectForKey:MUPMostRecentVersion];
  
  if ([defaults objectForKey:MUPMostRecentVersionURL] &&
      newestVersionString)
  {
    if ([macPADSocket compareVersion:(NSString *) newestVersionString toVersion:currentVersionString] == NSOrderedAscending)
    {
      if (showDialogIfUpdateIsAvailable &&
          (overrideExistingIgnoreRequest ||
           [macPADSocket compareVersion:(NSString *) newestVersionString toVersion:ignoredVersionString] == NSOrderedAscending))
      {
        int choice;
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString (MULNewVersionAvailableTitle, nil), newestVersionString, MUApplicationName]
                                         defaultButton:NSLocalizedString (MULDownload, nil)
                                       alternateButton:NSLocalizedString (MULDontRemind, nil)
                                           otherButton:NSLocalizedString (MULRemindLater, nil)
                             informativeTextWithFormat:NSLocalizedString (MULNewVersionAvailableMessage, nil)];
        
        choice = [alert runModal];
        
        if (choice == NSAlertDefaultReturn)
        {
          [self download:nil];
        }
        else if (choice == NSAlertAlternateReturn)
        {
          [defaults setObject:newestVersionString forKey:MUPNewestVersionToIgnore];
        }
        else if (choice == NSAlertOtherReturn)
        {
          [defaults removeObjectForKey:MUPNewestVersionToIgnore];
        }
      }
    }
    else if (showDialogIfUpdateIsNotAvailable)
    {
      if ([macPADSocket compareVersion:(NSString *) newestVersionString toVersion:currentVersionString] == NSOrderedDescending)
      {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString (MULHasUnreleasedVersionTitle, nil), MUApplicationName]
                                         defaultButton:NSLocalizedString (MULOkay, nil)
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString (MULHasUnreleasedVersionMessage, nil)];
        
        [alert runModal];
      }
      else
      {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString (MULHasMostRecentVersionTitle, nil), MUApplicationName]
                                         defaultButton:NSLocalizedString (MULOkay, nil)
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString (MULHasMostRecentVersionMessage, nil)];
        
        [alert runModal];
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
  
  [checkAutomaticallyIntervalButton selectItemWithTag:[defaults integerForKey:MUPCheckForUpdatesInterval]];
  
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
                           overrideExistingIgnoreRequest:(BOOL)overrideIgnore
{
  if (!updateLock)
    updateLock = [[NSLock alloc] init];
  
  if ([updateLock tryLock])
  {
    [checkNowButton setEnabled:NO];
    
    showDialogIfUpdateIsAvailable = isAvailable;
    showDialogIfUpdateIsNotAvailable = isNotAvailable;
    showDialogForErrors = forErrors;
    overrideExistingIgnoreRequest = overrideIgnore;
    macPADSocket = [[MacPADSocket alloc] init];
    [macPADSocket setDelegate:self];
    [macPADSocket performCheck:[NSURL URLWithString:MUUpdateURL]
                   withVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  }
}

- (void) checkForUpdatesAtIntervals:(NSTimer *)timer
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:[defaults integerForKey:MUPCheckForUpdatesInterval]];
  
  if ([interval shouldUpdateForBaseDate:[defaults objectForKey:MUPMostRecentVersionCheckTime]])
  {
    [self checkForUpdatesAutomatically];
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
