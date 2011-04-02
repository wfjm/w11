// $Id: RtclProxyBase.hpp 365 2011-02-28 07:28:26Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclProxyBase.hpp 365 2011-02-28 07:28:26Z mueller $
  \brief   Declaration of class RtclProxyBase.
*/

#ifndef included_Retro_RtclProxyBase
#define included_Retro_RtclProxyBase 1

#include "tcl.h"

#include <string>
#include <map>

#include "RtclArgs.hpp"
#include "librtools/RmethDscBase.hpp"

namespace Retro {

  class RtclProxyBase {
    public:
      static const int kOK  = TCL_OK;
      static const int kERR = TCL_ERROR;

      typedef std::map<std::string, RmethDscBase<RtclArgs>*> mmap_t;
      typedef mmap_t::iterator         mmap_it_t;
      typedef mmap_t::const_iterator   mmap_cit_t;
      typedef mmap_t::value_type       mmap_val_t;

      typedef RmethDscBase<RtclArgs>   mdsc_t;

      explicit      RtclProxyBase(const std::string& type = std::string());
      virtual       ~RtclProxyBase();

      virtual int   ClassCmdConfig(Tcl_Interp* interp, int objc,
                                   Tcl_Obj* const objv[]);

      const std::string& Type() const;
      Tcl_Command        Token() const;

    protected:
      void          SetType(const std::string& type);

      void          AddMeth(const std::string& name, 
                            RmethDscBase<RtclArgs>* pmeth);

      void          CreateObjectCmd(Tcl_Interp* interp, const char* name);

      int           TclObjectCmd(Tcl_Interp* interp, int objc, 
                                 Tcl_Obj* const objv[]);

      static int    ThunkTclObjectCmd(ClientData cdata, Tcl_Interp* interp, 
                                      int objc, Tcl_Obj* const objv[]);
      static void   ThunkTclCmdDeleteProc(ClientData cdata);
      static void   ThunkTclExitProc(ClientData cdata);
    
    protected:
      std::string   fType;                  //!< proxied type name
      mmap_t        fMapMeth;               //!< map for named methods
      Tcl_Interp*   fInterp;                //!< tcl interpreter
      Tcl_Command   fCmdToken;              //!< cmd token for object command

    // RtclProxyBase is not copy or assignable
    private:
                    RtclProxyBase(const RtclProxyBase& rhs);
      RtclProxyBase&  operator=(const RtclProxyBase& rhs);
  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RtclProxyBase_NoInline))
#include "RtclProxyBase.ipp"
#endif

#endif
