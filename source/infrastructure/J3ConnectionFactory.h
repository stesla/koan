//
//  J3ConnectionFactory.h
//  Koan
//
//  Created by Samuel on 2/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3LineBuffer.h"
#import "J3Telnet.h"

@interface J3ConnectionFactory : NSObject 
{
}

+ (J3ConnectionFactory *) factory;

- (J3Telnet *) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                        port:(int)port
                                    delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
                          lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate;

- (J3Telnet *) telnetWithHostname:(NSString *)hostname
                             port:(int)port
                      inputBuffer:(NSObject <J3Buffer> *)buffer
                         delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate;
@end
