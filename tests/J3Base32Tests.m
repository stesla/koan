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
  const uint8_t encodedString[] = "";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 0 message: @"count"];
  free(decodedString);
}

- (void) testDecode_a
{
  const uint8_t encodedString[] = "ME======";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 1 message: @"count"];
  [self assertInt: decodedString[0] equals: 'a'];
  free(decodedString);
}

- (void) testDecode_1
{
  const uint8_t encodedString[] = "GE======";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 1 message: @"count"];
  [self assertInt: decodedString[0] equals: '1' message: @"1"];
  free(decodedString);
}

- (void) testDecode_12
{
  const uint8_t encodedString[] = "GEZA====";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 2 message: @"count"];
  [self assertInt: decodedString[0] equals: '1' message: @"1"];
  [self assertInt: decodedString[1] equals: '2' message: @"2"];
  free(decodedString);
}

- (void) testDecode_123
{
  const uint8_t encodedString[] = "GEZDG===";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 3 message: @"count"];
  [self assertInt: decodedString[0] equals: '1' message: @"1"];
  [self assertInt: decodedString[1] equals: '2' message: @"2"];
  [self assertInt: decodedString[2] equals: '3' message: @"3"];
  free(decodedString);
}

- (void) testDecode_1234
{
  const uint8_t encodedString[] = "GEZDGNA=";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 4 message: @"count"];
  [self assertInt: decodedString[0] equals: '1' message: @"1"];
  [self assertInt: decodedString[1] equals: '2' message: @"2"];
  [self assertInt: decodedString[2] equals: '3' message: @"3"];
  [self assertInt: decodedString[3] equals: '4' message: @"4"];
  free(decodedString);
}

- (void) testDecode_12345
{
  const uint8_t encodedString[] = "GEZDGNBV";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 5 message: @"count"];
  [self assertInt: decodedString[0] equals: '1' message: @"1"];
  [self assertInt: decodedString[1] equals: '2' message: @"2"];
  [self assertInt: decodedString[2] equals: '3' message: @"3"];
  [self assertInt: decodedString[3] equals: '4' message: @"4"];
  [self assertInt: decodedString[4] equals: '5' message: @"5"];
  free(decodedString);
}

- (void) testDecode_abcde
{
  const uint8_t encodedString[] = "MFRGGZDF";
  uint8_t *decodedString = NULL;
  [self assertInt: base32_decode (&decodedString, encodedString, strlen((char *)encodedString)) equals: 5 message: @"count"];
  [self assertInt: decodedString[0] equals: 'a' message: @"a"];
  [self assertInt: decodedString[1] equals: 'b' message: @"b"];
  [self assertInt: decodedString[2] equals: 'c' message: @"c"];
  [self assertInt: decodedString[3] equals: 'd' message: @"d"];
  [self assertInt: decodedString[4] equals: 'e' message: @"e"];
  free(decodedString);
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
  uint8_t *decodedString = NULL;
  size_t length = base32_decode (&decodedString, encodedString, strlen ((char *)encodedString));
  [self assertInt: length  equals: strlen ((char *)expectedString) message: @"count"];
  for (unsigned i = 0; i < length; i++)
    [self assertInt: decodedString[i] equals: expectedString[i] message: [NSString stringWithFormat:@"%c at position %d", expectedString[i], i]];
  free(decodedString);
}
@end
