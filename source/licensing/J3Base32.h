//
// J3Base32.h
//
// Copyright (c) 2007 3James Software.
//

@interface J3Base32 : NSObject
{
}

+ (NSData *) decodeData: (NSData *) data;
+ (NSData *) decodeString: (NSString *) string;

@end
