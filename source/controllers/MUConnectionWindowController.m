//
// MUConnectionWindowController.m
//
// Copyright (C) 2004 3James Software
//

#import "MUConnectionWindowController.h"

#import "MUAnsiRemovingFilter.h"
#import "MUTextLogFilter.h"

@interface MUConnectionWindowController (Private)

- (void) displayString:(NSString *)string;

@end

@implementation MUConnectionWindowController

- (id) initWithConnectionSpec:(MUConnectionSpec *)newConnectionSpec;
{
  if (self = [super initWithWindowNibName:@"MUConnectionWindow"])
  {
    connectionSpec = newConnectionSpec;
    
    historyRing = [[MUHistoryRing alloc] init];
    
    filterQueue = [[MUFilterQueue alloc] init];
    [filterQueue addFilter:[MUAnsiRemovingFilter filter]];
    [filterQueue addFilter:[MUTextLogFilter filter]];
  }
  return self;
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
  
  [[self window] setTitle:[connectionSpec name]];
}

- (void) dealloc
{
  [telnetConnection close];
  [telnetConnection release];
  [filterQueue release];
  [historyRing release];
}

// Accessors.

- (id) delegate
{
  return delegate;
}

- (void) setDelegate:(id)newDelegate
{
  delegate = newDelegate;
}

- (BOOL) isConnected
{
  return [telnetConnection isConnected];
}

// Actions.

- (IBAction) connect:(id)sender
{
  NSString *name = [connectionSpec hostname];
  int portNumber = [[connectionSpec port] intValue];
  
  telnetConnection = [[J3TelnetConnection alloc] initWithHostName:name
                                                            onPort:portNumber];
  if (telnetConnection)
  {
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

- (IBAction) writeLine:(id)sender
{
  NSString *input = [inputView string];
  NSString *inputToWrite;
  
  if ([input length] > 0)
  {
    inputToWrite = [NSString stringWithFormat:@"%@\n", [inputView string]];
    
    if ([telnetConnection isConnected])
    {
      [telnetConnection writeString:inputToWrite];
    }
    
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

// Delegate methods for J3TelnetConnection.

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
      case MUConnectionStatusConnecting:
        [self displayString:NSLocalizedString (MULConnectionOpening, nil)];
        break;
        
      case MUConnectionStatusConnected:
        [self displayString:NSLocalizedString (MULConnectionOpen, nil)];
        break;
        
      case MUConnectionStatusClosed:
        switch ([telnet reasonClosed])
        {
          case MUConnectionClosedReasonServer:
            [self displayString:NSLocalizedString (MULConnectionClosedByServer, nil)];
            break;
            
          case MUConnectionClosedReasonError:
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

// Delegate methods for NSTextView.

- (BOOL) textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  NSEvent *event = [NSApp currentEvent];
  
  if (textView == inputView)
  {
    if ([event type] != NSKeyDown)
    {
      return NO;
    }
    else if (commandSelector == @selector(insertNewline:))
    {
      unichar key = 0;
      
      if ([[event charactersIgnoringModifiers] length])
        key = [[event charactersIgnoringModifiers] characterAtIndex:0];
      
      if (key == NSCarriageReturnCharacter || key == NSEnterCharacter)
      {
        [self writeLine:textView];
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

// Delegate methods for NSWindow.

- (BOOL) windowShouldClose:(id)sender
{
  if ([self isConnected])
  {
    NSString *title = [NSString stringWithFormat:NSLocalizedString (MULConfirmCloseTitle, nil), [connectionSpec name]];
    NSAlert *alert;
    int choice;
    
    alert = [NSAlert alertWithMessageText:title
                            defaultButton:NSLocalizedString (MULOkay, nil)
                          alternateButton:NSLocalizedString (MULCancel, nil)
                              otherButton:nil
                informativeTextWithFormat:NSLocalizedString (MULConfirmCloseMessage, nil),
      [connectionSpec hostname]];
    
    choice = [alert runModal];
    
    if (choice == NSAlertAlternateReturn)
    {
      return NO;
    }
  }
  
  [sender autorelease];
  [self disconnect:sender];
  if ([[self delegate] respondsToSelector:@selector(windowIsClosingForConnectionWindowController:)])
  {
    [[self delegate] windowIsClosingForConnectionWindowController:self];
  }
  return YES;
}

@end

@implementation MUConnectionWindowController (Private)

- (void) displayString:(NSString *)string
{
  NSAttributedString *unfilteredString =
    [NSAttributedString attributedStringWithString:string
                                        attributes:[receivedTextView typingAttributes]];
  NSAttributedString *filteredString = [filterQueue processAttributedString:unfilteredString];
  NSTextStorage *textStorage = [receivedTextView textStorage];
  float scrollerPosition = [[[receivedTextView enclosingScrollView] verticalScroller] floatValue];
  
  [textStorage replaceCharactersInRange:NSMakeRange ([textStorage length], 0)
                   withAttributedString:filteredString];
  
  [[receivedTextView window] invalidateCursorRectsForView:receivedTextView];
  
  if (scrollerPosition - 1.0 < 0.000001) // Avoiding inaccuracy of == for floats.
    [receivedTextView scrollRangeToVisible:NSMakeRange ([textStorage length], 0)];
  
  if (![NSApp isActive])
  {
    [NSApp requestUserAttention:NSInformationalRequest];
  }
}

@end
