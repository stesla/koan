//
// MUConnectionWindowController.m
//
// Copyright (C) 2004 3James Software
//

#import "MUConnectionWindowController.h"

#import "J3AnsiRemovingFilter.h"
#import "J3TextLogger.h"
#import "J3URLLinkFilter.h"

@interface MUConnectionWindowController (Private)

- (void) displayString:(NSString *)string;

@end

#pragma mark -

@implementation MUConnectionWindowController

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
{
  if (self = [super initWithWindowNibName:@"MUConnectionWindow"])
  {
    world = [newWorld retain];
    player = [newPlayer retain];
    
    autoLoggedIn = NO;
    
    historyRing = [[J3HistoryRing alloc] init];
    
    filterQueue = [[J3FilterQueue alloc] init];
    [filterQueue addFilter:[J3ANSIRemovingFilter filter]];
    //[filterQueue addFilter:[J3URLLinkFilter filter]];
    
    if (world)
    {
      if (player)
      {
        [filterQueue addFilter:[J3TextLogger filterWithWorld:world player:player]];
      }
      else
      {
        [filterQueue addFilter:[J3TextLogger filterWithWorld:world]];
      }
    }
    else
    {
      [filterQueue addFilter:[J3TextLogger filter]];
    }
  }
  return self;
}

- (id) initWithWorld:(MUWorld *)newWorld
{
  return [self initWithWorld:newWorld player:nil];
}

- (void) awakeFromNib
{
  NSString *frameName;
  NSString *windowName;
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
  
  if (player)
  {
    [[self window] setTitle:[player windowName]];
    [[self window] setFrameAutosaveName:[player frameName]];
    [[self window] setFrameUsingName:[player frameName]];
  }
  else
  {
    [[self window] setTitle:[world windowName]];
    [[self window] setFrameAutosaveName:[world frameName]];
    [[self window] setFrameUsingName:[world frameName]];
  }
}

- (void) dealloc
{
  [telnetConnection close];
  [telnetConnection release];
  [filterQueue release];
  [historyRing release];
  [world release];
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
  telnetConnection = [world newTelnetConnection];
  
  if (telnetConnection)
  {
    if ([world usesSSL])
      [telnetConnection setSecurityLevel:NSStreamSocketSecurityLevelNegotiatedSSL];
    
    if ([world usesProxy])
    {
      [telnetConnection enableProxyWithHostname:[world proxyHostname]
                                         onPort:[[world proxyPort] intValue]
                                        version:[world proxyVersion]
                                       username:[world proxyUsername]
                                       password:[world proxyPassword]];
    }
    
    [telnetConnection setDelegate:self];
    [telnetConnection open];
  }
  //else
  //TODO: Error messaging goes here
  
  [[self window] makeFirstResponder:inputView];
}

- (IBAction) disconnect:(id)sender
{
  [telnetConnection close];
  [telnetConnection release];
  telnetConnection = nil;
}

- (BOOL) sendString:(NSString *)string
{
  NSString *inputToWrite;
  
  if ([string length] > 0)
  {
    inputToWrite = [NSString stringWithFormat:@"%@\n", string];
    
    if ([telnetConnection isConnected])
    {
      [telnetConnection writeString:inputToWrite];
      return YES;
    }
    else
    {
      return NO;
    }
  }
}

- (IBAction) sendInputText:(id)sender
{
  NSString *input = [inputView string];
  
  if ([self sendString:input])
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
        if (!autoLoggedIn && player)
        {
          [self sendString:[player loginString]];
          autoLoggedIn = YES;
        }
        [self displayString:NSLocalizedString (MULConnectionOpen, nil)];
        break;
        
      case J3ConnectionStatusClosed:
        switch ([telnet reasonClosed])
        {
          case J3ConnectionClosedReasonServer:
            [self displayString:NSLocalizedString (MULConnectionClosedByServer, nil)];
            break;
            
          case J3ConnectionClosedReasonError:
            [self displayString:[NSString stringWithFormat:NSLocalizedString (MULConnectionClosedByError, nil), 
              [telnet errorMessage]]];
            break;
            
          default:
            [self displayString:NSLocalizedString (MULConnectionClosed, nil)];
        }
        [self disconnect:nil];
        break;
        
      default:
        //Do nothing
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
      [textView setSelectedRange:NSMakeRange ([[textView textStorage] length], 0)];
      [[self window] makeFirstResponder:inputView];
      return YES;
    }
    else
    {
      [inputView doCommandBySelector:commandSelector];
      [textView setSelectedRange:NSMakeRange ([[textView textStorage] length], 0)];
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
    else if (commandSelector == @selector(insertTab:) ||
             commandSelector == @selector(insertBacktab:))
    {
      return YES;
    }
    else if (commandSelector == @selector(insertNewline:))
    {
      unichar key = 0;
      
      if ([[event charactersIgnoringModifiers] length])
        key = [[event charactersIgnoringModifiers] characterAtIndex:0];
      
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
#pragma mark NSWindow delegate

- (BOOL) windowShouldClose:(id)sender
{
  if ([self isConnected])
  {
    NSString *title = [NSString stringWithFormat:NSLocalizedString (MULConfirmCloseTitle, nil), player ? [player windowName]
                                                                                                       : [world windowName]];
    NSAlert *alert;
    int choice;
    
    alert = [NSAlert alertWithMessageText:title
                            defaultButton:NSLocalizedString (MULOkay, nil)
                          alternateButton:NSLocalizedString (MULCancel, nil)
                              otherButton:nil
                informativeTextWithFormat:NSLocalizedString (MULConfirmCloseMessage, nil),
      [world worldHostname]];
    
    choice = [alert runModal];
    
    if (choice == NSAlertAlternateReturn)
    {
      return NO;
    }
  }
  
  [sender autorelease];
  [self disconnect:sender];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionWindowControllerWillCloseNotification
                                                      object:self];
  
  return YES;
}

@end

#pragma mark -

@implementation MUConnectionWindowController (Private)

- (void) displayString:(NSString *)string
{
  NSAttributedString *unfilteredString =
  [NSAttributedString attributedStringWithString:string
                                      attributes:[receivedTextView typingAttributes]];
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

@end
