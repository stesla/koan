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


#import "J3TestCase.h"

@implementation J3TestCase

- (void) assert:(id)actual equals:(id)expected;
{
  [self assert:actual equals:expected message:@""];
}

- (void) assert:(id)actual equals:(id)expected message:(NSString *)message;
{
  if (expected == nil && actual == nil)
    return;
  if ([expected isEqual:actual])
    return;
  [self fail:[NSString stringWithFormat:@"%@ expected [%@] but was [%@]", message, expected, actual]];
}

- (void) assertFalse:(BOOL)actual;
{
  [self assertFalse:actual message:@""];
}

- (void) assertFalse:(BOOL)actual message:(NSString *)message;
{
  [self assertTrue:!actual message:message];
}

- (void) assertFloat:(float)actual equals:(float)expected;
{
  [self assertFloat:actual equals:expected message:@""];
}

- (void) assertFloat:(float)actual equals:(float)expected message:(NSString *)message;
{
  [self assert:[NSNumber numberWithFloat:actual] equals:[NSNumber numberWithFloat:expected] message:message];
}

- (void) assertInt:(int)actual equals:(int)expected;
{
  [self assertInt:actual equals:expected message:@""];
}

- (void) assertInt:(int)actual equals:(int)expected message:(NSString *)message;
{
  [self assert:[NSNumber numberWithInt:actual] equals:[NSNumber numberWithInt:expected] message:message];
}

- (void) assertNil:(id)actual;
{
  [self assertNil:actual message:@""];
}

- (void) assertNil:(id)actual message:(NSString *)message;
{
  NSString * error = [NSString stringWithFormat:@"%@ expected nil but was [%@]", message, actual];
  [self assertTrue:(actual == nil) message:error];
}

- (void) assertNotNil:(id)actual;
{
  [self assertNotNil:actual message:@""];
}

- (void) assertNotNil:(id)actual message:(NSString *)message;
{
  NSString * error = [NSString stringWithFormat:@"%@ expected not to be nil", message, actual];
  [self assertTrue:(actual != nil) message:error];
}

- (void) assertTrue:(BOOL)actual;
{
  [self assertTrue:actual message:@""];
}

- (void) assertTrue:(BOOL)actual message:(NSString *)message;
{
  if (!actual)
    [self fail:message];
}

- (void) fail;
{
  [self fail:@""];
}

- (void) fail:(NSString *)message;
{
  [self failWithException:[NSException exceptionWithName:@"J3TestFailure" reason:message userInfo:nil]];
}

@end
