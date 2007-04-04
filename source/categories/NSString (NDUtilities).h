//
// NSString (NDUtilities).h
//
// Copyright (c) 2002 Nathan Day
//
// From <http://homepage.mac.com/nathan_day/pages/source.xml>:
// "Some of the source code I've written is available for other developers to
// use, there are really no restrictions on use of this code other than leave
// my name (Nathan Day) within the source code, especially if you make your
// source code public with my code in it."
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface NSString (NDUtilities)

- (unsigned) indexOfCharacter: (unichar) character range: (NSRange) range;

@end
