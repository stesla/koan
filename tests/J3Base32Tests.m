//
// J3Base32Tests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3Base32Tests.h"
#import "licensing/J3Base32.h"

@implementation J3Base32Tests

- (void) testEmptyString
{
  [self assert: [J3Base32 decodeData: [NSData data]] equals: [NSData data]];
}

- (void) testDecode_a
{
  const uint8_t encodedString[] = "ME======";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "a" length: 1]];
}

- (void) testDecode_1
{
  const uint8_t encodedString[] = "GE======";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "1" length: 1]];
}

- (void) testDecode_12
{
  const uint8_t encodedString[] = "GEZA====";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "12" length: 2]];
}

- (void) testDecode_123
{
  const uint8_t encodedString[] = "GEZDG===";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "123" length: 3]];
}

- (void) testDecode_1234
{
  const uint8_t encodedString[] = "GEZDGNA=";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "1234" length: 4]];
}

- (void) testDecode_12345
{
  const uint8_t encodedString[] = "GEZDGNBV";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "12345" length: 5]];
}

- (void) testDecode_abcde
{
  const uint8_t encodedString[] = "MFRGGZDF";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: "abcde" length: 5]];
}

- (void) testDecodeConstitutionPreamble
{
  const uint8_t expectedString[] = 
    "We the people of the United States, in order to form a more perfect union,"
    " establish justice, insure domestic tranquility, provide for the common"
    " defense, promote the general welfare, and secure the blessings of liberty"
    " to ourselves and our posterity, do ordain and establish this Constitution"
    " for the United States of America.";
  const uint8_t encodedString[] =
    "K5SSA5DIMUQHAZLPOBWGKIDPMYQHI2DFEBKW42LUMVSCAU3UMF2GK4ZMEBUW4IDPOJSGK4RA" 
    "ORXSAZTPOJWSAYJANVXXEZJAOBSXEZTFMN2CA5LONFXW4LBAMVZXIYLCNRUXG2BANJ2XG5DJ"
    "MNSSYIDJNZZXK4TFEBSG63LFON2GSYZAORZGC3TROVUWY2LUPEWCA4DSN53GSZDFEBTG64RA"
    "ORUGKIDDN5WW233OEBSGKZTFNZZWKLBAOBZG63LPORSSA5DIMUQGOZLOMVZGC3BAO5SWYZTB"
    "OJSSYIDBNZSCA43FMN2XEZJAORUGKIDCNRSXG43JNZTXGIDPMYQGY2LCMVZHI6JAORXSA33V"
    "OJZWK3DWMVZSAYLOMQQG65LSEBYG643UMVZGS5DZFQQGI3ZAN5ZGIYLJNYQGC3TEEBSXG5DB"
    "MJWGS43IEB2GQ2LTEBBW63TTORUXI5LUNFXW4IDGN5ZCA5DIMUQFK3TJORSWIICTORQXIZLT"
    "EBXWMICBNVSXE2LDMEXA====";
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: encodedString  length: strlen((char *) encodedString)]]
        equals: [NSData dataWithBytes: expectedString length: strlen((char *) expectedString)]];
}

- (void) testWrongLengthText
{
  [self assert: [J3Base32 decodeData: [NSData dataWithBytes: "123456" length: 6]] equals: [NSData data]];  
}

@end
