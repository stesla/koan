//
// MUConnectionWindowController.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUConnectionWindowController.h"
#import "MUGrowlService.h"

#import "J3ANSIFormattingFilter.h"
#import "J3NaiveURLFilter.h"
#import "MUFugueEditFilter.h"
#import "MUTextLogger.h"

#import <objc/objc-runtime.h>

enum MUSearchDirections
{
  MUBackwardSearch,
  MUForwardSearch
};

@interface MUConnectionWindowController (Private)

- (BOOL) canCloseWindow;
- (void) cleanUpPingTimer;
- (J3Filter *) createLogger;
- (void) didEndCloseSheet: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) disconnect;
- (void) endCompletion;
- (BOOL) isUsingTelnet: (J3TelnetConnection *) telnet;
- (void) postConnectionWindowControllerDidReceiveTextNotification;
- (void) postConnectionWindowControllerWillCloseNotification;
- (void) sendPeriodicPing: (NSTimer *) timer;
- (NSString *) splitViewAutosaveName;
- (void) tabCompleteWithDirection: (enum MUSearchDirections)direction;
- (void) willEndCloseSheet: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;

@end

#pragma mark -

@implementation MUConnectionWindowController

- (id) initWithProfile: (MUProfile *) newProfile
{
  if (!(self = [super initWithWindowNibName: @"MUConnectionWindow"]))
    return nil;
  
  profile = [newProfile retain];
  
  historyRing = [[J3HistoryRing alloc] init];
  filterQueue = [[J3FilterQueue alloc] init];
  
  [filterQueue addFilter: [J3ANSIFormattingFilter filterWithFormatting: [profile formatting]]];
  [filterQueue addFilter: [MUFugueEditFilter filterWithDelegate: self]];
  [filterQueue addFilter: [J3NaiveURLFilter filter]];
  [filterQueue addFilter: [self createLogger]];
  
  return self;
}

- (id) initWithWorld: (MUWorld *) newWorld player: (MUPlayer *) newPlayer
{
  return [self initWithProfile: [MUProfile profileWithWorld: newWorld player: newPlayer]];
}

- (id) initWithWorld: (MUWorld *) newWorld
{
  return [self initWithWorld: newWorld player: nil];
}

- (void) awakeFromNib
{
  NSDictionary *bindingOptions = [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                             forKey: @"NSValueTransformerName"];
  
  [receivedTextView bind: @"font"
                toObject: profile
             withKeyPath: @"effectiveFont"
                 options: nil];
  [inputView bind: @"font"
         toObject: profile
      withKeyPath: @"effectiveFont"
          options: nil];
  
  [receivedTextView bind: @"textColor"
                toObject: profile
             withKeyPath: @"effectiveTextColor"
                 options: bindingOptions];
  [inputView bind: @"textColor"
         toObject: profile
      withKeyPath: @"effectiveTextColor"
          options: bindingOptions];
  
  [receivedTextView bind: @"backgroundColor"
                toObject: profile
             withKeyPath: @"effectiveBackgroundColor"
                 options: bindingOptions];
  [inputView bind: @"backgroundColor"
         toObject: profile
      withKeyPath: @"effectiveBackgroundColor"
          options: bindingOptions];
  
  [inputView bind: @"insertionPointColor"
         toObject: profile
      withKeyPath: @"effectiveTextColor"
          options: bindingOptions];
  
  [[self window] setTitle: profile.windowTitle];
  [[self window] setFrameAutosaveName: profile.uniqueIdentifier];
  [[self window] setFrameUsingName: profile.uniqueIdentifier];

  [splitView setAutosaveName: [self splitViewAutosaveName]
                 recursively: YES];
  [splitView restoreState: YES];
  [splitView adjustSubviews];
  
  currentlySearching = NO;
}

- (void) dealloc
{
  [self disconnect];
  
  [[NSNotificationCenter defaultCenter] removeObserver: nil name: nil object: self];
  
  [telnetConnection release];
  [filterQueue release];
  [historyRing release];
  [profile release];
  [super dealloc];
}

- (BOOL) validateMenuItem: (NSMenuItem *) menuItem
{
  SEL menuItemAction = [menuItem action];
  
  if (menuItemAction == @selector (connectOrDisconnect:))
  {
    if ([self isConnectedOrConnecting])
      [menuItem setTitle: _(MULDisconnect)];
    else
      [menuItem setTitle: _(MULConnect)];
    return YES;
  }
  else if (menuItemAction == @selector (clearWindow:))
  {
  	return YES;
  }
  return NO;
}

- (BOOL) validateToolbarItem: (NSToolbarItem *) toolbarItem
{
  SEL toolbarItemAction = [toolbarItem action];
  
  if (toolbarItemAction == @selector (goToWorldURL:))
  {
    NSString *url = profile.world.url;
    
    return (url && ![url isEqualToString: @""]);
  }
  
  return NO;
}

- (BOOL) windowShouldClose: (id) sender
{
  return [self canCloseWindow];
}

- (void) windowWillClose: (NSNotification *) notification
{
  if ([notification object] == [self window])
  {
  	[splitView saveState: YES];
  	[[self window] setDelegate: nil];
  
  	[self postConnectionWindowControllerWillCloseNotification];
  }
}
  
#pragma mark -
#pragma mark Accessors

- (id) delegate
{
  return delegate;
}

- (void) setDelegate: (id) newDelegate
{
  if (delegate == newDelegate)
    return;
  
  [[NSNotificationCenter defaultCenter] removeObserver: delegate
                                                  name: nil
                                                object: self];
  
  delegate = newDelegate;
  
  if ([delegate respondsToSelector: @selector (connectionWindowControllerWillClose:)])
  {
    [[NSNotificationCenter defaultCenter] addObserver: delegate
                                             selector: @selector (connectionWindowControllerWillClose:)
                                                 name: MUConnectionWindowControllerWillCloseNotification
                                               object: self];
  }
  
  if ([delegate respondsToSelector: @selector (connectionWindowControllerDidReceiveText:)])
  {
    [[NSNotificationCenter defaultCenter] addObserver: delegate
                                             selector: @selector (connectionWindowControllerDidReceiveText:)
                                                 name: MUConnectionWindowControllerDidReceiveTextNotification
                                               object: self];
  }
}

- (BOOL) isConnectedOrConnecting
{
  return [telnetConnection isConnected] || [telnetConnection isConnecting];
}

#pragma mark -
#pragma mark Actions

- (void) confirmClose: (SEL) callback
{
  [[self window] makeKeyAndOrderFront: nil];
  
  NSBeginAlertSheet ([NSString stringWithFormat: _(MULConfirmCloseTitle), profile.windowTitle],
                     _(MULOK),
                     _(MULCancel),
                     nil,
                     [self window],
                     self,
                     @selector (willEndCloseSheet:returnCode:contextInfo:),
                     @selector (didEndCloseSheet:returnCode:contextInfo:),
                     (void *) callback,
                     _(MULConfirmCloseMessage),
                     profile.hostname);
}

- (IBAction) clearWindow: (id) sender
{
  [receivedTextView setString: @""];
}

- (IBAction) connect: (id) sender
{
  if ([self isConnectedOrConnecting])
    return;
  if (!telnetConnection)
    telnetConnection = [[profile createNewTelnetConnectionWithDelegate: self] retain];
  // TODO: if (!telnetConnection) { //ERROR! }
  
  [telnetConnection open];
  
  pingTimer = [[NSTimer scheduledTimerWithTimeInterval: 60.0
                                                target: self
                                              selector: @selector (sendPeriodicPing:)
                                              userInfo: nil
                                               repeats: YES] retain];
  
  [[self window] makeFirstResponder: inputView];
}

- (IBAction) connectOrDisconnect: (id) sender
{
  if ([self isConnectedOrConnecting])
    [self disconnect: nil];
  else
    [self connect: nil];
}

- (IBAction) disconnect: (id) sender
{
  [self disconnect];
}

- (IBAction) goToWorldURL: (id) sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: profile.world.url]];
}

- (IBAction) sendInputText: (id) sender
{
  [telnetConnection writeLine: [inputView string]];
  [historyRing saveString: [inputView string]];
  [inputView setString: @""];
  
  [[self window] makeFirstResponder: inputView];
}

- (IBAction) nextCommand: (id) sender
{
  [historyRing updateString: [inputView string]];
  [inputView setString: [historyRing nextString]];
}

- (IBAction) previousCommand: (id) sender
{
  [historyRing updateString: [inputView string]];
  [inputView setString: [historyRing previousString]];
}

#pragma mark -
#pragma mark Filter delegate methods

- (void) setInputViewString: (NSString *) string
{
  [inputView setString: string];
}

#pragma mark -
#pragma mark J3TelnetConnectionDelegate protocol

- (void) displayString: (NSString *) string
{  
  if (!string || [string length] == 0)
    return;
  
  NSTextStorage *textStorage = [receivedTextView textStorage];
  float scrollerPosition = [[[receivedTextView enclosingScrollView] verticalScroller] floatValue];
  
  NSMutableDictionary *typingAttributes =
  [NSMutableDictionary dictionaryWithDictionary: [receivedTextView typingAttributes]];
  
  [typingAttributes removeObjectForKey: NSLinkAttributeName];
  [typingAttributes removeObjectForKey: NSUnderlineStyleAttributeName];
  [typingAttributes setObject: [[profile formatting] foreground] forKey: NSForegroundColorAttributeName];
  [typingAttributes setObject: [[profile formatting] background] forKey: NSBackgroundColorDocumentAttribute];
  
  NSAttributedString *unfilteredString = [NSAttributedString attributedStringWithString: string attributes: typingAttributes];
  NSAttributedString *filteredString = [filterQueue processAttributedString: unfilteredString];
  
  [textStorage replaceCharactersInRange: NSMakeRange ([textStorage length], 0) withAttributedString: filteredString];
  [[receivedTextView window] invalidateCursorRectsForView: receivedTextView];
  
  // Scroll to the bottom of the text window, but only if we were previously at the bottom.
  
  if (1.0 - scrollerPosition < 0.000001) // Avoiding inaccuracy of == for floats.
    [receivedTextView scrollRangeToVisible: NSMakeRange ([textStorage length], 0)];
  
  [self postConnectionWindowControllerDidReceiveTextNotification];
}

- (void) telnetConnectionDidConnect: (NSNotification *) notification
{
  [self displayString: _(MULConnectionOpen)];
  [self displayString: @"\n"];
  [MUGrowlService connectionOpenedForTitle: profile.windowTitle];
  
  if ([profile hasLoginInformation])
    [telnetConnection writeLine: profile.loginString];
}

- (void) telnetConnectionIsConnecting: (NSNotification *) notification
{
  [self displayString: _(MULConnectionOpening)];
  [self displayString: @"\n"];
}

- (void) telnetConnectionWasClosedByClient: (NSNotification *) notification
{
  [self cleanUpPingTimer];
  [self displayString: _(MULConnectionClosed)];
  [self displayString: @"\n"];
  [MUGrowlService connectionClosedForTitle: profile.windowTitle];
}

- (void) telnetConnectionWasClosedByServer: (NSNotification *) notification
{
  [self cleanUpPingTimer];
  [self displayString: _(MULConnectionClosedByServer)];
  [self displayString: @"\n"];
  [MUGrowlService connectionClosedByServerForTitle: profile.windowTitle];
}

- (void) telnetConnectionWasClosedWithError: (NSNotification *) notification
{
  NSString *errorMessage = [[notification userInfo] valueForKey: J3TelnetConnectionErrorMessageKey];
  [self cleanUpPingTimer];
  [self displayString: [NSString stringWithFormat: _(MULConnectionClosedByError), errorMessage]];
  [self displayString: @"\n"];
  [MUGrowlService connectionClosedByErrorForTitle: profile.windowTitle error: errorMessage];
}

#pragma mark -
#pragma mark NSTextView delegate

- (BOOL) textView: (NSTextView *) textView doCommandBySelector: (SEL) commandSelector
{
  if (textView == receivedTextView)
  {
    if ([[NSApp currentEvent] type] != NSKeyDown
        || commandSelector == @selector (moveUp:)
        || commandSelector == @selector (moveDown:)
        || commandSelector == @selector (scrollPageUp:)
        || commandSelector == @selector (scrollPageDown:)
        || commandSelector == @selector (scrollToBeginningOfDocument:)
        || commandSelector == @selector (scrollToEndOfDocument:))
    {
      return NO;
    }
    else if (commandSelector == @selector (insertNewline:)
             || commandSelector == @selector (insertTab:)
             || commandSelector == @selector (insertBacktab:))
    {
      [[self window] makeFirstResponder: inputView];
      return YES;
    }
    else
    {
      [inputView doCommandBySelector: commandSelector];
      [[self window] makeFirstResponder: inputView];
      return YES;
    }
  }
  else if (textView == inputView)
  {
    if ([[NSApp currentEvent] type] != NSKeyDown)
    {
      return NO;
    }
    else if (commandSelector == @selector (insertBacktab:))
    {
      [self tabCompleteWithDirection: MUForwardSearch];
      return YES;
    }
    else if (commandSelector == @selector (insertNewline:))
    {
      unichar key = 0;
      
      if ([[[NSApp currentEvent] charactersIgnoringModifiers] length] > 0)
        key = [[[NSApp currentEvent] charactersIgnoringModifiers] characterAtIndex: 0];
      
      if ([[[NSApp currentEvent] charactersIgnoringModifiers] length] > 1)
        NSLog (@"Speculative log for #49: length = %d", [[[NSApp currentEvent] charactersIgnoringModifiers] length]);
      
      [self endCompletion];
      
      if (key == NSCarriageReturnCharacter || key == NSEnterCharacter)
      {
        [self sendInputText: textView];
        return YES;
      }
    }
    else if (commandSelector == @selector (insertTab:))
    {
      [self tabCompleteWithDirection: MUBackwardSearch];
      return YES;
    }
    else if (commandSelector == @selector (moveDown:))
    {
      unichar key = 0;
      
      if ([[[NSApp currentEvent] charactersIgnoringModifiers] length] > 0)
        key = [[[NSApp currentEvent] charactersIgnoringModifiers] characterAtIndex: 0];
      
      [self endCompletion];
      
      if ([textView selectedRange].location == [[textView textStorage] length]
          && key == NSDownArrowFunctionKey)
      {
        [self nextCommand: self];
        [textView setSelectedRange: NSMakeRange ([[textView textStorage] length], 0)];
        return YES;
      }
    }
    else if (commandSelector == @selector (moveUp:))
    {
      unichar key = 0;
      
      if ([[[NSApp currentEvent] charactersIgnoringModifiers] length] > 0)
        key = [[[NSApp currentEvent] charactersIgnoringModifiers] characterAtIndex: 0];
      
      [self endCompletion];
      
      if ([textView selectedRange].location == 0
          && key == NSUpArrowFunctionKey)
      {
        [self previousCommand: self];
        [textView setSelectedRange: NSMakeRange (0, 0)];
        return YES;
      }
    }
    else if (commandSelector == @selector (scrollPageDown:)
             || commandSelector == @selector (scrollPageUp:)
             || commandSelector == @selector (scrollToBeginningOfDocument:)
             || commandSelector == @selector (scrollToEndOfDocument:))
    {
      [receivedTextView doCommandBySelector: commandSelector];
      return YES;
    }
  }
  return NO;
}

#pragma mark -
#pragma mark MUTextView delegate

- (BOOL) textView: (MUTextView *) textView insertText: (id) string
{
  if (textView == receivedTextView)
  {
    [inputView insertText: string];
    [[self window] makeFirstResponder: inputView];
    return YES;
  }
  else if (textView == inputView)
  {
    [self endCompletion];
    return NO;
  }
  return NO;
}

- (BOOL) textView: (MUTextView *) textView pasteAsPlainText: (id) originalSender
{
  if (textView == receivedTextView)
  {
    [inputView pasteAsPlainText: originalSender];
    [[self window] makeFirstResponder: inputView];
    return YES;
  }
  else if (textView == inputView)
  {
    [self endCompletion];
    return NO;
  }
  return NO;
}

@end

#pragma mark -

@implementation MUConnectionWindowController (Private)

- (BOOL) canCloseWindow
{
  if ([self isConnectedOrConnecting])
  {
    [self confirmClose: NULL];
    return NO;
  }
  
  return YES;
}

- (void) cleanUpPingTimer
{
  [pingTimer invalidate];
  [pingTimer release];
  pingTimer = nil;  
}

- (J3Filter *) createLogger
{
  if (profile)
    return [profile createLogger];
  else
    return [MUTextLogger filter];
}

- (void) didEndCloseSheet: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
  if (returnCode == NSAlertAlternateReturn) /* Cancel. */
  {
    if (contextInfo)
      ((void (*) (id, SEL, BOOL)) objc_msgSend) ([NSApp delegate], (SEL) contextInfo, NO);
  }
}

- (void) disconnect
{
  if (telnetConnection)
    [telnetConnection close];
}

- (void) endCompletion
{
  currentlySearching = NO;
  [historyRing resetSearchCursor];
}

- (BOOL) isUsingTelnet: (J3TelnetConnection *) telnet
{
  return telnetConnection == telnet;
}

- (void) postConnectionWindowControllerDidReceiveTextNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName: MUConnectionWindowControllerDidReceiveTextNotification
  																										object: self];
}

- (void) postConnectionWindowControllerWillCloseNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName: MUConnectionWindowControllerWillCloseNotification
                                                      object: self];
}

- (void) sendPeriodicPing: (NSTimer *) timer
{
  [telnetConnection writeLine: @"@@"];
}

- (NSString *) splitViewAutosaveName
{
  return [NSString stringWithFormat: @"%@.split", profile.uniqueIdentifier];
}

- (void) tabCompleteWithDirection: (enum MUSearchDirections) direction
{
  NSString *currentPrefix;
  NSString *foundString;
  
  if (currentlySearching)
  {
    currentPrefix = [[[[inputView string] copy] autorelease] substringToIndex: [inputView selectedRange].location];
    
    if ([historyRing numberOfUniqueMatchesForStringPrefix: currentPrefix] == 1)
    {
      [inputView setSelectedRange: NSMakeRange ([[inputView textStorage] length], 0)];
      [self endCompletion];
      return;
    }
  }
  else
    currentPrefix = [[[inputView string] copy] autorelease];
  
  foundString = (direction == MUBackwardSearch) ? [historyRing searchBackwardForStringPrefix: currentPrefix]
                                                : [historyRing searchForwardForStringPrefix: currentPrefix];
  
  if (foundString)
  {
    while ([foundString isEqualToString: [inputView string]])
      foundString = (direction == MUBackwardSearch) ? [historyRing searchBackwardForStringPrefix: currentPrefix]
                                                    : [historyRing searchForwardForStringPrefix: currentPrefix];
    
    [inputView setString: foundString];
    [inputView setSelectedRange: NSMakeRange ([currentPrefix length], [[inputView textStorage] length] - [currentPrefix length])];
  }
  
  currentlySearching = YES;
}

- (void) willEndCloseSheet: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
  if (returnCode == NSAlertDefaultReturn) /* Close. */
  {
    if ([self isConnectedOrConnecting])
      [self disconnect];
    
    [[self window] close];

    if (contextInfo)
      ((void (*) (id, SEL, BOOL)) objc_msgSend) ([NSApp delegate], (SEL) contextInfo, YES);
  }
}


@end
