//
// MUMainWindowController.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUMainWindowController.h"

#import "MUAnsiRemovingFilter.h"
#import "MUTextLogFilter.h"

@implementation MUMainWindowController

- (void) awakeFromNib
{
  NSDictionary *bindingOptions = [NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
                                                             forKey:@"NSValueTransformerName"];
  
  [receivedTextView bind:@"backgroundColor"
                toObject:[NSUserDefaultsController sharedUserDefaultsController]
             withKeyPath:@"values.MUPBackgroundColor"
                 options:bindingOptions];
  [inputField bind:@"backgroundColor"
          toObject:[NSUserDefaultsController sharedUserDefaultsController]
       withKeyPath:@"values.MUPBackgroundColor"
           options:bindingOptions];
  
  _historyRing = [[MUHistoryRing alloc] init];
  
  _filterQueue = [[MUFilterQueue alloc] init];
  [_filterQueue addFilter:[MUAnsiRemovingFilter filter]];
  [_filterQueue addFilter:[MUTextLogFilter filter]];
  
  [disconnectButton setEnabled:NO];
  [connectButton setEnabled:YES];
}

- (void) dealloc
{
  [_telnetConnection close];
  [_telnetConnection release];
  [_filterQueue release];
  [_historyRing release];
}

- (IBAction) connect:(id)sender
{
  NSString *name = [hostNameField stringValue];
  int portNumber = [portField intValue];
  _telnetConnection = [[J3TelnetConnection alloc] initWithHostName:name
                                                            onPort:portNumber];
  if(_telnetConnection)
  {
    [_telnetConnection setDelegate:self];
    [_telnetConnection open];
  
    [connectButton setEnabled:NO];
    [disconnectButton setEnabled:YES];
  }
  //else
  //TODO: Error messaging goes here
  [[self window] makeFirstResponder:inputField];
}

- (IBAction) disconnect:(id)sender
{
  [_telnetConnection close];
  [_telnetConnection release];
  _telnetConnection = nil;
  [disconnectButton setEnabled:NO];
  [connectButton setEnabled:YES];
}

- (IBAction) writeLine:(id)sender
{
  NSString *input = [inputField stringValue];
  NSString *inputToWrite;
  
  if ([input length] > 0)
  {
    inputToWrite = [NSString stringWithFormat:@"%@\n", [inputField stringValue]];
    
    if ([_telnetConnection isConnected])
    {
      [_telnetConnection writeString:inputToWrite];
    }
    
    [_historyRing saveString:[inputField stringValue]];
    
    [inputField setStringValue:@""];
  }
  
  [[self window] makeFirstResponder:inputField];
}

- (void) _displayString:(NSString *)string
{
  NSAttributedString *unfilteredString =
    [NSAttributedString attributedStringWithString:string
                                        attributes:[receivedTextView typingAttributes]];
  NSAttributedString *filteredString = [_filterQueue processAttributedString:unfilteredString];

  NSTextStorage *textStorage = [receivedTextView textStorage];
  
  [textStorage beginEditing];
  [textStorage appendAttributedString:filteredString];
  [textStorage endEditing];
  
  if ([[(NSScrollView *) [[receivedTextView superview] superview] verticalScroller] floatValue] == 1.0)
    [receivedTextView scrollRangeToVisible:NSMakeRange ([textStorage length], 1)];  
}

- (IBAction) nextCommand:(id)sender
{
  [_historyRing updateString:[inputField stringValue]];
  [inputField setStringValue:[_historyRing nextString]];
}

- (IBAction) previousCommand:(id)sender
{
  [_historyRing updateString:[inputField stringValue]];
  [inputField setStringValue:[_historyRing previousString]];
}

// Delegate methods for J3TelnetConnection.

- (void) telnetDidReadLine:(J3TelnetConnection *)telnet
{
  if (telnet == _telnetConnection)
    [self _displayString:[telnet read]];
}

- (void) telnetDidChangeStatus:(J3TelnetConnection *)telnet
{
  if (telnet == _telnetConnection)
  {
    switch ([telnet connectionStatus])
    {
      case MUConnectionStatusConnecting:
        [self _displayString:NSLocalizedString (MULConnectionOpening, nil)];
        break;
        
      case MUConnectionStatusConnected:
        [self _displayString:NSLocalizedString (MULConnectionOpen, nil)];
        break;
        
      case MUConnectionStatusClosed:
        switch ([telnet reasonClosed])
        {
          case MUConnectionClosedReasonServer:
            [self _displayString:NSLocalizedString (MULConnectionClosedByServer, nil)];
            break;
            
          case MUConnectionClosedReasonError:
            [self _displayString:[NSString stringWithFormat:NSLocalizedString (MULConnectionClosedByError, nil), 
              [telnet errorMessage]]];
            break;
            
          default:
            [self _displayString:NSLocalizedString (MULConnectionClosed, nil)];
        }
        [self disconnect:nil];
        break;
        
      default:
        //Do nothing
        break;
    }
    
    [self _displayString:@"\n"];    
  }
}

// Delegate methods for NSTextView.

- (BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  if (control == inputField)
  {
    
    if (commandSelector == @selector(moveUp:))
    {
      if ([textView selectedRange].location == 0)
      {
        [self previousCommand:self];
        [textView setSelectedRange:NSMakeRange (0, 0)];
        return YES;
      }
    }
    else if (commandSelector == @selector(moveDown:))
    {
      if ([textView selectedRange].location == [[textView textStorage] length])
      {
        [self nextCommand:self];
        [textView setSelectedRange:NSMakeRange ([[textView textStorage] length], 0)];
        return YES;
      }
    }
  }
  return NO;
}

@end
