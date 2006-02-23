//
//  J3ConnectionFactory.m
//  Koan
//
//  Created by Samuel on 2/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3ConnectionFactory.h"
#import "J3Socket.h"
#import "J3TelnetParser.h"

@implementation J3ConnectionFactory

+ (J3ConnectionFactory *) factory;
{
  return [[[self alloc] init] autorelease];
}

- (J3Telnet *) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                        port:(int)port
                                    delegate:(NSObject <J3TelnetConnectionDelegate> *)delegate
                          lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate;
{  
  J3LineBuffer *buffer = [J3LineBuffer buffer];
  
  [buffer setDelegate:lineBufferDelegate];
  return [self telnetWithHostname:hostname port:port inputBuffer:buffer delegate:delegate];
}

- (J3Telnet *) telnetWithHostname:(NSString *)hostname
                             port:(int)port
                      inputBuffer:(NSObject <J3Buffer> *)buffer
                         delegate:(NSObject <J3TelnetConnectionDelegate> *)delegate
{
  J3TelnetParser *parser;
  J3Socket *socket;
  J3Telnet *result;

  parser = [J3TelnetParser parser];
  [parser setInputBuffer:buffer];
  socket = [J3Socket socketWithHostname:hostname port:port];
  result = [[[J3Telnet alloc] initWithConnection:socket parser:parser delegate:delegate] autorelease];
  [socket setDelegate:result];
  return result;
}

@end
