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

@implementation MUMainWindowController

- (void) awakeFromNib
{
  NSFont *monacoFont = [NSFont fontWithName:@"Monaco" size:10];
  NSDictionary *attributeDictionary = [NSDictionary dictionaryWithObject:monacoFont
                                                                  forKey:NSFontAttributeName];
  [receivedTextView setTypingAttributes:attributeDictionary];
  
  _historyIndex = -1;
  _historyArray = [[NSMutableArray alloc] init];
  
  _filterQueue = [[MUInputFilterQueue alloc] init];
  [_filterQueue addFilter:[MUAnsiRemovingFilter filter]];
  
  [disconnectButton setEnabled:NO];
  [connectButton setEnabled:YES];
}

- (void) dealloc
{
  [_telnetConnection close];
  [_telnetConnection release];
  [_filterQueue release];
  [_historyArray release];
}

- (IBAction) connect:(id)sender
{
  NSString *name = [hostNameField stringValue];
  int portNumber = [portField intValue];
  _telnetConnection = [[MUTelnetConnection alloc] initWithHostName:name
                                                            onPort:portNumber];
  [_telnetConnection setDelegate:self];
  [_telnetConnection open];
  
  [connectButton setEnabled:NO];
  [disconnectButton setEnabled:YES];
  
  [[self window] makeFirstResponder:inputField];
}

- (IBAction) disconnect:(id)sender
{
  [_telnetConnection close];
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
    
    if (_historyIndex >= 0 && _historyIndex < [_historyArray count])
      [_historyArray removeObjectAtIndex:_historyIndex];
    [_historyArray addObject:[inputField stringValue]];
    _historyIndex = -1;
    
    [inputField setStringValue:@""];
  }
  
  [[self window] makeFirstResponder:inputField];
}

- (void) _displayString:(NSString *)string
{
  NSString *filteredString = [_filterQueue processString:string];
  NSAttributedString *attributedString;
  attributedString = [[NSAttributedString alloc] initWithString:filteredString 
                                                     attributes:[receivedTextView typingAttributes]];
  NSTextStorage *textStorage = [receivedTextView textStorage];
  
  [textStorage beginEditing];
  [textStorage appendAttributedString:attributedString];
  [textStorage endEditing];
  
  if ([[(NSScrollView *) [[receivedTextView superview] superview] verticalScroller] floatValue] == 1.0)
    [receivedTextView scrollRangeToVisible:NSMakeRange ([textStorage length], 1)];  
}

- (IBAction) nextCommand:(id)sender
{
  _historyIndex++;
  
  if (_historyIndex >= [_historyArray count] || _historyIndex < -1)
  {
    _historyIndex = -1;
    [inputField setStringValue:@""];
  }
  else
  {
    [inputField setStringValue:[_historyArray objectAtIndex:_historyIndex]];
  }
}

- (IBAction) previousCommand:(id)sender
{
  _historyIndex--;
  
  if (_historyIndex == -2)
    _historyIndex = [_historyArray count] - 1;
  else if (_historyIndex >= [_historyArray count] || _historyIndex < -2)
    _historyIndex == -1;

  if (_historyIndex == -1)
    [inputField setStringValue:@""]; 
  else
    [inputField setStringValue:[_historyArray objectAtIndex:_historyIndex]];
}

// Delegate methods for MUTelnetConnection.

- (void) telnetDidReadLine:(MUTelnetConnection *)telnet
{
  [self _displayString:[telnet read]];
}

- (void) telnetDidChangeStatus:(MUTelnetConnection *)telnet
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
      [telnet release];
      [disconnectButton setEnabled:NO];
      [connectButton setEnabled:YES];      
      break;
      
    default:
      //Do nothing
      break;
  }
  
  [self _displayString:@"\n"];
}

// Delegate methods for NSTextView.

- (BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
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
  return NO;
}

@end
