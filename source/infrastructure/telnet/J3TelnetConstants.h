//
// J3TelnetConstants.h
//
// Copyright (c) 2010 3James Software.
//

enum J3TelnetCommands
{
  // This command is defined in RFC 885.
  J3TelnetEndOfRecord = 239,
  
  // These commands are defined in RFC 854.
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

#define TELNET_OPTION_MAX UINT8_MAX

enum J3TelnetOptions
{
  // These options are defined by various RFCs.
  J3TelnetOptionTransmitBinary = 0,
  J3TelnetOptionEcho = 1,
  J3TelnetOptionSuppressGoAhead = 3,
  J3TelnetOptionStatus = 5,
  J3TelnetOptionTerminalType = 24,
  J3TelnetOptionEndOfRecord = 25,
  J3TelnetOptionNegotiateAboutWindowSize = 31,
  J3TelnetOptionTerminalSpeed = 32,
  J3TelnetOptionToggleFlowControl = 33,
  J3TelnetOptionLineMode = 34,
  J3TelnetOptionXDisplayLocation = 35,
  J3TelnetOptionNewEnvironment = 39,
  J3TelnetOptionCharset = 42,
  
  // The START-TLS extension is defined in <http://tools.ietf.org/html/draft-altman-telnet-starttls-02>.
  J3TelnetOptionStartTLS = 46,
  
  // MUD Server Status Protocol.
  // The MSSP extension is defined at <http://tintin.sourceforge.net/mssp/>.
  J3TelnetOptionMSSP = 70,
  
  // MUD Client Compression Protocol.
  // The MCCP extension is defined at <http://mccp.afkmud.com/protocol.html>.
  J3TelnetOptionMCCP1 = 85,
  J3TelnetOptionMCCP2 = 86,
  
  // MUD eXtension Protocol and MUD Sound Protocol.
  // The MXP extension is defined at <http://www.zuggsoft.com/zmud/mxp.htm>.
  J3TelnetOptionMSP = 90,
  J3TelnetOptionMXP = 91
};

enum J3TelnetTerminalTypeSubnegotiationCommands
{
  // These commands are defined in RFC 1091.
  J3TelnetTerminalTypeIs = 0,
  J3TelnetTerminalTypeSend = 1
};

enum J3TelnetCharsetSubnegotiationCommands
{
  // These commands are defined in RFC 2066
  J3TelnetCharsetRequest = 1,
  J3TelnetCharsetAccepted = 2,
  J3TelnetCharsetRejected = 3,
  J3TelnetCharsetTTableIs = 4,
  J3TelnetCharsetTTableRejected = 5,
  J3TelnetCharsetTTableAck = 6,
  J3TelnetCharsetTTableNak = 7
};
