//
//  J3TelnetState.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetState.h"

@class J3TelnetParser;

@implementation J3TelnetState
+ (id) state;
{
  return [[[self alloc] init] autorelease];
}

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser;
{
  @throw [NSException exceptionWithName:@"SubclassResponsibility" reason:@"Subclass failed to implement -parse:forParser:" userInfo:nil];
}
@end
