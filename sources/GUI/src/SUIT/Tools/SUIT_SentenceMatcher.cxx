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

#include "SUIT_SentenceMatcher.h"
#include <limits>


namespace SUIT_tools {

SUIT_SentenceMatcher::SUIT_SentenceMatcher()
{
  myUseExactWordOrder = false;
  myUseFuzzyWords = true;
  myIsCaseSensitive = false;
}

void SUIT_SentenceMatcher::setUseExactWordOrder(bool theOn)
{
  if (myUseExactWordOrder == theOn)
    return;

  myUseExactWordOrder = theOn;
  if (theOn) {
    myPermutatedSentences.clear();
    myFuzzyPermutatedSentences.clear();
    return;
  }

  if (myPermutatedSentences.isEmpty())
    SUIT_SentenceMatcher::makePermutatedSentences(myWords, myPermutatedSentences);

  if (myUseFuzzyWords && myFuzzyPermutatedSentences.isEmpty())
    SUIT_SentenceMatcher::makePermutatedSentences(myFuzzyWords, myFuzzyPermutatedSentences);
}

void SUIT_SentenceMatcher::setUseFuzzyWords(bool theOn)
{
  if (myUseFuzzyWords == theOn)
    return;

  myUseFuzzyWords = theOn;
  if (myWords.isEmpty() || !theOn) {
    myFuzzyWords.clear();
    myFuzzyPermutatedSentences.clear();
    return;
  }

  myFuzzyWords.clear();
  SUIT_SentenceMatcher::makeFuzzyWords(myWords, myFuzzyWords);

  if (!myUseExactWordOrder) {
    myFuzzyPermutatedSentences.clear();
    SUIT_SentenceMatcher::makePermutatedSentences(myFuzzyWords, myFuzzyPermutatedSentences);
  }
}

void SUIT_SentenceMatcher::setCaseSensitive(bool theOn)
{
  myIsCaseSensitive = theOn;
}

void SUIT_SentenceMatcher::setQuery(QString theQuery)
{
  theQuery = theQuery.simplified();
  if (theQuery == myQuery)
    return;

  myQuery = theQuery;
  myWords = theQuery.split(" ", QString::SkipEmptyParts);

  { // Set permutated sentences.
    myPermutatedSentences.clear();
    if (!myUseExactWordOrder)
      SUIT_SentenceMatcher::makePermutatedSentences(myWords, myPermutatedSentences);
  }

  // Set fuzzy words and sentences.
  myFuzzyWords.clear();
  myFuzzyPermutatedSentences.clear();

  if (myUseFuzzyWords) {
    SUIT_SentenceMatcher::makeFuzzyWords(myWords, myFuzzyWords);
    if (!myUseExactWordOrder)
      SUIT_SentenceMatcher::makePermutatedSentences(myFuzzyWords, myFuzzyPermutatedSentences);
  }
}

double SUIT_SentenceMatcher::match(const QString& theInputString) const
{
  int n = 0;
  if (myUseExactWordOrder) {
    n = SUIT_SentenceMatcher::match(theInputString, myWords, myIsCaseSensitive);
    if (n != theInputString.length() && myUseFuzzyWords) {
      const int nFuzzy = SUIT_SentenceMatcher::match(theInputString, myFuzzyWords, myIsCaseSensitive);
      if (nFuzzy > n)
        n = nFuzzy;
    }
  }
  else /* if match with permutated query sentences */ {
    n = SUIT_SentenceMatcher::match(theInputString, myPermutatedSentences, myIsCaseSensitive);
    if (n != theInputString.length() && myUseFuzzyWords) {
      const int nFuzzy = SUIT_SentenceMatcher::match(theInputString, myFuzzyPermutatedSentences, myIsCaseSensitive);
      if (nFuzzy > n)
        n = nFuzzy;
    }
  }

  if (n <= 0)
    return std::numeric_limits<double>::infinity();

  const auto strLength = theInputString.length() > myQuery.length() ? theInputString.length() : myQuery.length();

  if (n > strLength)
    return 0; // Exact match or almost exact.

  return double(strLength - n);
}

QString SUIT_SentenceMatcher::toString() const
{
  QString res = QString("myUseExactWordOrder: ") + (myUseExactWordOrder ? "true" : "false") + ";\n";
  res += QString("myUseFuzzyWords: ") + (myUseFuzzyWords ? "true" : "false") + ";\n";
  res += QString("myIsCaseSensitive: ") + (myIsCaseSensitive ? "true" : "false") + ";\n";
  res += QString("myQuery: ") + myQuery + ";\n";
  res += QString("myWords: ") + myWords.join(", ") + ";\n";
  res += QString("myFuzzyWords: ") + myFuzzyWords.join(", ") + ";\n";

  res += "myPermutatedSentences:\n";
  for (const auto& sentence : myPermutatedSentences) {
    res += "\t" + sentence.join(", ") + ";\n";
  }

  res += "myFuzzyPermutatedSentences:\n";
  for (const auto& sentence : myFuzzyPermutatedSentences) {
    res += "\t" + sentence.join(", ") + ";\n";
  }

  res += ".";
  return res;
}

/*static*/ bool SUIT_SentenceMatcher::makePermutatedSentences(const QStringList& theWords, QList<QStringList>& theSentences)
{
  theSentences.clear();
  theSentences.push_back(theWords);
  QStringList nextPerm = theWords;
  QStringList prevPerm = theWords;

  bool hasNextPerm = true;
  bool hasPrevPerm = true;

  while (hasNextPerm || hasPrevPerm) {
    if (hasNextPerm)
      hasNextPerm = std::next_permutation(nextPerm.begin(), nextPerm.end());

    if (hasNextPerm && !theSentences.contains(nextPerm))
      theSentences.push_back(nextPerm);

    if (hasPrevPerm)
      hasPrevPerm = std::prev_permutation(prevPerm.begin(), prevPerm.end());

    if (hasPrevPerm && !theSentences.contains(prevPerm))
      theSentences.push_back(prevPerm);
  }

  return theSentences.size() > 1;
}

/*static*/ void SUIT_SentenceMatcher::makeFuzzyWords(const QStringList& theWords, QStringList& theFuzzyWords)
{
  theFuzzyWords.clear();
  for (const QString& word : theWords) {
    QString fuzzyWord;
    for (int i = 0; i < word.size(); i++) {
      fuzzyWord += word[i];
      fuzzyWord += "\\w*";
    }
    theFuzzyWords.push_back(fuzzyWord);
  }
}

/*static*/ int SUIT_SentenceMatcher::matchWithSentenceIgnoreEndings(const QString& theInputString, const QStringList& theSentence, bool theCaseSensitive)
{
  const QRegExp regExp("^" + theSentence.join("\\w*\\W+"), theCaseSensitive ? Qt::CaseSensitive : Qt::CaseInsensitive);
  regExp.indexIn(theInputString);
  const int matchMetrics = regExp.matchedLength();
  return matchMetrics > 0 ? matchMetrics : 0;
}

/*static*/ int SUIT_SentenceMatcher::matchWithSentencesIgnoreEndings(const QString& theInputString, const QList<QStringList>& theSentences, bool theCaseSensitive)
{
  int res = 0;
  for (const QStringList& sentence : theSentences) {
    const int matchMetrics = SUIT_SentenceMatcher::matchWithSentenceIgnoreEndings(theInputString, sentence, theCaseSensitive);
    if (matchMetrics > res) {
      res = matchMetrics;
      if (res == theInputString.length())
        return res;
    }
  }
  return res;
}

/*static*/ int SUIT_SentenceMatcher::matchAtLeastOneWord(const QString& theInputString, const QStringList& theWords, bool theCaseSensitive)
{
  int res = 0;
  for (const QString& word : theWords) {
    const auto regExp = QRegExp(word, theCaseSensitive ? Qt::CaseSensitive : Qt::CaseInsensitive);
    regExp.indexIn(theInputString);
    const int matchMetrics = regExp.matchedLength();
    // The same input word can be counted multiple times. Nobody cares.
    if (matchMetrics > 0)
      res += matchMetrics;
  }
  return res;
}

/*static*/ int SUIT_SentenceMatcher::match(
  const QString& theInputString,
  const QStringList& theSentence,
  bool theCaseSensitive
) {
  int res = SUIT_SentenceMatcher::matchWithSentenceIgnoreEndings(theInputString, theSentence, theCaseSensitive);
  if (res == theInputString.length())
    return res;

  const int matchMetrics = SUIT_SentenceMatcher::matchAtLeastOneWord(theInputString, theSentence, theCaseSensitive);
  if (matchMetrics > res)
    res = matchMetrics;

  return res;
}

/*static*/ int SUIT_SentenceMatcher::match(
  const QString& theInputString,
  const QList<QStringList>& theSentences,
  bool theCaseSensitive
) {
  int res = SUIT_SentenceMatcher::matchWithSentencesIgnoreEndings(theInputString, theSentences, theCaseSensitive);
  if (res == theInputString.length())
    return res;

  if (theSentences.size() > 0) {
    const int matchMetrics = SUIT_SentenceMatcher::matchAtLeastOneWord(theInputString, theSentences[0], theCaseSensitive);
    if (matchMetrics > res)
      res = matchMetrics;
  }

  return res;
}

} //namespace SUIT_tools