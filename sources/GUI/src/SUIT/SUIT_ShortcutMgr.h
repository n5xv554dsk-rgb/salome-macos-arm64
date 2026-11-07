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

#ifndef SUIT_SHORTCUTMGR_H
#define SUIT_SHORTCUTMGR_H

#include "SUIT.h"

#include <QObject>
#include <QString>
#include <QKeySequence>
#include <QStringList>
#include <QIcon>
#include <map>
#include <set>
#include <memory>
#include <utility>
#include <limits>
#include <functional>

class QAction;
class QtxAction;
class QJsonObject;

#if defined WIN32
#pragma warning( disable: 4251 )
#endif

// Define SHORTCUT_MGR_DBG to enable SUIT_ShortcutMgr debug logging.
// #define SHORTCUT_MGR_DBG
/*! \returns true, if SUIT_ShortcutMgr debug logging is enabled. */
SUIT_EXPORT extern inline bool ShCutDbg() {
#ifdef SHORTCUT_MGR_DBG
  return true;
#else
  return false;
#endif
}
/*! \brief Prints theString to std::wcout, if SUIT_ShortcutMgr debug logging is enabled. */
SUIT_EXPORT extern bool ShCutDbg(const QString& theString);
/*! \brief Prints theString to std::wcout, if SUIT_ShortcutMgr debug logging is enabled. */
SUIT_EXPORT extern bool ShCutDbg(const char* theString);


/*!
  \class SUIT_ShortcutContainer
  \brief Provides means to keep and edit shortcuts in compliance with the application logics.
  \ref See SUIT_ShortcutMgr for details.
*/
class SUIT_EXPORT SUIT_ShortcutContainer
{
public:
  SUIT_ShortcutContainer();

  /*! \returns IDs of modules, which interfere with the module:
  if the module is root (theModuleID is empty) - returns all module IDs, otherwise returns ["", theModuleID]. */
  std::set<QString> getIDsOfInterferingModules(const QString& theModuleID) const;

  std::set<QString> getIDsOfAllModules() const;

  /*! \returns True, if no shortcut is added. */
  bool isEmpty() const;

  /*! \brief Checks for conflicts. If theOverride, modifies incoming and disables all conflicting shortcuts.
  Redefining a key sequence for the action, if theKeySequence does not conflict with other shortcuts, is not considered as a conflict.
  \param theModuleID The method has no effect if theModuleID is invalid. \ref See SUIT_ShortcutMgr::isModuleIDValid(const QString&) for details.
  \param theInModuleActionID The method has no effect if theInModuleActionID is invalid. \ref See SUIT_ShortcutMgr::isInModuleActionIDValid(const QString&).
  If theInModuleActionID is meta-action ID, the shortcut is set to root module, and theModuleID is ignored.
  \param theKeySequence Empty theKeySequence does not cause conflicts, in this case
  a shortcut for the action is disabled: theInModuleActionID is added/retained in the container but mapped to empty key sequence.
  \param theOverride If true, conflicting shortcuts are disabled.
  \returns {moduleID, inModuleActionID}[] - Set of conflicting actions if theOverride = false,
  otherwise set of actions (without incoming one), whose shortcuts have been disabled. */
  std::set<std::pair<QString, QString>> setShortcut(
    QString theModuleID,
    const QString& theInModuleActionID,
    const QKeySequence& theKeySequence,
    bool theOverride
  );

  /*! \brief Checks for conflicts. Existence of a shortcut with another key sequence for the action,
  if theKeySequence does not conflict with other shortcuts, is not considered as a conflict.
  \param theInModuleActionID If theInModuleActionID is meta-action ID, the shortcut is looked for in root module, and theModuleID is ignored.
  \param theKeySequence Empty theKeySequence does not have conflicts.
  \returns {moduleID, inModuleActionID}[] - Set of conflicting actions. */
  std::set<std::pair<QString, QString>> getConflicts(
    QString theModuleID,
    const QString& theInModuleActionID,
    const QKeySequence& theKeySequence
  ) const;

  /*! \returns empty key sequence if shortcut for the action is not set.
  \param theInModuleActionID If theInModuleActionID is meta-action ID, seeks in root module, and theModuleID is ignored.*/
  const QKeySequence& getKeySequence(QString theModuleID, const QString& theInModuleActionID) const;

  /*! \returns true, if shortcut for the action is set (even if the mapped key sequence is empty).
   \param theInModuleActionID If theInModuleActionID is meta-action ID, seeks in root module, and theModuleID is ignored.*/
  bool hasShortcut(QString theModuleID, const QString& theInModuleActionID) const;

  /*! \returns {inModuleActionID, keySequence}[] - If the module was not added, the map is empty. */
  const std::map<QString, QKeySequence>& getModuleShortcutsInversed(const QString& theModuleID) const;

  /*! \brief Seeks for shortcuts in the module with in-module action IDs, which start with theInModuleActionIDPrefix.
  \returns {inModuleActionID, keySequence}[] - If the module was not added, the map is empty. */
  const std::map<QString, QKeySequence> getModuleShortcutsInversed(const QString& theModuleID, const QString& theInModuleActionIDPrefix) const;

  /*! \brief Merges shortcuts of theOther into this.
  \param theOverride if true, overrides conflicting shortcuts.
  If false, and this has no shortcut for an incoming action, and the incoming shortcut conflicts
  with an existing shortcut, disabled shortcut for the incoming action is set.
  \param theTreatAbsentIncomingAsDisabled If theOverride == false, theTreatAbsentIncomingAsDisabled is ignored.
  If theOverride and theTreatAbsentIncomingAsDisabled, and theOther has no shortcut for an action, which exists in this,
  the existing shortcut in this is set disabled.
    \returns { moduleID, { inModuleActionID, {oldKeySequence, newKeySequence} }[] }[] - Modiified shortcuts inversed. */
  std::map<QString, std::map<QString, std::pair<QKeySequence, QKeySequence>>> merge(
    const SUIT_ShortcutContainer& theOther,
    bool theOverride,
    bool theTreatAbsentIncomingAsDisabled = false
  );

  bool hasKeySequence(const QString& theModuleID, const QKeySequence& theKeySequence) const;

  /*! \brief Generates human-readable text representation of content. */
  QString toString() const;

private:
  /** { moduleID, { keySequence, inModuleActionID }[] }[]. keySequence can not be empty.
   * Can not contain entries like { <non-root module ID>, { keySequence, <meta-action ID> } }. */
  std::map<QString, std::map<QKeySequence, QString>> myShortcuts;

  /** { moduleID, { inModuleActionID, keySequence }[] }[]. keySequence can be empty.
   * Can not contain entries like { <non-root module ID>, { <meta-action ID>, keySequence } }. */
  std::map<QString, std::map<QString, QKeySequence>> myShortcutsInversed;
};


class SUIT_ShortcutItemAssets;


/*! \brief Base class for GUI-related assets of module, action or folder. Used by Shortcut Manager, Find Action Dialog, etc. */
class SUIT_EXPORT SUIT_ShortcutAssets : public std::enable_shared_from_this<SUIT_ShortcutAssets>
{
public:
  enum class Type
  {
    Module,
    Item // Folder, action or folder-action.
  };


  struct LangDependentAssets
  {
    static const QString PROP_ID_NAME;
    static const QString PROP_ID_TOOLTIP;

    bool fromJSON(const QJsonObject& theJsonObject);
    void toJSON(QJsonObject& oJsonObject) const;

    QString myName;
    QString myToolTip;
  };


  static const QString PROP_ID_LANG_DEPENDENT_ASSETS;
  static const QString PROP_ID_ICON_PATH;
  static const QString PROP_ID_CHILDREN;

protected:
  SUIT_ShortcutAssets(const QString& theModuleID);

public:
  virtual ~SUIT_ShortcutAssets() = 0;

  const std::map<QString, std::shared_ptr<SUIT_ShortcutItemAssets>>& children() const;

  /*!
  \param theRelativeID If empty, nullptr is returned.
  \returns Descdendant item (if exist) with inModuleID = myInModuleID/theRelativeID.
  Module assets effectively have empty myInModuleID. */
  std::shared_ptr<SUIT_ShortcutItemAssets> findDescendantItem(const QString& theRelativeID) const;

  /*!
  \param theRelativeID If empty, nullptr is returned.
  \param theIsAction If true and the descendant is missing, makes the created item action.
  \returns Descdendant item with inModuleID = myInModuleID/theRelativeID.
  If the descendant item does not exist, creates the item and its missing ancestors. All missing ancestors are created as not actions.
  Module assets effectively have empty myInModuleID. */
  std::shared_ptr<SUIT_ShortcutItemAssets> descendantItem(const QString& theRelativeID, bool theIsAction = true);

  virtual int depth() const = 0;
  virtual SUIT_ShortcutAssets::Type type() const = 0;

private:
  /*! \brief Parses everything, except children.
  \param theLangs If empty, LangDependentAssets in all available languages are parsed. */
  bool fromJSONOwnProps(const QJsonObject& theJsonObject, const std::set<QString>& theLangs = {});

public:
  /*!
  \param theLangs If empty, LangDependentAssets in all available languages are parsed.
  \returns true, if any property is parsed. */
  bool fromJSON(const QJsonObject& theJsonObject, bool theParseDescendants = true, const std::set<QString>& theLangs = {});

  /*! \brief Parses only the branch of descdendants, which leads to the item with theRelativeID.
  \param theRelativeID If empty, no descendants are added/updated.
  \param theLangs If empty, LangDependentAssets in all available languages are parsed.
  \returns true, if any property is parsed. */
  bool fromJSON(const QJsonObject& theJsonObject, const QString& theRelativeID, const std::set<QString>& theLangs = {});

  void toJSON(QJsonObject& oJsonObject) const;

  /*! \param theOverride If true, values of theOther override conflicting values of this. */
  virtual void merge(const SUIT_ShortcutAssets& theOther, bool theOverride);

  /*! \param theOverride If true, values of theOther override conflicting values of this. */
  virtual void merge(SUIT_ShortcutAssets&& theOther, bool theOverride);

private:
  /*! \brief Parses properties of SUIT_ShortcutAssets subclasses.
  \returns true, if any property is parsed. */
  virtual bool fromJSONOtherProps(const QJsonObject& theJsonObject) { return false; };

  virtual void toJSONVirtual(QJsonObject& oJsonObject) const {};

public:
  void loadIcon(bool theReload = false);

  /*! \brief Iterates all descendants. *this is not iterated. */
  void forEachDescendant(const std::function<void(SUIT_ShortcutItemAssets&)>& theFunc) const;

  /*! \brief Iterates all descendants. *this is not iterated. */
  void forEachDescendant(const std::function<void(const SUIT_ShortcutItemAssets&)>& theFunc) const;

  /*! \brief Iterates all descendants. *this is not iterated. */
  void forEachDescendant(const std::function<void(std::shared_ptr<SUIT_ShortcutItemAssets>)>& theFunc) const;

  /*! \brief Iterates all descendants. *this is not iterated. */
  void forEachDescendant(const std::function<void(std::shared_ptr<const SUIT_ShortcutItemAssets>)>& theFunc) const;

  QString toString() const;
  virtual QString description() const = 0;

  QStringList getLangs() const;
  void clearAllLangsExcept(const QString& theLang);

  /*!
  \param theLang If empty, current language is requested.
  \returns Requested assets or assets in EN, if requested language is absent. */
  const LangDependentAssets* bestLangDependentAssets(QString theLang = QString()) const;

  virtual const QString& bestName(const QString& theLang = QString()) const = 0;

  /*!
  \param theLang If empty, current language is requested.
  \returns Requested tool tip or tool tip in EN, if requested language is absent. If EN is absent - empty string. */
  virtual const QString& bestToolTip(const QString& theLang = QString()) const;

public:
  const QString myModuleID;

  std::map<QString, LangDependentAssets> myLangDependentAssets;
  QString myIconPath;

  /*! Not serialized. */
  QIcon myIcon;

private:
  // { IDLastToken, assets }.
  std::map<QString, std::shared_ptr<SUIT_ShortcutItemAssets>> myChildren;
};


/*! \brief GUI-related module assets.*/
class SUIT_EXPORT SUIT_ShortcutModuleAssets : public SUIT_ShortcutAssets
{
private:
  SUIT_ShortcutModuleAssets(const QString& theModuleID);
  SUIT_ShortcutModuleAssets(const SUIT_ShortcutModuleAssets&) = delete;
  SUIT_ShortcutModuleAssets& operator= (const SUIT_ShortcutModuleAssets&) = delete;

public:
  static std::shared_ptr<SUIT_ShortcutModuleAssets> create(const QString& theModuleID);
  ~SUIT_ShortcutModuleAssets() = default;

  int depth() const { return 0; };
  SUIT_ShortcutAssets::Type type() const { return SUIT_ShortcutAssets::Type::Module; };

  /*!
  \param theLang If empty, current language is requested.
  \returns Requested name or name in EN, if requested language is absent. If EN is absent - moduleID. */
  const QString& bestName(const QString& theLang = QString()) const;

  QString description() const;
};


/*! \brief May represent not just an action, but also a folder within item tree of a module.
May also represent action-folder: an action with nested actions.
Each action inModuleID is unique within a tree of assets. */
class SUIT_EXPORT SUIT_ShortcutItemAssets : public SUIT_ShortcutAssets
{
  friend class SUIT_ShortcutAssets;

public:
  static void loadDefaultIcons();
  static const QString PROP_ID_IS_ACTION; // Absense of the key in JSON means myIsAction == true.

private:
  static QIcon DEFAUT_ICON_ACTION;
  static QIcon DEFAUT_ICON_FOLDER;
  static QIcon DEFAUT_ICON_FOLDER_ACTION;

  /*! \brief Creates root item of module.
  \param theModule must not be nullptr.
  \param theIDLastToken is also a inModuleID.
  */
  SUIT_ShortcutItemAssets(std::shared_ptr<SUIT_ShortcutModuleAssets> theModule, const QString& theIDLastToken, bool theIsAction = true);

  /*! \brief Creates nested item within item tree of module.
  \param theParent must not be nullptr. */
  SUIT_ShortcutItemAssets(std::shared_ptr<SUIT_ShortcutItemAssets> theParentItem, const QString& theIDLastToken, bool theIsAction = true);
  SUIT_ShortcutItemAssets(const SUIT_ShortcutItemAssets&) = delete;
  SUIT_ShortcutItemAssets& operator= (const SUIT_ShortcutItemAssets&) = delete;
  static std::shared_ptr<SUIT_ShortcutItemAssets> create(std::shared_ptr<SUIT_ShortcutAssets> theParentItemOrModule, const QString& theIDLastToken, bool theIsAction = true);

 public:
  ~SUIT_ShortcutItemAssets() = default;

  int depth() const;
  SUIT_ShortcutAssets::Type type() const { return SUIT_ShortcutAssets::Type::Item; };

  /*! \param theOverride If true, values of theOther override conflicting values of this. */
  void merge(const SUIT_ShortcutItemAssets& theOther, bool theOverride);

  /*! \param theOverride If true, values of theOther override conflicting values of this. */
  virtual void merge(SUIT_ShortcutItemAssets&& theOther, bool theOverride);

private:
  bool fromJSONOtherProps(const QJsonObject& theJsonObject);
  void toJSONVirtual(QJsonObject& oJsonObject) const;

public:
  /*!
  \param theLang If empty, current language is requested.
  \returns Requested name or name in EN, if requested language is absent. If EN is absent - inModuleID. */
  const QString& bestName(const QString& theLang = QString()) const;

  /*! \brief Composed as <depth_1_item.bestName>/...<depth_N_item.bestName>.../<this->bestName>. Module name is not included. */
  const QString& bestPath(const QString theLang = QString()) const;

  QString description() const;

  bool isAction() const;
  bool isFolder() const;
  std::shared_ptr<SUIT_ShortcutAssets> parent() const;
  std::shared_ptr<SUIT_ShortcutModuleAssets> module() const;

  /*! \brief Even if SUIT_ShortcutItemAssets is not action, its ID is composed in the same way. */
  QString actionID() const;

  /*! \returns myIcon, if !myIcon.isNull(). Otherwise returns appropriate default icon. */
  const QIcon& icon() const;

private:
  std::weak_ptr<SUIT_ShortcutAssets> myParent;

  bool myIsAction;

public:
  const QString myIDLastToken;
  const QString myInModuleID; // Composed as <depth_1_item.myIDLastToken>/...<depth_N_item.myIDLastToken>.../<this->myIDLastToken>. Synonym for inModuleActionID.

private:
  const int myDepth;

  /** {lang, bestPath}[] */
  mutable std::map<QString, QString> myBestPaths;
};


/*!
  \class SUIT_ShortcutMgr
  \brief Handles action shortcut customization.

  The manager is designed to detect shortcut conflicts even for actions, which are not constructed yet.
  To do this, data about action shortcuts should be available for the manager prior to construction of actions.

  SHORTCUT PREFERENCES
  The data about shortcuts is stored in preference files (see SUIT_ShortcutMgr::setShortcutsFromPreferences()) as maps [action ID]->[key sequence].
  It means, actions should have valid IDs (see SUIT_ShortcutMgr::isActionIDValid(const QString&)).
  Let's call such action identified, and actions with invalid IDs anonymous.
  Action IDs are language-independent.

  After an action is constructed (even if it is anonymous), it must be registered by the manager.
  If the action is instance of QtxAction, the manager registers it automatically (see SUIT_ShortcutMgr:eventFilter(QObject* theObject, QEvent* theEvent)).
  Otherwise SUIT_ShortcutMgr::registerAction(const QString& theActionID, QAction* theAction) must be called.

  Upon registration of an action, the manager checks, if a key sequence, assigned to the action, clashes with other shortcuts.
  If it does, and the action is anonymous - empty keysequnce is set to the action.
  If the action is identified - a keysequence from preferences is set to the action,
  even if incoming key sequence does not clash with other shortcuts. Absence of an action ID in preference files means
  default key sequence is empty.

  If shortcuts are changed (via SUIT_ShortcutMgr::mergeShortcutContainer(const SUIT_ShortcutContainer&, bool, bool, bool)),
  the manager serizalizes the changes into user preference file and sets new key sequences to according registered actions.

  ACTION ASSETS
  Users are not aware about action IDs, since GUI normally shows user-friendly data: action names, tooltips and icons. Let's call the data assets.
  Assets of an action should be available for GUI for shortcut presenting/editing (let's call the piece of GUI Shortcut Editor) even before
  the action is constructed. The assets should be provided is asset files (see SUIT_ShortcutMgr::setAssetsFromResources(QString)).

  CONFLICT DETECTION
    IDENTIFIED ACTIONS/SHORTCUTS
    Let's call GUI module root module.
    Only one module, besides the root module, can be active at instance. So a key sequence must be unique within a joined temporary table of
    root and active module shortcuts. An action is allowed to be bound with only key sequence. Multiple actions may be registered under the same ID.

    Action ID is application-unique, language-independent and must be composed as <moduleID>/<inModuleActionID>.
    If an action belongs to root module (e.g. 'Save As'), use empty string as <moduleID>.
    Let's call actions with empty module ID root actions.

    <inModuleActionID> can be composed of several tokens, delimited by "/". See SUIT_ShortcutMgr::isInModuleActionIDValid(const QString&) for details.
    Shortcut Editor considers <inModuleActionID> as "path":
    <inModuleActionID> without the last token is inModuleID of parent folder or action-folder (see SUIT_ShortcutMgr::setAssetsFromResources(QString)).

      META-ACTIONS
      There is a need to keep actions from different modules, which do the same from user' perspective,
      bound to the same key sequence. E.g. 'Front view' or 'Undo'. Let's call such set of actions meta-action.
      <inModuleActionID> of all members of a meta-action must be the same and the last token of the ID must start with "#".
      Meta-action is root action, when it comes to checking for conflicts.
      Shortcuts of meta-actions are (de)serialized to the same section of preference files as root shortcuts.
      Assets of meta-actions should be placed in asset files of root (GUI) module.

    ANONYMOUS ACTIONS/SHORTCUTS
    Actions without action IDs or with invalid ones are called anonymous actions.
    All anonymous actions with non-empty shortcut key sequences are registered by SUIT_ShortcutMgr.
    If a shortcut for an anonymous action clashes with a shortcut for an action with defined ID (identified action/shortcut),
    the shortcut for the anonymous action is disabled, but [the anonymous action, the hard-coded key sequence] pair
    remains within the SUIT_ShortcutMgr. If user redefines key sequences for identified actions,
    and the clash is gone, SUIT_ShortcutMgr enables back the shortcut for the anonymous action.

    It is not possible to reassign key sequences for anonymous actions using the Shortcut Editor GUI.
    It is not possible to always warn users, if a key sequence, they assigns to an identified action,
    disables an anonymous shortcut, because SUIT_ShortcutMgr has no data about anonymous actions until they appear in runtime.
    To prevent the user from relying on such warnings, they are completely disabled.

  HOW TO USE
  1) Come up with valid action ID for an action and:
    1A) Pass the ID as an agrument to constructor of QtxAction; or
    1B) Call SUIT_ShortcutMgr::registerAction(const QString& theActionID, QAction* theAction); or
    1C) Construct the action using SUIT_ShortcutMgr::createAction(..). The latest option allows to avoid duplication of action assets in *.ts files.
  2) Add action assets in asset files.
  3) Add action default keysequence to default preference file.

  DEVELOPMENT
  There are two macros: SHORTCUT_MGR_DBG and SHORTCUT_MGR_DEVTOOLS.
  SHORTCUT_MGR_DBG enables shortcut-related debug output.
  SHORTCUT_MGR_DEVTOOLS enables DevTools class. It assists in making anonymous actions identified and composing asset and default preference files.

  More details can be found in the "SUIT_ShortcutMgr. ReadMe.md".
*/
class SUIT_EXPORT SUIT_ShortcutMgr: public QObject
{
  Q_OBJECT

private:
  SUIT_ShortcutMgr();
  SUIT_ShortcutMgr(const SUIT_ShortcutMgr&) = delete;
  SUIT_ShortcutMgr& operator=(const SUIT_ShortcutMgr&) = delete;

protected:
  virtual ~SUIT_ShortcutMgr();

public:
  static const QString ROOT_MODULE_ID;

  /*! \brief Create new singleton-instance of shortcut manager, if it has not been created. */
  static void Init();

  static SUIT_ShortcutMgr* get();

  /*! \brief Checks whether the theKeySequence is platform-compatible. */
  static bool isKeySequenceValid(const QKeySequence& theKeySequence);

  /*! \returns {false, _ } if  theKeySequenceString is invalid. */
  static std::pair<bool, QKeySequence> toKeySequenceIfValid(const QString& theKeySequenceString);

  /*! \brief Valid module ID does not contain "/" and equals to result of QString(theModuleID).simplified().
  Empty module ID is valid - it is root module ID. */
  static bool isModuleIDValid(const QString& theModuleID);

  static bool isInModuleIDTokenValid(const QString& theInModuleIDToken);

  static bool isInModuleIDTokenMeta(const QString& theInModuleIDToken);

  /*! \brief Valid in-module action ID may consist of several tokens, separated by "/":
  <token_0>/<token_1>...<token_N>/<token_N-1>.
  Each <token> must be non-empty and be equal to QString(<token>).simplified().
  Token "#" is also not valid, since the character in the beginning of the last token means action is meta-action. */
  static bool isInModuleActionIDValid(const QString& theInModuleActionID);

  /*! \returns true, is theInModuleActionID starts with "#". */
  static bool isInModuleMetaActionID(const QString& theInModuleActionID);

  /*! \brief Extracts module ID and in-module action ID from application-unique action ID.
  The theActionID must be composed as <moduleID>/<inModuleActionID>.
  \returns { _ , "" }, if theActionID is invalid. */
  static std::pair<QString, QString> splitIntoModuleIDAndInModuleID(const QString& theActionID);

  /*! \brief Does not check validity. */
  static QStringList splitIntoTokens(const QString& theRelativeID);

  /*! \brief Does not check validity. */
  static QString joinIntoRelativeID(const QStringList& theTokens);

  /*! See \ref splitIntoModuleIDAndInModuleID(const QString&). */
  static bool isActionIDValid(const QString& theActionID);

  /*! \brief Creates application-unique action ID. Reverse to splitIntoModuleIDAndInModuleID.
  \returns Empty string, if either theModuleID or theInModuleActionID is invalid*/
  static QString makeActionID(const QString& theModuleID, const QString& theInModuleActionID);

  /*! \brief Sets all shortcuts from preferences to theContainer. Incoming shortcuts override existing ones.
  If the container has shortcut for an action, which is absent in preferences, and the existing shortcut
  does not conflict with incoming ones, it is untouched.
  See \ref setShortcutsFromPreferences() for details.
  \param theDefaultOnly If true, user preferences are ignored and only default preferences are used. */
  static void fillContainerFromPreferences(SUIT_ShortcutContainer& theContainer, bool theDefaultOnly);

  /*! \param theSectionNamePrefix Prefix of section name in preference files to look in. */
  static void fillContainerFromPreferences(SUIT_ShortcutContainer& theContainer, bool theDefaultOnly, const QString& theSectionNamePrefix);

  /*! \brief Returns item assets as they are in asset files.
  Returned module assets is necessary to keep memory ownership of theAction ancestors. The module assets contain only ancestors of theActionID.
  \param theLangs If empty, all languages is parsed. */
  static std::pair<std::shared_ptr<SUIT_ShortcutModuleAssets>, std::shared_ptr<SUIT_ShortcutItemAssets>>
  getActionAssetsFromResources(const QString& theActionID, const std::set<QString>& theLangs = {});

  /*! \returns Language, which is set in resource manager. */
  static QString currentLang();


  /*! \brief Add theAction to map of managed actions. */
  void registerAction(const QString& theActionID, QAction* theAction);

  /*! \brief Add theAction to map of managed actions. QtxAction::ID() is used as action ID. */
  void registerAction(QtxAction* theAction);

  /*! \brief Get registered actions. If theInModuleActionID is meta-action ID, seeks in all modules. */
  std::set<QAction*> getActions(const QString& theModuleID, const QString& theInModuleActionID) const;

  /*! \brief Get module ID and in-module-ID of theAction.
  \returns { _ , "" } if theAction is not registered. */
  std::pair<QString, QString> getModuleIDAndInModuleID(const QAction* theAction) const;

  /*! Returns true if theAction is registered. */
  bool hasAction(const QAction* theAction) const;

  /*! \brief Get action ID of theActon.
  \returns empty string if theAction is not registered. */
  QString getActionID(const QAction* theAction) const;

  /*! \brief Enables/disable actions of the module.
  Only those actions are affected, whose parent widget is active desktop. */
  void setActionsOfModuleEnabled(const QString& theModuleID, const bool theEnable = true) const;

  [[deprecated("Use setActionsOfModuleEnabled(const QString&, bool) instead.")]]
  void setSectionEnabled(const QString& theInModuleActionIDPrefix, bool theEnable = true) const;

  /*! \brief Enables/disables all registered actions whose in-module action ID begins with theInModuleActionIDPrefix.
  Only those actions are affected, whose parent widget is active desktop. */
  void setActionsWithPrefixInIDEnabled(const QString& theInModuleActionIDPrefix, bool theEnable = true) const;

  /*! \brief For all registered actions binds key sequences from myShortcutContainer. */
  void rebindActionsToKeySequences() const;

  [[deprecated("Use rebindActionsToKeySequences() instead.")]]
  void updateShortcuts() const;

  /*! \brief Checks for conflicts. If theOverride, modifies incoming and disables all conflicting shortcuts.
  Then binds key sequences with corresponding registered actions. Saves changes to preferences.

  Redefining a key sequence for the action, if the key sequence does not conflict with other shortcuts, is not considered as a conflict.
  \param theInModuleActionID The method has no effect if theInModuleActionID is empty.
  \param theKeySequence Empty theKeySequence does not cause conflicts, in this case
  a shortcut for the action is disabled: theInModuleActionID is added/retained in the container but mapped to empty key sequence.
  \param theOverride If true, conflicting shortcuts are disabled.
  \returns {moduleID, inModuleActionID}[] - Set of conflicting actions if theOverride = false,
  otherwise set of actions (without incoming one), whose shortcuts have been disabled. */
  std::set<std::pair<QString, QString>> setShortcut(const QString& theActionID, const QKeySequence& theKeySequence, bool theOverride = false);
  std::set<std::pair<QString, QString>> setShortcut(const QString& theModuleID, const QString& theInModuleActionID, const QKeySequence& theKeySequence, bool theOverride = false);

  const SUIT_ShortcutContainer& getShortcutContainer() const;

  /*! \brief Does not perform validity checks on theModuleID and theInModuleActionID. */
  void mergeShortcutContainer(const SUIT_ShortcutContainer& theContainer, bool theOverride = true, bool theTreatAbsentIncomingAsDisabled = false, bool theSaveToPreferences = true);

  /*! \brief Get a key sequence mapped to the action. */
  const QKeySequence& getKeySequence(const QString& theModuleID, const QString& theInModuleActionID) const;

  /*! \returns {inModuleActionID, keySequence}[] */
  const std::map<QString, QKeySequence>& getModuleShortcutsInversed(const QString& theModuleID) const;

  /*! \returns All module IDs, which were added to myShortcutContainer. */
  std::set<QString> getShortcutModuleIDs() const;

  /*! \returns IDs of modules, which interfere with the module:
  if the module is root (theModuleID is empty) - returns all module IDs, otherwise returns ["", theModuleID]. */
  std::set<QString> getIDsOfInterferingModules(const QString& theModuleID) const;

  std::shared_ptr<const SUIT_ShortcutModuleAssets> getModuleAssets(const QString& theModuleID) const;
  const std::map<QString, std::shared_ptr<SUIT_ShortcutModuleAssets>>& getModuleAssets() const { return myModuleAssets; }

  /*! \brief Retrieves module name, if the asset was loaded using \ref setAssetsFromResources(). If theLang is empty, it is current language. */
  QString getModuleName(const QString& theModuleID, const QString& theLang = "") const;

  std::shared_ptr<const SUIT_ShortcutItemAssets> getActionAssets(const QString& theModuleID, const QString& theInModuleActionID, bool theTryToCreateRuntimeAssetsIfAbsent = true) const;

  std::shared_ptr<const SUIT_ShortcutItemAssets> getActionAssets(const QString& theActionID, bool theTryToCreateRuntimeAssetsIfAbsent = true) const;

  /*! \brief Creates assets using action instance fields, if corresponding action is registered. */
  std::shared_ptr<const SUIT_ShortcutItemAssets> createRuntimeActionAssets(const QString& theModuleID, const QString& theInModuleActionID) const;

  /*! \brief Retrieves action name, if the asset is myModuleAssets. Name of module is not included. If theLang is empty, it is current language. */
  QString getActionName(const QString& theModuleID, const QString& theInModuleActionID, const QString& theLang = "") const;

  /*! \brief Creates an action and sets asset data to the action. */
  QtxAction* createAction(QObject* theParent, QObject* theReceiver, const char* theReceiverSlot, const QString& theActionID, const bool theIsToggle = false) const;

private slots:
  /*!
  \brief Called when the corresponding action is destroyed.
  Removes destroyed action from maps of registered actions. Preserves shortcut.
  \param theObject action being destroyed.
  */
  void onActionDestroyed(QObject* theObject);

  void onAnonymousActionDestroyed(QObject* theObject);

private:
  /*! \brief Overrides QObject::eventFilter().
  If theEvent is QEvent::ActionAdded and the action is instance of QtxAction, registers it. */
  virtual bool eventFilter(QObject* theObject, QEvent* theEvent);

  /*! \brief Does not perform validity checks on theModuleID and theInModuleActionID. */
  std::set<std::pair<QString, QString>> setShortcutNoIDChecks(const QString& theModuleID, const QString& theInModuleActionID, const QKeySequence& theKeySequence, bool theOverride);

  /*! \brief Set shortcuts from preference files. The method is intended to be called before any calls to setShortcut() or mergeShortcutContainer().
  Definition of this method assumes, that shortcut settings are serialized as prerefence entries {name=<inModuleActionID>, val=<keySequence>}
  in dedicated section for each module, with names of sections being composed as "shortcuts_vA1.0:<moduleID>".

  E.g. in case of XML file it may look like this:
  <!--
  <section name="<module ID>">
    ...
    <parameter name="<in-module action ID>" value="key sequence">
    ...
  </section>
  -->
  <section name="shortcuts_vA1.0:">
    <parameter name="AboutDialog" value="Alt+Shift+A"/>
    <parameter name="Edit/#Clipboard_Copy" value="Ctrl+C"/>
    <parameter name="Edit/#Clipboard_Paste" value="Ctrl+V"/>
    <parameter name="File/New" value="Ctrl+N"/>
    <parameter name="File/Open" value="Ctrl+O"/>
  </section>
  <section name="shortcuts_vA1.0:SHAPER">
    <parameter name="Part/Dump" value=""/>
    <parameter name="Part/Parameter" value=""/>
    <parameter name="Part/ParametersMgr" value=""/>
    <parameter name="Sketch" value="Ctrl+4"/>
    <parameter name="Sketch/SketchPoint" value="Ctrl+Shift+*"/>
    <parameter name="Sketch/SketchLine" value="Ctrl+Shift+_"/>
  </section>

  Empty inModuleActionIDs are ignored.
  */
  void setShortcutsFromPreferences();

  /*! \brief Writes shortcuts to preference files.
  \param theShortcuts { moduleID, { inModuleActionID, keySequence }[] }[]. Empty inModuleActionIDs are ignored. */
  static void saveShortcutsToPreferences(const std::map<QString, std::map<QString, QKeySequence>>& theShortcutsInversed);

  /*! \brief Writes shortcuts to preference files.
  \param theShortcuts { moduleID, { inModuleActionID, {oldKeySequence, newKeySequence} }[] }[]. Empty inModuleActionIDs are ignored.
  OldKeySequences are ignored. */
  static void saveShortcutsToPreferences(const std::map<QString, std::map<QString, std::pair<QKeySequence, QKeySequence>>>& theShortcutsInversed);

  /*! Fills myModuleAssets from asset files in theLanguage and EN.
  \param theLanguage If empty, fills assets in current language and EN.

  Asset files must be structured like this:
  {
    moduleID: {
      "iconPath": iconPath,
      "langDependentAssets": {
        ...
        lang: {
          "name": moduleName,
          "tooltip": moduleTooltip
        },
        ...
      },
      "children": {
        ...
        actionA_IDLastToken : {
          "iconPath": iconPath,
          "langDependentAssets": {
            ...
            lang: {
              "name": actionName,
              "tooltip": actionTooltip
            },
            ...
          },
          "children": { // The action has nested actions.
            actionB_IDLastToken: {
            ...
            }
          }
        },
        ...
        folderC_IDLastToken: {
          "isAction": false, // The folder is pure folder.
          "iconPath": iconPath,
          "langDependentAssets": {
            ...
          },
          children: {
            ...
          }
        }
        ...
      }
    }
  }

  The JSON above describes an action-folder with ID "moduleID/actionA_IDLastToken" and a pure folder with ID "moduleID/folderC_IDLastToken".
  The action-folder has a nested action with "moduleID/actionA_IDLastToken//actionB_IDLastToken".
  Requirements for action' and folder' IDs are the same.
  */
  void setAssetsFromResources(QString theLanguage = QString());

  void registerAnonymousShortcut(QAction* const theAction);
  void enableAnonymousShortcutsClashingWith(const QString& theModuleID, const bool theEnable) const;
  void enableAnonymousShortcutsClashingWith(const QKeySequence& theKeySequence, bool theEnable) const;
  QString anonymousShortcutsToString() const;

private:
  static SUIT_ShortcutMgr* myShortcutMgr;

  /** { moduleID, { inModuleActionID, action[] }[] }[]. May contain entries like { <non-root module ID>, { <meta-action ID>, actions[] } }. */
  std::map<QString, std::map<QString, std::set<QAction*>>> myActions;

  /** { action, { moduleID, inModuleActionID } }[]. May contain entries like { <non-root module ID>, { <meta-action ID>, actions[] } }. */
  std::map<QAction*, std::pair<QString, QString>> myActionIDs; // To maintain uniqueness of actions and effectively retrieve IDs of registered actions.

  /** Can not contain entries like { <non-root module ID>, { <meta-action ID>, actions[] } }. */
  SUIT_ShortcutContainer myShortcutContainer;

  /* nb!
  Sets of moduleIDs and inModuleActionIDs are equal for myActions and myActionIDs.
  Sets of moduleIDs and inModuleActionIDs may NOT be equal for myActions and myShortcutContainer.
  */

  /** {moduleID, moduleAssets}[]. Structured assets: module assets refer to folders and actions, folders and actions refer to nested ones, etc. */
  mutable std::map<QString, std::shared_ptr<SUIT_ShortcutModuleAssets>> myModuleAssets;

  /** True, if SUIT_ShortcutMgr::setAssetsFromResources(QString) was called. */
  bool myAssetsLoaded;

  mutable std::set<QString> myActiveModuleIDs;

  /** Actions without IDs, but with hard-coded non-empty key sequences.
  * Shortcuts, defined in preferences, override shortcuts of anonymous actions - if an active module has a preference shortcut,
  * anonymous shortcuts with the same key sequence are disabled. If the root module has a preference shortcut, which
  * is in clash with anonymous shortcuts, clashing anonymous actions are always disabled. */
  std::map<QAction*, QKeySequence> myAnonymousShortcuts;

  std::map<QKeySequence, std::set<QAction*>> myAnonymousShortcutsInverse;
};


/*! \brief Sometimes developers change IDs of actions. And at the moment of release of these changes
users may already have cutomized shortcuts. SUIT_ShortcutHistorian assits with user defined shorcut settings' migrations.
It retrieves keysequences, assigned to actions by user using older Salome versions,
which operated with old action ID sets. "Action ID set" is also referred as AIDS for brevity.

HOW TO USE
Use the guide, if action IDs have been changed or some action have been removed.
If new actions have been added, no need to make anything related to SUIT_ShortcutHistorian.

1) Go to action_assets.json files and change assets accordingly. Remove assets of removed actions.

2) Come up with a new prefix for shortcut sections' name in preference files. At the moment of writing, the prefix is "shortcuts_vA1.0".
   The prefix must not contain ":" character - the character delimits prefix from module ID.
   Append the new prefix to SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION list.
   All prefixes in the list must be unique.

3) Go to default preference files (.xml, or .xml.in). Change an old prefix to the new one.
   Change old action IDs to new ones. Remove shorcuts of removed actions.

4) Compose/modify action_id_mutations.json files.
   Add an entry, structured as shown below, to "mutations" array.
   A) <OLD_SHORTCUT_PREFIX> and <NEW_SHORTCUT_PREFIX> must be consecutive prefixes from SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.
   B) Sorting or mutations array does not matter.
   C) If no IDs were changed/removed between shortcut versions "L" and "N",
   there is no need to add mutations "L==>L+1", "L+1==>L+2", ..., "N-1==>N".
   D) Mutations also handle move of an action to another module: "oldToNewActionIDMap"
      contains action IDs, which are composed of a moduleID and an inModuleActionID.
   E) If an action has been removed, put an empty ID after its <moduleID/inModuleActionID>.

    {
      "sectionPrefixOld": "OLD_SHORTCUT_PREFIX",
      "sectionPrefixNew": "NEW_SHORTCUT_PREFIX,
      "oldToNewActionIDMap": {
        "MODULE_ID_1/OLD_IN_MODULE_ACTION_ID_1" : "MODULE_ID_1/MODIFIED_IN_MODULE_ACTION_ID_1",
        "MODULE_ID_1/OLD_IN_MODULE_ACTION_ID_2" : "MODULE_ID_2/MODIFIED_IN_MODULE_ACTION_ID_2",
        "MODULE_ID_1/REMOVED_IN_MODULE_ACTION_ID" : ""
      }
    }

  5) If action_id_mutations.json has just been created, put a path to it into
     a default preference file, section "actionID_mutations", e.g.:

    <section name="actionID_mutations">
      <parameter name="%GEOM_ROOT_DIR%/share/salome/resources/geom/action_id_mutations.json" value=""/>
    </section>
    .

  HOW IT WORKS
  1) During the SUIT_ShortcutMgr initialization an instance of SUIT_ShortcutHistorian is created.
  2) The SUIT_ShortcutHistorian instance goes through the SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION and
  parses old shortcut sections of user preference file (~/.config/salome/SalomeApprc.9.11.0 on Linux).
  3) Using mutation data, it replaces old action IDs with actual ones, and merges them
  into single SUIT_ShortcutContainer. Newer shortcuts override older ones.
  4) Merges migrated shortcut container into an actual one. Migrated shortcuts override actual ones.
  5) Updates actual shortcut section of user preference file.
  6) Erases old shortcut sections of user preference file.
*/
class SUIT_EXPORT SUIT_ShortcutHistorian
{
public:
  /** {name prefix of a section in user preference files}[]. Sorted from the newest to the oldest.
   *  The list is hardcoded. Update it every time, a new AIDS and appropriate AIDSMutation are added. */
  static const std::vector<QString> SECTION_PREFIX_EVOLUTION;

private:
  /*! \brief Describes how action IDs evolved between consequtive versions of action ID sets.
  PS. Once upon a time I also wanted to cure AIDS. But instead I spawned new ones. With mutations. */
  class SUIT_EXPORT AIDSMutation
  {
  public:
    static const QString PROP_ID_MUTATIONS;
    static const QString PROP_ID_PREFIX_OLD;
    static const QString PROP_ID_PREFIX_NEW;
    static const QString PROP_ID_OLD_TO_NEW_ACTION_ID_MAP;

    static bool isPairOfNewAndOldActionIDsValid(const QString& theSectionPrefixNew, const QString& theSectionPrefixOld);

    AIDSMutation(const QString& theSectionPrefixNew, const QString& theSectionPrefixOld);
    AIDSMutation(const QJsonObject& theJsonObject, const bool theParseMap = true);

    const QString& getSectionPrefixOld() const { return mySectionPrefixOld; };
    const QString& getSectionPrefixNew() const { return mySectionPrefixNew; };
    const std::map<QString, QString>& getNewToOldActionIDMap() const { return myNewToOldActionIDMap; };
    const std::map<QString, QString>& getOldToNewActionIDMap() const { return myOldToNewActionIDMap; };

    /*! \returns True, if both old and new prefixes are the same as ones of theOther. */
    bool isConcurrent(const AIDSMutation& theOther) const;

    /*! \returns True, if mutation maps are augmented. */
    bool merge(const AIDSMutation& theOther);

  private:
    /** Old name prefix of a section in user preference files. */
    QString mySectionPrefixOld;

    /** New name prefix of a section in user preference files. */
    QString mySectionPrefixNew;

    /** The map only keeps changes between AIDS versions. It means, there is no need to add entries like {theSameActionID, theSameActionID}.
     *  New action ID can't be empty. */
    std::map<QString, QString> myNewToOldActionIDMap;

    /** The map only keeps changes between AIDS versions. It means, there is no need to add entries like {theSameActionID, theSameActionID}.
     *  New action ID may be empty. */
    std::map<QString, QString> myOldToNewActionIDMap;
  };

public:
  SUIT_ShortcutHistorian();

  /*! \returns True, if myShortcutContainers has at least one shortcut. */
  bool doOldShortcutPreferencesExist() const;

  /*! \brief Evolves theOldActionID defined in section theOldSectionPrefix.
  \returns Empty string, if theOldSectionPrefix is not defined in SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.*/
  QString getActionID(const QString& theOldActionID, const QString& theOldSectionPrefix) const;

  /*!
  \param theActionID Action ID in latest version (as elsewhere in ShortcutMgr code).
  \returns {false, _ }, if shortcut is not defined in any outdated shortcut section of user preference files. */
  std::pair<bool, QKeySequence> getOldUserDefinedKeySequence(const QString& theActionID) const;

  const SUIT_ShortcutContainer& getContainerWithOldShortcuts() const { return myShortcutContainer; };

  /*! \brief Removes old shortcut sections from preference files and clears myShortcutContainers. */
  void removeOldShortcutPreferences();

private:
  void parseMutations();

  /*!
  \param theSectionPrefix User preferences' section name with shortcuts.
  \returns {false, _ }, is the shortcut is not defined in the section. */
  std::pair<bool, QKeySequence> getKeySequenceFromSection(const QString& theActionID, const QString& theSectionPrefix) const;

private:
  /** {sectionNamePrefixOld, mutation}[]. Sorted from the newest to the oldest. */
  std::list<std::pair<QString, SUIT_ShortcutHistorian::AIDSMutation>> myOldPrefixToMutationList;

  /** {sectionNamePrefixOld, shortcutContainer}[]. */
  std::map<QString, SUIT_ShortcutContainer> myShortcutContainers;

  /** Merged myShortcutContainers. Merge is performed from the oldest to the newest, newer shortcuts override older ones. */
  SUIT_ShortcutContainer myShortcutContainer;
};


namespace SUIT_tools {
  class SUIT_SentenceMatcher;
}


/*!
  \class SUIT_ActionSearcher
  \brief Searches in data, provided in action asset files and shortcut preferences.
*/
class SUIT_EXPORT SUIT_ActionSearcher
{
public:
  enum MatchField {
    ID,
    Name, // Also matches with path, composed as <depth_1_item.name>/...<depth_N_item.name>.../<actionItem.name>.
    ToolTip,
    KeySequence
  };

  class AssetsAndSearchData
  {
  public:
    AssetsAndSearchData(std::shared_ptr<const SUIT_ShortcutItemAssets> theAssets = nullptr, double theMatchMetrics = std::numeric_limits<double>::infinity());

    void setMatchMetrics(double theMatchMetrics);
    double matchMetrics() const { return myMatchMetrics; };

    std::shared_ptr<const SUIT_ShortcutItemAssets> myAssets;

    void toJSON(QJsonObject& oJsonObject) const;
    QString toString() const;

  private:
    /*! \brief Ideally it should be number of weighted character permutations. Now it is just a number of characters in unmatched words. */
    double myMatchMetrics;
  };


  static double matchKeySequenceString(const QString& theQuery, const QString& theKeySequence);

  /*! Default config:
      Included modules' IDs = { ROOT_MODULE_ID };
      Include disabled actions = false;
      Fields to match = { Name, Tooltip };
      Case sensitive = false;
      Fuzzy matching = true;
      Query = ""; // matches nothing.
  */
  SUIT_ActionSearcher();
  SUIT_ActionSearcher(const SUIT_ActionSearcher&) = delete;
  SUIT_ActionSearcher& operator=(const SUIT_ActionSearcher&) = delete;
  virtual ~SUIT_ActionSearcher();

  /*! \returns true, if set of results is changed.
  \param doNotUpdateResults Set to true to initialize the instance without unnececessary computations. */
  bool setIncludedModuleIDs(std::set<QString> theIncludedModuleIDs, bool doNotUpdateResults = false);

  /*! \returns true, if set of results is changed.
  \param doNotUpdateResults Set to true to initialize the instance without unnececessary computations. */
  bool includeDisabledActions(bool theOn, bool doNotUpdateResults = false);
  inline bool areDisabledActionsIncluded() const {return myIncludeDisabledActions;};

  /*! \returns true, if set of results is changed.
  \param doNotUpdateResults Set to true to initialize the instance without unnececessary computations. */
  bool setFieldsToMatch(const std::set<SUIT_ActionSearcher::MatchField>& theFields, bool doNotUpdateResults = false);

  /*! \returns { true, _ } if set of results is changed; { _ , true } if matching metrics is changed for at least one result.
  \param theKeySequenceGetter getKeySequence(theModuleID, theInModuleActionID). If empty, a default getter, retrieving key sequence from ShortcutMgr, is set.
  \param doNotUpdateResults Set to true to initialize the instance without unnececessary computations. */
  std::pair<bool, bool> setKeySequenceGetter(
    const std::function<QString(const QString&, const QString&)>& theKeySequenceGetter = std::function<QString(const QString&, const QString&)>(),
    bool doNotUpdateResults = false
  );

  /*! \returns true, if set of results is changed.
  \param doNotUpdateResults Set to true to initialize the instance without unnececessary computations. */
  bool setCaseSensitive(bool theOn, bool doNotUpdateResults = false);

  /*! \returns true, if set of results is changed. */
  bool setQuery(const QString& theQuery);
  inline const QString& getQuery() const;

  const std::map<QString, std::map<QString, SUIT_ActionSearcher::AssetsAndSearchData>>& getSearchResults() const;


private:
  /*! \brief Applies filter to all actions, provided in asset files for SUIT_ShortcutMgr.
  \returns { true, _ } if set of results is changed; { _ , true } if matching metrics is changed for at least one result. */
  std::pair<bool, bool> filter();

  /*! \brief Applies filter to search results only.
  \returns { true, _ } if set of results is shrunk; { _ , true } if matching metrics is changed for at least one result. */
  std::pair<bool, bool> filterResults();

  /*! \brief Applies filter only to actions, which are not in search results.
  \returns True, if set of results is extended. */
  bool extendResults();

  double matchAction(const SUIT_ShortcutItemAssets& theAssets);

  QString toString() const;


  std::set<QString> myIncludedModuleIDs;
  bool myIncludeDisabledActions;

  std::set<SUIT_ActionSearcher::MatchField> myFieldsToMatch;
  ::SUIT_tools::SUIT_SentenceMatcher* myMatcher;

  /* getKeySequence(theModuleID, theInModuleActionID) */
  std::function<QString(const QString&, const QString&)> myKeySequenceGetter;

  /* { moduleID, {inModuleActionID, assetsAndSearchData}[] }[]. */
  std::map<QString, std::map<QString, SUIT_ActionSearcher::AssetsAndSearchData>> mySearchResults;
};


#if defined WIN32
#pragma warning( default: 4251 )
#endif

#endif //SUIT_SHORTCUTMGR_H
