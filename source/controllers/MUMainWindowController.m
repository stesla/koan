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

@implementation MUMainWindowController

- (void) awakeFromNib
{
  NSFont *monacoFont = [NSFont fontWithName:@"Monaco" size:10];
  NSDictionary *attributeDictionary = [NSDictionary dictionaryWithObject:monacoFont
                                                                  forKey:NSFontAttributeName];
  [textView setTypingAttributes:attributeDictionary];
  
  [disconnectButton setEnabled:NO];
  [connectButton setEnabled:YES];
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
  
  if ([input length] == 0)
  {
    [[self window] makeFirstResponder:inputField];
    return;
  }
  
  inputToWrite = [NSString stringWithFormat:@"%@\n", [inputField stringValue]];
  [inputField setStringValue:@""];
  
  if ([_telnetConnection isConnected])
  {
    [_telnetConnection writeString:inputToWrite];
  }
  
  [[self window] makeFirstResponder:inputField];
}

- (void) displayString:(NSString *)string
{
  NSAttributedString *attributedString;
  attributedString = [[NSAttributedString alloc] initWithString:string 
                                                     attributes:[textView typingAttributes]];
  NSTextStorage *textStorage = [textView textStorage];
  
  [textStorage beginEditing];
  [textStorage appendAttributedString:attributedString];
  [textStorage endEditing];
  [string release];
  
  if ([[(NSScrollView *) [[textView superview] superview] verticalScroller] floatValue] == 1.0)
    [textView scrollRangeToVisible:NSMakeRange ([textStorage length], 1)];  
}

- (void) telnetDidReadLine:(MUTelnetConnection *)telnet
{
  [self displayString:[telnet read]];
}

- (void) telnetDidChangeStatus:(MUTelnetConnection *)telnet
{
  switch ([telnet connectionStatus])
  {
    case MUConnectionStatusConnecting:
      [self displayString:@"Trying to open connection...\n"];
      break;

    case MUConnectionStatusConnected:
      [self displayString:@"Connected.\n"];
      break;

    case MUConnectionStatusClosed:
      switch([telnet reasonClosed])
      { 
        case MUConnectionClosedReasonServer:
          [self displayString:@"Connection closed by server.\n"];
          break;

        case MUConnectionClosedReasonError:
          [self displayString:[NSString stringWithFormat:@"Connection closed with error: %@\n", 
            [telnet errorMessage]]];
          break;

        default:
          [self displayString:@"Connection closed.\n"];
      }
      [_telnetConnection release];
      [disconnectButton setEnabled:NO];
      [connectButton setEnabled:YES];      
      break;
      
    default:
      //Do nothing
      break;
  }
}

// Delegate methods for NSTextView.

- (BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  if (commandSelector == @selector(moveUp:))
  {
    NSRange range;
    NSRect rect;

    //TODO: FIX THIS
    //rect = [[textView layoutManager] lineFragmentRectForGlyphAtIndex:selectedRange.location
    //                                                  effectiveRange:&range];
    if (range.location == 0)
    {
      
      return YES;
    }
    else
      return NO;
  }
  else if (commandSelector == @selector(moveDown:))
  {

  }
  return NO;
}

@end
