// $Id: Rw11VirtTapeTap.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-07-08  1180   1.1    use RfileFd; remove dtor
// 2018-12-19  1090   1.0.4  use RosPrintf(bool)
// 2018-09-22  1048   1.0.3  BUGFIX: coverity (resource leak; bad expression)
// 2017-04-15   875   1.0.2  Open(): set default scheme
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11VirtTapeTap.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rtools.hpp"

#include "Rw11VirtTapeTap.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtTapeTap
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint32_t Rw11VirtTapeTap::kMetaEof;
const uint32_t Rw11VirtTapeTap::kMetaEom;
const uint32_t Rw11VirtTapeTap::kMeta_M_Perr;
const uint32_t Rw11VirtTapeTap::kMeta_M_Mbz;
const uint32_t Rw11VirtTapeTap::kMeta_B_Rlen;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTapeTap::Rw11VirtTapeTap(Rw11Unit* punit)
  : Rw11VirtTape(punit),
    fFd("Rw11VirtTapeTap::fFd."),
    fSize(0),
    fPos(0),
    fBad(true),
    fPadOdd(false),
    fTruncPend(false)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Open(const std::string& url, RerrMsg& emsg)
{
  if (!fUrl.Set(url, "|wpro|e11|cap=|", "tap", emsg)) return false;

  fWProt  = fUrl.FindOpt("wpro");
  fPadOdd = fUrl.FindOpt("e11");

  string str_cap;
  unsigned long capacity=0;
  if (fUrl.FindOpt("cap",str_cap)) {
    if (str_cap.length() > 0) {
      unsigned long scale = 1;
      string str_conv = str_cap;
      char clast = str_cap[str_cap.length()-1];
      bool ok = true;

      if (! (clast >= '0' && clast <= '9') ) {
        str_conv = str_cap.substr(0,str_cap.length()-1);
        switch(str_cap[str_cap.length()-1]) {
        case 'k':
        case 'K':
          scale = 1024;
          break;
        case 'm':
        case 'M':
          scale = 1024*1024;
          break;
        default:
          ok = false;
          break;
        }
      }
      if (ok) {
        RerrMsg emsg_conv;
        ok = Rtools::String2Long(str_conv, capacity, emsg_conv);
      }
      if (!ok) {
        emsg.Init("Rw11VirtTapeTap::Open()", 
                  string("bad capacity option '")+str_cap+"'");
        return false;
      }
      capacity *= scale;
    }    
  }

  if (!fFd.Open(fUrl.Path().c_str(), fWProt ? O_RDONLY : O_CREAT|O_RDWR,
                S_IRUSR|S_IWUSR|S_IRGRP, emsg)) return false;  

  struct stat sbuf;
  if (!fFd.Stat(&sbuf, emsg)) {
    fFd.Close();
    return false;
  }
  
  if ((sbuf.st_mode & S_IWUSR) == 0) fWProt = true;

  fSize = sbuf.st_size;
  fPos  = 0;
  fBad  = false;
  fTruncPend = true;

  fCapacity = capacity;
  fBot = true;
  fEot = false;
  fEom = false;
  fPosFile   = 0;
  fPosRecord = 0;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::ReadRecord(size_t nbyt, uint8_t* data, size_t& ndone, 
                                 int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTReadRec);
  
  opcode = kOpCodeBadFormat;
  ndone  = 0;
  if (fBad) return BadTapeMsg("ReadRecord()", emsg);
  
  if (fPos == fSize) {
    fEom   = true;
    opcode = kOpCodeEom;
    return true;
  }

  uint32_t metabeg;
  uint32_t metaend;

  if (!CheckSizeForw(sizeof(metabeg), "missed metabeg", emsg)) return SetBad();
  if (!Read(sizeof(metabeg), reinterpret_cast<uint8_t*>(&metabeg), 
            emsg)) return SetBad();

  if (metabeg == kMetaEof) {
    fStats.Inc(kStatNVTReadEof);
    opcode = kOpCodeEof;
    fPosFile   += 1;
    fPosRecord  = 0;
    return true;
  }

  if (metabeg == kMetaEom) {
    if (!Seek(sizeof(metabeg), -1, emsg)) return SetBad();
    fStats.Inc(kStatNVTReadEom);
    fEom   = true;
    opcode = kOpCodeEom;
    return true;
  }

  size_t rlen;
  bool   perr;
  if (!ParseMeta(metabeg, rlen, perr, emsg)) return SetBad();
  size_t rlenpad = BytePadding(rlen);

  if (!CheckSizeForw(rlenpad, "missed data", emsg)) return SetBad();

  ndone = (rlen <= nbyt) ? rlen : nbyt;
  if (!Read(ndone, data, emsg)) return SetBad();
  if (ndone < rlenpad) {
    if (!Seek(rlenpad, +1, emsg)) return SetBad();
  }

  if (!CheckSizeForw(sizeof(metaend), "missed metaend", emsg)) return SetBad();
  if (!Read(sizeof(metaend), reinterpret_cast<uint8_t*>(&metaend), 
            emsg)) return SetBad();

  if (metabeg != metaend) {
    emsg.Init("Rw11VirtTapeTap::ReadRecord", "metabeg metaend mismatch");
    ndone = 0;
    return SetBad();
  }

  IncPosRecord(+1);
  opcode = kOpCodeOK;
  if (perr) {
    fStats.Inc(kStatNVTReadPErr);
    opcode = kOpCodeBadParity;
  }
  if (ndone < rlen) {
    fStats.Inc(kStatNVTReadLErr);
    opcode = kOpCodeRecLenErr;
  }
  
  fStats.Inc(kStatNVTReadByt, ndone);

  return true;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::WriteRecord(size_t nbyt, const uint8_t* data, 
                                  int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTWriteRec);
  fStats.Inc(kStatNVTWriteByt, nbyt);

  opcode = kOpCodeBadFormat;
  if (fBad) return BadTapeMsg("WriteRecord()", emsg);

  fEom   = false;

  uint32_t meta = nbyt;
  uint8_t  zero = 0x00;

  if (!Write(sizeof(meta), reinterpret_cast<uint8_t*>(&meta), 
             false, emsg)) return SetBad();

  if (!Write(nbyt, data, 
             false, emsg)) return SetBad();
  if (fPadOdd && (nbyt&0x01)) {
    if (!Write(sizeof(zero), &zero, false, emsg)) return SetBad();
  }
  
  if (!Write(sizeof(meta), reinterpret_cast<uint8_t*>(&meta), 
             false, emsg)) return SetBad();
  if (!Write(sizeof(kMetaEom), reinterpret_cast<const uint8_t*>(&kMetaEom), 
             true, emsg)) return SetBad();

  IncPosRecord(+1);
  opcode = kOpCodeOK;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::WriteEof(RerrMsg& emsg)
{
  fStats.Inc(kStatNVTWriteEof);

  if (fBad) return BadTapeMsg("WriteEof()", emsg);

  fEom   = false;

  if (!Write(sizeof(kMetaEof), reinterpret_cast<const uint8_t*>(&kMetaEof), 
             false, emsg)) return SetBad();
  if (!Write(sizeof(kMetaEom), reinterpret_cast<const uint8_t*>(&kMetaEom), 
             true, emsg)) return SetBad();

  fPosFile   += 1;
  fPosRecord  = 0;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::SpaceForw(size_t nrec, size_t& ndone, 
                                int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSpaForw);

  opcode = kOpCodeBadFormat;
  ndone  = 0;
  if (fBad) return BadTapeMsg("SpaceForw()", emsg);

  while (nrec > 0) {

    if (fPos == fSize) {
      fEom   = true;
      opcode = kOpCodeEom;
      return true;
    }

    uint32_t metabeg;

    if (!CheckSizeForw(sizeof(metabeg), "missed metabeg", emsg)) return SetBad();
    if (!Read(sizeof(metabeg), reinterpret_cast<uint8_t*>(&metabeg), 
              emsg)) return SetBad();
    
    if (metabeg == kMetaEof) {
      opcode = kOpCodeEof;
      fPosFile   += 1;
      fPosRecord  = 0;
      return true;
    }

    if (metabeg == kMetaEom) {
      if (!Seek(sizeof(metabeg), -1, emsg)) return SetBad();
      fEom   = true;
      opcode = kOpCodeEom;
      return true;
    }

    size_t rlen;
    bool   perr;
    if (!ParseMeta(metabeg, rlen, perr, emsg)) return SetBad();
    size_t rlenpad = BytePadding(rlen);

    if (!CheckSizeForw(sizeof(metabeg)+rlenpad, "missed data or metaend", emsg))
      return SetBad();
    if (!Seek(sizeof(metabeg)+rlenpad, +1, emsg)) return SetBad();    

    IncPosRecord(+1);
    nrec  -= 1;
    ndone += 1;
  }

  opcode = kOpCodeOK;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::SpaceBack(size_t nrec, size_t& ndone, 
                                int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSpaBack);

  opcode = kOpCodeBadFormat;
  ndone  = 0;
  if (fBad) return BadTapeMsg("SpaceBack()", emsg);

  fEom = false;
  fTruncPend = true;

  while (nrec > 0) {

    if (fPos == 0) {
      opcode = kOpCodeBot;
      fPosFile    = 0;
      fPosRecord  = 0;
      return true;
    }

    uint32_t metaend;

    if (!CheckSizeBack(sizeof(metaend), "missed metaend", emsg)) return SetBad();
    if (!Seek(sizeof(metaend), -1, emsg)) return SetBad();
    if (!Read(sizeof(metaend), reinterpret_cast<uint8_t*>(&metaend), 
              emsg)) return SetBad();
    
    if (metaend == kMetaEof) {
      if (!Seek(sizeof(metaend), -1, emsg)) return SetBad();
      opcode = kOpCodeEof;
      fPosFile   -= 1;
      fPosRecord  = -1;
      return true;
    }

    if (metaend == kMetaEom) {
      emsg.Init("Rw11VirtTapeTap::SpaceBack()","unexpected EOM marker");
      return SetBad();
    }

    size_t rlen;
    bool   perr;
    if (!ParseMeta(metaend, rlen, perr, emsg)) return SetBad();
    size_t rlenpad = BytePadding(rlen);
    
    if (!CheckSizeBack(2*sizeof(metaend)+rlenpad, 
                       "missed data or metabeg", emsg)) return SetBad();
    if (!Seek(2*sizeof(metaend)+rlenpad, -1, emsg)) return SetBad();    

    IncPosRecord(-1);
    nrec  -= 1;
    ndone += 1;
  }

  opcode = kOpCodeOK;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Rewind(int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTRewind);

  opcode = kOpCodeBadFormat;
  if (!Seek(0, 0, emsg)) return SetBad();

  fBot = true;
  fEot = false;
  fEom = false;
  fPosFile   = 0;
  fPosRecord = 0;
  fBad = false;
  fTruncPend = true;

  opcode = kOpCodeOK;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTapeTap::Dump(std::ostream& os, int ind, const char* text,
                           int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTapeTap @ " << this << endl;

  os << bl << "  fFd:             " << fFd.Fd() << endl;
  os << bl << "  fSize:           " << fSize << endl;
  os << bl << "  fPos:            " << fPos << endl;
  os << bl << "  fBad:            " << RosPrintf(fBad) << endl;
  os << bl << "  fPadOdd:         " << RosPrintf(fPadOdd) << endl;
  os << bl << "  fTruncPend:      " << RosPrintf(fTruncPend) << endl;
  Rw11VirtTape::Dump(os, ind, " ^", detail);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Seek(size_t seekpos, int dir, RerrMsg& emsg)
{
  off_t offset = seekpos;
  int   whence = SEEK_SET;
  if (dir > 0) {
    whence = SEEK_CUR;
  } else if (dir < 0) {
    whence = SEEK_CUR;
    offset = -offset;
  }
  if (!fFd.Seek(offset, whence, emsg)) return false;

  UpdatePos(seekpos, dir);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Read(size_t nbyt, uint8_t* data, RerrMsg& emsg)
{
  ssize_t irc = fFd.Read(data, nbyt, emsg);
  if (irc < 0) return false;
  UpdatePos(nbyt, +1);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Write(size_t nbyt, const uint8_t* data, bool back,
                            RerrMsg& emsg)
{
  if (fTruncPend) {
    if (!fFd.Truncate(fPos, emsg)) return false;
    fTruncPend = false;    
    fSize = fPos;
  }

  if (!fFd.WriteAll(data, nbyt, emsg)) return false;
  UpdatePos(nbyt, +1);
  if (fPos > fSize) fSize = fPos;

  if (back) {
    if (!Seek(nbyt, -1, emsg)) return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::CheckSizeForw(size_t nbyt, const char* text, 
                                    RerrMsg& emsg)
{
  if (fPos+nbyt <= fSize) return true;
  emsg.Init("Rw11VirtTapeTap::CheckSizeForw()", text);
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::CheckSizeBack(size_t nbyt, const char* text,
                                    RerrMsg& emsg)
{
  if (nbyt <= fPos) return true;
  emsg.Init("Rw11VirtTapeTap::CheckSizeBack()", text);
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTapeTap::UpdatePos(size_t nbyt, int dir)
{
  if (dir == 0) {
    fPos  = nbyt;
  } else if (dir > 0) {
    fPos += nbyt;
  } else {
    fPos -= nbyt;
  }

  fBot = (fPos == 0);
  fEot = (fCapacity == 0) ? false : (fPos > fCapacity);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::ParseMeta(uint32_t meta, size_t& rlen, bool& perr, 
                                RerrMsg& emsg)
{
  rlen = meta & kMeta_B_Rlen;
  perr = meta & kMeta_M_Perr;
  if (meta & kMeta_M_Mbz) {
    emsg.Init("Rw11VirtTapeTap::ParseMeta", "bad meta tag");
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::BadTapeMsg(const char* meth, RerrMsg& emsg)
{
  emsg.Init(string("Rw11VirtTapeTap::")+meth, "bad tape format");
  return false;
}

} // end namespace Retro
