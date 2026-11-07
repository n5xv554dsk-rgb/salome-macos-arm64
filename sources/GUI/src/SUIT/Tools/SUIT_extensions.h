// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
//
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//

#ifndef SUIT_TOOLS_EXTENSIONS_H
#define SUIT_TOOLS_EXTENSIONS_H

#include "../SUIT.h"
#include <cstddef>
#include <limits>
#include <string>
#include <QString>


namespace SUIT_tools {

   /*! \brief Compensates lack of std::distance(..) prior to C++17.
   Does not check whether the iterators iterate the same container instance.*/
   template <class Iterator>
   SUIT_EXPORT std::size_t distance(
      const Iterator& theStartIt,
      const Iterator& theFinalIt
   ) {
      auto it = theStartIt;
      std::size_t distance = 0;
      while (distance <= std::numeric_limits<typename std::iterator_traits<Iterator>::difference_type>::max()) {
         if (it == theFinalIt)
            return distance;

         it++;
         distance++;
      }
      return distance;
   }

   /*! \returns Distance from the theContainer.begin() to theIt.
   \returns Inf, if theIt is not iterator of theContainer. */
   template <class Container>
   SUIT_EXPORT std::size_t distanceFromBegin(
      const Container& theContainer,
      const typename Container::const_iterator& theIt
   ) {
      auto it = theContainer.begin();
      std::size_t distance = 0;
      while (it != theContainer.end()) {
         if (it == theIt)
            return distance;

         it++;
         distance++;
      }
      return std::numeric_limits<std::size_t>::infinity();
   }

   /*! \brief Replaces all Bash-style variables (enlosed with "${" and "}") with values of corresponding environment variables. */
   SUIT_EXPORT QString substituteBashVars(const QString& theString);

   /*! \brief Replaces all DOS-style variables (enlosed with "%") with values of corresponding environment variables. */
   SUIT_EXPORT QString substituteDOSVars(const QString& theString);

   /*! \brief Replaces all Bash- and DOS- style variables with values of corresponding environment variables. */
   SUIT_EXPORT QString substituteVars(const QString& theString);

   SUIT_EXPORT std::wstring to_wstring(const std::string& theStdString);

} //namespace SUIT_tools

#endif //SUIT_TOOLS_EXTENSIONS_H

