//
// MUConnectionWindowController.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "MUConnectionWindowController.h"
#import "MUGrowlService.h"

#import "J3ANSIRemovingFilter.h"
#import "J3NaiveANSIFilter.h"
#import "J3NaiveURLFilter.h"
#import "J3TextLogger.h"

#import <objc/objc-runtime.h>

enum MUSearchDirections
{
  MUBackwardSearch,
  MUForwardSearch
};

@interface MUConnectionWindowController (Private)

- (BOOL) canCloseWindow;
- (void) cleanUp;
- (void) cleanUpPingTimer;
- (void) cleanUpTelnetConnection;
- (J3Filter *) createLogger;
- (void) didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) disconnect;
- (void) disconnectAndCleanUp;
- (void) displayString:(NSString *)string;
- (void) endCompletion;
- (BOOL) isUsingTelnet:(J3Telnet *)telnet;
- (void) postConnectionWindowControllerDidReceiveTextNotification;
- (void) postConnectionWindowControllerWillCloseNotification;
- (void) sendPeriodicPing:(NSTimer *)timer;
- (NSString *) splitViewAutosaveName;
- (void) tabCompleteWithDirection:(enum MUSearchDirections)direction;
- (void) willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

#pragma mark -

@implementation MUConnectionWindowController

- (id) initWithProfile:(MUProfile*)newProfile;
{
  if (![super initWithWindowNibName:@"MUConnectionWindow"])
    return nil;
  
  profile = [newProfile retain];
    
  historyRing = [[J3HistoryRing alloc] init];
    
  filterQueue = [[J3FilterQueue alloc] init];
  // [filterQueue addFilter:[J3ANSIRemovingFilter filter]];
  [filterQueue addFilter:[J3NaiveURLFilter filter]];
  [filterQueue addFilter:[J3NaiveANSIFilter filter]];
  [filterQueue addFilter:[self createLogger]];
  
  return self;
}

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
{
  return [self initWithProfile:[MUProfile profileWithWorld:newWorld player:newPlayer]];
}

- (id) initWithWorld:(MUWorld *)newWorld
{
  return [self initWithWorld:newWorld player:nil];
}

- (void) awakeFromNib
{
  NSDictionary *bindingOptions = [NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
                                                             forKey:@"NSValueTransformerName"];
	
	[receivedTextView bind:@"font"
                toObject:profile
             withKeyPath:@"effectiveFont"
                 options:nil];
  [inputView bind:@"font"
         toObject:profile
      withKeyPath:@"effectiveFont"
          options:nil];
	
	[receivedTextView bind:@"textColor"
                toObject:profile
             withKeyPath:@"effectiveTextColor"
                 options:bindingOptions];
  [inputView bind:@"textColor"
         toObject:profile
      withKeyPath:@"effectiveTextColor"
          options:bindingOptions];
	
	[receivedTextView bind:@"backgroundColor"
                toObject:profile
             withKeyPath:@"effectiveBackgroundColor"
                 options:bindingOptions];
  [inputView bind:@"backgroundColor"
         toObject:profile
      withKeyPath:@"effectiveBackgroundColor"
          options:bindingOptions];
	
  [inputView bind:@"insertionPointColor"
         toObject:profile
      withKeyPath:@"effectiveTextColor"
          options:bindingOptions];
  
  [[self window] setTitle:[profile windowTitle]];
  [[self window] setFrameAutosaveName:[profile uniqueIdentifier]];
  [[self window] setFrameUsingName:[profile uniqueIdentifier]];

  [splitView setAutosaveName:[self splitViewAutosaveName]
                 recursively:YES];
  [splitView restoreState:YES];
  [splitView adjustSubviews];
  
  currentlySearching = NO;
}

- (void) dealloc
{
  [self disconnectAndCleanUp];
  [filterQueue release];
  [historyRing release];
  [profile release];
  [super dealloc];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  SEL menuItemAction = [menuItem action];
  
  if (menuItemAction == @selector(connectOrDisconnect:))
  {
    if ([self isConnected])
      [menuItem setTitle:MULDisconnect];
    else
      [menuItem setTitle:MULConnect];
    return YES;
  }
	else if (menuItemAction == @selector(clearWindow:))
	{
		return YES;
	}
  return NO;
}

- (BOOL) validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	SEL toolbarItemAction = [toolbarItem action];
	
	if (toolbarItemAction == @selector(goToWorldURL:))
  {
    NSString *url = [[profile world] URL];
    
    return (url && ![url isEqualToString:@""]);
  }
	
	return NO;
}

- (BOOL) windowShouldClose:(id)sender
{
  return [self canCloseWindow];
}

- (void) windowWillClose:(NSNotification *)notification
{
  NSWindow *window = [self window];
  
  [splitView saveState:YES];
  [window setDelegate:nil];
  
  [self postConnectionWindowControllerWillCloseNotification];
}
  
#pragma mark -
#pragma mark Accessors

- (id) delegate
{
  return delegate;
}

- (void) setDelegate:(id)newDelegate
{
  [[NSNotificationCenter defaultCenter] removeObserver:delegate
                                                  name:nil
                                                object:self];
  
  delegate = newDelegate;
  
  if ([delegate respondsToSelector:@selector(connectionWindowControllerWillClose:)])
  {
    [[NSNotificationCenter defaultCenter] addObserver:delegate
                                             selector:@selector(connectionWindowControllerWillClose:)
                                                 name:MUConnectionWindowControllerWillCloseNotification
                                               object:self];
  }
  
  if ([delegate respondsToSelector:@selector(connectionWindowControllerDidReceiveText:)])
  {
    [[NSNotificationCenter defaultCenter] addObserver:delegate
                                             selector:@selector(connectionWindowControllerDidReceiveText:)
                                                 name:MUConnectionWindowControllerDidReceiveTextNotification
                                               object:self];
  }
}

- (BOOL) isConnected
{
  return [telnetConnection isConnected];
}

#pragma mark -
#pragma mark Actions

- (void) confirmClose:(SEL)callback 
{
  NSString *title = [NSString stringWithFormat:
    NSLocalizedString (MULConfirmCloseTitle, nil), [profile windowTitle]];
  
  [[self window] makeKeyAndOrderFront:nil];
  
  NSBeginAlertSheet (title,
                     NSLocalizedString (MULOkay, nil),
                     NSLocalizedString (MULCancel, nil),
                     nil,
                     [self window],
                     self,
                     @selector(willEndCloseSheet:returnCode:contextInfo:),
                     @selector(didEndCloseSheet:returnCode:contextInfo:),
                     (void *) callback,
                     NSLocalizedString (MULConfirmCloseMessage, nil),
                     [profile hostname]);
}

- (IBAction) clearWindow:(id)sender
{
	[receivedTextView setString:@""];
}

- (IBAction) connect:(id)sender
{
  if (![self isConnected])
  {
    telnetConnection = [[profile createNewTelnetConnectionWithDelegate:self] retain];
    //TODO: if (!telnetConnection) { //ERROR! }
    
    [telnetConnection open];
    
    pingTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0
                                                  target:self
                                                selector:@selector(sendPeriodicPing:)
                                                userInfo:nil
                                                 repeats:YES] retain];
    
    [[self window] makeFirstResponder:inputView];
  }
}

- (IBAction) connectOrDisconnect:(id)sender
{
  if ([self isConnected])
    [self disconnect:nil];
  else
    [self connect:nil];
}

- (IBAction) disconnect:(id)sender
{
  [self disconnectAndCleanUp];
}

- (IBAction) goToWorldURL:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[profile world] URL]]];
}

- (IBAction) sendInputText:(id)sender
{
  NSString *input = [inputView string];
  
  [telnetConnection writeLine:input];
  [historyRing saveString:input];
  [inputView setString:@""];
  
  [[self window] makeFirstResponder:inputView];
}

- (IBAction) nextCommand:(id)sender
{
  [historyRing updateString:[inputView string]];
  [inputView setString:[historyRing nextString]];
}

- (IBAction) previousCommand:(id)sender
{
  [historyRing updateString:[inputView string]];
  [inputView setString:[historyRing previousString]];
}

#pragma mark -
#pragma mark J3LineBufferDelegate protocol

- (void) lineBufferHasReadLine:(J3LineBuffer *)buffer
{
  if (![telnetConnection hasInputBuffer:buffer])
    return;
  [self displayString:[buffer readLine]];
}

#pragma mark -
#pragma mark J3TelnetConnectionDelegate protocol

- (void) telnetConnectionIsConnecting:(J3Telnet *)telnet
{
  if (![self isUsingTelnet:telnet])
    return;
  
  [self displayString:NSLocalizedString (MULConnectionOpening, nil)];  
  [self displayString:@"\n"];  
}

- (void) telnetConnectionIsConnected:(J3Telnet *)telnet
{
  if (![self isUsingTelnet:telnet])
    return;
  
  [self displayString:NSLocalizedString (MULConnectionOpen, nil)];
  [self displayString:@"\n"];
  [MUGrowlService connectionOpenedForTitle:[profile windowTitle]];
  
  [telnetConnection writeLine:[profile loginString]];
}

- (void) telnetConnectionWasClosedByClient:(J3Telnet *)telnet
{
  if (![self isUsingTelnet:telnet])
    return;
  
  [self cleanUp];
  [self displayString:NSLocalizedString (MULConnectionClosed, nil)];
  [self displayString:@"\n"];
  [MUGrowlService connectionClosedForTitle:[profile windowTitle]];
}

- (void) telnetConnectionWasClosedByServer:(J3Telnet *)telnet
{
  if (![self isUsingTelnet:telnet])
    return;
  
  [self cleanUp];
  [self displayString:NSLocalizedString (MULConnectionClosedByServer, nil)];
  [self displayString:@"\n"];
  [MUGrowlService connectionClosedByServerForTitle:[profile windowTitle]];
}

- (void) telnetConnectionWasClosed:(J3Telnet *)telnet withError:(NSString *)errorMessage
{
  if (![self isUsingTelnet:telnet])
    return;
  
  [self cleanUp];
  [self displayString:[NSString stringWithFormat:NSLocalizedString (MULConnectionClosedByError, nil), errorMessage]];
  [self displayString:@"\n"];
  [MUGrowlService connectionClosedByErrorForTitle:[profile windowTitle] error:errorMessage];
}

#pragma mark -
#pragma mark NSTextView delegate

- (BOOL) textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  NSEvent *event = [NSApp currentEvent];
  
  if (textView == receivedTextView)
  {
    if ([event type] != NSKeyDown ||
        commandSelector == @selector(moveUp:) ||
        commandSelector == @selector(moveDown:) ||
        commandSelector == @selector(scrollPageUp:) ||
        commandSelector == @selector(scrollPageDown:) ||
        commandSelector == @selector(scrollToBeginningOfDocument:) ||
        commandSelector == @selector(scrollToEndOfDocument:))
    {
      return NO;
    }
    else if (commandSelector == @selector(insertNewline:) ||
             commandSelector == @selector(insertTab:) ||
             commandSelector == @selector(insertBacktab:))
    {
      [[self window] makeFirstResponder:inputView];
      return YES;
    }
    else
    {
      [inputView doCommandBySelector:commandSelector];
      [[self window] makeFirstResponder:inputView];
      return YES;
    }
  }
  else if (textView == inputView)
  {
    if ([event type] != NSKeyDown)
    {
      return NO;
    }
    if (commandSelector == @selector(insertTab:))
    {
      [self tabCompleteWithDirection:MUBackwardSearch];
      return YES;
    }
    else if (commandSelector == @selector(insertBacktab:))
    {
      [self tabCompleteWithDirection:MUForwardSearch];
      return YES;
    }
    else if (commandSelector == @selector(insertNewline:))
    {
      unichar key = 0;
      
      if ([[event charactersIgnoringModifiers] length])
        key = [[event charactersIgnoringModifiers] characterAtIndex:0];
      
      [self endCompletion];
      
      if (key == NSCarriageReturnCharacter || key == NSEnterCharacter)
      {
        [self sendInputText:textView];
        return YES;
      }
    }
    else if (commandSelector == @selector(moveUp:))
    {
      unichar key = 0;
      
      if ([[event charactersIgnoringModifiers] length])
        key = [[event charactersIgnoringModifiers] characterAtIndex:0];
      
      [self endCompletion];
      
      if ([textView selectedRange].location == 0 &&
          key == NSUpArrowFunctionKey)
      {
        [self previousCommand:self];
        [textView setSelectedRange:NSMakeRange (0, 0)];
        return YES;
      }
    }
    else if (commandSelector == @selector(moveDown:))
    {
      unichar key = 0;
      
      if ([[event charactersIgnoringModifiers] length])
        key = [[event charactersIgnoringModifiers] characterAtIndex:0];
      
      [self endCompletion];
      
      if ([textView selectedRange].location == [[textView textStorage] length] &&
          key == NSDownArrowFunctionKey)
      {
        [self nextCommand:self];
        [textView setSelectedRange:NSMakeRange ([[textView textStorage] length], 0)];
        return YES;
      }
    }
  }
  return NO;
}

#pragma mark -
#pragma mark MUTextView delegate

- (BOOL) textView:(MUTextView *)textView insertText:(id)string
{
  if (textView == receivedTextView)
  {
    [inputView insertText:string];
    [[self window] makeFirstResponder:inputView];
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
  if ([self isConnected])
  {
    [self confirmClose:NULL];
    return NO;
  }
  
  return YES;
}

- (void) cleanUp;
{
  [self cleanUpPingTimer];
  [self cleanUpTelnetConnection];
}

- (void) cleanUpPingTimer;
{
  [pingTimer invalidate];
  [pingTimer release];
  pingTimer = nil;  
}

- (void) cleanUpTelnetConnection;
{
  [telnetConnection release];
  telnetConnection = nil;  
}

- (J3Filter *) createLogger
{
  if (profile)
    return [profile logger];
  else
    return [J3TextLogger filter];
}

- (void) didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == NSAlertAlternateReturn) /* Cancel. */
  {
    if (contextInfo)
      ((void (*) (id, SEL, BOOL)) objc_msgSend) ([NSApp delegate], (SEL) contextInfo, NO);
  }
}

- (void) disconnect;
{
  if (telnetConnection)
    [telnetConnection close];
}

- (void) disconnectAndCleanUp
{
  [self disconnect];
  [self cleanUp];
}

- (void) displayString:(NSString *)string
{
  NSMutableDictionary *typingAttributes =
    [NSMutableDictionary dictionaryWithDictionary:[receivedTextView typingAttributes]];
  NSAttributedString *unfilteredString;
  NSAttributedString *filteredString;
  
  if (!string)
    return;
  
  [typingAttributes removeObjectForKey:NSLinkAttributeName];
  
  unfilteredString =
    [NSAttributedString attributedStringWithString:string
                                        attributes:typingAttributes];  
  
  filteredString = [filterQueue processAttributedString:unfilteredString];
  NSTextStorage *textStorage = [receivedTextView textStorage];
  float scrollerPosition = 
    [[[receivedTextView enclosingScrollView] verticalScroller] floatValue];
  
  [textStorage replaceCharactersInRange:NSMakeRange ([textStorage length], 0)
                   withAttributedString:filteredString];
  
  [[receivedTextView window] invalidateCursorRectsForView:receivedTextView];
  
  if (1.0 - scrollerPosition < 0.000001) // Avoiding inaccuracy of == for floats.
    [receivedTextView scrollRangeToVisible:NSMakeRange ([textStorage length], 0)];

	[self postConnectionWindowControllerDidReceiveTextNotification];
}

- (void) endCompletion
{
  currentlySearching = NO;
  [historyRing resetSearchCursor];
}

- (BOOL) isUsingTelnet:(J3Telnet *)telnet
{
  return telnetConnection == telnet;
}

- (void) postConnectionWindowControllerDidReceiveTextNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionWindowControllerDidReceiveTextNotification
																											object:self];
}

- (void) postConnectionWindowControllerWillCloseNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionWindowControllerWillCloseNotification
                                                      object:self];
}

- (void) sendPeriodicPing:(NSTimer *)timer
{
  [telnetConnection writeLine:@"@pemit me="];
}

- (NSString *) splitViewAutosaveName
{
	return [NSString stringWithFormat:@"%@.split", [profile uniqueIdentifier]];
}

- (void) tabCompleteWithDirection:(enum MUSearchDirections)direction
{
  NSString *currentPrefix;
  NSString *foundString;
  
  if (currentlySearching)
  {
    currentPrefix = [[[[inputView string] copy] autorelease] substringToIndex:[inputView selectedRange].location];
    
    if ([historyRing numberOfUniqueMatchesForStringPrefix:currentPrefix] == 1)
    {
      [inputView setSelectedRange:NSMakeRange ([[inputView textStorage] length], 0)];
      [self endCompletion];
      return;
    }
  }
  else
    currentPrefix = [[[inputView string] copy] autorelease];
  
  foundString = (direction == MUBackwardSearch) ? [historyRing searchBackwardForStringPrefix:currentPrefix]
                                                : [historyRing searchForwardForStringPrefix:currentPrefix];
  
  if (foundString)
  {
    while ([foundString isEqualToString:[inputView string]])
      foundString = (direction == MUBackwardSearch) ? [historyRing searchBackwardForStringPrefix:currentPrefix]
                                                    : [historyRing searchForwardForStringPrefix:currentPrefix];
    
    [inputView setString:foundString];
    [inputView setSelectedRange:NSMakeRange ([currentPrefix length], [[inputView textStorage] length] - [currentPrefix length])];
  }
  
  currentlySearching = YES;
}

- (void) willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == NSAlertDefaultReturn) /* Close. */
  {
    if ([self isConnected])
      [self disconnectAndCleanUp];
    
    [[self window] close];

    if (contextInfo)
      ((void (*) (id, SEL, BOOL)) objc_msgSend) ([NSApp delegate], (SEL) contextInfo, YES);
  }
}


@end
