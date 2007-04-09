//
// UKPrefsPanel.h
//
// Copyright (c) 2003-2005 M. Uli Kusterer. All rights reserved.
//
// License:
//
//   You may redistribute, modify, use in commercial products free of charge,
//   however distributing modified copies requires that you clearly mark them
//   as having been modified by you, while maintaining the original markings
//   and copyrights. I don't like getting bug reports about code I wasn't
//   involved in.
//
//   I'd also appreciate if you gave credit in your app's about screen or a
//   similar place. A simple "Thanks to M. Uli Kusterer" is quite sufficient.
//   Also, I rarely turn down any postcards, gifts, complementary copies of
//   applications etc.
//
// Modifications by Tyler Berry.
// Copyright (c) 2007 3James Software.
//

#import <Foundation/Foundation.h>

@interface UKPrefsPanel : NSObject
{
  IBOutlet NSTabView *tabView;
  
  NSMutableDictionary *itemsList;
  NSString *baseWindowName;
  NSString *autosaveName;
}

- (NSTabView *) tabView;
- (void) setTabView: (NSTabView*) view;

- (NSString *) autosaveName;
- (void) setAutosaveName: (NSString*) name;

- (IBAction) orderFrontPrefsPanel: (id) sender;

@end
