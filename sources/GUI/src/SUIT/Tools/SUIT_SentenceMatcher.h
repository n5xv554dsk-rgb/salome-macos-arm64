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

#ifndef SUIT_SENTENCEMATCHER_H
#define SUIT_SENTENCEMATCHER_H

#include "../SUIT.h"

#include <QString>
#include <QStringList>


namespace SUIT_tools {
   /*! \class SUIT_SentenceMatcher
   \brief Approximate string matcher, treats strings as sentences composed of words. */
   class SUIT_EXPORT SUIT_SentenceMatcher
   {
   public:
   /*! Default config:
      Exact word order = false;
      Fuzzy words = true;
      Case sensitive = false;
      Query = ""; // matches nothing.
   */
   SUIT_SentenceMatcher();

   void setUseExactWordOrder(bool theOn);
   void setUseFuzzyWords(bool theOn);
   void setCaseSensitive(bool theOn);
   inline bool isCaseSensitive() const { return myIsCaseSensitive; };

   /*! \param theQuery should not be regex. */
   void setQuery(QString theQuery);

   inline const QString& getQuery() const { return myQuery; };

   /*! \returns match metrics. The metrics >= 0. INF means mismatch.
   The class is unable to differentiate exact match with some approximate matches! */
   double match(const QString& theInputString) const;

   /** \brief For debug. */
   QString toString() const;

   private:
   static bool makePermutatedSentences(const QStringList& theWords, QList<QStringList>& theSentences);
   static void makeFuzzyWords(const QStringList& theWords, QStringList& theFuzzyWords);

   /*! \returns number of characters in matched words. The number >= 0. */
   static int matchWithSentenceIgnoreEndings(const QString& theInputString, const QStringList& theSentence, bool theCaseSensitive);
   /*! \returns number of characters in matched words. The number >= 0. */
   static int matchWithSentencesIgnoreEndings(const QString& theInputString, const QList<QStringList>& theSentences, bool theCaseSensitive);

   /*! \returns number of characters in matched words. The number >= 0. */
   static int matchAtLeastOneWord(const QString& theInputString, const QStringList& theWords, bool theCaseSensitive);

   /*! \returns number of characters in matched words. The number >= 0. */
   static int match(
      const QString& theInputString,
      const QStringList& theSentence,
      bool theCaseSensitive
   );

   /*! \returns number of characters in matched words. The number >= 0. */
   static int match(
      const QString& theInputString,
      const QList<QStringList>& theSentences,
      bool theCaseSensitive
   );

   bool myUseExactWordOrder; // If false, try to match with sentences, composed of query's words in different orders.
   bool myUseFuzzyWords; // Try to match with sentences, composed of query's truncated words.
   bool myIsCaseSensitive;
   QString myQuery;

   QStringList myWords; // It is also original search sentence.
   QList<QStringList> myPermutatedSentences;

   QStringList myFuzzyWords; // Regexes.
   QList<QStringList> myFuzzyPermutatedSentences;
   };

} //namespace SUIT_tools

#endif //SUIT_SENTENCEMATCHER_H