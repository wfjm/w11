// $Id: Rw11.cpp 1114 2019-02-23 18:01:55Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-19  1090   1.1.4  use RosPrintf(bool)
// 2018-12-15  1082   1.1.3  use lambda instead of boost::bind
// 2018-12-09  1080   1.1.2  use std::shared_ptr instead of boost and range loop
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2014-12-30   625   1.1    adopt to Rlink V4 attn logic
// 2013-03-06   495   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11.
*/

#include <functional>

#include "librtools/Rexception.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "Rw11Cpu.hpp"

#include "Rw11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const int      Rw11::kLam;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11::Rw11()
  : fspServ(),
    fNCpu(0),
    fStarted(false)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11::~Rw11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::SetServer(const std::shared_ptr<RlinkServer>& spserv)
{
  fspServ = spserv;
  fspServ->AddAttnHandler(bind(&Rw11::AttnHandler, this, _1), 
                          uint16_t(1)<<kLam, this);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::AddCpu(const std::shared_ptr<Rw11Cpu>& spcpu)
{
  if (fNCpu >= 4)
    throw Rexception("Rw11::AddCpu", "Bad state: already 4 cpus registered");
  if (fNCpu > 0 && fspCpu[0]->Type() != spcpu->Type())
    throw Rexception("Rw11::AddCpu", "Bad state: type mismatch, new is " 
                     + spcpu->Type() + " first was " + fspCpu[0]->Type());

  fspCpu[fNCpu] = spcpu;
  fNCpu += 1;
  spcpu->Setup(this);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11Cpu& Rw11::Cpu(size_t ind) const
{
  return *fspCpu[ind];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::Start()
{
  if (fStarted) 
    throw Rexception("Rw11::Start()","alread started");
  
  for (size_t i=0; i<fNCpu; i++) fspCpu[i]->Start();

  if (!Server().IsActive()) Server().Start();

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::Dump(std::ostream& os, int ind, const char* text, int /*detail*/) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11 @ " << this << endl;

  os << bl << "  fspServ:         " << fspServ.get() << endl;
  os << bl << "  fNCpu:           " << fNCpu << endl;
  os << bl << "  fspCpu[4]:       ";
  for (auto& o: fspCpu) os << o.get() << " ";
  os << endl;
  os << bl << "  fStarted:        " << RosPrintf(fStarted) << endl;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11::AttnHandler(RlinkServer::AttnArgs& args)
{
  Server().GetAttnInfo(args);

  for (size_t i=0; i<fNCpu; i++) fspCpu[i]->W11AttnHandler();
  return 0;
}
  
} // end namespace Retro
