//
//  MUTelnetConnectionTests.h
//  Koan
//
//  Created by Samuel on 9/16/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

@class MUTelnetConnection;

@interface MUTelnetConnectionTests : TestCase
{
  MUTelnetConnection *_telnet;
  NSString *_lineRead;
}

@end
