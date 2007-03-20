//
// MUProxySettingsController.h
//
// Copyright (c) 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>

@class J3ProxySettings;

@interface MUProxySettingsController : NSWindowController
{
  IBOutlet NSTextField *hostnameField;
  IBOutlet NSTextField *portField;
}

- (J3ProxySettings *) proxySettings;

@end
