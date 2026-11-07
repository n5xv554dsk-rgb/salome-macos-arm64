// Copyright (C) 2019-2026 EDF
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
#ifndef YDEFX_SAMPLE_H
#define YDEFX_SAMPLE_H

#include <vector>
#include <string>
#include <list>
#include <map>

namespace ydefx
{

template <class T>
class VariablesGroup
{
public:
  VariablesGroup();
  VariablesGroup( const T& defaultValue);
  std::list<std::string> names()const;
  bool isSet(const std::string& name, std::size_t index)const;
  /*! Get the values for a variable name.
   *  Pay attention to default values. Use isSet function in order to know
   *  if the value has been set.
   */
  const std::vector<T>& get(const std::string& name)const;
  const T& get(const std::string& name, std::size_t index)const;
  void set(const std::string& name, const std::vector<T>& values);
  void set(const std::string& name, std::size_t index, const T& value);
  void clear(); //! names and values are cleared.
  void clearValues(); //! values are cleared, but names are kept.
  void resetNames(const std::list<std::string>& names);
  void removeName(const std::string& name);
  void addName(const std::string& name);
  void unset(const std::string& name, std::size_t index);
  bool isPointSet(std::size_t index)const; //! every variable is set
  void setDefault(const T& defaultValue) {_defaultValue = defaultValue;}
  std::size_t maxSize()const;
private:
  std::map<std::string, std::vector<T> > _variables;
  std::map<std::string, std::vector<bool> > _status;
  T _defaultValue;
};

enum class ExecutionState {NOTEXECUTED, DONE, ERROR};

template <class T>
class OneTypeSample
{
public:
  const VariablesGroup<T>& inputs()const;
  VariablesGroup<T>& inputs();
  const VariablesGroup<T>& outputs()const;
  VariablesGroup<T>& outputs();
protected:
  bool isPointSet(int index);
  void unset(const std::string& name, std::size_t index);
private:
  VariablesGroup<T> _inputs;
  VariablesGroup<T> _outputs;
};

template <class... Ts> class Sample;

// no type sample
template <>
class Sample<>
{
public:
  const std::vector<std::string>& errors()const{return _errors;}
  std::vector<std::string>& errors(){return _errors;}
  void clearErrors(){_errors.clear();}
  void setError(std::size_t index, const std::string& message)
  {
    if(index >= _errors.size())
      _errors.resize(index+1);
    _errors[index] = message;
  }
  
  std::string getError(std::size_t index)const
  {
    std::string result("");
    if(index < _errors.size())
      result = _errors[index];
    return result;
  }

  virtual ExecutionState pointState(int index)
  {
    ExecutionState result = ExecutionState::DONE;
    if(index < _errors.size())
      if(!_errors[index].empty())
        result = ExecutionState::ERROR;
    return result;
  }
  virtual void clear(){_errors.clear();}
  virtual void clearInputValues(){}
  virtual void clearOutputValues(){_errors.clear();}

  virtual std::list<std::string> allInputNames()const
  {return std::list<std::string>();}

  virtual std::list<std::string> allOutputNames()const
  {return std::list<std::string>();}

  virtual void unset(const std::string& name, std::size_t index){}
  virtual std::size_t maxSize()const {return 0;}
  
private:
  std::vector<std::string> _errors;
};

// multi type sample
template <class T, class... Ts>
class Sample<T, Ts...> : public OneTypeSample<T>, public Sample<Ts...>
{
public:
  virtual ExecutionState pointState(int index);
  virtual void clear(); //! names and values are cleared.
  virtual void clearInputValues(); //! values are cleared, but names are kept.
  virtual void clearOutputValues(); //! values are cleared, but names are kept.
  virtual std::list<std::string> allInputNames()const;
  virtual std::list<std::string> allOutputNames()const;
  virtual void unset(const std::string& name, std::size_t index);
  virtual std::size_t maxSize()const; //! outputs ignored!

  template <class NT>
  const VariablesGroup<NT>& inputs()const
  {return OneTypeSample<NT>::inputs();}

  template <class NT>
  VariablesGroup<NT>& inputs()
  {return OneTypeSample<NT>::inputs();}

  template <class NT>
  const VariablesGroup<NT>& outputs()const
  {return OneTypeSample<NT>::outputs();}

  template <class NT>
  VariablesGroup<NT>& outputs()
  {return OneTypeSample<NT>::outputs();}

};

// Sample<T, Ts...>
template <class T, class... Ts>
ExecutionState Sample<T, Ts...>::pointState(int index)
{
  ExecutionState result = Sample<Ts...>::pointState(index);
  if(result == ExecutionState::DONE)
    if(!OneTypeSample<T>::isPointSet(index))
      result = ExecutionState::NOTEXECUTED;
  return result;
}

template <class T, class... Ts>
void Sample<T, Ts...>::clear()
{
  OneTypeSample<T>::inputs().clear();
  OneTypeSample<T>::outputs().clear();
  Sample<Ts...>::clear();
}

template <class T, class... Ts>
void Sample<T, Ts...>::clearInputValues()
{
  OneTypeSample<T>::inputs().clearValues();
  Sample<Ts...>::clearInputValues();
}

template <class T, class... Ts>
void Sample<T, Ts...>::clearOutputValues()
{
  OneTypeSample<T>::outputs().clearValues();
  Sample<Ts...>::clearOutputValues();
}

template <class T, class... Ts>
std::list<std::string> Sample<T, Ts...>::allInputNames()const
{
  std::list<std::string> result = OneTypeSample<T>::inputs().names();
  result.splice(result.end(), Sample<Ts...>::allInputNames());
  return result;
}

template <class T, class... Ts>
std::list<std::string> Sample<T, Ts...>::allOutputNames()const
{
  std::list<std::string> result = OneTypeSample<T>::outputs().names();
  result.splice(result.end(),Sample<Ts...>::allOutputNames());
  return result;
}

template <class T, class... Ts>
void Sample<T, Ts...>::unset(const std::string& name, std::size_t index)
{
  OneTypeSample<T>::unset(name, index);
  Sample<Ts...>::unset(name, index);
}

template <class T, class... Ts>
std::size_t Sample<T, Ts...>::maxSize()const
{
  std::size_t result=OneTypeSample<T>::inputs().maxSize();
  std::size_t superR=Sample<Ts...>::maxSize();
  if(superR > result)
    result = superR;
  return result;
}

// VariablesGroup

template <class T>
VariablesGroup<T>::VariablesGroup( )
: _variables()
, _status()
, _defaultValue(T())
{
}

template <class T>
VariablesGroup<T>::VariablesGroup( const T& defaultValue)
: _variables()
, _status()
, _defaultValue(defaultValue)
{
}

template <class T>
std::list<std::string> VariablesGroup<T>::names()const
{
  std::list<std::string> result;
  for(const auto& it : _variables)
    result.push_back(it.first);
  return result;
}

template <class T>
bool VariablesGroup<T>::isSet(const std::string& name, std::size_t index)const
{
  bool result = false;
  auto it = _status.find(name);
  if(it != _status.end())
    if(index < it->second.size())
      result = it->second[index];
  return result;
}

template <class T>
bool VariablesGroup<T>::isPointSet(std::size_t index)const
{
  bool allSet = true;
  std::map<std::string, std::vector<bool> >::const_iterator it;
  for( it = _status.begin(); it != _status.end() && allSet; it++)
    allSet = index < it->second.size() && it->second[index];
  return allSet;
}

template <class T>
std::size_t VariablesGroup<T>::maxSize()const
{
  std::size_t result = 0;
  for(const auto& it : _variables)
    if(result < it.second.size())
      result = it.second.size();
  return result;
}

template <class T>
const std::vector<T>& VariablesGroup<T>::get(const std::string& name)const
{
  static const std::vector<T> emptyVector;
  auto it = _variables.find(name);
  if(it != _variables.end())
    return it->second;
  else
    return emptyVector;
}

template <class T>
const T& VariablesGroup<T>::get(const std::string& name, std::size_t index)const
{
  auto it = _variables.find(name);
  if(it != _variables.end())
    if(index < it->second.size())
      return it->second[index];
  return _defaultValue;
}

template <class T>
void VariablesGroup<T>::set(const std::string& name, const std::vector<T>& values)
{
  _variables[name] = values;
  std::vector<bool>& status = _status[name];
  status.clear();
  status.insert(status.begin(), values.size(), true);
}

template <class T>
void VariablesGroup<T>::set(const std::string& name, std::size_t index, const T& value)
{
  std::vector<T>& values = _variables[name];
  std::vector<bool>& status = _status[name];
  if(index >= values.size())
  {
    values.resize(index+1, _defaultValue);
    status.resize(index+1, false);
  }
  values[index] = value;
  status[index] = true;
}

template <class T>
void VariablesGroup<T>::clear()
{
  _variables.clear();
  _status.clear();
}

template <class T>
void VariablesGroup<T>::clearValues()
{
  for(auto& it : _variables)
  {
    it.second.clear();
  }
  for(auto& it : _status)
  {
    it.second.clear();
  }
}

template <class T>
void VariablesGroup<T>::resetNames(const std::list<std::string>& names)
{
  clear();
  for(const auto& it : names)
  {
    _variables[it].clear();
    _status[it].clear();
  }
}

template <class T>
void VariablesGroup<T>::removeName(const std::string& name)
{
  _variables.erase(name);
  _status.erase(name);
}

template <class T>
void VariablesGroup<T>::addName(const std::string& name)
{
  _variables[name];
  _status[name];
}

template <class T>
void VariablesGroup<T>::unset(const std::string& name, std::size_t index)
{
  auto it = _status.find(name);
  if(it != _status.end())
    if(index < it->second.size())
    {
      it->second[index] = false;
      if(index+1 == it->second.size())
      {
        // remove all the unset values at the end of the list
        while(index>0 && !it->second[index])
          --index;
        it->second.resize(index);
        _variables[name].resize(index);
      }
    }
}
  
// OneTypeSample
template <class T>
const VariablesGroup<T>& OneTypeSample<T>::inputs()const
{
  return _inputs;
}

template <class T>
VariablesGroup<T>& OneTypeSample<T>::inputs()
{
  return _inputs;
}

template <class T>
const VariablesGroup<T>& OneTypeSample<T>::outputs()const
{
  return _outputs;
}

template <class T>
VariablesGroup<T>& OneTypeSample<T>::outputs()
{
  return _outputs;
}

template <class T>
bool OneTypeSample<T>::isPointSet(int index)
{
  return _inputs.isPointSet(index) && _outputs.isPointSet(index);
}

template <class T>
void OneTypeSample<T>::unset(const std::string& name, std::size_t index)
{
  _outputs.unset(name, index);
}

}//namespace ydefx
#endif // YDEFX_SAMPLE_H
