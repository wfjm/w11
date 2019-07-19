// $Id: RtclContext.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-16  1084   1.0.5  use =delete for noncopyable instead of boost
// 2017-02-04   866   1.0.4  rename fMapContext -> fContextMap
// 2013-01-12   474   1.0.3  add FindProxy() method
// 2011-04-24   380   1.0.2  use boost::noncopyable (instead of private dcl's)
// 2011-03-12   368   1.0.1  drop fExitSeen, get exit handling right
// 2011-02-18   362   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RtclContext.
*/

#ifndef included_Retro_RtclContext
#define included_Retro_RtclContext 1

#include "tcl.h"

#include <string>
#include <set>
#include <map>

#include "RtclClassBase.hpp"
#include "RtclProxyBase.hpp"

namespace Retro {

  class RtclContext {
    public:
      typedef std::set<RtclClassBase*> cset_t;
      typedef std::set<RtclProxyBase*> pset_t;
      typedef std::map<Tcl_Interp*, RtclContext*>  xmap_t;

      explicit      RtclContext(Tcl_Interp* interp);
      virtual      ~RtclContext();
    
                    RtclContext(const RtclContext&) = delete;  // noncopyable 
      RtclContext&  operator=(const RtclContext&) = delete;    // noncopyable

      void          RegisterClass(RtclClassBase* pobj);
      void          UnRegisterClass(RtclClassBase* pobj);

      void          RegisterProxy(RtclProxyBase* pobj);
      void          UnRegisterProxy(RtclProxyBase* pobj);
      bool          CheckProxy(RtclProxyBase* pobj);
      bool          CheckProxy(RtclProxyBase* pobj, const std::string& type);

      void          ListProxy(std::vector<RtclProxyBase*>& list,
                              const std::string& type);
      RtclProxyBase* FindProxy(const std::string& type,
                               const std::string& name);

      static RtclContext&  Find(Tcl_Interp* interp);

      static void   ThunkTclExitProc(ClientData cdata);

    protected:

      Tcl_Interp*   fInterp;                //!< associated tcl interpreter
      cset_t        fSetClass;              //!< set for Class objects
      pset_t        fSetProxy;              //!< set for Proxy objects

      static xmap_t fContextMap;            //!< map of contexts
  };
  
} // end namespace Retro

//#include "RtclContext.ipp"

#endif
