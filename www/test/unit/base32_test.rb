#
# Copyright (c) 2007 3James Software.
#

require 'test/unit'
require 'base32'

class TestBase32 < Test::Unit::TestCase
  # Rails seems to override these somewhere upstream from us,
  # so we'll override them here and make them the NOPs we expect.
  def setup; end
  def teardown; end

  def test_empty_string
    assert_equal('', Base32.encode(''))
  end

  def test_a
    assert_equal('ME======', Base32.encode('a'))
  end

  def test_12345
    assert_equal('GEZDGNBV', Base32.encode('12345'))
  end

  def test_abcde
    assert_equal('MFRGGZDF', Base32.encode('abcde'))
  end

  def test_constitution_preamble
    plaintext =<<-EOT
      We the people of the United States, in order to form a more perfect union,
      establish justice, insure domestic tranquility, provide for the common
      defense, promote the general welfare, and secure the blessings of liberty
      to ourselves and our posterity, do ordain and establish this Constitution
      for the United States of America.
    EOT
    encoded = %W(
      EAQCAIBAEBLWKIDUNBSSA4DFN5YGYZJAN5TCA5DIMUQFK3TJORSWIICTORQXIZLTFQQGS3RA
      N5ZGIZLSEB2G6IDGN5ZG2IDBEBWW64TFEBYGK4TGMVRXIIDVNZUW63RMBIQCAIBAEAQGK43U
      MFRGY2LTNAQGU5LTORUWGZJMEBUW443VOJSSAZDPNVSXG5DJMMQHI4TBNZYXK2LMNF2HSLBA
      OBZG65TJMRSSAZTPOIQHI2DFEBRW63LNN5XAUIBAEAQCAIDEMVTGK3TTMUWCA4DSN5WW65DF
      EB2GQZJAM5SW4ZLSMFWCA53FNRTGC4TFFQQGC3TEEBZWKY3VOJSSA5DIMUQGE3DFONZWS3TH
      OMQG6ZRANRUWEZLSOR4QUIBAEAQCAIDUN4QG65LSONSWY5TFOMQGC3TEEBXXK4RAOBXXG5DF
      OJUXI6JMEBSG6IDPOJSGC2LOEBQW4ZBAMVZXIYLCNRUXG2BAORUGS4ZAINXW443UNF2HK5DJ
      N5XAUIBAEAQCAIDGN5ZCA5DIMUQFK3TJORSWIICTORQXIZLTEBXWMICBNVSXE2LDMEXAU===).join
    assert_equal(encoded, Base32.encode(plaintext))
  end
end
