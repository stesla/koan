//
//  MUWorldRegistryTests.h
//  Koan
//
//  Created by Samuel on 1/6/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

@class MUWorld;
@class MUWorldRegistry;

@interface MUWorldRegistryTests : TestCase
{
  MUWorldRegistry *registry;
  MUWorld *world;
}

@end
