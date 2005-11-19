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

enum MUSearchDirections
{
  MUBackwardSearch,
  MUForwardSearch
};

@interface MUConnectionWindowController (Private)

- (J3Filter *) createLogger;
- (void) displayString:(NSString *)string;
- (void) endCompletion;
- (void) postConnectionWindowControllerDidReceiveTextNotification;
- (void) postConnectionWindowControllerWillCloseNotification;
- (void) sendPeriodicPing:(NSTimer *)timer;
- (NSString *) splitViewAutosaveName;
- (void) tabCompleteWithDirection:(enum MUSearchDirections)direction;

@end

#pragma mark -

@implementation MUConnectionWindowController

- (id) initWithProfile:(MUProfile*)newProfile;
{
  if (self = [super initWithWindowNibName:@"MUConnectionWindow"])
  {
    profile = [newProfile retain];
    
    historyRing = [[J3HistoryRing alloc] init];
    
    filterQueue = [[J3FilterQueue alloc] init];
//  [filterQueue addFilter:[J3ANSIRemovingFilter filter]];
    [filterQueue addFilter:[J3NaiveURLFilter filter]];
    [filterQueue addFilter:[J3NaiveANSIFilter filter]];
    [filterQueue addFilter:[self createLogger]];
  }
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
  [self disconnect:nil];
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
    NSString *url = [[profile world] worldURL];
    
    return (url && ![url isEqualToString:@""]);
  }
	
	return NO;
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
    [self disconnect:sender];
  else
    [self connect:sender];
}

- (IBAction) disconnect:(id)sender
{	
	[profile logoutWithConnection:telnetConnection];
	
	if (pingTimer)
	{
		[pingTimer invalidate];
		[pingTimer release];
		pingTimer = nil;
	}
	
  if ([self isConnected])
  {
    [telnetConnection close];
    [telnetConnection release];
    telnetConnection = nil;
  }
}

- (IBAction) goToWorldURL:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[profile world] worldURL]]];
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
#pragma mark J3LineBuffer delegate

- (void) lineBufferHasReadLine:(J3LineBuffer *)buffer;
{
  if (![telnetConnection hasInputBuffer:buffer])
    return;
  [self displayString:[buffer readLine]];
}

#pragma mark -
#pragma mark J3Connection delegate

- (void) connectionIsConnecting:(id <J3Connection>)socket;
{
  if (![telnetConnection isOnConnection:socket])
    return;
  [self displayString:NSLocalizedString (MULConnectionOpening, nil)];  
  [self displayString:@"\n"];  
}

- (void) connectionIsConnected:(id <J3Connection>)socket;
{
  if (![telnetConnection isOnConnection:socket])
    return;
  [profile loginWithConnection:telnetConnection];  
  [self displayString:NSLocalizedString (MULConnectionOpen, nil)];
  [self displayString:@"\n"];
  [MUGrowlService connectionOpenedForTitle:[profile windowTitle]];
}

- (void) connectionIsClosedByClient:(id <J3Connection>)socket;
{
  if (![telnetConnection isOnConnection:socket])
    return;
  [self displayString:NSLocalizedString (MULConnectionClosed, nil)];
  [self disconnect:nil];
  [self displayString:@"\n"];
  [MUGrowlService connectionClosedForTitle:[profile windowTitle]];
}

- (void) connectionIsClosedByServer:(id <J3Connection>)socket;
{
  if (![telnetConnection isOnConnection:socket])
    return;
  [self displayString:NSLocalizedString (MULConnectionClosedByServer, nil)];
  [self disconnect:nil];
  [self displayString:@"\n"];
  [MUGrowlService connectionClosedByServerForTitle:[profile windowTitle]];
}

- (void) connectionIsClosed:(id <J3Connection>)socket withError:(NSString *)errorMessage;
{
  if (![telnetConnection isOnConnection:socket])
    return;
  [self displayString:[NSString stringWithFormat:NSLocalizedString (MULConnectionClosedByError, nil), errorMessage]];
  [self disconnect:nil];
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

#pragma mark -
#pragma mark NSWindow delegate

- (BOOL) windowShouldClose:(id)sender
{
  if ([self isConnected])
  {
    NSString *title = [NSString stringWithFormat:
      NSLocalizedString (MULConfirmCloseTitle, nil), [profile windowTitle]];
    NSAlert *alert;
    int choice;
    
    alert = [NSAlert alertWithMessageText:title
                            defaultButton:NSLocalizedString (MULOkay, nil)
                          alternateButton:NSLocalizedString (MULCancel, nil)
                              otherButton:nil
                informativeTextWithFormat:NSLocalizedString (MULConfirmCloseMessage, nil),
      [profile hostname]];
    
    choice = [alert runModal];
    
    if (choice == NSAlertAlternateReturn)
    {
      return NO;
    }
    
    [self disconnect:sender];
  }
  
  [splitView saveState:YES];
  
  [self postConnectionWindowControllerWillCloseNotification];
  
  return YES;
}

@end

#pragma mark -

@implementation MUConnectionWindowController (Private)

- (J3Filter *) createLogger
{
  if (profile)
    return [profile logger];
  else
    return [J3TextLogger filter];
}

- (void) displayString:(NSString *)string
{
  NSMutableDictionary *typingAttributes =
    [NSMutableDictionary dictionaryWithDictionary:[receivedTextView typingAttributes]];
  NSAttributedString *unfilteredString;
  NSAttributedString *filteredString;
  
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

@end
