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

#include "SUIT_extensions.h"
#include <QProcessEnvironment>
#include <QRegExp>
#include <Qtx.h>
#include <codecvt>
#include <locale>

namespace SUIT_tools {

QString substituteBashVars(const QString& theString)
{
  QString res = theString;
  const auto env = QProcessEnvironment::systemEnvironment();
  int pos = 0;
  QRegExp rx("\\$\\{([^\\}]+)\\}"); // Match substrings enclosed with "${" and "}".
  rx.setMinimal(true); // Set search to non-greedy.
  while((pos = rx.indexIn(res, pos)) != -1) {
    QString capture = rx.cap(1);
    QString subst = env.value(capture);
    res.replace("${" + capture + "}", subst);
    pos += rx.matchedLength();
  }
  return res;
}

QString substituteDOSVars(const QString& theString)
{
  QString res = theString;
  int pos = 0;
  QRegExp rx("%([^%]+)%"); // Match substrings enclosed with "%".
  rx.setMinimal(true); // Set search to non-greedy.
  while((pos = rx.indexIn(res, pos)) != -1) {
    QString capture = rx.cap(1);
    QString subst = Qtx::getenv(capture.toUtf8().constData());
    res.replace("%" + capture + "%", subst);
    pos += rx.matchedLength();
  }
  return res;
}

QString substituteVars(const QString& theString)
{
  QString str = substituteBashVars(theString);
  return substituteDOSVars(str);
}

std::wstring to_wstring(const std::string& theStdString)
{
  std::wstring wideString = std::wstring_convert<std::codecvt_utf8<wchar_t>>().from_bytes(theStdString);
  return wideString;
}

} //namespace SUIT_tools
