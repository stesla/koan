//
// MUConnectionsPaneController.m
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

#import "MUConnectionsPaneController.h"
#import "MUConstants.h"

@implementation MUConnectionsPaneController

- (void) awakeFromNib
{
  
}

- (void) controlTextDidEndEditing:(NSNotification *)note
{
  
}

// Implementation of the SSPreferencePaneProtocol protocol.

+ (NSArray *) preferencePanes
{
  return [NSArray arrayWithObjects:[[[MUConnectionsPaneController alloc] init] autorelease], nil];
}

- (NSView *) paneView
{
  BOOL loaded = YES;
  
  if (!paneView)
  {
    loaded = [NSBundle loadNibNamed:@"MUConnectionsPane" owner:self];
  }
  
  if (loaded)
  {
    return paneView;
  }
  
  return nil;
}

- (NSString *) paneName
{
  return NSLocalizedString (MULPreferencePaneConnectionsName, nil);
}

- (NSImage *) paneIcon
{
  return nil;
}

- (NSString *) paneToolTip
{
  return NSLocalizedString (MULPreferencePaneConnectionsToolTip, nil);
}

- (BOOL) allowsHorizontalResizing
{
  return NO;
}

- (BOOL) allowsVerticalResizing
{
  return NO;
}

@end