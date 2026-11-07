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

//  HELLOGUI : HELLO component GUI implemetation

#ifndef _HELLOGUI_H_
#define _HELLOGUI_H_


#ifdef WIN32
# if defined HELLO_EXPORTS || defined Hello_EXPORTS
#  define HELLO_EXPORT __declspec( dllexport )
# else
#  define HELLO_EXPORT __declspec( dllimport )
# endif
#else
# define HELLO_EXPORT
#endif

#include <SalomeApp_Module.h>

#include <SALOMEconfig.h>
#include CORBA_CLIENT_HEADER(HELLO_Gen)

class SalomeApp_Application;

class HELLO_EXPORT HELLOGUI: public SalomeApp_Module
{
  Q_OBJECT

  //! operations
  enum { 
    OpTestMe  = 190,   //!< Test me
    OpHello   = 901,   //!< Hello
    OpGoodbye = 902,   //!< Goodbye
  };

public:
  HELLOGUI();
  ~HELLOGUI();

  static HELLO_ORB::HELLO_Gen_var engine();

  virtual void                    initialize( CAM_Application* app );
  virtual QString                 engineIOR() const;

  virtual QPixmap                 moduleIcon() const;
  virtual QString                 iconName() const;

  virtual void                    windows( QMap<int, int>& theMap ) const;
  virtual void                    viewManagers( QStringList& theList ) const;

  virtual LightApp_Selection*     createSelection() const;
  virtual LightApp_Displayer*     displayer();

  virtual void                    contextMenuPopup( const QString& type, QMenu* menu, QString& title );

  virtual void                    createPreferences();
  virtual void                    preferencesChanged( const QString& section, const QString& parameter );

  virtual void                    storeVisualParameters( int savePoint );
  virtual void                    restoreVisualParameters( int savePoint );

  virtual void                    studyActivated();

  virtual bool                    canCopy() const;
  virtual bool                    canPaste() const;
  virtual void                    copy();
  virtual void                    paste();

  virtual bool                    isDraggable( const SUIT_DataObject* what ) const;
  virtual bool                    isDropAccepted( const SUIT_DataObject* where ) const;
  virtual void                    dropObjects( const DataObjectList& what, SUIT_DataObject* where,
					       const int row, Qt::DropAction action );

public slots:
  virtual bool                    activateModule( SUIT_Study* theStudy );
  virtual bool                    deactivateModule( SUIT_Study* theStudy );

protected:
  virtual LightApp_Operation*     createOperation( const int id ) const;

protected slots:
  void                            testMe();
  void                            hello();
  void                            goodbye();

private:
  static void                     init();

private:
  static HELLO_ORB::HELLO_Gen_var myEngine;
};

#endif // _HELLOGUI_H_
