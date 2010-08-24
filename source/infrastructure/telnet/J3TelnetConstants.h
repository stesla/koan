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
  J3TelnetOptionTransmitBinary = 0,            // RFC 856.
  J3TelnetOptionEcho = 1,                      // RFC 857.
  J3TelnetOptionSuppressGoAhead = 3,           // RFC 858.
  J3TelnetOptionStatus = 5,                    // RFC 859.
  J3TelnetOptionTimingMark = 6,                // RFC 860.
  J3TelnetOptionTerminalType = 24,             // RFC 1091.
  J3TelnetOptionEndOfRecord = 25,              // RFC 885.
  J3TelnetOptionNegotiateAboutWindowSize = 31, // RFC 1073.
  J3TelnetOptionTerminalSpeed = 32,            // RFC 1079.
  J3TelnetOptionToggleFlowControl = 33,        // RFC 1080.
  J3TelnetOptionLineMode = 34,                 // RFC 1184.
  J3TelnetOptionXDisplayLocation = 35,         // RFC 1096.
  J3TelnetOptionEnvironment = 36,              // RFC 1408.
  J3TelnetOptionNewEnvironment = 39,           // RFC 1572.
  J3TelnetOptionCharset = 42,                  // RFC 2066.
  
  // The START-TLS extension is defined in <http://tools.ietf.org/html/draft-altman-telnet-starttls-02>.
  J3TelnetOptionStartTLS = 46,
  
  // MUD Server Data Protocol.
  // The MSDP extension is defined at <http://tintin.sourceforge.net/msdp/>.
  J3TelnetOptionMSDP = 69,
  
  // MUD Server Status Protocol.
  // The MSSP extension is defined at <http://tintin.sourceforge.net/mssp/>.
  J3TelnetOptionMSSP = 70,
  
  // MUD Client Compression Protocol.
  // The MCCP extension is defined at <http://mccp.smaugmuds.org/>.
  J3TelnetOptionMCCP1 = 85,
  J3TelnetOptionMCCP2 = 86,
  
  // MUD eXtension Protocol and MUD Sound Protocol.
  // The MXP extension is defined at <http://www.zuggsoft.com/zmud/mxp.htm>.
  J3TelnetOptionMSP = 90,
  J3TelnetOptionMXP = 91,
  
  // Zenith MUD Protocol, an out-of-band communication protocol.
  // The ZMP protocol is defined at <http://zmp.sourcemud.org/spec.shtml>.
  J3TelnetOptionZMP = 93,
  
  // Aardwolf informal out-of-band protocol.
  // The Aardwolf protocol is sort of documented at <http://www.qondio.com/telnet-options-client-interaction>.
  J3TelnetOptionAardwolf = 102,
  
  // Achaea Telnet Client Protocol.
  // The ATCP protocol is defined at <http://www.ironrealms.com/rapture/manual/files/FeatATCP-txt.html>.
  // More documentation is available at <http://www.mudstandards.org/ATCP_Specification>.
  J3TelnetOptionATCP = 200,
  
  // Generic MUD Communication Protocol, a.k.a. ATCP2.
  // The GMCP protocol is semi-defined at <http://www.mudstandards.org/forum/viewtopic.php?f=7&t=107>.
  // More documentation is available at <http://www.aardwolf.com/wiki/index.php/Clients/GMCP>.
  J3TelnetOptionGMCP = 201
};

enum J3TelnetTerminalTypeSubnegotiationCommands
{
  // These commands are defined in RFC 1091.
  J3TelnetTerminalTypeIs = 0,
  J3TelnetTerminalTypeSend = 1
};

enum J3TelnetCharsetSubnegotiationCommands
{
  // These commands are defined in RFC 2066.
  J3TelnetCharsetRequest = 1,
  J3TelnetCharsetAccepted = 2,
  J3TelnetCharsetRejected = 3,
  J3TelnetCharsetTTableIs = 4,
  J3TelnetCharsetTTableRejected = 5,
  J3TelnetCharsetTTableAck = 6,
  J3TelnetCharsetTTableNak = 7
};
