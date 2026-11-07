// Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
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
/*
 *  SimpleParser.cpp
 *
 *  Created on: 23 juil. 2009
 *  Author: Renaud BARATE - EDF R&D
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>

#include <Test_config.h>

#include "SimpleParser.hxx"

using namespace std;


ParserException::ParserException(string msg) noexcept
  : exception(),
    _msg(msg)
{
}

ParserException::~ParserException() noexcept
{
}

const char * ParserException::what() const noexcept
{
  return _msg.c_str();
}


SimpleParser::SimpleParser() noexcept
{
}

SimpleParser::~SimpleParser() noexcept
{
}

std::string SimpleParser::trim(const std::string & str) const noexcept
{
  size_t beg = str.find_first_not_of(" \t");
  if (beg == string::npos) beg = 0;
  size_t end = str.find_last_not_of(" \t");
  return str.substr(beg, end-beg+1);
}

void SimpleParser::parse(const string & filename)
{
  ifstream fileStream(filename.c_str());
  if (!fileStream) {
    throw ParserException(string("Can't open file ") + filename);
  }
  string line;
  int lineNumber = 1;
  while (getline(fileStream, line)) {
    string str = line;
    // Strip comments
    size_t pos = str.find_first_of('#');
    if (pos != string::npos) {
      str = str.substr(0, pos);
    }
    // Strip leading and trailing spaces
    str = trim(str);
    if (!str.empty()) {
      // Find '=' symbol and split the line
      pos = str.find_first_of('=');
      if (pos == string::npos) {
        stringstream msg;
        msg << "Syntax error (missing =) on line " << lineNumber << ": " << line;
        throw ParserException(msg.str());
      } else {
        string key = trim(str.substr(0, pos));
        string value = trim(str.substr(pos+1));
        // Eventually remove '"' symbols at the beginning and at the end of the string
        if (value.size()>1 && value[0] == '"' && value[value.size()-1] == '"') {
          value = value.substr(1, value.size()-2);
        }
        _configmap[key] = value;
      }
    }
    ++lineNumber;
  }
  fileStream.close();
}

void SimpleParser::parseTestConfigFile()
{
  char * filename = getenv(TEST_CONFIG_FILE_ENV_VAR);
  if (filename == NULL) {
    throw ParserException(string("Environment variable ") + TEST_CONFIG_FILE_ENV_VAR + " is not declared.");
  } else {
    parse(filename);
  }
}

const string & SimpleParser::getValue(const string & key) const
{
  map<string,string>::const_iterator iter = _configmap.find(key);
  if (iter == _configmap.end()) {
    throw ParserException(string("No value found for key ") + key + ".");
  }
  return iter->second;
}

const string & SimpleParser::getTestValue(const string & bmType, const string & protocolStr,
                                          const string & key) const
{
  string fullkey = string("TEST_") + bmType + "_" + protocolStr + "_" + key;
  try {
    return getValue(fullkey);
  } catch (const ParserException &) {}
  fullkey = string("TEST_") + bmType + "_" + key;
  try {
    return getValue(fullkey);
  } catch (const ParserException &) {}
  fullkey = string("TEST_") + key;
  return getValue(fullkey);
}

int SimpleParser::getValueAsInt(const string & key) const
{
  const string & valueStr = getValue(key);
  const char * valueCStr = valueStr.c_str();
  char * end = NULL;
  int res = strtol(valueCStr, &end, 0);
  if (*valueCStr == '\0' || *end != '\0') {
    throw ParserException(string("Invalid value (not integer) for key ") + key + ".");
  }
  return res;
}

int SimpleParser::getTestValueAsInt(const string & bmType, const string & protocolStr,
                                    const string & key) const
{
  string fullkey = string("TEST_") + bmType + "_" + protocolStr + "_" + key;
  try {
    return getValueAsInt(fullkey);
  } catch (const ParserException &) {}
  fullkey = string("TEST_") + bmType + "_" + key;
  try {
    return getValueAsInt(fullkey);
  } catch (const ParserException &) {}
  fullkey = string("TEST_") + key;
  return getValueAsInt(fullkey);
}

ostream & operator <<(ostream & os, const SimpleParser & parser) noexcept
{
  if (parser._configmap.empty()) {
    os << "Empty map" << endl;
  } else {
    map<string,string>::const_iterator iter;
    for (iter = parser._configmap.begin() ; iter != parser._configmap.end() ; ++iter) {
      os << iter->first << " = " << iter->second << endl;
    }
  }
  return os;
}
