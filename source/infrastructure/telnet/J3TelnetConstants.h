//
// J3TelnetConstants.h
//
// Copyright (c) 2005 3James Software
//

enum J3TelnetCommands
{
  J3TelnetEndSubnegotiation = 240,
  J3TelnetNoOperation = 241,
  J3TelnetDataMark = 242,
  J3TelnetBreak = 243,
  J3TelnetInterruptProcess = 244,
  J3TelnetAbortOutput = 245,
  J3TelnetAreYouThere = 246,
  J3TelnetEraseCharacter = 247,
  J3TelnetEraseLine = 248,
  J3TelnetGoAhead = 249,
  J3TelnetBeginSubnegotiation = 250,
  J3TelnetWill = 251,
  J3TelnetWont = 252,
  J3TelnetDo = 253,
  J3TelnetDont = 254,
  J3TelnetInterpretAsCommand = 255
};

enum J3TelnetOptions
{
  // These options are defined by RFC.
  J3TelnetSuppressGoAhead = 3,
  J3TelnetTerminalType = 24,
  J3TelnetEndOfRecord = 25,
  J3TelnetNegotiateAboutWindowSize = 31,
  J3TelnetLineMode = 34,
  
  // The MCCP extension is defined at <http://mccp.afkmud.com/protocol.html>.
  J3TelnetMCCP1 = 85,
  J3TelnetMCCP2 = 86
};
