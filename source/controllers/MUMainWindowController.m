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
}

- (IBAction) disconnect:(id)sender
{
  [_telnetConnection close];
  [_telnetConnection release];
  [disconnectButton setEnabled:NO];
  [connectButton setEnabled:YES];
}

- (IBAction) writeLine:(id)sender
{
  NSString *input = [NSString stringWithFormat:@"%@\n", [inputField stringValue]];
  [inputField setStringValue:@""];
  
  if ([_telnetConnection isConnected])
  {
    [_telnetConnection writeString:input];
  }
}

- (void) telnetDidReadLine:(MUTelnetConnection *)telnet
{
  NSAttributedString *string = [[NSAttributedString alloc] initWithString:[telnet read] attributes:[textView typingAttributes]];
  NSTextStorage *textStorage = [textView textStorage];
  
  [textStorage beginEditing];
  [textStorage appendAttributedString:string];
  [textStorage endEditing];
  [string release];
  
  if ([[(NSScrollView *) [[textView superview] superview] verticalScroller] floatValue] == 1.0)
    [textView scrollRangeToVisible:NSMakeRange ([textStorage length], 1)];
}

@end