//COPYRIGHT:BEGIN
//
//Copyright (C) 2005 Samuel Tesla
//
//This program is free software; you can redistribute it and/or
//modify it under the terms of the GNU General Public License
//as published by the Free Software Foundation; either version 2
//of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program; if not, write to the Free Software
//Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
//COPYRIGHT:END
//

#import <SenTestingKit/SenTestingKit.h>


@interface J3TestCase : SenTestCase
{
}

- (void) assert:(id)actual equals:(id)expected;
- (void) assert:(id)actual equals:(id)expected message:(NSString *)message;
- (void) assertFalse:(BOOL)actual;
- (void) assertFalse:(BOOL)actual message:(NSString *)message;
- (void) assertFloat:(float)actual equals:(float)expected;
- (void) assertFloat:(float)actual equals:(float)expected message:(NSString *)message;
- (void) assertInt:(int)actual equals:(int)expected;
- (void) assertInt:(int)actual equals:(int)expected message:(NSString *)message;
- (void) assertNil:(id)actual;
- (void) assertNil:(id)actual message:(NSString *)message;
- (void) assertNotNil:(id)actual;
- (void) assertNotNil:(id)actual message:(NSString *)message;
- (void) assertTrue:(BOOL)actual;
- (void) assertTrue:(BOOL)actual message:(NSString *)message;
- (void) fail;
- (void) fail:(NSString *)message;

@end
