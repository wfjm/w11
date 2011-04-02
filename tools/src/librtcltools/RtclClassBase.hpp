// $Id: RtclClassBase.hpp 365 2011-02-28 07:28:26Z mueller $
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
  \version $Id: RtclClassBase.hpp 365 2011-02-28 07:28:26Z mueller $
  \brief   Declaration of class RtclClassBase.
*/

#ifndef included_Retro_RtclClassBase
#define included_Retro_RtclClassBase 1

#include "tcl.h"

namespace Retro {

  class RtclClassBase {
    public:
      static const int kOK  = TCL_OK;
      static const int kERR = TCL_ERROR;

      explicit      RtclClassBase(const std::string& type = std::string());
      virtual       ~RtclClassBase();

      const std::string& Type() const;
      Tcl_Command        Token() const;

    protected:
      void          SetType(const std::string& type);

      void          CreateClassCmd(Tcl_Interp* interp, const char* name);

      virtual int   TclClassCmd(Tcl_Interp* interp, int objc, 
                                Tcl_Obj* const objv[]);

      virtual int   ClassCmdList(Tcl_Interp* interp);
      virtual int   ClassCmdDelete(Tcl_Interp* interp, const char* name);
      virtual int   ClassCmdCreate(Tcl_Interp* interp, int objc, 
                                   Tcl_Obj* const objv[]) = 0;

      static int    ThunkTclClassCmd(ClientData cdata, Tcl_Interp* interp, 
                                     int objc, Tcl_Obj* const objv[]);

      static void   ThunkTclCmdDeleteProc(ClientData cdata);
      static void   ThunkTclExitProc(ClientData cdata);
    
    protected:
      std::string   fType;                  //!< classed type name
      Tcl_Interp*   fInterp;                //!< tcl interpreter
      Tcl_Command   fCmdToken;              //!< cmd token for class command

    // RtclClassBase is not copy or assignable
    private:
                    RtclClassBase(const RtclClassBase& rhs);
      RtclClassBase&  operator=(const RtclClassBase& rhs);


  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RtclClassBase_NoInline))
#include "RtclClassBase.ipp"
#endif

#endif
