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
- (void) sendPeriodicPing:(NSTimer *)timer;
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
//    [filterQueue addFilter:[J3ANSIRemovingFilter filter]];
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
  
  [receivedTextView bind:@"backgroundColor"
                toObject:[NSUserDefaultsController sharedUserDefaultsController]
             withKeyPath:@"values.MUPBackgroundColor"
                 options:bindingOptions];
  [inputView bind:@"backgroundColor"
         toObject:[NSUserDefaultsController sharedUserDefaultsController]
      withKeyPath:@"values.MUPBackgroundColor"
          options:bindingOptions];
  [inputView bind:@"insertionPointColor"
         toObject:[NSUserDefaultsController sharedUserDefaultsController]
      withKeyPath:@"values.MUPTextColor"
          options:bindingOptions];
  
  [[self window] setTitle:[profile windowTitle]];
  [[self window] setFrameAutosaveName:[profile uniqueIdentifier]];
  [[self window] setFrameUsingName:[profile uniqueIdentifier]];

  [splitView setAutosaveName:[NSString stringWithFormat:@"%@.split", [profile uniqueIdentifier]]
                 recursively:YES];
  [splitView restoreState:YES];
  [splitView adjustSubviews];
  
  baseAttributes = [[receivedTextView typingAttributes] copy];
  
  currentlySearching = NO;
}

- (void) dealloc
{
  [self disconnect:nil];
  [baseAttributes release];
  [filterQueue release];
  [historyRing release];
  [profile release];
  [super dealloc];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  if ([menuItem action] == @selector(connectOrDisconnect:))
  {
    if ([telnetConnection isConnected])
      [menuItem setTitle:MULDisconnect];
    else
      [menuItem setTitle:MULConnect];
    return YES;
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

- (IBAction) connect:(id)sender
{
  if (![self isConnected])
  {
    telnetConnection = [profile openTelnetWithDelegate:self];
    //TODO: if (!telnetConnection) { //ERROR! }
    
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
  if ([telnetConnection isConnected])
    [self disconnect:sender];
  else
    [self connect:sender];
}

- (IBAction) disconnect:(id)sender
{
	[pingTimer invalidate];
	[pingTimer release];
	
	[profile logoutWithConnection:telnetConnection];
	
  if ([self isConnected])
  {
    [telnetConnection close];
    [telnetConnection release];
    telnetConnection = nil;
  }
}

- (IBAction) sendInputText:(id)sender
{
  NSString *input = [inputView string];
  
  if ([telnetConnection sendLine:input])
  {
    [historyRing saveString:input];
    [inputView setString:@""];
  }
  
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
#pragma mark J3TelnetConnection delegate

- (void) telnetDidReadLine:(J3TelnetConnection *)telnet
{
  if (telnet == telnetConnection)
    [self displayString:[telnet read]];
}

- (void) telnetDidChangeStatus:(J3TelnetConnection *)telnet
{
  if (telnet == telnetConnection)
  {
    switch ([telnet connectionStatus])
    {
      case J3ConnectionStatusConnecting:
        [self displayString:NSLocalizedString (MULConnectionOpening, nil)];
        break;
        
      case J3ConnectionStatusConnected:
        [profile loginWithConnection:telnetConnection];  
        [self displayString:NSLocalizedString (MULConnectionOpen, nil)];
        [MUGrowlService connectionOpenedForTitle:[profile windowTitle]];
        break;
        
      case J3ConnectionStatusClosed:
        switch ([telnet reasonClosed])
        {
          case J3ConnectionClosedReasonServer:
            [self displayString:NSLocalizedString (MULConnectionClosedByServer, nil)];
            [MUGrowlService connectionClosedByServerForTitle:[profile windowTitle]];
            break;
            
          case J3ConnectionClosedReasonError:
            [self displayString:[NSString stringWithFormat:NSLocalizedString (MULConnectionClosedByError, nil), 
              [telnet errorMessage]]];
            [MUGrowlService connectionClosedByErrorForTitle:[profile windowTitle] error:[telnet errorMessage]];
            break;
            
          default:
            [self displayString:NSLocalizedString (MULConnectionClosed, nil)];
            [MUGrowlService connectionClosedForTitle:[profile windowTitle]];
            break;
        }
        [self disconnect:nil];
        break;
        
      default:
        // Do nothing.
        break;
    }
    
    [self displayString:@"\n"];    
  }
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
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionWindowControllerWillCloseNotification
                                                      object:self];
  
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
  NSAttributedString *unfilteredString =
  [NSAttributedString attributedStringWithString:string
                                      attributes:baseAttributes];
  NSAttributedString *filteredString = [filterQueue processAttributedString:unfilteredString];
  NSTextStorage *textStorage = [receivedTextView textStorage];
  float scrollerPosition = 
    [[[receivedTextView enclosingScrollView] verticalScroller] floatValue];
  
  [textStorage replaceCharactersInRange:NSMakeRange ([textStorage length], 0)
                   withAttributedString:filteredString];
  
  [[receivedTextView window] invalidateCursorRectsForView:receivedTextView];
  
  if (1.0 - scrollerPosition < 0.000001) // Avoiding inaccuracy of == for floats.
    [receivedTextView scrollRangeToVisible:NSMakeRange ([textStorage length], 0)];

  [[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionWindowControllerDidReceiveTextNotification
                                                      object:self];
}

- (void) endCompletion
{
  currentlySearching = NO;
  [historyRing resetSearchCursor];
}

- (void) sendPeriodicPing:(NSTimer *)timer
{
  [telnetConnection sendLine:@"@pemit me="];
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