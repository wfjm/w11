// $Id: RosFill.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2000-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-01-30   359   1.0    Adopted from CTBosFill
// 2000-02-06     -   -      Last change on CTBosFill
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RosFill.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor.
/*!
  The fill character is specified with \a fill, the repeat count is
  specified with \a count. Note, that RosFill does not have a default
  constructor and that this constructor is the only means to set this object up.
  Note also, that the \a fill argument can be omitted, the default fill
  character is a blank.
*/
inline RosFill::RosFill(int count, char fill)
  : fCount(count),
    fFill(fill)
{}

//------------------------------------------+-----------------------------------
//! Get repeat count.

inline int RosFill::Count() const
{
  return fCount;
}

//------------------------------------------+-----------------------------------
//! Get fill character.

inline char RosFill::Fill() const
{
  return fFill;
}

} // end namespace Retro
