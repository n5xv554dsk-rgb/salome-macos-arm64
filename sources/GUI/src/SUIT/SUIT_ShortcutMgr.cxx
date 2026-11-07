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

#include "SUIT_ShortcutMgr.h"

#include "SUIT_Session.h"
#include "SUIT_ResourceMgr.h"
#include "SUIT_MessageBox.h"
#include "Tools/SUIT_extensions.h"
#include "Tools/SUIT_SentenceMatcher.h"

#include <QAction>
#include <QtxAction.h>

#include <QApplication>
#include <QActionEvent>
#include <QKeySequence>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonParseError>
#include <QFile>

#include <list>
#include <iostream>
#include <string>
#include <sstream>
#include <stdexcept>


const std::wstring SHORTCUT_MGR_LOG_PREFIX = L"SHORTCUT_MGR_DBG: ";
bool ShCutDbg(const QString& theString)
{
  if (ShCutDbg()) {
    std::wcout << SHORTCUT_MGR_LOG_PREFIX << theString.toStdWString() << std::endl;
    return true;
  }
  return false;
}
bool ShCutDbg(const char* src)
{
  if (ShCutDbg()) {
    std::wcout << SHORTCUT_MGR_LOG_PREFIX << std::wstring(src, src + strlen(src)) << std::endl;
    return true;
  }
  return false;
}

void Warning(const QString& theString)
{
  //std::wcout << theString.toStdWString() << std::endl;
}
void Warning(const char* src)
{
  //std::wcout << std::wstring(src, src + strlen(src)) << std::endl;
}


static const QKeySequence NO_KEYSEQUENCE = QKeySequence(QString(""));
static const QString NO_ACTION = QString("");
/** Separates tokens in action ID. */
static const QString TOKEN_SEPARATOR = QString("/");
/*static*/ const QString SUIT_ShortcutMgr::ROOT_MODULE_ID = QString("");
static const QString META_ACTION_PREFIX = QString("#");

/** Prefix of names of shortcut setting sections in preference files. */
static const QString SECTION_NAME_PREFIX = QString("shortcuts_vA1.0");


const QString DEFAULT_LANG = QString("en");
const QString LANG_SECTION = QString("language");

static const QString SECTION_NAME_ACTION_ASSET_FILE_PATHS = QString("action_assets");



/** Uncomment this to enable DevTools. */
// #define SHORTCUT_MGR_DEVTOOLS
#ifdef SHORTCUT_MGR_DEVTOOLS
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include "QtxMap.h"
#include <functional>
#ifndef QT_NO_DOM
#include <QDomDocument>
#include <QDomElement>
#include <QDomNode>
#endif // QT_NO_DOM

/*! \brief
    Alleviates making actions, coded without taking into account SUIT_ShortcutMgr action requirements, dynamically assignable to shortcuts.

    Generates XML files with key sequences of actions, registered by the shortcut manager,
    if these actions are anonymous or their shortcuts are absent in default preference files.
    Generates JSON files with assets (using fieilds of action instances) of identified actions, registered by the shortcut manager,
    if their assets are absent in assets files.
    Content of these files can be easily copied to preference/asset files.
    The files are dumped in "<APP_DIR>/shortcut_mgr_dev/". Content of dump files is appended on every run.

    HOW TO USE
    1) Run application and touch features of interest.
    2) Look into *actions_with_invalid_IDs.csv files.
    3) Identify where from those actions come from.
       Also look for DevTools::SECTION_NAME_ACTION_IDS_TO_THROW_EXCEPTION and DevTools::SECTION_NAME_ACTION_TOOLTIPS_TO_THROW_EXCEPTION.
    4) Assign valid IDs to actions of interest in the code and rebuild.
    5) Delete all dump files.
    6) Go to apllication preferences and set language of interest (if these features are localized in that language). Run the features again. Repeat.
    7) Files *_assets*.json hold assets, composed using runtime data, of those identified actions, whose assets are absent in project asset files.
       Files *_shortcuts.xml hold shortcuts of those identified actions, which are absent in default preference files.
  */
class DevTools
{
private:
  DevTools() : myActionsWithInvalidIDsFile(nullptr) {};
  DevTools(const DevTools&) = delete;
  void operator=(const DevTools&) = delete;

public:
  ~DevTools()
  {
    for (const auto& fileNameAndPtrs : myXMLFilesAndDocs) {
      delete fileNameAndPtrs.second.second;
      delete fileNameAndPtrs.second.first;
    }

    for (const auto& fileNameAndPtrs : myJSONFilesAndDocs) {
      delete fileNameAndPtrs.second.second;
      delete fileNameAndPtrs.second.first;
    }
  }

  static DevTools* get() {
    if (!DevTools::instance)
      DevTools::instance = new DevTools();

    return DevTools::instance;
  }

  void collectShortcut(
    const QString& theModuleID,
    const QString& theInModuleActionID,
    const QKeySequence& theKeySequence
  ) {
    if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID)) {
      auto& moduleShortcuts = myShortcutsOfMetaActions[theModuleID];
      moduleShortcuts[theInModuleActionID] = theKeySequence.toString();

      const QString fileName = theModuleID + DevTools::SHORTCUTS_OF_META_SUFFIX;
      const QString sectionName = SECTION_NAME_PREFIX + DevTools::XML_SECTION_TOKENS_SEPARATOR + SUIT_ShortcutMgr::ROOT_MODULE_ID;
      std::map<QString, std::map<QString, QString>> sections;
      sections[sectionName] = moduleShortcuts;
      writeToXMLFile(fileName, sections);
    }
    else {
      auto& moduleShortcuts = myShortcuts[theModuleID];
      moduleShortcuts[theInModuleActionID] = theKeySequence.toString();

      const QString fileName = theModuleID + DevTools::SHORTCUTS_SUFFIX;
      const QString sectionName = SECTION_NAME_PREFIX + DevTools::XML_SECTION_TOKENS_SEPARATOR + theModuleID;
      std::map<QString, std::map<QString, QString>> sections;
      sections[sectionName] = moduleShortcuts;
      writeToXMLFile(fileName, sections);
    }
  }

  void collectAssets(
    const SUIT_ShortcutModuleAssets& theModuleAssetsInResources,
    const QString& theModuleID,
    const QString& theInModuleActionID,
    const QString& theLang,
    const QAction* theAction
  ) {
    if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID)) {
      QString actionID = SUIT_ShortcutMgr::makeActionID(SUIT_ShortcutMgr::ROOT_MODULE_ID, theInModuleActionID);

      auto itModuleAssets = myAssetsOfMetaActions.find(theModuleID);
      if (itModuleAssets == myAssetsOfMetaActions.end()) {
        itModuleAssets = myAssetsOfMetaActions.emplace(theModuleID, SUIT_ShortcutModuleAssets::create(SUIT_ShortcutMgr::ROOT_MODULE_ID)).first;
      }
      auto& moduleAssets = itModuleAssets->second;

      auto actionAssets = moduleAssets->descendantItem(theInModuleActionID);
      actionAssets->myLangDependentAssets[theLang].myName = theAction->text();
      actionAssets->myLangDependentAssets[theLang].myToolTip = theAction->statusTip();

      const QString fileName = theModuleID + DevTools::ASSETS_OF_META_SUFFIX;
      writeToJSONFile(fileName, *moduleAssets);
    }
    else {
      QString actionID = SUIT_ShortcutMgr::makeActionID(theModuleID, theInModuleActionID);

      auto itModuleAssets = myAssets.find(theModuleID);
      if (itModuleAssets == myAssets.end()) {
        itModuleAssets = myAssets.emplace(theModuleID, SUIT_ShortcutModuleAssets::create(theModuleID)).first;
      }
      auto& moduleAssets = itModuleAssets->second;

      moduleAssets->merge(theModuleAssetsInResources, true);
      auto actionAssets = moduleAssets->descendantItem(theInModuleActionID,  true);
      actionAssets->myLangDependentAssets[theLang].myName = theAction->text();
      actionAssets->myLangDependentAssets[theLang].myToolTip = theAction->statusTip();


      const QString fileName = theModuleID + DevTools::ASSETS_SUFFIX;
      writeToJSONFile(fileName, *moduleAssets);
    }
  }

  void collectShortcutAndAssets(const QtxAction* const theAction)
  {
    const auto moduleIDAndActionID = SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(theAction->ID());
    if (moduleIDAndActionID.second.isEmpty())
      return;

    if (!SUIT_ShortcutMgr::get()->getShortcutContainer().hasShortcut(moduleIDAndActionID.first, moduleIDAndActionID.second))
      collectShortcut(moduleIDAndActionID.first, moduleIDAndActionID.second, theAction->shortcut());

    { // Collect action assets, if they are not provided in asset files.
      SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
      if (!resMgr) {
        Warning("DevTools for SUIT_ShortcutMgr can't retrieve resource manager!");
        return;
      }

      const QString lang = SUIT_ShortcutMgr::currentLang();
      const auto moduleAndActionAssetsInResources = SUIT_ShortcutMgr::getActionAssetsFromResources(theAction->ID());
      const auto& moduleAssetsInResources = moduleAndActionAssetsInResources.first;
      const auto& actionAssetsInResources = moduleAndActionAssetsInResources.second;

      if (actionAssetsInResources && actionAssetsInResources->myLangDependentAssets.find(lang) != actionAssetsInResources->myLangDependentAssets.end())
        return;

      if (moduleAssetsInResources)
        collectAssets(*moduleAssetsInResources, moduleIDAndActionID.first, moduleIDAndActionID.second, lang, theAction);
    }
  }

private:
  /*! Appends new entries to content of dump files. */
  bool writeToXMLFile(const QString& theFileName, const std::map<QString, std::map<QString, QString>>& theSections)
  {
#ifdef QT_NO_DOM
  Warning("DebugTools for SUIT_ShortcutMgr can't create XML - #QT_NO_DOM is defined.");
  return false;
#else QT_NO_DOM
    static const QString DOC_TAG = "document";
    static const QString SECTION_TAG = "section";
    static const QString PARAMETER_TAG = "parameter";
    static const QString NAME_ATTR = "name";
    static const QString VAL_ATTR = "value";

    const auto itFileAndDoc = myXMLFilesAndDocs.find(theFileName);
    if (itFileAndDoc == myXMLFilesAndDocs.end()) {
      const QString fullPath = DevTools::SAVE_PATH + theFileName + ".xml";
      if (!Qtx::mkDir(QFileInfo(fullPath).absolutePath())) {
        myXMLFilesAndDocs[theFileName] = std::pair<QFile*, QDomDocument*>(nullptr, nullptr);
        return false;
      }

      QFile* file = new QFile(fullPath);
      if (!file->open(QFile::ReadWrite | QIODevice::Text)) {
        delete file;
        myXMLFilesAndDocs[theFileName] = std::pair<QFile*, QDomDocument*>(nullptr, nullptr);
        return false;
      }

      QDomDocument* dom = new QDomDocument(DOC_TAG);
      QTextStream instream(file);
      dom->setContent(instream.readAll());
      myXMLFilesAndDocs[theFileName] = std::pair<QFile*, QDomDocument*>(file, dom);
    }
    else if (itFileAndDoc->second.first == nullptr) {
      return false;
    }

    const auto fileAndDom = myXMLFilesAndDocs[theFileName];
    QFile* const file = fileAndDom.first;
    QDomDocument* const dom = fileAndDom.second;

    QDomElement doc = dom->documentElement();
    if (doc.isNull()) {
      *dom = QDomDocument(DOC_TAG);
      doc = dom->createElement(DOC_TAG);
      dom->appendChild(doc);
    }

    static const std::function<void(const std::map<QString, QString>&, QDomDocument&, QDomElement&)> mergeParamsToSection =
    [&](const std::map<QString, QString>& parameters, QDomDocument& dom, QDomElement& sectionInDom)
    {
      for (const std::pair<QString, QString>& nameAndVal : parameters) {
        const QString& paramName = nameAndVal.first;
        const QString& paramVal = nameAndVal.second;
        bool fileHasParam = false;
        for (QDomElement paramInDom = sectionInDom.firstChildElement(PARAMETER_TAG); !paramInDom.isNull(); paramInDom = paramInDom.nextSiblingElement(PARAMETER_TAG)) {
          const QString paramNameInDom = paramInDom.attribute(NAME_ATTR);
          if (paramName == paramNameInDom) {
            const QString paramValInDom = paramInDom.attribute(VAL_ATTR);
            if (paramValInDom != paramVal) {
              QDomElement replaceElement = dom.createElement(PARAMETER_TAG);
              replaceElement.setAttribute(NAME_ATTR, paramName);
              replaceElement.setAttribute(VAL_ATTR, paramVal);
              sectionInDom.replaceChild(replaceElement, paramInDom);
            }

            fileHasParam = true;
            break;
          }
        }
        if (!fileHasParam) {
          QDomElement newParam = dom.createElement(PARAMETER_TAG);
          newParam.setAttribute(NAME_ATTR, paramName);
          newParam.setAttribute(VAL_ATTR, paramVal);
          sectionInDom.insertAfter(newParam, sectionInDom.lastChildElement(PARAMETER_TAG));
        }
      }
      return;
    };

    for (const auto& sectionNameAndParams : theSections) {
      const QString& sectionName = sectionNameAndParams.first;
      const std::map<QString, QString>& parameters = sectionNameAndParams.second;

      bool fileHasSection = false;
      for (QDomElement sectionInDom = doc.firstChildElement(SECTION_TAG); !sectionInDom.isNull(); sectionInDom = sectionInDom.nextSiblingElement(SECTION_TAG)) {
        QString sectionNameInDom = sectionInDom.attribute(NAME_ATTR);
        if (sectionNameInDom == sectionName) {
          mergeParamsToSection(parameters, *dom, sectionInDom);
          fileHasSection = true;
          break;
        }
      }

      if (!fileHasSection) {
        QDomElement newSection = dom->createElement(SECTION_TAG);
        newSection.setAttribute(NAME_ATTR, sectionName);
        doc.insertAfter(newSection, doc.lastChildElement(SECTION_TAG));
        mergeParamsToSection(parameters, *dom, newSection);
      }
    }

    file->resize(0);
    QTextStream outstream(file);
    outstream << dom->toString();

    return true;
#endif // QT_NO_DOM
  }

  /*! Appends new entries to content of dump files. */
  bool writeToJSONFile(const QString& theFileName, const SUIT_ShortcutModuleAssets& theModuleAssetsInResources)
  {
    const auto itFileAndDoc = myJSONFilesAndDocs.find(theFileName);
    if (itFileAndDoc == myJSONFilesAndDocs.end()) {
      const QString fullPath = DevTools::SAVE_PATH + theFileName + ".json";
      if (!Qtx::mkDir(QFileInfo(fullPath).absolutePath())) {
        myJSONFilesAndDocs[theFileName] = std::pair<QFile*, QJsonDocument*>(nullptr, nullptr);
        return false;
      }

      const bool fileExisted = QFileInfo::exists(fullPath);
      QFile* file = new QFile(fullPath);
      if (!file->open(QFile::ReadWrite | QIODevice::Text)) {
        delete file;
        myJSONFilesAndDocs[theFileName] = std::pair<QFile*, QJsonDocument*>(nullptr, nullptr);
        return false;
      }

      QJsonParseError jsonError;
      QJsonDocument* document = new QJsonDocument(QJsonDocument::fromJson(file->readAll(), &jsonError));
      if (jsonError.error != QJsonParseError::NoError && fileExisted) {
        Warning("SUIT_ShortcutMgr: error during parsing of action asset dump file \"" + fullPath + "\"!");
        delete file;
        delete document;
        myJSONFilesAndDocs[theFileName] = std::pair<QFile*, QJsonDocument*>(nullptr, nullptr);
        return false;
      }

      if (!document->isObject()) {
        document->setObject(QJsonObject());
        file->resize(0);
        QTextStream outstream(file);
        outstream << document->toJson(QJsonDocument::Indented);
      }

      myJSONFilesAndDocs[theFileName] = std::pair<QFile*, QJsonDocument*>(file, document);
    }
    else if (itFileAndDoc->second.first == nullptr) {
      return false;
    }

    const auto fileAndDoc = myJSONFilesAndDocs[theFileName];
    QFile* const file = fileAndDoc.first;
    QJsonDocument* const document = fileAndDoc.second;

    const QString& moduleID = theModuleAssetsInResources.myModuleID;

    QJsonObject documentJSONObject = document->object();
    QJsonObject moduleAssetsJSONObject = documentJSONObject[moduleID].toObject();
    const auto dumpedModuleAssets = SUIT_ShortcutModuleAssets::create(moduleID);
    dumpedModuleAssets->fromJSON(moduleAssetsJSONObject);
    dumpedModuleAssets->merge(theModuleAssetsInResources, true /*theOverride*/);
    dumpedModuleAssets->toJSON(moduleAssetsJSONObject);

    documentJSONObject[moduleID] = moduleAssetsJSONObject;
    document->setObject(documentJSONObject);

    file->resize(0);
    QTextStream outstream(file);
    outstream << document->toJson(QJsonDocument::Indented);

    return true;
  }

public:
  void collectAssetsOfActionWithInvalidID(const QAction* const theAction)
  {
    SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
    if (!resMgr) {
      Warning("DevTools for SUIT_ShortcutMgr can't retrieve resource manager!");
      return;
    }

    const QString lang = resMgr->stringValue(LANG_SECTION, LANG_SECTION);
    if (lang.isEmpty())
      return;

    if (!myActionsWithInvalidIDsFile) {
      const QString fullPath = DevTools::SAVE_PATH + lang + DevTools::INVALID_ID_ACTIONS_SUFFIX + ".csv";
      if (!Qtx::mkDir(QFileInfo(fullPath).absolutePath()))
        return;

      myActionsWithInvalidIDsFile = new QFile(fullPath);
      if (!myActionsWithInvalidIDsFile->open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        delete myActionsWithInvalidIDsFile;
        myActionsWithInvalidIDsFile = nullptr;
        return;
      }

      QTextStream ostream(myActionsWithInvalidIDsFile);
      ostream << "text\t" << "tool tip\t" << "status tip\t" << "key sequence\t" << "QtxAction?\t" << "ID\n";
      ostream.flush();
    }

    QTextStream ostream(myActionsWithInvalidIDsFile);
    const auto aQtxAction = qobject_cast<const QtxAction*>(theAction);
    ostream << theAction->text() << "\t" << theAction->toolTip() << "\t" << theAction->statusTip() << "\t"
    << theAction->shortcut().toString() << "\t" << (aQtxAction ? "yes\t" : "no\t") << (aQtxAction ? aQtxAction->ID() + "\n" : "\n");
    ostream.flush();
  }

  static const QString SAVE_PATH;
  static const QString SHORTCUTS_SUFFIX;
  static const QString SHORTCUTS_OF_META_SUFFIX;
  static const QString ASSETS_SUFFIX;
  static const QString ASSETS_OF_META_SUFFIX;
  static const QString INVALID_ID_ACTIONS_SUFFIX;

  static DevTools* instance;
  static const QString XML_SECTION_TOKENS_SEPARATOR;


  /** Add such section to preference file to throw exceptions upon registration of actions with listed IDs.
   *  Makes it easier to find the code where actions are created.
   *
      <section name="SHORTCUT_MGR_DEVTOOLS_Action_IDs_to_throw_exception">
        ...
        <parameter name="moduleID/inModuleActionID" value=""/>
        ...
      </section>
  */
  static const QString SECTION_NAME_ACTION_IDS_TO_THROW_EXCEPTION;

  /** Add such section to preference file to throw exceptions upon registration of actions with listed tool tips.
   *  Makes it easier to find the code where actions are created.
   *
      <section name="SHORTCUT_MGR_DEVTOOLS_Action_tooltips_to_throw_exception">
        ...
        <parameter name="actionToolTip" value=""/>
        ...
      </section>
  */
  static const QString SECTION_NAME_ACTION_TOOLTIPS_TO_THROW_EXCEPTION;

  /** { moduleID, { inModuleActionID, keySequence }[] }[]. keySequence can be empty. */
  std::map<QString, std::map<QString, QString>> myShortcuts;

  /** { moduleID, { inModuleActionID, keySequence }[] }[]. keySequence can be empty. */
  std::map<QString, std::map<QString, QString>> myShortcutsOfMetaActions;

  /** { moduleID, moduleAssets }[] */
  std::map<QString, std::shared_ptr<SUIT_ShortcutModuleAssets>> myAssets;

  /** { moduleID, moduleAssets }[] */
  std::map<QString, std::shared_ptr<SUIT_ShortcutModuleAssets>> myAssetsOfMetaActions;

#ifndef QT_NO_DOM
  // { filename, {file, domDoc} }[]
  std::map<QString, std::pair<QFile*, QDomDocument*>> myXMLFilesAndDocs;
#endif // QT_NO_DOM
  // { filename, {file, jsonDoc} }[]
  std::map<QString, std::pair<QFile*, QJsonDocument*>> myJSONFilesAndDocs;

  QFile* myActionsWithInvalidIDsFile;
};
/*static*/ DevTools* DevTools::instance = nullptr;
/*static*/ const QString DevTools::SAVE_PATH = "shortcut_mgr_dev/";
/*static*/ const QString DevTools::INVALID_ID_ACTIONS_SUFFIX = "_actions_with_invalid_IDs";
/*static*/ const QString DevTools::XML_SECTION_TOKENS_SEPARATOR = ":";
/*static*/ const QString DevTools::SHORTCUTS_SUFFIX = "_shortcuts";
/*static*/ const QString DevTools::SHORTCUTS_OF_META_SUFFIX = "_shortcuts_of_meta_actions";
/*static*/ const QString DevTools::ASSETS_SUFFIX = "_assets";
/*static*/ const QString DevTools::ASSETS_OF_META_SUFFIX = "_assets_of_meta_actions";
/*static*/ const QString DevTools::SECTION_NAME_ACTION_IDS_TO_THROW_EXCEPTION = "SHORTCUT_MGR_DEVTOOLS_Action_IDs_to_throw_exception";
/*static*/ const QString DevTools::SECTION_NAME_ACTION_TOOLTIPS_TO_THROW_EXCEPTION = "SHORTCUT_MGR_DEVTOOLS_Action_tooltips_to_throw_exception";
#endif // SHORTCUT_MGR_DEVTOOLS



SUIT_ShortcutContainer::SUIT_ShortcutContainer()
{
  myShortcuts.emplace(SUIT_ShortcutMgr::ROOT_MODULE_ID, std::map<QKeySequence, QString>());
  myShortcutsInversed.emplace(SUIT_ShortcutMgr::ROOT_MODULE_ID, std::map<QString, QKeySequence>());
}

std::set<QString> SUIT_ShortcutContainer::getIDsOfInterferingModules(const QString& theModuleID) const
{
  std::set<QString> IDsOfInterferingModules;
  if (theModuleID == SUIT_ShortcutMgr::ROOT_MODULE_ID) {
    for (const auto& moduleIDAndShortcuts : myShortcuts) {
      IDsOfInterferingModules.emplace(moduleIDAndShortcuts.first);
    }
  }
  else {
    IDsOfInterferingModules.emplace(SUIT_ShortcutMgr::ROOT_MODULE_ID);
    if (theModuleID != SUIT_ShortcutMgr::ROOT_MODULE_ID)
      IDsOfInterferingModules.emplace(theModuleID);
  }
  return IDsOfInterferingModules;
}

std::set<QString> SUIT_ShortcutContainer::getIDsOfAllModules() const
{
  std::set<QString> res;
  for (const auto& moduleIDAndShortcuts : myShortcutsInversed) {
    res.emplace(moduleIDAndShortcuts.first);
  }
  return res;
}

bool SUIT_ShortcutContainer::isEmpty() const
{
  for (const auto& moduleIDAndShortcuts : myShortcutsInversed) {
    const auto& moduleShortcutsInversed = moduleIDAndShortcuts.second;
    if (!moduleShortcutsInversed.empty())
      return false;
  }
  return true;
}

std::set<std::pair<QString, QString>> SUIT_ShortcutContainer::setShortcut(QString theModuleID, const QString& theInModuleActionID, const QKeySequence& theKeySequence, bool theOverride)
{
  if (!SUIT_ShortcutMgr::isModuleIDValid(theModuleID)) {
    ShCutDbg() && ShCutDbg("Attempt to define a shortcut using invalid module ID = \"" + theModuleID + "\".");
    return std::set<std::pair<QString, QString>>();
  }

  if (!SUIT_ShortcutMgr::isInModuleActionIDValid(theInModuleActionID)) {
    ShCutDbg() && ShCutDbg("Attempt to define a shortcut using invalid in-module action ID = \"" + theInModuleActionID + "\".");
    return std::set<std::pair<QString, QString>>();
  }

  if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID))
    theModuleID = SUIT_ShortcutMgr::ROOT_MODULE_ID;

  auto itModuleShortcuts = myShortcuts.find(theModuleID);
  auto itModuleShortcutsInversed = myShortcutsInversed.find(theModuleID);
  if (itModuleShortcuts == myShortcuts.end()) {
    itModuleShortcuts = myShortcuts.emplace(theModuleID, std::map<QKeySequence, QString>()).first;
    itModuleShortcutsInversed = myShortcutsInversed.emplace(theModuleID, std::map<QString, QKeySequence>()).first;
  }

  std::map<QKeySequence, QString>& moduleShortcuts = itModuleShortcuts->second;
  std::map<QString, QKeySequence>& moduleShortcutsInversed = itModuleShortcutsInversed->second;

  if (theKeySequence.isEmpty()) {
    // Disable shortcut.

    auto itShortcutInversed = moduleShortcutsInversed.find(theInModuleActionID);
    if (itShortcutInversed == moduleShortcutsInversed.end()) {
      // No key sequence was mapped to the action earlier.
      // Set disabled shortcut.
      moduleShortcutsInversed.emplace(theInModuleActionID, NO_KEYSEQUENCE);
      return std::set<std::pair<QString, QString>>();
    }
    else /* if keySequence was mapped to the action earlier. */ {
      QKeySequence& keySequence = itShortcutInversed->second;

      moduleShortcuts.erase(keySequence);
      keySequence = NO_KEYSEQUENCE;

      return std::set<std::pair<QString, QString>>();
    }
  }

  { // Check if the shortcut is already set.
    const auto itShortcut = moduleShortcuts.find(theKeySequence);
    if (itShortcut != moduleShortcuts.end()) {
      if (itShortcut->second == theInModuleActionID) {
        // The shortcut was set earlier. Nothing to change.
        return std::set<std::pair<QString, QString>>();
      }
    }
  }

  auto conflictingActionIDs = std::set<std::pair<QString, QString>>();
  { // Look for conflicting shortcuts with the same key sequence from interfering modules.
    std::set<QString> IDsOfInterferingModules = getIDsOfInterferingModules(theModuleID);
    for (const QString& IDOfInterferingModule : IDsOfInterferingModules) {
      std::map<QKeySequence, QString>& shortcutsOfInterferingModule = myShortcuts.at(IDOfInterferingModule);
      auto itConflictingShortcut = shortcutsOfInterferingModule.find(theKeySequence);
      if (itConflictingShortcut != shortcutsOfInterferingModule.end()) {
        const QString& conflictingActionID = itConflictingShortcut->second;

        conflictingActionIDs.insert(std::pair<QString, QString>(IDOfInterferingModule, conflictingActionID));

        if (theOverride) {
          // Disable conflicting shortcuts.
          std::map<QString, QKeySequence>& shortcutsOfInterferingModuleInversed = myShortcutsInversed.at(IDOfInterferingModule);
          shortcutsOfInterferingModuleInversed[conflictingActionID] = NO_KEYSEQUENCE;
          shortcutsOfInterferingModule.erase(itConflictingShortcut);
        }
      }
    }

    if (!theOverride && !conflictingActionIDs.empty())
      return conflictingActionIDs;
  }

  { // Ensure, that the module has only shortcut for the action ID.
    auto itShortcutInversed = moduleShortcutsInversed.find(theInModuleActionID);
    if (itShortcutInversed != moduleShortcutsInversed.end()) {
      // Redefine key sequence for existing action.

      QKeySequence& keySequence = itShortcutInversed->second;

      moduleShortcuts.erase(keySequence);
      moduleShortcuts[theKeySequence] = theInModuleActionID;

      keySequence = theKeySequence;
    }
    else /* if the action has not been added earlier. */ {
      moduleShortcuts[theKeySequence] = theInModuleActionID;
      moduleShortcutsInversed[theInModuleActionID] = theKeySequence;
    }
  }

  return conflictingActionIDs;
}

std::set<std::pair<QString, QString>> SUIT_ShortcutContainer::getConflicts(
  QString theModuleID,
  const QString& theInModuleActionID,
  const QKeySequence& theKeySequence
) const
{
  if (theKeySequence.isEmpty())
    return std::set<std::pair<QString, QString>>();

  if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID))
    theModuleID = SUIT_ShortcutMgr::ROOT_MODULE_ID;

  { // Check if the shortcut is set.
    const auto itModuleShortcuts = myShortcuts.find(theModuleID);
    if (itModuleShortcuts != myShortcuts.end()) {
      const std::map<QKeySequence, QString>& moduleShortcuts = itModuleShortcuts->second;
      const auto itShortcut = moduleShortcuts.find(theKeySequence);
      if (itShortcut != moduleShortcuts.end()) {
        if (itShortcut->second == theInModuleActionID) {
          // The shortcut is set => no conflicts.
          return std::set<std::pair<QString, QString>>();
        }
      }
    }
  }

  auto conflictingActionIDs = std::set<std::pair<QString, QString>>();
  { // Look for conflicting shortcuts with the same key sequence from interfering modules.
    std::set<QString> IDsOfInterferingModules = getIDsOfInterferingModules(theModuleID);
    for (const QString& IDOfInterferingModule : IDsOfInterferingModules) {
      const std::map<QKeySequence, QString>& shortcutsOfInterferingModule = myShortcuts.at(IDOfInterferingModule);
      const auto itConflictingShortcut = shortcutsOfInterferingModule.find(theKeySequence);
      if (itConflictingShortcut != shortcutsOfInterferingModule.end()) {
        const QString& conflictingActionID = itConflictingShortcut->second;
        conflictingActionIDs.insert(std::pair<QString, QString>(IDOfInterferingModule, conflictingActionID));
      }
    }
  }
  return conflictingActionIDs;
}

const QKeySequence& SUIT_ShortcutContainer::getKeySequence(QString theModuleID, const QString& theInModuleActionID) const
{
  if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID))
    theModuleID = SUIT_ShortcutMgr::ROOT_MODULE_ID;

  const auto itModuleShortcutsInversed = myShortcutsInversed.find(theModuleID);
  if (itModuleShortcutsInversed == myShortcutsInversed.end())
    return NO_KEYSEQUENCE;

  const auto& moduleShortcutsInversed = itModuleShortcutsInversed->second;
  const auto itShortcutInversed = moduleShortcutsInversed.find(theInModuleActionID);
  if (itShortcutInversed == moduleShortcutsInversed.end())
    return NO_KEYSEQUENCE;

  return itShortcutInversed->second;
}

bool SUIT_ShortcutContainer::hasShortcut(QString theModuleID, const QString& theInModuleActionID) const
{
  if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID))
    theModuleID = SUIT_ShortcutMgr::ROOT_MODULE_ID;

  const auto itModuleShortcutsInversed = myShortcutsInversed.find(theModuleID);
  if (itModuleShortcutsInversed == myShortcutsInversed.end())
    return false;

  const auto& moduleShortcutsInversed = itModuleShortcutsInversed->second;
  const auto itShortcutInversed = moduleShortcutsInversed.find(theInModuleActionID);
  if (itShortcutInversed == moduleShortcutsInversed.end())
    return false;

  return true;
}

const std::map<QString, QKeySequence>& SUIT_ShortcutContainer::getModuleShortcutsInversed(const QString& theModuleID) const
{
  static const std::map<QString, QKeySequence> EMPTY_RES;
  const auto it = myShortcutsInversed.find(theModuleID);
  if (it == myShortcutsInversed.end())
    return EMPTY_RES;

  return it->second;
}

const std::map<QString, QKeySequence> SUIT_ShortcutContainer::getModuleShortcutsInversed(const QString& theModuleID, const QString& theActionIDPrefix) const
{
  const auto it = myShortcutsInversed.find(theModuleID);
  if (it == myShortcutsInversed.end())
    return std::map<QString, QKeySequence>();

  std::map<QString, QKeySequence> shortcutsInversed;
  for (const auto& existingShortcut : it->second) {
    if (existingShortcut.first.startsWith(theActionIDPrefix))
      shortcutsInversed[existingShortcut.first] = existingShortcut.second;
  }
  return shortcutsInversed;
}

bool SUIT_ShortcutContainer::hasKeySequence(const QString& theModuleID, const QKeySequence& theKeySequence) const
{
  const auto itModuleShortcuts = myShortcuts.find(theModuleID);
  if (itModuleShortcuts == myShortcuts.end())
    return false;

  const auto& moduleShortcuts = itModuleShortcuts->second;
  return moduleShortcuts.find(theKeySequence) != moduleShortcuts.end();
}

QString SUIT_ShortcutContainer::toString() const
{
  QString text;
  text += "Shortcuts inversed:\n";
  for (auto it = myShortcutsInversed.begin(); it != myShortcutsInversed.end(); it++) {
    const QString& moduleID = it->first;
    const auto& moduleShortcuts = it->second;
    text += (it == myShortcutsInversed.begin() ? "\"" : "\n\"")  + moduleID + "\"";
    for (const auto& shortcut : moduleShortcuts) {
      text += "\n\t\"" + shortcut.first + "\"\t\"" + shortcut.second.toString() + "\"";
    }
  }
  text += "\nShortcuts:\n";
  for (auto it = myShortcuts.begin(); it != myShortcuts.end(); it++) {
    const QString& moduleID = it->first;
    const auto& moduleShortcuts = it->second;
    text += (it == myShortcuts.begin() ? "\"" : "\n\"")  + moduleID + "\"";
    for (const auto& shortcut : moduleShortcuts) {
      text += "\n\t\"" + shortcut.first.toString() + "\"\t\"" + shortcut.second + "\"";
    }
  }
  return text;
}

std::map<QString, std::map<QString, std::pair<QKeySequence, QKeySequence>>> SUIT_ShortcutContainer::merge(
  const SUIT_ShortcutContainer& theOther,
  bool theOverride,
  bool theTreatAbsentIncomingAsDisabled
) {
  std::map<QString, std::map<QString, std::pair<QKeySequence, QKeySequence>>> changesOfThis;

  const SUIT_ShortcutContainer copyOfThisBeforeMerge = *this; // TODO Get rid of whole container copying.

  for (const auto& shortcutsInversedOfOtherPair : theOther.myShortcutsInversed) {
    const QString& moduleIDOther = shortcutsInversedOfOtherPair.first;
    const auto& shortcutsInversedOther = shortcutsInversedOfOtherPair.second;
    for (const auto& shortcutInversedOther : shortcutsInversedOther) {
      const QString& inModuleActionIDOther = shortcutInversedOther.first;
      const QKeySequence& keySequenceOther = shortcutInversedOther.second;
      const QKeySequence& keySequenceThis  = getKeySequence(moduleIDOther, inModuleActionIDOther);
      if (theOverride) {
        if (hasShortcut(moduleIDOther, inModuleActionIDOther) && keySequenceThis == keySequenceOther) {
          continue;
        }
        else /* if this has no shortcut for the action  or  if this has a shortcut for the action, but the key sequence differs. */ {
          const auto disabledActionsOfThis = setShortcut(moduleIDOther, inModuleActionIDOther, keySequenceOther, true);
          //changesOfThis[moduleIDOther][inModuleActionIDOther] = std::pair<QKeySequence, QKeySequence>(keySequenceThis, keySequenceOther);
          changesOfThis[moduleIDOther][inModuleActionIDOther] = std::pair<QKeySequence, QKeySequence>(copyOfThisBeforeMerge.getKeySequence(moduleIDOther, inModuleActionIDOther), keySequenceOther);
          for (const auto& disabledActionOfThis : disabledActionsOfThis) {
            changesOfThis[disabledActionOfThis.first][disabledActionOfThis.second] = std::pair<QKeySequence, QKeySequence>(keySequenceOther, NO_KEYSEQUENCE);
          }
        }
      }
      else /* if (!theOverride) */ {
        if (hasShortcut(moduleIDOther, inModuleActionIDOther))
          continue;
        else {
          const auto conflictingActionsOfThis = setShortcut(moduleIDOther, inModuleActionIDOther, keySequenceOther, false);
          if (conflictingActionsOfThis.empty()) {
            changesOfThis[moduleIDOther][inModuleActionIDOther] = std::pair<QKeySequence, QKeySequence>(NO_KEYSEQUENCE, keySequenceOther);
          }
          else /* if this has no shortcut for the action, but the incoming key sequence conflicts with others shortcuts. */ {
            changesOfThis[moduleIDOther][inModuleActionIDOther] = std::pair<QKeySequence, QKeySequence>(NO_KEYSEQUENCE, NO_KEYSEQUENCE);
          }
        }
      }
    }
  }

  if (theOverride && theTreatAbsentIncomingAsDisabled) {
    // Disable existing shortcuts, if they are absent in theOther.
    for (auto& shortcutsInversedPair : myShortcutsInversed) {
      const QString& moduleID = shortcutsInversedPair.first;
      auto& moduleShortcutsInversed = shortcutsInversedPair.second;
      for (auto& inversedShortcut : moduleShortcutsInversed) {
        if (theOther.hasShortcut(moduleID, inversedShortcut.first))
          continue;

        if (inversedShortcut.second.isEmpty())
          continue; // Existing shortcut is already disabled.

        auto itShortcutsPair = myShortcuts.find(moduleID);
        if (itShortcutsPair == myShortcuts.end())
          continue; // The check is an overhead in an error-free designed class, but let be just in case.

        auto& moduleShortcuts = itShortcutsPair->second;
        moduleShortcuts.erase(inversedShortcut.second);
        changesOfThis[moduleID][inversedShortcut.first] = std::pair<QKeySequence, QKeySequence>(inversedShortcut.second, NO_KEYSEQUENCE);
        inversedShortcut.second = NO_KEYSEQUENCE;
      }
    }
  }

  return changesOfThis;
}


/*static*/ const QString SUIT_ShortcutAssets::LangDependentAssets::PROP_ID_NAME = "name";
/*static*/ const QString SUIT_ShortcutAssets::LangDependentAssets::PROP_ID_TOOLTIP = "tooltip";

bool SUIT_ShortcutAssets::LangDependentAssets::fromJSON(const QJsonObject& theJsonObject)
{
  myName    = theJsonObject[SUIT_ShortcutAssets::LangDependentAssets::PROP_ID_NAME].toString();
  myToolTip = theJsonObject[SUIT_ShortcutAssets::LangDependentAssets::PROP_ID_TOOLTIP].toString();

  if (myName.isEmpty())
    myName = myToolTip;

  return !myName.isEmpty();
}

void SUIT_ShortcutAssets::LangDependentAssets::toJSON(QJsonObject& oJsonObject) const
{
  if (!myName.isEmpty())
    oJsonObject[SUIT_ShortcutAssets::LangDependentAssets::PROP_ID_NAME] = myName;

  if (!myToolTip.isEmpty())
    oJsonObject[SUIT_ShortcutAssets::LangDependentAssets::PROP_ID_TOOLTIP] = myToolTip;
}


/*static*/ const QString SUIT_ShortcutAssets::PROP_ID_LANG_DEPENDENT_ASSETS = "langDependentAssets";
/*static*/ const QString SUIT_ShortcutAssets::PROP_ID_ICON_PATH = "iconPath";
/*static*/ const QString SUIT_ShortcutAssets::PROP_ID_CHILDREN = "children";

SUIT_ShortcutAssets::SUIT_ShortcutAssets(const QString& theModuleID)
: myModuleID(theModuleID)
{
  if (!SUIT_ShortcutMgr::isModuleIDValid(myModuleID))
    throw std::invalid_argument("SUIT_ShortcutAssets: invalid module ID \"" + myModuleID.toStdString() + "\".");
}

SUIT_ShortcutAssets::~SUIT_ShortcutAssets()
{}

const std::map<QString, std::shared_ptr<SUIT_ShortcutItemAssets>>& SUIT_ShortcutAssets::children() const
{
  return myChildren;
}

std::shared_ptr<SUIT_ShortcutItemAssets> SUIT_ShortcutAssets::findDescendantItem(const QString& theRelativeID) const
{
  QStringList tokens = SUIT_ShortcutMgr::splitIntoTokens(theRelativeID);
  if (tokens.isEmpty())
    return std::shared_ptr<SUIT_ShortcutItemAssets>(nullptr); // Without the check *this with casted-away constness is returned.

  std::shared_ptr<SUIT_ShortcutAssets> descendant = std::const_pointer_cast<SUIT_ShortcutAssets>(shared_from_this());
  while (!tokens.isEmpty()) {
    const QString& token = tokens.front();

    const auto itChild = descendant->myChildren.find(token);
    if (itChild == descendant->myChildren.end())
      return std::shared_ptr<SUIT_ShortcutItemAssets>(nullptr);

    descendant = itChild->second;
    tokens.pop_front();
  }
  return std::static_pointer_cast<SUIT_ShortcutItemAssets>(descendant);
}

std::shared_ptr<SUIT_ShortcutItemAssets> SUIT_ShortcutAssets::descendantItem(const QString& theRelativeID, bool theIsAction)
{
  QStringList tokens = SUIT_ShortcutMgr::splitIntoTokens(theRelativeID);
  if (tokens.isEmpty())
    return std::shared_ptr<SUIT_ShortcutItemAssets>(nullptr); // Without the check return value type must be SUIT_ShortcutAssets*.

  std::shared_ptr<SUIT_ShortcutAssets> descendant = std::const_pointer_cast<SUIT_ShortcutAssets>(shared_from_this());
  while (!tokens.isEmpty()) {
    const QString token = tokens.front();
    tokens.pop_front();

    auto itChild = descendant->myChildren.find(token);
    if (itChild == descendant->myChildren.end()) {
      const bool childIsAction = tokens.isEmpty() ? theIsAction : false; // Make missing ancestors pure folders.
      auto child = SUIT_ShortcutItemAssets::create(descendant, token, childIsAction);
      if (!child)
        return std::shared_ptr<SUIT_ShortcutItemAssets>(nullptr);

      itChild = descendant->myChildren.emplace(token, std::move(child)).first;
    }
    descendant = itChild->second;
  }
  return std::static_pointer_cast<SUIT_ShortcutItemAssets>(descendant);
}

bool SUIT_ShortcutAssets::fromJSONOwnProps(const QJsonObject& theJsonObject, const std::set<QString>& theLangs)
{
  myLangDependentAssets.clear();
  auto lda = SUIT_ShortcutAssets::LangDependentAssets();
  const auto& langToLdaJson = theJsonObject[SUIT_ShortcutAssets::PROP_ID_LANG_DEPENDENT_ASSETS].toObject();
  for (const QString& lang : langToLdaJson.keys()) {
    if (!theLangs.empty() && theLangs.find(lang) == theLangs.end())
      continue;

    if (!lda.fromJSON(langToLdaJson[lang].toObject()))
      continue;

    myLangDependentAssets[lang] = lda;
  }

  myIconPath = theJsonObject[SUIT_ShortcutAssets::PROP_ID_ICON_PATH].toString();
  const bool otherPropsParsed = fromJSONOtherProps(theJsonObject);

  return !myLangDependentAssets.empty() || !myIconPath.isEmpty() || otherPropsParsed;
}

bool SUIT_ShortcutAssets::fromJSON(const QJsonObject& theJsonObject, bool theParseDescendants, const std::set<QString>& theLangs)
{
  for (const auto& IDLTAndChild : myChildren) {
    IDLTAndChild.second->myParent.reset();
  }
  myChildren.clear();

  const bool ownPropsParsed = fromJSONOwnProps(theJsonObject, theLangs);

  if (theParseDescendants) {
    const auto& childrenJsonObject = theJsonObject[SUIT_ShortcutAssets::PROP_ID_CHILDREN].toObject();
    for (const QString& IDLastToken : childrenJsonObject.keys()) {
      if (!SUIT_ShortcutMgr::isInModuleIDTokenValid(IDLastToken)) {
        Warning("SUIT_ActionAssets::fromJSON: child assets with invalid IDLastToken \"" + IDLastToken + "\" have been encountered. *this is " + description());
        continue;
      }

      auto child = SUIT_ShortcutItemAssets::create(shared_from_this(), IDLastToken, false /*theIsAction*/);
      child->fromJSON(childrenJsonObject[IDLastToken].toObject(), true /*theParseDescendants*/, theLangs);
      myChildren.emplace(IDLastToken, std::move(child));
    }
  }

  return ownPropsParsed || !myChildren.empty();
}

bool SUIT_ShortcutAssets::fromJSON(const QJsonObject& theJsonObject, const QString& theRelativeID, const std::set<QString>& theLangs)
{
  for (const auto& IDLTAndChild : myChildren) {
    IDLTAndChild.second->myParent.reset();
  }
  myChildren.clear();

  const bool ownPropsParsed = fromJSONOwnProps(theJsonObject, theLangs);

  QStringList tokens = SUIT_ShortcutMgr::splitIntoTokens(theRelativeID);
  if (!tokens.isEmpty()) {
    const QString token = tokens.front();
    if (!SUIT_ShortcutMgr::isInModuleIDTokenValid(token))
      Warning("SUIT_ActionAssets::fromJSON: child assets with invalid IDLastToken \"" + token + "\" is requested. *this is " + description());
    else {
      const auto& childrenJsonObject = theJsonObject[SUIT_ShortcutAssets::PROP_ID_CHILDREN].toObject();
      const auto itChildJSONValue = childrenJsonObject.find(token);
      if (itChildJSONValue != childrenJsonObject.end()) {
        auto child = SUIT_ShortcutItemAssets::create(shared_from_this(), token, false /*theIsAction*/);
        tokens.pop_front();
        child->fromJSON(itChildJSONValue->toObject(), SUIT_ShortcutMgr::joinIntoRelativeID(tokens), theLangs);
        myChildren.emplace(token, std::move(child));
      }
    }
  }

  return ownPropsParsed || !myChildren.empty();
}

void SUIT_ShortcutAssets::toJSON(QJsonObject& oJsonObject) const
{
  if (!myLangDependentAssets.empty()) {
    auto langDependentAssetsJSON = QJsonObject();
    for (const auto& langAndLDA : myLangDependentAssets) {
      auto langDependentAssetsItemJSON = QJsonObject();
      langAndLDA.second.toJSON(langDependentAssetsItemJSON);
      langDependentAssetsJSON[langAndLDA.first] = langDependentAssetsItemJSON;
    }
    oJsonObject[SUIT_ShortcutAssets::PROP_ID_LANG_DEPENDENT_ASSETS] = langDependentAssetsJSON;
  }

  if (!myIconPath.isEmpty())
    oJsonObject[SUIT_ShortcutAssets::PROP_ID_ICON_PATH] = myIconPath;

  toJSONVirtual(oJsonObject);

  if (!myChildren.empty()) {
    auto childrenJSON = QJsonObject();
    for (const auto& IDLastTokenAndChild : myChildren) {
      auto childJSON = QJsonObject();
      IDLastTokenAndChild.second->toJSON(childJSON);
      childrenJSON[IDLastTokenAndChild.first] = childJSON;
    }
    oJsonObject[SUIT_ShortcutItemAssets::PROP_ID_CHILDREN] = childrenJSON;
  }
}

void SUIT_ShortcutAssets::merge(const SUIT_ShortcutAssets& theOther, bool theOverride)
{
  if (&theOther == this)
    return;

  if (myModuleID != theOther.myModuleID) {
    Warning("SUIT_ShortcutAssets::merge: attempt to merge assets with different module ID.");
    return;
  }

  for (const auto& otherLangAndLDA : theOther.myLangDependentAssets) {
    const QString& lang = otherLangAndLDA.first;
    const auto& otherLDA = otherLangAndLDA.second;
    auto& thisLDA = myLangDependentAssets[lang];

    if (thisLDA.myName.isEmpty() || theOverride && !otherLDA.myName.isEmpty())
      thisLDA.myName = otherLDA.myName;

    if (thisLDA.myToolTip.isEmpty() || theOverride && !otherLDA.myToolTip.isEmpty())
      thisLDA.myToolTip = otherLDA.myToolTip;
  }

  if (myIconPath.isEmpty() || theOverride && !theOther.myIconPath.isEmpty()) {
    myIconPath = theOther.myIconPath;
    if (!myIcon.isNull())
      loadIcon(true /*theReload*/);
  }

  for (const auto& otherChildIDLTAndChild : theOther.myChildren) {
    const QString& childIDLastToken = otherChildIDLTAndChild.first;
    const SUIT_ShortcutItemAssets& otherChild = *(otherChildIDLTAndChild.second);

    const auto itChild = myChildren.find(childIDLastToken);
    if (itChild == myChildren.end()) {
      auto child = SUIT_ShortcutItemAssets::create(shared_from_this(), childIDLastToken, false /*theIsAction*/);
      child->merge(otherChild, theOverride);
      myChildren.emplace(childIDLastToken, std::move(child));
    }
    else {
      std::shared_ptr<SUIT_ShortcutItemAssets> child = itChild->second;
      child->merge(otherChild, theOverride);
    }
  }
}

void SUIT_ShortcutAssets::merge(SUIT_ShortcutAssets&& theOther, bool theOverride)
{
  if (&theOther == this)
    return;

  if (myModuleID != theOther.myModuleID) {
    Warning("SUIT_ShortcutAssets::merge: attempt to merge assets with different module ID.");
    return;
  }

  for (auto itOtherLangAndLDA = theOther.myLangDependentAssets.begin(); itOtherLangAndLDA != theOther.myLangDependentAssets.end();) {
    const QString& lang = itOtherLangAndLDA->first;
    const auto& otherLDA = itOtherLangAndLDA->second;

    const auto itThisLDA = myLangDependentAssets.find(lang);
    if (itThisLDA == myLangDependentAssets.end()) {
      myLangDependentAssets.emplace(lang, std::move(otherLDA));
      itOtherLangAndLDA = theOther.myLangDependentAssets.erase(itOtherLangAndLDA);
      continue;
    }

    auto& thisLDA = itThisLDA->second;

    if (thisLDA.myName.isEmpty() || theOverride && !otherLDA.myName.isEmpty())
      thisLDA.myName = otherLDA.myName;

    if (thisLDA.myToolTip.isEmpty() || theOverride && !otherLDA.myToolTip.isEmpty())
      thisLDA.myToolTip = otherLDA.myToolTip;

    itOtherLangAndLDA++;
  }

  if (myIconPath.isEmpty() || theOverride && !theOther.myIconPath.isEmpty()) {
    myIconPath = std::move(theOther.myIconPath);
    if (!myIcon.isNull()) {
      if (theOther.myIcon.isNull())
        loadIcon(true /*theReload*/);
      else
        myIcon = std::move(theOther.myIcon);
    }
  }

  for (auto itOtherChildIDLTAndChild = theOther.myChildren.begin(); itOtherChildIDLTAndChild != theOther.myChildren.end(); ) {
    const QString& childIDLastToken = itOtherChildIDLTAndChild->first;
    const auto& otherChild = itOtherChildIDLTAndChild->second;

    const auto itChild = myChildren.find(childIDLastToken);
    if (itChild == myChildren.end()) {
      auto child = otherChild; // Acquire ownership.
      child->myParent = shared_from_this();
      itOtherChildIDLTAndChild = theOther.myChildren.erase(itOtherChildIDLTAndChild);
      myChildren.emplace(childIDLastToken, std::move(child));
    }
    else {
      std::shared_ptr<SUIT_ShortcutItemAssets> child = itChild->second;
      child->merge(*otherChild, theOverride);
      itOtherChildIDLTAndChild++;
    }
  }
}

void SUIT_ShortcutAssets::loadIcon(bool theReload)
{
  if (!myIconPath.isEmpty() && (myIcon.isNull() || theReload))
    myIcon = QIcon(::SUIT_tools::substituteVars(myIconPath));
}

void SUIT_ShortcutAssets::forEachDescendant(const std::function<void(SUIT_ShortcutItemAssets&)>& theFunc) const
{
  for (const auto& childIDLTAndChild : myChildren) {
    SUIT_ShortcutItemAssets& child = *(childIDLTAndChild.second);
    theFunc(child);
    child.forEachDescendant(theFunc);
  }
}

void SUIT_ShortcutAssets::forEachDescendant(const std::function<void(const SUIT_ShortcutItemAssets&)>& theFunc) const
{
  for (const auto& childIDLTAndChild : myChildren) {
    const SUIT_ShortcutItemAssets& child = *(childIDLTAndChild.second);
    theFunc(child);
    child.forEachDescendant(theFunc);
  }
}

void SUIT_ShortcutAssets::forEachDescendant(const std::function<void(std::shared_ptr<SUIT_ShortcutItemAssets>)>& theFunc) const
{
  for (const auto& childIDLTAndChild : myChildren) {
    const std::shared_ptr<SUIT_ShortcutItemAssets>& child = childIDLTAndChild.second;
    theFunc(child);
    child->forEachDescendant(theFunc);
  }
}

void SUIT_ShortcutAssets::forEachDescendant(const std::function<void(std::shared_ptr<const SUIT_ShortcutItemAssets>)>& theFunc) const
{
  for (const auto& childIDLTAndChild : myChildren) {
    const std::shared_ptr<const SUIT_ShortcutItemAssets>& child = childIDLTAndChild.second;
    theFunc(child);
    child->forEachDescendant(theFunc);
  }
}

QString SUIT_ShortcutAssets::toString() const
{
  QJsonObject jsonObject;
  toJSON(jsonObject);
  return QString::fromStdString(QJsonDocument(jsonObject).toJson(QJsonDocument::Indented).toStdString());
}

QStringList SUIT_ShortcutAssets::getLangs() const
{
  QStringList langs;

  for (const auto& langAndAssets : myLangDependentAssets) {
    langs.push_back(langAndAssets.first);
  }

  return langs;
}

void SUIT_ShortcutAssets::clearAllLangsExcept(const QString& theLang)
{
  for (auto it = myLangDependentAssets.begin(); it != myLangDependentAssets.end();) {
    if (it->first == theLang)
      it++;
    else
      it = myLangDependentAssets.erase(it);
  }
}

const SUIT_ShortcutAssets::LangDependentAssets* SUIT_ShortcutAssets::bestLangDependentAssets(QString theLang) const
{
  if (theLang.isEmpty())
    theLang = SUIT_ShortcutMgr::currentLang();

  auto langPriorityList = QStringList({DEFAULT_LANG});
  langPriorityList.push_front(theLang);
  langPriorityList.removeDuplicates();

  for (const QString& lang : langPriorityList) {
    const auto it = myLangDependentAssets.find(lang);
    if (it != myLangDependentAssets.end())
      return &(it->second);
  }

  // Return any other LDA, if exist.
  if (!myLangDependentAssets.empty())
    return &(myLangDependentAssets.begin()->second);

  return nullptr;
}

const QString& SUIT_ShortcutAssets::bestToolTip(const QString& theLang) const
{
  static const QString dummyString = QString();
  const auto bestLDA = bestLangDependentAssets(theLang);
  if (bestLDA)
    return bestLDA->myToolTip;
  else
    return dummyString;
}


SUIT_ShortcutModuleAssets::SUIT_ShortcutModuleAssets(const QString& theModuleID)
: SUIT_ShortcutAssets(theModuleID)
{}

/*static*/ std::shared_ptr<SUIT_ShortcutModuleAssets> SUIT_ShortcutModuleAssets::create(const QString& theModuleID)
{
  if (!SUIT_ShortcutMgr::isModuleIDValid(theModuleID))
    return std::shared_ptr<SUIT_ShortcutModuleAssets>(nullptr);

  return std::shared_ptr<SUIT_ShortcutModuleAssets>(new SUIT_ShortcutModuleAssets(theModuleID));
}

const QString& SUIT_ShortcutModuleAssets::bestName(const QString& theLang) const
{
  const auto bestLDA = bestLangDependentAssets(theLang);
  if (bestLDA)
    return bestLDA->myName;
  else
    return myModuleID;
}

QString SUIT_ShortcutModuleAssets::description() const
{
  return "SUIT_ShortcutModuleAssets \"" + myModuleID + "\".";
}


/*static*/ void SUIT_ShortcutItemAssets::loadDefaultIcons()
{
  SUIT_ShortcutItemAssets::DEFAUT_ICON_ACTION = QIcon(":/resources/default_action_icon.svg");
  SUIT_ShortcutItemAssets::DEFAUT_ICON_FOLDER = QIcon(":/resources/default_folder_icon.svg");
  SUIT_ShortcutItemAssets::DEFAUT_ICON_FOLDER_ACTION = QIcon(":/resources/default_folder_action_icon.svg");
}

/*static*/ const QString SUIT_ShortcutItemAssets::PROP_ID_IS_ACTION = "isAction";
/*static*/ QIcon SUIT_ShortcutItemAssets::DEFAUT_ICON_ACTION = QIcon();
/*static*/ QIcon SUIT_ShortcutItemAssets::DEFAUT_ICON_FOLDER = QIcon();
/*static*/ QIcon SUIT_ShortcutItemAssets::DEFAUT_ICON_FOLDER_ACTION = QIcon();

SUIT_ShortcutItemAssets::SUIT_ShortcutItemAssets(std::shared_ptr<SUIT_ShortcutModuleAssets> theModule, const QString& theIDLastToken, bool theIsAction)
: SUIT_ShortcutAssets(theModule->myModuleID), myParent(theModule), myIsAction(theIsAction), myIDLastToken(theIDLastToken), myInModuleID(theIDLastToken), myDepth(myInModuleID.split(TOKEN_SEPARATOR).length())
{}

SUIT_ShortcutItemAssets::SUIT_ShortcutItemAssets(std::shared_ptr<SUIT_ShortcutItemAssets> theParentItem, const QString& theIDLastToken, bool theIsAction)
: SUIT_ShortcutAssets(theParentItem->myModuleID), myParent(theParentItem), myIsAction(theIsAction),
  myIDLastToken(theIDLastToken), myInModuleID(theParentItem->myInModuleID + TOKEN_SEPARATOR + theIDLastToken), myDepth(SUIT_ShortcutMgr::splitIntoTokens(myInModuleID).length())
{}

/*static*/ std::shared_ptr<SUIT_ShortcutItemAssets> SUIT_ShortcutItemAssets::create(std::shared_ptr<SUIT_ShortcutAssets> theParentItemOrModule, const QString& theIDLastToken, bool theIsAction)
{
  auto res = std::shared_ptr<SUIT_ShortcutItemAssets>(nullptr);

  if (!theParentItemOrModule)
    return res;

  switch (theParentItemOrModule->type()) {
    case SUIT_ShortcutAssets::Type::Module:
    {
      const auto moduleAssets = std::static_pointer_cast<SUIT_ShortcutModuleAssets>(theParentItemOrModule);
      if (!SUIT_ShortcutMgr::isInModuleIDTokenValid(theIDLastToken)) {
        Warning(QString("SUIT_ShortcutItemAssets::create: invalid inModuleID (last token of ID of root item) \"") + theIDLastToken + "\". Parent is module \"" + moduleAssets->myModuleID + "\".");
        return res;
      }

      res.reset(new SUIT_ShortcutItemAssets(moduleAssets, theIDLastToken, theIsAction));
      return res;
    };
    case SUIT_ShortcutAssets::Type::Item:
    {
      const auto itemAssets = std::static_pointer_cast<SUIT_ShortcutItemAssets>(theParentItemOrModule);
      if (!SUIT_ShortcutMgr::isInModuleIDTokenValid(theIDLastToken)) {
        Warning(QString("SUIT_ShortcutItemAssets::create: invalid last token of ID \"") + theIDLastToken + "\". Parent is item \"" + itemAssets->actionID() + "\".");
        return res;
      }

      res.reset(new SUIT_ShortcutItemAssets(itemAssets, theIDLastToken, theIsAction));
      return res;
    };
    default:
      return res;
  }
}

int SUIT_ShortcutItemAssets::depth() const
{
  return myDepth;
}

void SUIT_ShortcutItemAssets::merge(const SUIT_ShortcutItemAssets& theOther, bool theOverride)
{
  if (&theOther == this)
    return;

  if (myInModuleID != theOther.myInModuleID) {
    Warning("SUIT_ShortcutItemAssets::merge: attempt to merge assets with different IDs: \"" + theOther.myModuleID + TOKEN_SEPARATOR + theOther.myInModuleID + "\" into \"" + myModuleID + TOKEN_SEPARATOR + myInModuleID + "\".");
    return;
  }

  SUIT_ShortcutAssets::merge(theOther, theOverride);

  myIsAction = myIsAction || theOther.myIsAction;
}

void SUIT_ShortcutItemAssets::merge(SUIT_ShortcutItemAssets&& theOther, bool theOverride)
{
  if (&theOther == this)
    return;

  if (myInModuleID != theOther.myInModuleID) {
    Warning("SUIT_ShortcutItemAssets::merge: attempt to merge assets with different IDs: \"" + theOther.myModuleID + TOKEN_SEPARATOR + theOther.myInModuleID + "\" into \"" + myModuleID + TOKEN_SEPARATOR + myInModuleID + "\".");
    return;
  }

  SUIT_ShortcutAssets::merge(theOther, theOverride);

  myIsAction = myIsAction || theOther.myIsAction;
}

bool SUIT_ShortcutItemAssets::fromJSONOtherProps(const QJsonObject& theJsonObject)
{
  myIsAction = theJsonObject[SUIT_ShortcutItemAssets::PROP_ID_IS_ACTION].toBool(true);
  return !myIsAction;
}

void SUIT_ShortcutItemAssets::toJSONVirtual(QJsonObject& oJsonObject) const
{
  if (!myIsAction)
    oJsonObject[SUIT_ShortcutItemAssets::PROP_ID_IS_ACTION] = false;
}

const QString& SUIT_ShortcutItemAssets::bestName(const QString& theLang) const
{
  const auto bestLDA = bestLangDependentAssets(theLang);
  if (bestLDA)
    return bestLDA->myName;
  else
    return myIDLastToken;
}

const QString& SUIT_ShortcutItemAssets::bestPath(QString theLang) const
{
  if (theLang.isEmpty())
    theLang = SUIT_ShortcutMgr::currentLang();

  auto itBestPath = myBestPaths.find(theLang);
  if (itBestPath != myBestPaths.end())
    return itBestPath->second;

  QString path = bestName(theLang);
  std::shared_ptr<const SUIT_ShortcutAssets> ancestor = parent();
  int ancestorDepth = depth() - 1;
  while (ancestor && ancestor->type() == SUIT_ShortcutAssets::Type::Item) {
    const auto ancestorItem = std::static_pointer_cast<const SUIT_ShortcutItemAssets>(ancestor);
    path = ancestorItem->bestName(theLang) + TOKEN_SEPARATOR + path;
    ancestor = ancestorItem->parent();
    ancestorDepth--;
  }

  if (ancestorDepth > 0) {
    Warning(QString("SUIT_ShortcutItemAssets::bestPath: instance \"") + actionID() + "\" is dangling at depth " + QString::number(ancestorDepth) + ". ");
    auto tokens = SUIT_ShortcutMgr::splitIntoTokens(myInModuleID);
    for (int i = ancestorDepth; i > 0; i--) {
      path = tokens[i] + TOKEN_SEPARATOR + path;
    }
  }

  itBestPath = myBestPaths.emplace(theLang, path).first;
  return itBestPath->second;
}

QString SUIT_ShortcutItemAssets::description() const
{
  return QString("SUIT_ShortcutItemAssets ") + (myIsAction ? "" : "(not action)") + " \"" + actionID() + "\".";
}

bool SUIT_ShortcutItemAssets::isAction() const
{
  return myIsAction;
}

bool SUIT_ShortcutItemAssets::isFolder() const
{
  return !myIsAction || !children().empty();
}

std::shared_ptr<SUIT_ShortcutAssets> SUIT_ShortcutItemAssets::parent() const
{
  return myParent.lock();
}

std::shared_ptr<SUIT_ShortcutModuleAssets> SUIT_ShortcutItemAssets::module() const
{
  std::shared_ptr<SUIT_ShortcutAssets> ancestor = parent();
  while (ancestor) {
    if (ancestor->type() == SUIT_ShortcutAssets::Type::Module)
      return std::static_pointer_cast<SUIT_ShortcutModuleAssets>(ancestor);
    else if (ancestor->type() == SUIT_ShortcutAssets::Type::Item)
      ancestor = std::static_pointer_cast<SUIT_ShortcutItemAssets>(ancestor)->parent();
    else {
      Warning("SUIT_ShortcutItemAssets::module: unexpected SUIT_ShortcutAssets::Type has been encountered. Fix the method!");
      return std::shared_ptr<SUIT_ShortcutModuleAssets>(nullptr);
    }
  }
  return std::shared_ptr<SUIT_ShortcutModuleAssets>(nullptr);
}

QString SUIT_ShortcutItemAssets::actionID() const
{
  return myModuleID + TOKEN_SEPARATOR + myInModuleID;
}

const QIcon& SUIT_ShortcutItemAssets::icon() const
{
  if (myIcon.isNull()) {
    if (myIsAction) {
      if (children().empty())
        return SUIT_ShortcutItemAssets::DEFAUT_ICON_ACTION;
      else
        return SUIT_ShortcutItemAssets::DEFAUT_ICON_FOLDER_ACTION;
    }
    else
      return SUIT_ShortcutItemAssets::DEFAUT_ICON_FOLDER;
  }
  else
    return myIcon;
}


SUIT_ShortcutMgr* SUIT_ShortcutMgr::myShortcutMgr = nullptr;

SUIT_ShortcutMgr::SUIT_ShortcutMgr()
: QObject(), myActiveModuleIDs({SUIT_ShortcutMgr::ROOT_MODULE_ID}), myAssetsLoaded(false)
{
  Q_INIT_RESOURCE( SUIT );
  qApp->installEventFilter( this );
  SUIT_ShortcutItemAssets::loadDefaultIcons();
}

SUIT_ShortcutMgr::~SUIT_ShortcutMgr()
{
  qApp->removeEventFilter( this );
}

/*static*/ void SUIT_ShortcutMgr::Init()
{
  if( myShortcutMgr == nullptr) {
    ShCutDbg("SUIT_ShortcutMgr initialization has started.");
    myShortcutMgr = new SUIT_ShortcutMgr();
    myShortcutMgr->setAssetsFromResources();
    myShortcutMgr->setShortcutsFromPreferences();

    { // Migrate old shortcut preferences.
      SUIT_ShortcutHistorian historian;
      myShortcutMgr->mergeShortcutContainer(
        historian.getContainerWithOldShortcuts(),
        true /*theOverride*/,
        false /*theTreatAbsentIncomingAsDisabled*/,
        true /*theSaveToPreferences*/
      );

      historian.removeOldShortcutPreferences();
    }

    ShCutDbg("SUIT_ShortcutMgr initialization has finished.");
  }
}

/*static*/ SUIT_ShortcutMgr* SUIT_ShortcutMgr::get()
{
  Init();
  return myShortcutMgr;
}

/*static*/ bool SUIT_ShortcutMgr::isKeySequenceValid(const QKeySequence& theKeySequence)
{
  // TODO Perform check whether a key sequence is platform-compatible.
  return true;
}

/*static*/ std::pair<bool, QKeySequence> SUIT_ShortcutMgr::toKeySequenceIfValid(const QString& theKeySequenceString)
{
  auto res = std::pair<bool, QKeySequence>(false, QKeySequence());

  try {
    res.second = QKeySequence::fromString(theKeySequenceString);
    if (res.second.toString() != theKeySequenceString)
      return std::pair<bool, QKeySequence>(false, QKeySequence());

    if (!SUIT_ShortcutMgr::isKeySequenceValid(res.second))
      return std::pair<bool, QKeySequence>(false, QKeySequence());
  }
  catch (...) {
    return std::pair<bool, QKeySequence>(false, QKeySequence());
  }

  res.first = true;
  return res;
}

/*static*/ bool SUIT_ShortcutMgr::isModuleIDValid(const QString& theModuleID)
{
  if (theModuleID.contains(TOKEN_SEPARATOR))
    return false;

  if (theModuleID.simplified() != theModuleID)
    return false;

  return true;
}

/*static*/ bool SUIT_ShortcutMgr::isInModuleIDTokenValid(const QString& theInModuleIDToken)
{
  if (theInModuleIDToken.contains(TOKEN_SEPARATOR))
    return false;

  const QString simplifiedToken = theInModuleIDToken.simplified();
  return !simplifiedToken.isEmpty() &&
         simplifiedToken == theInModuleIDToken &&
         simplifiedToken != META_ACTION_PREFIX;
}

/*static*/ bool SUIT_ShortcutMgr::isInModuleIDTokenMeta(const QString& theInModuleIDToken)
{
  return theInModuleIDToken.startsWith(META_ACTION_PREFIX);
}

/*static*/ bool SUIT_ShortcutMgr::isInModuleActionIDValid(const QString& theInModuleActionID)
{
  const QStringList tokens = SUIT_ShortcutMgr::splitIntoTokens(theInModuleActionID);

  if (tokens.isEmpty())
    return false;

  for (const QString& token : tokens) {
    if (!SUIT_ShortcutMgr::isInModuleIDTokenValid(token))
      return false;
  }
  return true;
}

/*static*/ bool SUIT_ShortcutMgr::isInModuleMetaActionID(const QString& theInModuleActionID)
{
  const QStringList tokens = SUIT_ShortcutMgr::splitIntoTokens(theInModuleActionID);
  if (tokens.isEmpty())
    return false;

  return SUIT_ShortcutMgr::isInModuleIDTokenMeta(tokens.back());
}

/*static*/ std::pair<QString, QString> SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(const QString& theActionID)
{
  QStringList tokens = theActionID.split(TOKEN_SEPARATOR);
  if (tokens.length() < 2)
    return std::pair<QString, QString>();

  auto res = std::pair<QString, QString>();

  if (tokens[0].simplified() != tokens[0])
    return std::pair<QString, QString>();

  res.first = tokens[0];
  tokens.pop_front();

  for (const QString& token : tokens) {
    if (!SUIT_ShortcutMgr::isInModuleIDTokenValid(token))
      return std::pair<QString, QString>();
  }
  res.second = tokens.join(TOKEN_SEPARATOR);

  return res;
}

/*static*/ QStringList SUIT_ShortcutMgr::splitIntoTokens(const QString& theRelativeID)
{
  if (theRelativeID.isEmpty())
    return QStringList();

  return theRelativeID.split(TOKEN_SEPARATOR);
}

/*static*/ QString SUIT_ShortcutMgr::joinIntoRelativeID(const QStringList& theTokens)
{
  return theTokens.join(TOKEN_SEPARATOR);
}

/*static*/ bool SUIT_ShortcutMgr::isActionIDValid(const QString& theActionID)
{
  return !SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(theActionID).second.isEmpty();
}

/*static*/ QString SUIT_ShortcutMgr::makeActionID(const QString& theModuleID, const QString& theInModuleActionID)
{
  if (!SUIT_ShortcutMgr::isModuleIDValid(theModuleID))
    return QString();

  if (!isInModuleActionIDValid(theInModuleActionID))
    return QString();

  return theModuleID + TOKEN_SEPARATOR + theInModuleActionID;
}

/*static*/ void SUIT_ShortcutMgr::fillContainerFromPreferences(SUIT_ShortcutContainer& theContainer, bool theDefaultOnly)
{
  return SUIT_ShortcutMgr::fillContainerFromPreferences(theContainer, theDefaultOnly, SECTION_NAME_PREFIX);
}

/*static*/ void SUIT_ShortcutMgr::fillContainerFromPreferences(SUIT_ShortcutContainer& theContainer, bool theDefaultOnly, const QString& theSectionNamePrefix)
{
  ShCutDbg() && ShCutDbg(QString("SUIT_ShortcutMgr::fillContainerFromPreferences(theContainer, theDefaultOnly = ") + (theDefaultOnly ? "true" : "false") + ", theSectionPrefix = \"" + theSectionNamePrefix + "\") started.");

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutMgr can't retrieve resource manager!");
    return;
  }

  const auto resMgrWorkingModeBefore = resMgr->workingMode();
  if (theDefaultOnly)
    resMgr->setWorkingMode(QtxResourceMgr::IgnoreUserValues);

  /** List of modules with invalid IDs. */
  QStringList invalidModuleIDs;

  /** { moduleID, {inModuleActionID, keySequence}[] }[] */
  std::map<QString, std::list<std::pair<QString, QString>>> invalidShortcuts;

  /**
   * Shortcuts, which have not been set, because they are in conflict with previously parsed shortcuts.
   * { moduleID, {inModuleActionID, keySequence}[] }[] */
  std::map<QString, std::list<std::pair<QString, QKeySequence>>> conflicts;

  // Resource manager strips leading and trailing whitespaces from subsections' names.
  // And then it is not able to retrieve parametes from that subsections,
  // because parsed subsection names differ from the ones in resource file.
  // Anyway, it does not affect operability of ShortcutMgr.
  QStringList moduleIDs = resMgr->subSections(theSectionNamePrefix, true);
  if (ShCutDbg()) {
    if (moduleIDs.isEmpty())
      ShCutDbg("No discovered shortcut modules.");
    else
      ShCutDbg("Discovered shortcut modules: \"" + moduleIDs.join("\", \"") + ".");
  }
  moduleIDs.push_front(SUIT_ShortcutMgr::ROOT_MODULE_ID); // Resource manager filters out empty section suffices.
  moduleIDs.removeDuplicates();

  for (size_t i = 0; i < moduleIDs.size(); i++) {
    const auto& moduleID = moduleIDs[i];
    if (!SUIT_ShortcutMgr::isModuleIDValid(moduleID)) {
      invalidModuleIDs.push_back(moduleID);
      continue;
    }

    const QString sectionName = theSectionNamePrefix + resMgr->sectionsToken() + moduleID;
    QStringList moduleActionIDs = resMgr->parameters(sectionName);

    for(const QString& inModuleActionID : moduleActionIDs) {
      QString keySequenceString = QString("");
      resMgr->value(sectionName, inModuleActionID, keySequenceString);
      const auto keySequence = SUIT_ShortcutMgr::toKeySequenceIfValid(keySequenceString);

      ShCutDbg() && ShCutDbg("Shortcut parsed: \"" + moduleID + "\"\t\"" + inModuleActionID + "\"\t\"" + keySequenceString + "\".");

      if (
        !SUIT_ShortcutMgr::isInModuleActionIDValid(inModuleActionID) ||
        !keySequence.first ||
        SUIT_ShortcutMgr::isInModuleMetaActionID(inModuleActionID) && moduleID != SUIT_ShortcutMgr::ROOT_MODULE_ID
      ) {
        std::list<std::pair<QString, QString>>& moduleInvalidShortcuts = invalidShortcuts[moduleID];
        moduleInvalidShortcuts.push_back(std::pair<QString, QString>(inModuleActionID, keySequenceString));
        continue;
      }

      const auto shortcutConflicts = theContainer.setShortcut(moduleID, inModuleActionID, keySequence.second, false /*override*/);
      if (!shortcutConflicts.empty()) {
        auto& moduleConflicts = conflicts[moduleID];
        moduleConflicts.push_back(std::pair<QString, QKeySequence>(inModuleActionID, keySequence.second));
      }
    }
  }

  if (!invalidModuleIDs.isEmpty() || !invalidShortcuts.empty() || !conflicts.empty())
  { // Prepare report and show warning.
    QString report;
    if (!invalidModuleIDs.isEmpty()) {
      report += tr("Invalid module IDs") + ":";
      for (const QString& invalidModuleID : invalidModuleIDs) {
        report += "\n\t\"" + invalidModuleID + "\"" ;
      }
    }

    if (!invalidShortcuts.empty()) {
      if (!report.isEmpty())
        report += "\n\n";

      report += tr("Invalid shortcuts") + ":";
      for (const auto& moduleAndShortcuts : invalidShortcuts) {
        report += "\n\t\"" + moduleAndShortcuts.first + "\"";
        const std::list<std::pair<QString, QString>>& moduleShortcuts = moduleAndShortcuts.second;
        for (const auto& shortcut : moduleShortcuts) {
          report += "\n\t\t\"" + shortcut.first + "\"\t\"" + shortcut.second + "\"";
        }
      }
    }

    if (!conflicts.empty()) {
      if (!report.isEmpty())
        report += "\n\n";

      report += tr("These shortcuts have not been set to theContainer, because they conflict with previously parsed ones") + ":";
      for (const auto& moduleAndShortcuts : conflicts) {
        report += "\n\t\"" + moduleAndShortcuts.first + "\"";

        const std::list<std::pair<QString, QKeySequence>>& moduleShortcuts = moduleAndShortcuts.second;
        for (const auto& shortcut : moduleShortcuts) {
          report += "\n\t\t\"" + shortcut.first + "\"\t\"" + shortcut.second.toString() + "\"";
        }
      }
    }

    report += "\n.";

    const auto text = tr("Invalid shortcuts in preferences");
    const auto informativeText = tr("Fix the following entries in the preference files manually");
    if (!theDefaultOnly) {
      // If user preferences are accounted, show warning in UI.
      SUIT_Application* app = SUIT_Session::session()->activeApplication();
      if (app && app->desktop()) {
        // Is not compiled without cast or with static_cast<QWidget*>.
        QMessageBox msgBox((QWidget*)app->desktop());
        msgBox.setIcon(QMessageBox::Warning);
        msgBox.setTextFormat(Qt::RichText);
        msgBox.setText("<b>" + text + "</b>");
        msgBox.setInformativeText(informativeText + ":");
        msgBox.setWindowFlags(Qt::WindowType::Popup);
        msgBox.setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
        msgBox.setDetailedText(report);
        msgBox.setStandardButtons(QMessageBox::Ok);
        msgBox.setDefaultButton(QMessageBox::Ok);
        msgBox.setMinimumWidth(600);
        msgBox.exec();
      }
    }
    Warning(text + ". " + informativeText + ":\n" + report);
  }

  if (theDefaultOnly)
    resMgr->setWorkingMode(resMgrWorkingModeBefore);

  ShCutDbg() && ShCutDbg("theContainer holds following shortcuts:\n" + theContainer.toString());
  ShCutDbg() && ShCutDbg(QString("SUIT_ShortcutMgr::fillContainerFromPreferences(theContainer, theDefaultOnly = ") + (theDefaultOnly ? "true" : "false") + ", theSectionPrefix = \"" + theSectionNamePrefix + "\") finished.");
}

/*static*/ std::pair<std::shared_ptr<SUIT_ShortcutModuleAssets>, std::shared_ptr<SUIT_ShortcutItemAssets>>
SUIT_ShortcutMgr::getActionAssetsFromResources(const QString& theActionID, const std::set<QString>& theLangs)
{
  ShCutDbg("SUIT_ShortcutMgr::getActionAssetsFromResources(\"" + theActionID + "\") START");

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutMgr::getActionAssetsFromResources: can't retrieve resource manager!");
    return std::pair<std::shared_ptr<SUIT_ShortcutModuleAssets>, std::shared_ptr<SUIT_ShortcutItemAssets>>(nullptr, nullptr);
  }

  const auto splittedActionID = splitIntoModuleIDAndInModuleID(theActionID);
  if (splittedActionID.second.isEmpty()) {
    Warning(QString("SUIT_ShortcutMgr::getActionAssetsFromResources: \"") + theActionID + "\" is invalid.");
    return std::pair<std::shared_ptr<SUIT_ShortcutModuleAssets>, std::shared_ptr<SUIT_ShortcutItemAssets>>(nullptr, nullptr);
  }

  const QString& moduleID = SUIT_ShortcutMgr::isInModuleMetaActionID(splittedActionID.second) ? SUIT_ShortcutMgr::ROOT_MODULE_ID : splittedActionID.first;
  const QString& inModuleID = splittedActionID.second;

  std::shared_ptr<SUIT_ShortcutModuleAssets> combinedModuleAssets(nullptr);

  QStringList actionAssetFilePaths = resMgr->parameters(SECTION_NAME_ACTION_ASSET_FILE_PATHS);
#ifdef SHORTCUT_MGR_DBG
  ShCutDbg("Asset file paths: " + actionAssetFilePaths.join(", ") + ".");
#endif

  for (const QString& actionAssetFilePath : actionAssetFilePaths) {
    const QString path = ::SUIT_tools::substituteVars(actionAssetFilePath);
    ShCutDbg("Parsing asset file \"" + path + "\".");
    QFile actionAssetFile(path);
    if (!actionAssetFile.open(QIODevice::ReadOnly)) {
      Warning("SUIT_ShortcutMgr::getActionAssetsFromResources: can't open action asset file \"" + path + "\"!");
      continue;
    }

    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(actionAssetFile.readAll(), &jsonError);
    actionAssetFile.close();
    if (jsonError.error != QJsonParseError::NoError) {
      Warning("SUIT_ShortcutMgr::getActionAssetsFromResources: error during parsing of action asset file \"" + path + "\"!");
      continue;
    }

    if (!document.isObject()) {
      Warning("SUIT_ShortcutMgr::getActionAssetsFromResources: invalid asset file \"" + path + "\"!");
      continue;
    }

    QJsonObject documentJSONObject = document.object();
    const auto itModuleJSONValue = documentJSONObject.find(moduleID);
    if (itModuleJSONValue == documentJSONObject.end())
      continue;

    if (!itModuleJSONValue->isObject()) {
      ShCutDbg("SUIT_ShortcutMgr::getActionAssetsFromResources: file \"" + path + "\" contains invalid value with module ID \"" + moduleID + "\".");
      continue;
    }

    if (!combinedModuleAssets)
      combinedModuleAssets = SUIT_ShortcutModuleAssets::create(moduleID);

    const auto fileModuleAssets = SUIT_ShortcutModuleAssets::create(moduleID);
    const bool somethingUsefulIsParsed = fileModuleAssets->fromJSON(itModuleJSONValue->toObject(), inModuleID, theLangs);

    if (!somethingUsefulIsParsed)
      continue;

    combinedModuleAssets->merge(*fileModuleAssets, true);
  }

  if (combinedModuleAssets) {
#ifdef SHORTCUT_MGR_DBG
    ShCutDbg("SUIT_ShortcutMgr::getActionAssetsFromResources: module assets " + combinedModuleAssets->toString());
    ShCutDbg("SUIT_ShortcutMgr::getActionAssetsFromResources(\"" + theActionID + "\") END\n");
#endif
    return std::pair<std::shared_ptr<SUIT_ShortcutModuleAssets>, std::shared_ptr<SUIT_ShortcutItemAssets>>(combinedModuleAssets, combinedModuleAssets->findDescendantItem(inModuleID));
  }
  else {
    ShCutDbg("SUIT_ShortcutMgr::getActionAssetsFromResources(\"" + theActionID + "\") END\n");
    return std::pair<std::shared_ptr<SUIT_ShortcutModuleAssets>, std::shared_ptr<SUIT_ShortcutItemAssets>>(nullptr, nullptr);
  }
}


/*static*/ QString SUIT_ShortcutMgr::currentLang()
{
  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutMgr can't retrieve resource manager!");
    return DEFAULT_LANG;
  }

  return resMgr->stringValue(LANG_SECTION, LANG_SECTION, DEFAULT_LANG);
}


void SUIT_ShortcutMgr::registerAction(const QString& theActionID, QAction* theAction)
{
#ifdef SHORTCUT_MGR_DEVTOOLS
  SUIT_ResourceMgr* const resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SHORTCUT_MGR_DEVTOOLS: can't retrieve resource manager to check throw lists.");
  }
  else {
    const auto actionIDsToThrow = resMgr->parameters(DevTools::SECTION_NAME_ACTION_IDS_TO_THROW_EXCEPTION);
    if (actionIDsToThrow.contains(theActionID))
      throw std::invalid_argument(QString("SHORTCUT_MGR_DEVTOOLS: action with ID \"" + theActionID + "\" from throw list has been registered.").toStdString());

    const auto actionToolTipsToThrow = resMgr->parameters(DevTools::SECTION_NAME_ACTION_TOOLTIPS_TO_THROW_EXCEPTION);
    if (actionToolTipsToThrow.contains(theAction->toolTip()))
      throw std::invalid_argument(QString("SHORTCUT_MGR_DEVTOOLS: action with tool tip \"" + theAction->toolTip() + "\" from throw list has been registered.").toStdString());
  }
#endif //SHORTCUT_MGR_DEVTOOLS

  const auto moduleIDAndActionID = splitIntoModuleIDAndInModuleID(theActionID);
  const QString& moduleID = moduleIDAndActionID.first;
  const QString& inModuleActionID = moduleIDAndActionID.second;

  if (inModuleActionID.isEmpty()) {
    ShCutDbg() && ShCutDbg("Attempt to register an action \"" + theAction->toolTip() + "\" with invalid ID \"" + theActionID + "\". The action is treated as anonymous.");
    registerAnonymousShortcut(theAction);
    return;
  }

  { // If an action with the same memory address was registered earlier,
    // clear all data about it to start registration from scratch.
    auto itPreviousModuleAndActionID = myActionIDs.find(theAction);
    if (itPreviousModuleAndActionID != myActionIDs.end()) {
      // Clear the data from myActions.
      const auto& previousModuleAndActionID = itPreviousModuleAndActionID->second;
      auto itActions = myActions.find(previousModuleAndActionID.first);
      if (itActions != myActions.end()) {
        std::map<QString, std::set<QAction*>>& moduleActions = itActions->second;
        auto itModuleActions = moduleActions.find(previousModuleAndActionID.second);
        if (itModuleActions != moduleActions.end()) {
          std::set<QAction*>& registeredActions = itModuleActions->second;
          registeredActions.erase(theAction);
        }
      }

      myActionIDs.erase(itPreviousModuleAndActionID);
    }
  }

  auto itActions = myActions.find(moduleID);
  if (itActions == myActions.end()) {
    itActions = myActions.emplace(moduleID, std::map<QString, std::set<QAction*>>()).first;
  }

  std::map<QString, std::set<QAction*>>& moduleActions = itActions->second;
  auto itModuleActions = moduleActions.find(inModuleActionID);
  if (itModuleActions != moduleActions.end()) {
    std::set<QAction*>& registeredActions = itModuleActions->second;
    const bool actionIsNew = registeredActions.emplace(theAction).second;
    if (actionIsNew)
      myActionIDs[theAction] = moduleIDAndActionID;
  }
  else {
    std::set<QAction*>& registeredActions = moduleActions[inModuleActionID];
    registeredActions.emplace(theAction);
    myActionIDs[theAction] = moduleIDAndActionID;
  }

  connect(theAction, SIGNAL(destroyed(QObject*)), this, SLOT (onActionDestroyed(QObject*)));

  // Check if assets are provided.
  if (myAssetsLoaded) {
    const auto& actionAssets = getActionAssets(moduleID, inModuleActionID, true /*theTryToCreateRuntimeAssetsIfAbsent*/);
    if (!actionAssets)
      Warning("Assets of action \"" + moduleID + TOKEN_SEPARATOR + inModuleActionID + "\" are not provided in asset files and could not be created using runtime data.");
  }
#ifdef SHORTCUT_MGR_DBG
  else
    ShCutDbg("Action \"" + moduleID + TOKEN_SEPARATOR + inModuleActionID + "\" has been registered, but ShortcutMgr has not yet loaded asset files.");
#endif //SHORTCUT_MGR_DBG

  // Assign key sequence from preferences.
  if (myShortcutContainer.hasShortcut(moduleID, inModuleActionID)) {
    const QKeySequence& keySequence = getKeySequence(moduleID, inModuleActionID);
    theAction->setShortcut(keySequence);
    // Do not log/warn if action arrived with different key sequence. There are to many of them.
  }
  else { // Unbind any key sequence, if it was bound outside of the class and interferes with other shortcuts.
    const QKeySequence actionKeySequence = theAction->shortcut();
    auto conflicts = myShortcutContainer.setShortcut(moduleID, inModuleActionID, actionKeySequence, false);
    if (!conflicts.empty())
      theAction->setShortcut(NO_KEYSEQUENCE);

#ifdef SHORTCUT_MGR_DBG
    if (myAssetsLoaded) {
      QString report = "Shortcut \"" +
      (SUIT_ShortcutMgr::isInModuleMetaActionID(inModuleActionID) ? SUIT_ShortcutMgr::ROOT_MODULE_ID + TOKEN_SEPARATOR + inModuleActionID : theActionID) +
      "\"->\"" + actionKeySequence.toString() + "\" is not added to default preference files. ";

      if (!conflicts.empty())
        report += "The shortcut conflicted with other shortcuts and has been disabled.";

      report += QString("The ") + (conflicts.empty() ? "" : "disabled ") + "shortcut has been added to user preference files.";

      ShCutDbg(report);
    }
#endif //SHORTCUT_MGR_DBG
  }
}

void SUIT_ShortcutMgr::registerAction(QtxAction* theAction)
{
  registerAction(theAction->ID(), theAction);
}

std::set<QAction*> SUIT_ShortcutMgr::getActions(const QString& theModuleID, const QString& theInModuleActionID) const
{
  if (SUIT_ShortcutMgr::isInModuleMetaActionID(theInModuleActionID)) {
    std::set<QAction*> actions;
    for (const auto& actionAndID : myActionIDs) {
      if (actionAndID.second.second == theInModuleActionID)
        actions.emplace(actionAndID.first);
    }
    return actions;
  }
  else {
    const auto itActions = myActions.find(theModuleID);
    if (itActions == myActions.end())
      return std::set<QAction*>();

    const std::map<QString, std::set<QAction*>>& moduleActions = itActions->second;
    const auto itModuleActions = moduleActions.find(theInModuleActionID);
    if (itModuleActions == moduleActions.end())
      return std::set<QAction*>();

    return itModuleActions->second;
  }
}

std::pair<QString, QString> SUIT_ShortcutMgr::getModuleIDAndInModuleID(const QAction* theAction) const {
  const auto it = myActionIDs.find(const_cast<QAction*>(theAction));
  if (it == myActionIDs.end())
    return std::pair<QString, QString>();

  return it->second;
}

bool SUIT_ShortcutMgr::hasAction(const QAction* theAction) const
{
  return myActionIDs.find(const_cast<QAction*>(theAction)) != myActionIDs.end();
}

QString SUIT_ShortcutMgr::getActionID(const QAction* theAction) const
{
  const auto it = myActionIDs.find(const_cast<QAction*>(theAction));
  if (it == myActionIDs.end())
    return QString();

  return SUIT_ShortcutMgr::makeActionID(it->second.first, it->second.second);
}

void SUIT_ShortcutMgr::setActionsOfModuleEnabled(const QString& theModuleID, const bool theEnable) const
{
#ifdef SHORTCUT_MGR_DBG
  if (theEnable)
    ShCutDbg("Enable actions of module \"" + theModuleID + "\".");
  else
    ShCutDbg("Disable actions of module \"" + theModuleID + "\".");

    ShCutDbg("Anonymous actions before: " + anonymousShortcutsToString());
#endif//SHORTCUT_MGR_DBG

  if (theEnable)
    myActiveModuleIDs.emplace(theModuleID);
  else
    myActiveModuleIDs.erase(theModuleID);

  enableAnonymousShortcutsClashingWith(theModuleID, !theEnable);

  SUIT_Application* app = SUIT_Session::session()->activeApplication();
  if (!app)
    return;

  const auto itModuleActions = myActions.find(theModuleID);
  if (itModuleActions == myActions.end())
    return;

  const std::map<QString, std::set<QAction*>>& moduleActions = itModuleActions->second;
  for (const auto& idAndActions : moduleActions) {
    const std::set<QAction*>& actions = idAndActions.second;
    for (QAction* const action : actions) {
      if (action->parentWidget() == (QWidget*)app->desktop()) // Is not compiled without cast or with static_cast<QWidget*>.
        action->setEnabled(theEnable);
    }
  }

  #ifdef SHORTCUT_MGR_DBG
    ShCutDbg("Anonymous actions after: " + anonymousShortcutsToString());
  #endif//SHORTCUT_MGR_DBG
}

void SUIT_ShortcutMgr::setSectionEnabled(const QString& theInModuleActionIDPrefix, bool theEnable) const
{
  setActionsOfModuleEnabled(theInModuleActionIDPrefix, theEnable);
}

void SUIT_ShortcutMgr::setActionsWithPrefixInIDEnabled(const QString& theInModuleActionIDPrefix, bool theEnable) const
{
  SUIT_Application* app = SUIT_Session::session()->activeApplication();
  if (!app)
    return;

  for (const std::pair<QAction*, std::pair<QString, QString>>& actionAndID : myActionIDs) {
    QAction* const action = actionAndID.first;
    // Is not compiled without cast or with static_cast<QWidget*>.
    if (action->parentWidget() == (QWidget*)app->desktop()) {
      const QString& inModuleActionID = actionAndID.second.second;
      if (inModuleActionID.startsWith(theInModuleActionIDPrefix))
        action->setEnabled(theEnable);
    }
  }
}

void SUIT_ShortcutMgr::rebindActionsToKeySequences() const
{
  ShCutDbg() && ShCutDbg("SUIT_ShortcutMgr::rebindActionsToKeySequences()");
  for (const std::pair<QAction*, std::pair<QString, QString>>& actionAndID : myActionIDs) {
    actionAndID.first->setShortcut(getKeySequence(actionAndID.second.first, actionAndID.second.second));
  }
}

void SUIT_ShortcutMgr::updateShortcuts() const
{
  rebindActionsToKeySequences();
}

std::set<std::pair<QString, QString>> SUIT_ShortcutMgr::setShortcut(const QString& theActionID, const QKeySequence& theKeySequence, bool theOverride)
{
  const auto moduleIDAndActionID = splitIntoModuleIDAndInModuleID(theActionID);
  const QString& moduleID = moduleIDAndActionID.first;
  const QString& inModuleActionID = moduleIDAndActionID.second;

  if (inModuleActionID.isEmpty()) {
    ShCutDbg() && ShCutDbg("Attempt to set shortcut with invalid action ID \"" + theActionID + "\".");
    return std::set<std::pair<QString, QString>>();
  }

  return setShortcutNoIDChecks(moduleID, inModuleActionID, theKeySequence, theOverride);
}

std::set<std::pair<QString, QString>> SUIT_ShortcutMgr::setShortcut(const QString& theModuleID, const QString& theInModuleActionID, const QKeySequence& theKeySequence, bool theOverride)
{
  if (!SUIT_ShortcutMgr::isModuleIDValid(theModuleID)) {
    ShCutDbg() && ShCutDbg("Attempt to set shortcut with invalid module ID \"" + theModuleID + "\".");
    return std::set<std::pair<QString, QString>>();
  }

  if (!SUIT_ShortcutMgr::isInModuleActionIDValid(theInModuleActionID)) {
    ShCutDbg() && ShCutDbg("Attempt to set shortcut with invalid in-module action ID \"" + theInModuleActionID + "\".");
    return std::set<std::pair<QString, QString>>();
  }

  return setShortcutNoIDChecks(theModuleID, theInModuleActionID, theKeySequence, theOverride);
}

const SUIT_ShortcutContainer& SUIT_ShortcutMgr::getShortcutContainer() const
{
  return myShortcutContainer;
}

void SUIT_ShortcutMgr::mergeShortcutContainer(const SUIT_ShortcutContainer& theContainer, bool theOverride, bool theTreatAbsentIncomingAsDisabled, bool theSaveToPreferences)
{
  ShCutDbg() && ShCutDbg("ShortcutMgr merges shortcut container...");
  const auto changes = myShortcutContainer.merge(theContainer, theOverride, theTreatAbsentIncomingAsDisabled);
  ShCutDbg() && ShCutDbg("ShortcutMgr keeps following shortcuts:\n" + myShortcutContainer.toString());

  {
#ifdef SHORTCUT_MGR_DBG
    QString changesStr = "Changes:\n";
    for (const auto& moduleIDAndChanges : changes) {
      const QString& moduleID = moduleIDAndChanges.first;
      const auto& moduleChanges = moduleIDAndChanges.second;
      changesStr += "\t\"" + moduleID + "\":\n";
      for (const std::pair<QString, std::pair<QKeySequence, QKeySequence>>& modifiedShortcut : moduleChanges) {
        changesStr += "\t\t\"" + modifiedShortcut.first + "\": " + modifiedShortcut.second.first.toString() + "->" + modifiedShortcut.second.second.toString() + ";\n";
      }
    }
    ShCutDbg(changesStr);
#endif//SHORTCUT_MGR_DBG
  }

  /** { keySequence, {moduleID, isTheKeySequenceBound}[] }[] */
  std::map<QKeySequence, std::map<QString, bool>> modifiedBoundStates;

  // Turn off hotkeys for disabled shortcuts.
  for (const auto& moduleIDAndChanges : changes) {
    const QString& moduleID = moduleIDAndChanges.first;
    const auto& moduleChanges = moduleIDAndChanges.second;
    for (const std::pair<QString, std::pair<QKeySequence, QKeySequence>>& modifiedShortcut : moduleChanges) {
      if (modifiedShortcut.second.second == NO_KEYSEQUENCE) {
        const std::set<QAction*> actions = getActions(moduleID, modifiedShortcut.first);
        for (QAction* const action : actions) {
          action->setShortcut(NO_KEYSEQUENCE);
        }
      }

      if (modifiedShortcut.second.first != NO_KEYSEQUENCE)
        modifiedBoundStates[modifiedShortcut.second.first][moduleID] = false;
    }
  }

  // Turn on hotkeys for enabled shortcuts.
  for (const auto& moduleIDAndChanges : changes) {
    const QString& moduleID = moduleIDAndChanges.first;

    const auto& moduleChanges = moduleIDAndChanges.second;
    for (const std::pair<QString, std::pair<QKeySequence, QKeySequence>>& modifiedShortcut : moduleChanges) {
      if (modifiedShortcut.second.second != NO_KEYSEQUENCE) {
        const std::set<QAction*> actions = getActions(moduleID, modifiedShortcut.first);
        for (QAction* const action : actions) {
          action->setShortcut(modifiedShortcut.second.second);
        }

        modifiedBoundStates[modifiedShortcut.second.second][moduleID] = true;
      }
    }
  }

  // Update anonymous shortcuts.
  for (const auto& ksAndBoundStates : modifiedBoundStates) {
    const auto& keySequence = ksAndBoundStates.first;
    const auto& boundStates = ksAndBoundStates.second;

    bool ksIsBoundToAnActionInActiveModule = false;
    for (const auto& moduleIDAndBoundState : boundStates) {
      const QString& moduleID = moduleIDAndBoundState.first;
      const bool keySequenceIsBound = moduleIDAndBoundState.second;
      if (keySequenceIsBound && myActiveModuleIDs.find(moduleID) != myActiveModuleIDs.end()) {
        ksIsBoundToAnActionInActiveModule = true;
        break;
      }
    }
    enableAnonymousShortcutsClashingWith(keySequence, !ksIsBoundToAnActionInActiveModule);
  }

  if (theSaveToPreferences)
    SUIT_ShortcutMgr::saveShortcutsToPreferences(changes);
}

const QKeySequence& SUIT_ShortcutMgr::getKeySequence(const QString& theModuleID, const QString& theInModuleActionID) const
{
  return myShortcutContainer.getKeySequence(theModuleID, theInModuleActionID);
}

const std::map<QString, QKeySequence>& SUIT_ShortcutMgr::getModuleShortcutsInversed(const QString& theModuleID) const
{
  return myShortcutContainer.getModuleShortcutsInversed(theModuleID);
}

std::set<QString> SUIT_ShortcutMgr::getShortcutModuleIDs() const
{
  return myShortcutContainer.getIDsOfAllModules();
}

std::set<QString> SUIT_ShortcutMgr::getIDsOfInterferingModules(const QString& theModuleID) const
{
  return myShortcutContainer.getIDsOfInterferingModules(theModuleID);
}

std::shared_ptr<const SUIT_ShortcutModuleAssets> SUIT_ShortcutMgr::getModuleAssets(const QString& theModuleID) const
{
  const auto itModuleAssets = myModuleAssets.find(theModuleID);
  if (itModuleAssets == myModuleAssets.end())
    return std::shared_ptr<const SUIT_ShortcutModuleAssets>(nullptr);

  return itModuleAssets->second;
}

QString SUIT_ShortcutMgr::getModuleName(const QString& theModuleID, const QString& theLang) const
{
  const auto assets = getModuleAssets(theModuleID);
  if (!assets)
    return theModuleID;

  return assets->bestName(theLang);
}

std::shared_ptr<const SUIT_ShortcutItemAssets> SUIT_ShortcutMgr::getActionAssets(const QString& theModuleID, const QString& theInModuleActionID, bool theTryToCreateRuntimeAssetsIfAbsent) const
{
  const QString actionID = SUIT_ShortcutMgr::makeActionID(theModuleID, theInModuleActionID);
  if (actionID.isEmpty()) {
    ShCutDbg() && ShCutDbg("Can't get action assets: either/both module ID \"" + theModuleID + "\" or/and in-module action ID \"" + theInModuleActionID + "\" is/are invalid.");
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);
  }
  return getActionAssets(actionID, theTryToCreateRuntimeAssetsIfAbsent);
}

std::shared_ptr<const SUIT_ShortcutItemAssets> SUIT_ShortcutMgr::getActionAssets(const QString& theActionID, bool theTryToCreateRuntimeAssetsIfAbsent) const
{
  const auto moduleIDAndActionID = SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(theActionID);
  const QString& moduleID = SUIT_ShortcutMgr::isInModuleMetaActionID(moduleIDAndActionID.second) ? SUIT_ShortcutMgr::ROOT_MODULE_ID : moduleIDAndActionID.first;
  const QString& inModuleActionID = moduleIDAndActionID.second;

  if (inModuleActionID.isEmpty()) {
    ShCutDbg() && ShCutDbg("Attempt to get assets of an action with invalid ID \"" + theActionID + "\".");
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);
  }

  auto itModuleAssets = myModuleAssets.find(moduleID);
  if (itModuleAssets != myModuleAssets.end()) {
    const std::shared_ptr<const SUIT_ShortcutModuleAssets> moduleAssets = itModuleAssets->second;
    auto assets = moduleAssets->findDescendantItem(inModuleActionID);
    if (assets)
      return assets;
  }

  if (!myAssetsLoaded) {
    Warning("SUIT_ShortcutMgr::getActionAssets(\"" + theActionID + "\") has been called prior to loading of asset files.");
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);
  }
  else { // Action assets are not provided in asset files.
    Warning("SUIT_ShortcutMgr::getActionAssets(..): Assets of \"" + theActionID + "\" are not provided in asset files.");
    if (theTryToCreateRuntimeAssetsIfAbsent) {
      const auto runtimeAssets = createRuntimeActionAssets(moduleID, inModuleActionID);
      if (runtimeAssets) {
        if (itModuleAssets == myModuleAssets.end())
          itModuleAssets = myModuleAssets.emplace(moduleID, std::move(SUIT_ShortcutModuleAssets::create(moduleID))).first;

        auto& moduleAssets = itModuleAssets->second;
        auto actionAssets = moduleAssets->descendantItem(inModuleActionID, true /*theIsAction*/);

        actionAssets->merge(std::move(*runtimeAssets), false);
        ShCutDbg("Assets of action \"" + theActionID + "\" has been created using runtime data.");
        return actionAssets;
      }
    }
  }
  return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);
}

std::shared_ptr<const SUIT_ShortcutItemAssets> SUIT_ShortcutMgr::createRuntimeActionAssets(const QString& theModuleID, const QString& theInModuleActionID) const
{
  const auto actions = SUIT_ShortcutMgr::getActions(theModuleID, theInModuleActionID);
  if (actions.empty())
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);

  SUIT_ShortcutAssets::LangDependentAssets runtimeLDA;
  QIcon runtimeIcon;
  for (const auto action : actions) {
    if (!action->text().isEmpty())
      runtimeLDA.myName = action->text();

    if (!action->statusTip().isEmpty())
      runtimeLDA.myToolTip = action->statusTip();

    if (!action->icon().isNull())
      runtimeIcon = action->icon();
  }

  if (runtimeLDA.myName.isEmpty() && runtimeLDA.myToolTip.isEmpty() && runtimeIcon.isNull())
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);

  if (runtimeLDA.myName.isEmpty())
    runtimeLDA.myName = runtimeLDA.myToolTip;

  const auto moduleAssets = SUIT_ShortcutModuleAssets::create(theModuleID);
  if (!moduleAssets)
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);

  const auto actionAssets = moduleAssets->descendantItem(theInModuleActionID, true /*theIsAction*/);
  if (!actionAssets)
    return std::shared_ptr<const SUIT_ShortcutItemAssets>(nullptr);

  if (runtimeLDA.myName.isEmpty())
    runtimeLDA.myName = actionAssets->myInModuleID;

  actionAssets->myLangDependentAssets[SUIT_ShortcutMgr::currentLang()] = std::move(runtimeLDA);
  actionAssets->myIcon = std::move(runtimeIcon);

  return actionAssets;
}

QString SUIT_ShortcutMgr::getActionName(const QString& theModuleID, const QString& theInModuleActionID, const QString& theLang) const
{
  std::shared_ptr<const SUIT_ShortcutItemAssets> actionAssets = getActionAssets(theModuleID, theInModuleActionID, true /*theTryToCreateRuntimeAssetsIfAbsent*/);
  if (!actionAssets)
    return theInModuleActionID;

  auto LDA = actionAssets->bestLangDependentAssets(theLang);
  if (LDA)
    return LDA->myName;

  return theInModuleActionID;
}

QtxAction* SUIT_ShortcutMgr::createAction(QObject* theParent, QObject* theReceiver, const char* theReceiverMemberMethod, const QString& theActionID, const bool theIsToggle) const
{
  const auto moduleIDAndInModuleID = SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(theActionID);
  const QString& moduleID = moduleIDAndInModuleID.first;
  const QString& inModuleID = moduleIDAndInModuleID.second;

  if (inModuleID.isEmpty()) {
    Warning("Attempt to create action with invalid ID \"" + theActionID + "\".");
    return nullptr;
  }

  QtxAction* action = nullptr;
  const auto actionAssets = getActionAssets(theActionID, false /*theTryToCreateRuntimeAssetsIfAbsent*/);
  if (!actionAssets) {
    Warning("SUIT_ShortcutMgr::createAction(\"" + theActionID + "\"): assets of the action are absent.");
    const QString lastTokenOfID = SUIT_ShortcutMgr::splitIntoTokens(inModuleID).back();
    action = new QtxAction(theParent, theIsToggle, theActionID, inModuleID, lastTokenOfID, QIcon());
  }
  else {
    action = new QtxAction(theParent, theIsToggle, theActionID, actionAssets->bestToolTip(), actionAssets->bestName(), actionAssets->myIcon);
  }

  if (theReceiver && theReceiverMemberMethod)
    connect(action, SIGNAL(triggered(bool)), theReceiver, theReceiverMemberMethod);

  return action;
}

void SUIT_ShortcutMgr::onActionDestroyed(QObject* theObject)
{
  QAction* action = static_cast<QAction*>(theObject);

  auto itID = myActionIDs.find(action);
  if (itID == myActionIDs.end())
    return;

  const QString& moduleID = itID->second.first;
  const QString& inModuleActionID = itID->second.second;

  auto itModuleActions = myActions.find(moduleID);
  if (itModuleActions != myActions.end()) {
    std::map<QString, std::set<QAction*>>& moduleActions = itModuleActions->second;
    auto itActions = moduleActions.find(inModuleActionID);
    if (itActions != moduleActions.end()) {
      std::set<QAction*>& actions = itActions->second;
      actions.erase(action);
    }
  }

  myActionIDs.erase(itID);
}

void SUIT_ShortcutMgr::onAnonymousActionDestroyed(QObject* theObject)
{
  QAction* action = static_cast<QAction*>(theObject);

  const auto itShortcut = myAnonymousShortcuts.find(action);
  if (itShortcut == myAnonymousShortcuts.end())
    return;

  const auto& keySequence = itShortcut->second;

  const auto itShortcutsInverse = myAnonymousShortcutsInverse.find(keySequence);
  if (itShortcutsInverse == myAnonymousShortcutsInverse.end()) {
    ShCutDbg("Faulty logics of anonymous action destruction.");
    return;
  }
  std::set<QAction*>& actions = itShortcutsInverse->second;
  actions.erase(action);
  if (actions.empty())
    myAnonymousShortcutsInverse.erase(itShortcutsInverse);

  myAnonymousShortcuts.erase(itShortcut);
}

bool SUIT_ShortcutMgr::eventFilter(QObject* theObject, QEvent* theEvent)
{
  if (theEvent) {
    if (theEvent->type() == QEvent::ActionAdded) {
      auto anActionEvent = static_cast<QActionEvent*>(theEvent);

      QtxAction* aQtxAction = qobject_cast<QtxAction*>(anActionEvent->action());
      if (aQtxAction) {
#ifdef SHORTCUT_MGR_DBG
        {
          const auto moduleIDAndActionID = splitIntoModuleIDAndInModuleID(aQtxAction->ID());
          if (moduleIDAndActionID.second.isEmpty())
            ShCutDbg("ActionAdded event, but ID of the action is invalid. Action name = \"" + aQtxAction->toolTip() + "\", ID = \"" + aQtxAction->ID() + "\".");
          else if (!myShortcutContainer.hasShortcut(moduleIDAndActionID.first, moduleIDAndActionID.second))
            ShCutDbg("ActionAdded event, but shortcut container has no shortcut for the action. It is ok, if preference files has not been parsed yet. Action ID = \"" + moduleIDAndActionID.second + "\".");
        }
#endif//SHORTCUT_MGR_DBG
#ifdef SHORTCUT_MGR_DEVTOOLS
        {
          DevTools::get()->collectShortcutAndAssets(aQtxAction);
          const auto moduleIDAndActionID = splitIntoModuleIDAndInModuleID(aQtxAction->ID());
          if (moduleIDAndActionID.second.isEmpty())
            DevTools::get()->collectAssetsOfActionWithInvalidID(aQtxAction);
        }
#endif//SHORTCUT_MGR_DEVTOOLS
	      registerAction(aQtxAction);
      }
      else {
        QAction* aQAction = qobject_cast<QAction*>(anActionEvent->action());
#ifdef SHORTCUT_MGR_DEVTOOLS
        if (aQAction)
          DevTools::get()->collectAssetsOfActionWithInvalidID(aQAction);
#endif//SHORTCUT_MGR_DEVTOOLS
        if (aQAction)
          registerAnonymousShortcut(aQAction);
      }
    }
  }

  return QObject::eventFilter(theObject, theEvent);
}

std::set<std::pair<QString, QString>> SUIT_ShortcutMgr::setShortcutNoIDChecks(const QString& theModuleID, const QString& theInModuleActionID, const QKeySequence& theKeySequence, bool theOverride)
{
  std::set<std::pair<QString, QString>> disabledShortcutsIDs = myShortcutContainer.setShortcut(theModuleID, theInModuleActionID, theKeySequence, theOverride);

  if (theOverride || disabledShortcutsIDs.empty()) {
    // Bind actions to corresponding modified key sequences. Save changes to preferences.

    /** { moduleID, {inModuleActionID, keySequence}[] }[] */
    std::map<QString, std::map<QString, QKeySequence>> modifiedShortcuts;

    /** { moduleID, isTheKeySequenceBound }[] */
    std::map<QString, bool> modifiedBoundStates;

    for (const auto& moduleIDAndActionID : disabledShortcutsIDs) {
      // Unbind actions of disabled shortcuts.

      const QString& moduleID = moduleIDAndActionID.first;
      const QString& inModuleActionID = moduleIDAndActionID.second;

      modifiedShortcuts[moduleID][inModuleActionID] = NO_KEYSEQUENCE;
      modifiedBoundStates[moduleID] = false;

      const std::set<QAction*> actions = getActions(moduleID, inModuleActionID);
      for (QAction* const action : actions) {
        action->setShortcut(NO_KEYSEQUENCE);
      }
    }

    { // Bind actions to theKeySequence.
      modifiedShortcuts[theModuleID][theInModuleActionID] = theKeySequence;

      const auto it = modifiedBoundStates.find(theModuleID);
      if (it == modifiedBoundStates.end())
        modifiedBoundStates[theModuleID] = true;
      else
        modifiedBoundStates.erase(it);

      const std::set<QAction*> actions = getActions(theModuleID, theInModuleActionID);
      for (QAction* const action : actions) {
        action->setShortcut(theKeySequence);
      }
    }

    // Update anonymous shortcuts.
    bool ksIsBoundToAnActionInActiveModule = false;
    for (const auto& moduleIDAndBoundState : modifiedBoundStates) {
      const QString& moduleID = moduleIDAndBoundState.first;
      const bool keySequenceIsBound = moduleIDAndBoundState.second;
      if (keySequenceIsBound && myActiveModuleIDs.find(moduleID) != myActiveModuleIDs.end()) {
        ksIsBoundToAnActionInActiveModule = true;
        break;
      }
    }
    enableAnonymousShortcutsClashingWith(theKeySequence, !ksIsBoundToAnActionInActiveModule);

    SUIT_ShortcutMgr::saveShortcutsToPreferences(modifiedShortcuts);
  }

  return disabledShortcutsIDs;
}

void SUIT_ShortcutMgr::setShortcutsFromPreferences()
{
  ShCutDbg() && ShCutDbg("Retrieving shortcuts from preferences has started.");

  SUIT_ShortcutContainer container;
  SUIT_ShortcutMgr::fillContainerFromPreferences(container, false /*theDefaultOnly*/);
  mergeShortcutContainer(container, true /*theOverride*/, false /*theTreatAbsentIncomingAsDisabled*/, false /*theSaveToPreferences*/);

  if (myAssetsLoaded) {
    // Warn, if some action assets are not provided.
    const auto moduleIDs = myShortcutContainer.getIDsOfAllModules();
    for (const QString& moduleID : moduleIDs) {
      const auto& moduleShortcutsInversed = getModuleShortcutsInversed(moduleID);
      for (const auto& shortcutInversed : moduleShortcutsInversed) {
        const QString& inModuleActionID = shortcutInversed.first;
        const auto& actionAssets = getActionAssets(moduleID, inModuleActionID, false /*theTryToCreateRuntimeAssetsIfAbsent*/);
        if (!actionAssets)
          Warning("SUIT_ShortcutMgr::setShortcutsFromPreferences(): Assets of action \"" + moduleID + TOKEN_SEPARATOR + inModuleActionID + "\" are not provided in asset files.");
      }
    }
  }
  else
    Warning("SUIT_ShortcutMgr: loading of shortcuts from preferences happened earlier, than loading of asset files.");

  ShCutDbg() && ShCutDbg("Retrieving shortcuts from preferences has finished.");
}

/*static*/ void SUIT_ShortcutMgr::saveShortcutsToPreferences(const std::map<QString, std::map<QString, QKeySequence>>& theShortcutsInversed)
{
  ShCutDbg() && ShCutDbg("SUIT_ShortcutMgr::saveShortcutsToPreferences(New_Shortcuts_Inversed)");

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutMgr can't retrieve resource manager!");
    return;
  }

  for (const auto& moduleIDAndShortcutsInversed : theShortcutsInversed) {
    const auto& moduleID = moduleIDAndShortcutsInversed.first;
    const auto& moduleShortcutsInversed = moduleIDAndShortcutsInversed.second;
    for (const auto& shortcutInversed : moduleShortcutsInversed) {
      if (shortcutInversed.first.isEmpty()) {
        ShCutDbg("Attempt to serialize a shortcut with empty action ID.");
        continue;
      }

      const QString sectionName = SECTION_NAME_PREFIX + resMgr->sectionsToken() + moduleID;
      resMgr->setValue(sectionName, shortcutInversed.first, shortcutInversed.second.toString());

      ShCutDbg() && ShCutDbg("Saving shortcut: \"" + moduleID + "\"\t\"" + shortcutInversed.first + "\"\t\"" + shortcutInversed.second.toString() + "\"");
    }
  }
}

/*static*/ void SUIT_ShortcutMgr::saveShortcutsToPreferences(const std::map<QString, std::map<QString, std::pair<QKeySequence, QKeySequence>>>& theShortcutsInversed)
{
  ShCutDbg() && ShCutDbg("SUIT_ShortcutMgr::saveShortcutsToPreferences(Old_&_New_Shortcuts_Inversed)");

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutMgr can't retrieve resource manager!");
    return;
  }

  for (const auto& moduleIDAndShortcutsInversed : theShortcutsInversed) {
    const auto& moduleID = moduleIDAndShortcutsInversed.first;
    const auto& moduleShortcutsInversed = moduleIDAndShortcutsInversed.second;
    for (const auto& shortcutInversed : moduleShortcutsInversed) {
      if (shortcutInversed.first.isEmpty()) {
        ShCutDbg("Attempt to serialize a shortcut with empty action ID.");
        continue;
      }

      const QString sectionName = SECTION_NAME_PREFIX + resMgr->sectionsToken() + moduleID;
      resMgr->setValue(sectionName, shortcutInversed.first, shortcutInversed.second.second.toString());

      ShCutDbg() && ShCutDbg("Saving shortcut: \"" + moduleID + "\"\t\"" + shortcutInversed.first + "\"\t\"" + shortcutInversed.second.second.toString() + "\"");
    }
  }
}

void SUIT_ShortcutMgr::setAssetsFromResources(QString theLanguage)
{
  ShCutDbg() && ShCutDbg("Retrieving shortcut assets.");
  static const std::function<void(SUIT_ShortcutAssets&)> loadIcon = [] (SUIT_ShortcutAssets& theAssets) { theAssets.loadIcon(); };

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutMgr can't retrieve resource manager!");
    return;
  }

  if (theLanguage.isEmpty())
    theLanguage = SUIT_ShortcutMgr::currentLang();

  ShCutDbg("Requested asset language is \"" + theLanguage + "\".");

  const auto langs = std::set<QString>({ DEFAULT_LANG, theLanguage });

  QStringList actionAssetFilePaths = resMgr->parameters(SECTION_NAME_ACTION_ASSET_FILE_PATHS);
#ifdef SHORTCUT_MGR_DBG
  ShCutDbg("Asset files: " + actionAssetFilePaths.join(", ") + ".");
#endif
  for (const QString& actionAssetFilePath : actionAssetFilePaths) {
    const QString path = ::SUIT_tools::substituteVars(actionAssetFilePath);
    ShCutDbg("Parsing asset file \"" + path + "\".");
    QFile actionAssetFile(path);
    if (!actionAssetFile.open(QIODevice::ReadOnly)) {
      Warning("SUIT_ShortcutMgr can't open action asset file \"" + path + "\"!");
      continue;
    }

    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(actionAssetFile.readAll(), &jsonError);
    actionAssetFile.close();
    if (jsonError.error != QJsonParseError::NoError) {
      Warning("SUIT_ShortcutMgr: error during parsing of action asset file \"" + path + "\"!");
      continue;
    }

    if (document.isObject()) {
      QJsonObject documentJSONObject = document.object();
      for (const QString& moduleID : documentJSONObject.keys()) {
        if (!SUIT_ShortcutMgr::isModuleIDValid(moduleID)) {
          ShCutDbg("Action asset file \"" + path + "\" contains invalid module ID \"" + moduleID + "\".");
          continue;
        }

        const auto& moduleJSONValue = documentJSONObject[moduleID];
        if (!moduleJSONValue.isObject()) {
          ShCutDbg("Action asset file \"" + path + "\" contains invalid value with module ID \"" + moduleID + "\".");
          continue;
        }

        const auto parsedModuleAssets = SUIT_ShortcutModuleAssets::create(moduleID);
        if (!parsedModuleAssets->fromJSON(moduleJSONValue.toObject(), true /*theParseDescendants*/, langs)) {
          ShCutDbg("Action asset file \"" + path + "\" contains invalid/empty assets of module with ID \"" + moduleID + "\".");
          continue;
        }

        auto itModuleAssets = myModuleAssets.find(moduleID);
        if (itModuleAssets == myModuleAssets.end()) {
          itModuleAssets = myModuleAssets.emplace(moduleID, std::move(parsedModuleAssets)).first;
          SUIT_ShortcutModuleAssets& moduleAssets = *(itModuleAssets->second);

          moduleAssets.loadIcon();
          moduleAssets.forEachDescendant(loadIcon);

          { // Fill default assets of module itself, not its actions/folders. The default assets are overriden by assets in files.
            if (moduleID == SUIT_ShortcutMgr::ROOT_MODULE_ID) {
              if (moduleAssets.myLangDependentAssets.find(DEFAULT_LANG) == moduleAssets.myLangDependentAssets.end()) {
                auto& lda = moduleAssets.myLangDependentAssets[DEFAULT_LANG];
                lda.myName = tr("General");
              }

              if (moduleAssets.myIconPath.isEmpty()) {
                QString dirPath;
                if (resMgr->value("resources", "LightApp", dirPath))
                  moduleAssets.myIconPath = dirPath + (!dirPath.isEmpty() && dirPath.back() == "/" ? "" : "/") + "icon_default.png";
              }

              if (moduleAssets.myIcon.isNull())
                moduleAssets.myIcon = QIcon(::SUIT_tools::substituteVars(moduleAssets.myIconPath));
            }
            else /* if module is not root module */ {
              if (moduleAssets.myLangDependentAssets.find(DEFAULT_LANG) == moduleAssets.myLangDependentAssets.end()) {
                auto& lda = moduleAssets.myLangDependentAssets[DEFAULT_LANG];

                QString moduleName = moduleID;
                resMgr->value(moduleID, "name", moduleName);
                lda.myName = moduleName;

                resMgr->value(moduleID, "description", lda.myToolTip);
              }

              if (moduleAssets.myIconPath.isEmpty()) {
                QString dirPath;
                QString fileName;
                if (resMgr->value("resources", moduleID, dirPath) && resMgr->value(moduleID, "icon", fileName))
                  moduleAssets.myIconPath = dirPath + (!dirPath.isEmpty() && dirPath.back() == "/" ? "" : "/") + fileName;
              }

              if (moduleAssets.myIcon.isNull())
                moduleAssets.myIcon = QIcon(::SUIT_tools::substituteVars(moduleAssets.myIconPath));
            }
          }
        }
        else /* if assets of the module have already been added */ {
          SUIT_ShortcutModuleAssets& moduleAssets = *(itModuleAssets->second);

          moduleAssets.merge(std::move(*parsedModuleAssets), true);
          moduleAssets.loadIcon();
          moduleAssets.forEachDescendant(loadIcon);
        }
      }
    }
  }

  myAssetsLoaded = true;

#ifdef SHORTCUT_MGR_DBG
  ShCutDbg("All assets: ");
  QJsonObject moduleJSONObject;
  for (const auto& moduleIDAndAssets : myModuleAssets) {
    moduleIDAndAssets.second->toJSON(moduleJSONObject);
    QJsonDocument doc(moduleJSONObject);
    QString strJson = doc.toJson(QJsonDocument::Indented);
    ShCutDbg("\"" + moduleIDAndAssets.first + "\": " +  strJson);
  }
#endif
}

void SUIT_ShortcutMgr::registerAnonymousShortcut(QAction* const theAction)
{
  const auto itAnSh = myAnonymousShortcuts.find(theAction);
  if (itAnSh != myAnonymousShortcuts.end()) {
#ifdef SHORTCUT_MGR_DBG
    ShCutDbg("Registered anonymous shortcut is registered again.");
#endif//SHORTCUT_MGR_DBG
    onAnonymousActionDestroyed(theAction);
  }

  const QKeySequence keySequence = theAction->shortcut();

  if (keySequence == NO_KEYSEQUENCE)
    return;

#ifdef SHORTCUT_MGR_DBG
  ShCutDbg("Anonymous shortcut is registered: \"" + theAction->toolTip() + "\" - " + keySequence.toString() + ".");
#endif//SHORTCUT_MGR_DBG

  for (const auto& activeModuleID : myActiveModuleIDs) {
    if (myShortcutContainer.hasKeySequence(activeModuleID, keySequence)) {
      theAction->setShortcut(NO_KEYSEQUENCE);
      break;
    }
  }

  myAnonymousShortcuts[theAction] = keySequence;
  myAnonymousShortcutsInverse[keySequence].emplace(theAction);

  connect(theAction, SIGNAL(destroyed(QObject*)), this, SLOT (onAnonymousActionDestroyed(QObject*)));
}

void SUIT_ShortcutMgr::enableAnonymousShortcutsClashingWith(const QString& theModuleID, const bool theEnable) const
{
  for (const auto& ksAndActions : myAnonymousShortcutsInverse) {
    const QKeySequence& keySequence = ksAndActions.first;

    if (!myShortcutContainer.hasKeySequence(theModuleID, keySequence))
      continue;

    const std::set<QAction*>& actions = ksAndActions.second;
    if (theEnable) {
      for (const auto& action : actions)
        action->setShortcut(keySequence);
    }
    else {
      for (const auto& action : actions)
        action->setShortcut(NO_KEYSEQUENCE);
    }
  }
}

void SUIT_ShortcutMgr::enableAnonymousShortcutsClashingWith(const QKeySequence& theKeySequence, bool theEnable) const
{
  const auto itShortcutsInverse = myAnonymousShortcutsInverse.find(theKeySequence);
  if (itShortcutsInverse == myAnonymousShortcutsInverse.end())
    return;

  const std::set<QAction*>& actions = itShortcutsInverse->second;
  if (theEnable) {
    for (const auto& action : actions)
      action->setShortcut(theKeySequence);
  }
  else {
    for (const auto& action : actions)
      action->setShortcut(NO_KEYSEQUENCE);
  }
}

QString SUIT_ShortcutMgr::anonymousShortcutsToString() const
{
  QString res;
  res += "myAnonymousShortcutsInverse: {\n";
  for (const auto& ksAndActions : myAnonymousShortcutsInverse) {
    const QKeySequence& ks = ksAndActions.first;
    const std::set<QAction*>& actions = ksAndActions.second;
    res += "\t" + ks.toString() + ":";
    for (const auto& action : actions) {
      std::ostringstream ss;
      ss << (void const *)action;
      std::string addressStr = ss.str();
      res += " " + QString::fromStdString(addressStr);
    }
    res += ";\n";
  }
  res += "};\n\n";

  res += "myAnonymousShortcuts: {\n";
  for (const auto& shortcut : myAnonymousShortcuts) {
    const auto& action = shortcut.first;
    const QKeySequence& ks = shortcut.second;

    std::ostringstream ss;
    ss << (void const *)action;
    std::string addressStr = ss.str();
    res += "\t" + QString::fromStdString(addressStr) + ": {\n";
    res += "\t\tRegistered key sequence: " + ks.toString() + ";\n";
    res += "\t\tBound      key sequence: " + action->shortcut().toString() + ";\n";
    res += "\t};\n";
  }
  res += "};\n\n";

  return res;
}


SUIT_ActionSearcher::AssetsAndSearchData::AssetsAndSearchData(std::shared_ptr<const SUIT_ShortcutItemAssets> theAssets, double theMatchMetrics)
: myAssets(theAssets), myMatchMetrics(theMatchMetrics)
{
  if (theMatchMetrics < 0) {
    myMatchMetrics = std::numeric_limits<double>::infinity();
    ShCutDbg("WARNING: SUIT_ActionSearcher::AssetsAndSearchData: match metrics < 0. INF is assigned instead.");
  }
}

void SUIT_ActionSearcher::AssetsAndSearchData::setMatchMetrics(double theMatchMetrics)
{
  if (theMatchMetrics < 0) {
    myMatchMetrics = std::numeric_limits<double>::infinity();
    ShCutDbg("WARNING: SUIT_ActionSearcher::AssetsAndSearchData: match metrics < 0. INF is assigned instead.");
    return;
  }

  myMatchMetrics = theMatchMetrics;
}

void SUIT_ActionSearcher::AssetsAndSearchData::toJSON(QJsonObject& oJsonObject) const
{
  oJsonObject["myMatchMetrics"] = myMatchMetrics;

  if (myAssets) {
    QJsonObject assetsJSON;
    myAssets->toJSON(assetsJSON);
    oJsonObject["myAssets"] = assetsJSON;
  }
}

QString SUIT_ActionSearcher::AssetsAndSearchData::toString() const
{
  QJsonObject json;
  toJSON(json);
  QJsonDocument doc(json);
  return QString(doc.toJson(QJsonDocument::Indented));
}

/*static*/ double SUIT_ActionSearcher::matchKeySequenceString(const QString& theQuery, const QString& theKeySequence)
{
  static const QRegExp spaceRegEx("\\s");

  if (theKeySequence.isEmpty())
    return std::numeric_limits<double>::infinity();

  QString queryCleaned = theQuery.simplified().remove(spaceRegEx);;
  if (queryCleaned.isEmpty())
    return std::numeric_limits<double>::infinity();

  if (queryCleaned.contains(theKeySequence, Qt::CaseInsensitive))
    return queryCleaned.length() - theKeySequence.length();
  else if (theKeySequence.contains(queryCleaned, Qt::CaseInsensitive))
    return theKeySequence.length() - queryCleaned.length();

  return std::numeric_limits<double>::infinity();
}

SUIT_ActionSearcher::SUIT_ActionSearcher()
{
  myIncludedModuleIDs = { SUIT_ShortcutMgr::ROOT_MODULE_ID };
  myIncludeDisabledActions = false;
  myFieldsToMatch = { SUIT_ActionSearcher::MatchField::Name, SUIT_ActionSearcher::MatchField::ToolTip };
  myMatcher = new ::SUIT_tools::SUIT_SentenceMatcher();
  myMatcher->setCaseSensitive(false);
  myMatcher->setUseExactWordOrder(false);
  myMatcher->setUseFuzzyWords(true);
  myKeySequenceGetter = [] (const QString& theModuleID, const QString& theInModuleActionID) {
    return SUIT_ShortcutMgr::get()->getKeySequence(theModuleID, theInModuleActionID).toString();
  };
}

SUIT_ActionSearcher::~SUIT_ActionSearcher()
{
  delete myMatcher;
}

bool SUIT_ActionSearcher::setIncludedModuleIDs(std::set<QString> theIncludedModuleIDs, bool doNotUpdateResults)
{
  ShCutDbg("SUIT_ActionSearcher::setIncludedModuleIDs");

  if (myIncludedModuleIDs == theIncludedModuleIDs)
    return false;

  myIncludedModuleIDs = theIncludedModuleIDs;

  if (doNotUpdateResults)
    return false;

  bool res = false;
  // Erase search results from excluded modules. Erase IDs of modules, which are already in search results, from theIncludedModuleIDs.
  for (auto itFound = mySearchResults.begin(); itFound != mySearchResults.end(); ) {
    const auto itModuleID = theIncludedModuleIDs.find(itFound->first);
    if (itModuleID == theIncludedModuleIDs.end()) {
      itFound = mySearchResults.erase(itFound);
      res = true;
    }
    else {
      itFound++;
      theIncludedModuleIDs.erase(itModuleID);
    }
  }

  // Filter assets of added modules.
  const std::function<void(std::shared_ptr<const SUIT_ShortcutItemAssets>)> filterItem = [this, &res] (std::shared_ptr<const SUIT_ShortcutItemAssets> theItemAssets) {
    if (!theItemAssets->isAction())
      return;

    const double matchMetrics = matchAction(*theItemAssets);
    if (matchMetrics < std::numeric_limits<double>::infinity()) {
      mySearchResults[theItemAssets->myModuleID][theItemAssets->myInModuleID] = SUIT_ActionSearcher::AssetsAndSearchData(theItemAssets, matchMetrics);
      res = true;
    }
  };

  const auto& allAssets = SUIT_ShortcutMgr::get()->getModuleAssets();
  for (const auto& moduleIDAndAssets : allAssets) {
    const QString& moduleID = moduleIDAndAssets.first;
    if (theIncludedModuleIDs.find(moduleID) == theIncludedModuleIDs.end())
      continue;

    const auto& moduleAssets = moduleIDAndAssets.second;
    moduleAssets->forEachDescendant(filterItem);
  }

  ShCutDbg() && ShCutDbg(toString());
  return res;
}

bool SUIT_ActionSearcher::includeDisabledActions(bool theOn, bool doNotUpdateResults)
{
  ShCutDbg("SUIT_ActionSearcher::includeDisabledActions");

  if (myIncludeDisabledActions == theOn)
    return false;

  myIncludeDisabledActions = theOn;

  if (doNotUpdateResults)
    return false;

  bool res;
  if (myIncludeDisabledActions)
    res = extendResults();
  else
    res = filterResults().first;

  ShCutDbg() && ShCutDbg(toString());
  return res;
}

bool SUIT_ActionSearcher::setFieldsToMatch(const std::set<SUIT_ActionSearcher::MatchField>& theFields, bool doNotUpdateResults)
{
  if (myFieldsToMatch == theFields)
    return false;

  if (theFields.empty()) {
    myFieldsToMatch = theFields;
    mySearchResults.clear();
    return true;
  }

  static const auto isASubsetOfB = [] (const std::set<SUIT_ActionSearcher::MatchField>& theSetA, const std::set<SUIT_ActionSearcher::MatchField>& theSetB) {
    for (const auto& valA : theSetA) {
      if (theSetB.find(valA) == theSetB.end())
        return false;
    }
    return true;
  };

  const bool narrows = isASubsetOfB(theFields, myFieldsToMatch);
  const bool extends = isASubsetOfB(myFieldsToMatch, theFields);

  myFieldsToMatch = theFields;

  if (doNotUpdateResults)
    return false;

  bool res;
  if (narrows)
    res = filterResults().first;
  else if (extends)
    res = extendResults();
  else
    res = filter().first;

  ShCutDbg() && ShCutDbg(toString());
  return res;
}

std::pair<bool, bool> SUIT_ActionSearcher::setKeySequenceGetter(const std::function<QString(const QString&, const QString&)>& theKeySequenceGetter, bool doNotUpdateResults)
{
  if (theKeySequenceGetter)
    myKeySequenceGetter = theKeySequenceGetter;
  else {
    myKeySequenceGetter = [] (const QString& theModuleID, const QString& theInModuleActionID) {
      return SUIT_ShortcutMgr::get()->getKeySequence(theModuleID, theInModuleActionID).toString();
    };
  }

  if (doNotUpdateResults)
    return std::pair<bool, bool>(false, false);

  return filter();
}

bool SUIT_ActionSearcher::setCaseSensitive(bool theOn, bool doNotUpdateResults)
{
  if (myMatcher->isCaseSensitive() == theOn)
    return false;

  myMatcher->setCaseSensitive(theOn);

  if (doNotUpdateResults)
    return false;

  bool res;
  if (theOn)
    res = filterResults().first;
  else
    res = extendResults();

  ShCutDbg() && ShCutDbg(toString());
  return res;
}

bool SUIT_ActionSearcher::setQuery(const QString& theQuery)
{
  ShCutDbg("SUIT_ActionSearcher::setQuery");

  if (theQuery.simplified() == myMatcher->getQuery().simplified())
    return false;

  myMatcher->setQuery(theQuery);
  bool res = filter().first;
  ShCutDbg() && ShCutDbg(toString());
  return res;
}

const QString& SUIT_ActionSearcher::getQuery() const
{
  return myMatcher->getQuery();
}


const std::map<QString, std::map<QString, SUIT_ActionSearcher::AssetsAndSearchData>>& SUIT_ActionSearcher::getSearchResults() const
{
  return mySearchResults;
}

std::pair<bool, bool> SUIT_ActionSearcher::filter()
{
  ShCutDbg("SUIT_ActionSearcher::filter()");
  auto res = std::pair<bool, bool>(false, false);

  for (const auto& moduleIDAndAssets : SUIT_ShortcutMgr::get()->getModuleAssets()) {
    const auto& moduleID = moduleIDAndAssets.first;
    if (myIncludedModuleIDs.find(moduleID) == myIncludedModuleIDs.end())
      continue;

    auto itFoundModuleIDAndAssets = mySearchResults.find(moduleID);
    const std::function<void(std::shared_ptr<const SUIT_ShortcutItemAssets>)> filterItem = [this, &res, &itFoundModuleIDAndAssets] (std::shared_ptr<const SUIT_ShortcutItemAssets> theItemAssets) {
      if (!theItemAssets->isAction())
        return;

      const QString& moduleID = theItemAssets->myModuleID;
      const QString& inModuleActionID = theItemAssets->myInModuleID;

      if (itFoundModuleIDAndAssets != mySearchResults.end()) {
        auto& foundActionIDsAndAssets = itFoundModuleIDAndAssets->second;
        auto itFoundActionIDAndAssets = foundActionIDsAndAssets.find(inModuleActionID);
        if (itFoundActionIDAndAssets != foundActionIDsAndAssets.end()) {
          // Action is already in search results.
          SUIT_ActionSearcher::AssetsAndSearchData& aAndD = itFoundActionIDAndAssets->second;
          const double matchMetrics = matchAction(*(aAndD.myAssets));
          if (matchMetrics < std::numeric_limits<double>::infinity()) {
            if (matchMetrics != aAndD.matchMetrics()) {
              aAndD.setMatchMetrics(matchMetrics);
              res.second = true;
            }
          }
          else /* if n == 0 */ {
            foundActionIDsAndAssets.erase(itFoundActionIDAndAssets);
            res.first = true;
          }
          return;
        }
      }

      const double matchMetrics = matchAction(*theItemAssets);
      if (matchMetrics < std::numeric_limits<double>::infinity()) {
        if (itFoundModuleIDAndAssets == mySearchResults.end())
          itFoundModuleIDAndAssets = mySearchResults.emplace(moduleID, std::map<QString, SUIT_ActionSearcher::AssetsAndSearchData>()).first;

        itFoundModuleIDAndAssets->second.emplace(inModuleActionID, SUIT_ActionSearcher::AssetsAndSearchData(theItemAssets, matchMetrics));
        res.first = true;
      }
    };

    const auto& moduleAssets = moduleIDAndAssets.second;
    moduleAssets->forEachDescendant(filterItem);
  }

  return res;
}

std::pair<bool, bool> SUIT_ActionSearcher::filterResults()
{
  auto res = std::pair<bool, bool>(false, false);

  for (auto itFoundModuleIDAndAssets = mySearchResults.begin(); itFoundModuleIDAndAssets != mySearchResults.end(); ) {
    const QString& moduleID = itFoundModuleIDAndAssets->first;
    auto& actionIDsAndAssets = itFoundModuleIDAndAssets->second;
    for (auto itActionIDAndAssets = actionIDsAndAssets.begin(); itActionIDAndAssets != actionIDsAndAssets.end(); ) {
      const QString& inModuleActionID = itActionIDAndAssets->first;
      SUIT_ActionSearcher::AssetsAndSearchData& assetsAndSearchData = itActionIDAndAssets->second;
      const double matchMetrics = matchAction(*(assetsAndSearchData.myAssets));
      if (matchMetrics == std::numeric_limits<double>::infinity()) {
        itActionIDAndAssets = actionIDsAndAssets.erase(itActionIDAndAssets);
        res.first = true;
      }
      else {
        if (assetsAndSearchData.matchMetrics() != matchMetrics) {
          assetsAndSearchData.setMatchMetrics(matchMetrics);
          res.second = true;
        }
        itActionIDAndAssets++;
      }
    }

    if (actionIDsAndAssets.empty())
      itFoundModuleIDAndAssets = mySearchResults.erase(itFoundModuleIDAndAssets);
    else
      itFoundModuleIDAndAssets++;
  }

  return res;
}

bool SUIT_ActionSearcher::extendResults()
{
  ShCutDbg("SUIT_ActionSearcher::extendResults()");
  bool res = false;

  for (const auto& moduleIDAndAssets : SUIT_ShortcutMgr::get()->getModuleAssets()) {
    const auto& moduleID = moduleIDAndAssets.first;
    if (myIncludedModuleIDs.find(moduleID) == myIncludedModuleIDs.end())
      continue;

    auto itFoundModuleIDAndAssets = mySearchResults.find(moduleID);
    const std::function<void(std::shared_ptr<const SUIT_ShortcutItemAssets>)> filterItem = [this, &res, &itFoundModuleIDAndAssets] (std::shared_ptr<const SUIT_ShortcutItemAssets> theItemAssets) {
      if (!theItemAssets->isAction())
        return;

      const QString& moduleID = theItemAssets->myModuleID;
      const QString& inModuleActionID = theItemAssets->myInModuleID;

      if (itFoundModuleIDAndAssets != mySearchResults.end()) {
        const auto& foundActionIDsAndAssets = itFoundModuleIDAndAssets->second;
        if (foundActionIDsAndAssets.find(inModuleActionID) != foundActionIDsAndAssets.end())
          return; // Action is already in search results.
      }

      ShCutDbg() && ShCutDbg("SUIT_ActionSearcher::extendResults(): " + moduleID + TOKEN_SEPARATOR + inModuleActionID + "." );
      const double matchMetrics = matchAction(*theItemAssets);
      if (matchMetrics < std::numeric_limits<double>::infinity()) {
        ShCutDbg("SUIT_ActionSearcher::extendResults(): match, metrics = " + QString::fromStdString(std::to_string(matchMetrics)));
        if (itFoundModuleIDAndAssets == mySearchResults.end())
          itFoundModuleIDAndAssets = mySearchResults.emplace(moduleID, std::map<QString, SUIT_ActionSearcher::AssetsAndSearchData>()).first;

        itFoundModuleIDAndAssets->second.emplace(inModuleActionID, SUIT_ActionSearcher::AssetsAndSearchData(theItemAssets, matchMetrics));
        res = true;
      }
    };

    const auto& moduleAssets = moduleIDAndAssets.second;
    moduleAssets->forEachDescendant(filterItem);
  }

  return res;
}

double SUIT_ActionSearcher::matchAction(const SUIT_ShortcutItemAssets& theAssets)
{
  if (!theAssets.isAction())
    return std::numeric_limits<double>::infinity();

  if (!myIncludeDisabledActions) {
    const auto& actions = SUIT_ShortcutMgr::get()->getActions(theAssets.myModuleID, theAssets.myInModuleID);
    const bool actionEnabled = std::find_if(actions.begin(), actions.end(), [](const QAction* const theAction){ return theAction->isEnabled(); } ) != actions.end();
    if (!actionEnabled)
      return std::numeric_limits<double>::infinity();
  }

  double res = std::numeric_limits<double>::infinity();

  std::set<QString> langs = std::set<QString>({DEFAULT_LANG, SUIT_ShortcutMgr::currentLang()});
  for (const auto& langAndLDA : theAssets.myLangDependentAssets) {
    if (myFieldsToMatch.find(SUIT_ActionSearcher::MatchField::ToolTip) != myFieldsToMatch.end()) {
      const double matchMetrics = myMatcher->match(langAndLDA.second.myToolTip);
      if (matchMetrics < res)
        res = matchMetrics;
    }

    if (myFieldsToMatch.find(SUIT_ActionSearcher::MatchField::Name) != myFieldsToMatch.end()) {
      const double matchMetrics = myMatcher->match(langAndLDA.second.myName);
      if (matchMetrics < res)
        res = matchMetrics;

      // The block is not engaged at all, if theAssets does not contain LDA. But in fact, query may match with path prefix.
      // Path is matched in current, default and exisiting LDA languages in the next block.
      //
      // const double matchMetricsPath = myMatcher->match(theAssets.bestPath(langAndLDA.first));
      // if (matchMetricsPath < res)
      //   res = matchMetricsPath;
    }
    langs.emplace(langAndLDA.first);
  }

  // Match path.
  if (myFieldsToMatch.find(SUIT_ActionSearcher::MatchField::Name) != myFieldsToMatch.end()) {
    for (const QString& lang : langs) {
      const double matchMetrics = myMatcher->match(theAssets.bestPath(lang));
      if (matchMetrics < res)
        res = matchMetrics;
    }
  }

  if (myFieldsToMatch.find(SUIT_ActionSearcher::MatchField::ID) != myFieldsToMatch.end()) {
    const double matchMetrics = myMatcher->match(SUIT_ShortcutMgr::makeActionID(theAssets.myModuleID, theAssets.myInModuleID));
    if (matchMetrics < res)
        res = matchMetrics;
  }

  if (myFieldsToMatch.find(SUIT_ActionSearcher::MatchField::KeySequence) != myFieldsToMatch.end()) {
    const QString keySequence = myKeySequenceGetter(theAssets.myModuleID, theAssets.myInModuleID);
    const double matchMetrics = SUIT_ActionSearcher::matchKeySequenceString(myMatcher->getQuery(), keySequence);
    if (matchMetrics < res)
        res = matchMetrics;
  }

  return res;
}

QString SUIT_ActionSearcher::toString() const
{
  QString res;

  res += "myMatcher: {\n";
  res += myMatcher->toString();
  res += "};\n";

  res += "myIncludedModuleIDs: ";
  for (const QString& moduleID : myIncludedModuleIDs) {
    res += moduleID + ", ";
  }
  res += ";\n";

  res += QString("myIncludeDisabledActions: ") + (myIncludeDisabledActions ? "true" : "false") + ";\n";

  res += "myFieldsToMatch: ";
  for (const auto& field : myFieldsToMatch) {
    res += QString::number(int(field)) + ", ";
  }
  res += ";\n";

  res += "mySearchResults:\n";
  for (const auto& moduleIDAndAssets : mySearchResults ) {
    res += "\tModule ID: " + moduleIDAndAssets.first + ":\n";
    for (const auto& actionIDAndAssets : moduleIDAndAssets.second) {
      const auto& assetsAndSearchData = actionIDAndAssets.second;
      res += "\t\tAction ID: " + actionIDAndAssets.first + ": {";
      res += "\t\t: " + actionIDAndAssets.second.toString();
      res += "\t\t}";
    }
  }

  return res;
}



const QString SECTION_NAME_ACTION_ID_MUTATION_FILE_PATHS = "actionID_mutations";

/*static*/ const std::vector<QString> SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION = {"shortcuts_vA1.0", "shortcuts"};

/*static*/ const QString SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_MUTATIONS = "mutations";
/*static*/ const QString SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_PREFIX_OLD = "sectionPrefixOld";
/*static*/ const QString SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_PREFIX_NEW = "sectionPrefixNew";
/*static*/ const QString SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_OLD_TO_NEW_ACTION_ID_MAP = "oldToNewActionIDMap";

/*static*/ bool SUIT_ShortcutHistorian::AIDSMutation::isPairOfNewAndOldActionIDsValid(const QString& theSectionPrefixNew, const QString& theSectionPrefixOld)
{
  if (theSectionPrefixNew == theSectionPrefixOld) {
    Warning("SUIT_ShortcutHistorian::AIDSMutation: new section prefix is the same as old one - \"" + theSectionPrefixNew + "\".");
    return false;
  }

  return true;
}

SUIT_ShortcutHistorian::AIDSMutation::AIDSMutation(const QString& theSectionPrefixNew, const QString& theSectionPrefixOld)
{
  if (!SUIT_ShortcutHistorian::AIDSMutation::isPairOfNewAndOldActionIDsValid(theSectionPrefixNew, theSectionPrefixOld))
    throw std::invalid_argument("AIDSMutation::AIDSMutation: invalid prefixes.");

  mySectionPrefixOld = theSectionPrefixOld;
  mySectionPrefixNew = theSectionPrefixNew;
}

SUIT_ShortcutHistorian::AIDSMutation::AIDSMutation(const QJsonObject& theJsonObject, const bool theParseMap)
{
  mySectionPrefixOld = theJsonObject[SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_PREFIX_OLD].toString();
  mySectionPrefixNew = theJsonObject[SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_PREFIX_NEW].toString();
  if (!SUIT_ShortcutHistorian::AIDSMutation::isPairOfNewAndOldActionIDsValid(mySectionPrefixNew, mySectionPrefixOld))
    throw std::invalid_argument("AIDSMutation::AIDSMutation: invalid prefixes.");

  if (!theParseMap)
    return;

  const auto actionIDMapJSONObject = theJsonObject[SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_OLD_TO_NEW_ACTION_ID_MAP].toObject();
  for (const QString& oldActionID : actionIDMapJSONObject.keys()) {
    if (!SUIT_ShortcutMgr::isActionIDValid(oldActionID)) {
      Warning("SUIT_ShortcutHistorian::AIDSMutation::fromJSON: invalid action ID \"" + oldActionID + "\" has been encountered.");
      continue;
    }

    const QString newActionID = actionIDMapJSONObject[oldActionID].toString();
    if (!newActionID.isEmpty() && !SUIT_ShortcutMgr::isActionIDValid(newActionID)) {
      // New action ID may be empty. It means the action has been deleted.
      Warning("SUIT_ShortcutHistorian::AIDSMutation::fromJSON: invalid action ID \"" + newActionID + "\" has been encountered.");
      continue;
    }

    if (myOldToNewActionIDMap.find(oldActionID) != myOldToNewActionIDMap.end()) {
      Warning("SUIT_ShortcutHistorian::AIDSMutation::fromJSON: old action ID \"" + oldActionID + "\" is not unique within mutation. Ignored.");
      continue;
    }

    if (!newActionID.isEmpty() && myNewToOldActionIDMap.find(newActionID) != myNewToOldActionIDMap.end()) {
      Warning("SUIT_ShortcutHistorian::AIDSMutation::fromJSON: new action ID \"" + newActionID + "\" is not unique within mutation. Ignored.");
      continue;
    }

    myOldToNewActionIDMap.emplace(oldActionID, newActionID);

    if (!newActionID.isEmpty())
      myNewToOldActionIDMap.emplace(newActionID, oldActionID);
  }
}

bool SUIT_ShortcutHistorian::AIDSMutation::isConcurrent(const AIDSMutation& theOther) const
{
  return mySectionPrefixOld == theOther.mySectionPrefixOld && mySectionPrefixNew == theOther.mySectionPrefixNew;
}

bool SUIT_ShortcutHistorian::AIDSMutation::merge(const AIDSMutation& theOther)
{
  if (!isConcurrent(theOther))
    return false;

  bool areMutationMapsAugmented = false;
  for (const auto& oldAndNewActionIDOfOther : theOther.myOldToNewActionIDMap) {
    const QString& newActionIDOfOther = oldAndNewActionIDOfOther.second;
    const QString& oldActionIDOfOther = oldAndNewActionIDOfOther.first;

    if (myOldToNewActionIDMap.find(oldActionIDOfOther) != myOldToNewActionIDMap.end()) {
      Warning("SUIT_ShortcutHistorian::AIDSMutation::merge: old action ID \"" + oldActionIDOfOther + "\" is not unique within mutation. Ignored.");
      continue;
    }

    if (!newActionIDOfOther.isEmpty() && myNewToOldActionIDMap.find(newActionIDOfOther) != myNewToOldActionIDMap.end()) {
      Warning("SUIT_ShortcutHistorian::AIDSMutation::merge: new action ID \"" + newActionIDOfOther + "\" is not unique within mutation. Ignored.");
      continue;
    }

    myOldToNewActionIDMap.emplace(oldActionIDOfOther, newActionIDOfOther);
    if (!newActionIDOfOther.isEmpty())
      myNewToOldActionIDMap.emplace(newActionIDOfOther, oldActionIDOfOther);

    areMutationMapsAugmented = true;
  }

  return areMutationMapsAugmented;
}


SUIT_ShortcutHistorian::SUIT_ShortcutHistorian() {
  parseMutations();
  ShCutDbg("SUIT_ShortcutHistorian: parsing of old shortcut preference sections started.");
  for (const auto& oldPrefixAndMutation : myOldPrefixToMutationList) {
    const QString& oldPrefix = oldPrefixAndMutation.first;
    auto& container = myShortcutContainers.emplace(oldPrefix, SUIT_ShortcutContainer()).first->second;
    SUIT_ShortcutMgr::fillContainerFromPreferences(container, false, oldPrefix);
  }
  ShCutDbg("SUIT_ShortcutHistorian: parsing of old shortcut preference sections finished.");

  for (auto itPrefix = SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.rbegin(); itPrefix != SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.rend(); itPrefix++) {
    const auto itPrefixAndContainer = myShortcutContainers.find(*itPrefix);
    if (itPrefixAndContainer == myShortcutContainers.end())
      continue;

    const QString& oldPrefix = itPrefixAndContainer->first;
    const auto& container = itPrefixAndContainer->second;
    const auto oldModuleIDs = container.getIDsOfAllModules();
    for (const QString& moduleID : oldModuleIDs) {
      const auto& oldShortcutsInversed = container.getModuleShortcutsInversed(moduleID);
      for (const auto& oldShortcutInversed : oldShortcutsInversed) {
        const QString& oldInModuleActionID = oldShortcutInversed.first;
        const QKeySequence& keySequence = oldShortcutInversed.second;
        const QString oldActionID = SUIT_ShortcutMgr::makeActionID(moduleID, oldInModuleActionID);
        if (oldActionID.isEmpty())
          continue; // moduleID or oldInModuleActionID is invalid.

        const QString actionID = getActionID(oldActionID, oldPrefix);
        const auto moduleIDAndInModuleActionID = SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(actionID);
        if (moduleIDAndInModuleActionID.second.isEmpty())
          continue; // actionID is invalid.

        myShortcutContainer.setShortcut(
          moduleIDAndInModuleActionID.first,
          moduleIDAndInModuleActionID.second,
          keySequence,
          true /*theOverride*/
        );
      }
    }
  }
}

bool SUIT_ShortcutHistorian::doOldShortcutPreferencesExist() const
{
  for (const auto& prefixAndContainer : myShortcutContainers) {
    const auto& container = prefixAndContainer.second;
    if (!container.isEmpty())
      return true;
  }
  return false;
}

QString SUIT_ShortcutHistorian::getActionID(const QString& theOldActionID, const QString& theOldSectionPrefix) const
{
  if (theOldSectionPrefix == SECTION_NAME_PREFIX)
    return theOldActionID;

  const auto predicate = [&theOldSectionPrefix](const std::pair<QString, SUIT_ShortcutHistorian::AIDSMutation>& thePair) { return thePair.first == theOldSectionPrefix; };
  auto itOldPrefixAndMutation = std::find_if(myOldPrefixToMutationList.crbegin(), myOldPrefixToMutationList.crend(), predicate);
  if (itOldPrefixAndMutation == myOldPrefixToMutationList.crend())
    return QString();

  QString actionID = theOldActionID;
  for (; itOldPrefixAndMutation != myOldPrefixToMutationList.crend(); itOldPrefixAndMutation++) {
    const auto& mutation = itOldPrefixAndMutation->second;
    const auto itOldAndNewActionIDs = mutation.getOldToNewActionIDMap().find(actionID);
    if (itOldAndNewActionIDs != mutation.getOldToNewActionIDMap().end())
      actionID = itOldAndNewActionIDs->second;
  }
  return actionID;
}

std::pair<bool, QKeySequence> SUIT_ShortcutHistorian::getOldUserDefinedKeySequence(const QString& theActionID) const
{
  auto result = std::pair<bool, QKeySequence>(false, QKeySequence());

  /** ID of the same action before a mutation (migration) happened. */
  QString oldActionID = theActionID;
  for (const auto& oldPrefixAndMutation : myOldPrefixToMutationList) {
    const auto& mutation = oldPrefixAndMutation.second;
    const auto itNewAndOldActionIDs = mutation.getNewToOldActionIDMap().find(oldActionID);
    if (itNewAndOldActionIDs != mutation.getNewToOldActionIDMap().end())
      oldActionID = itNewAndOldActionIDs->second;

    std::pair<bool, QKeySequence> oldKeySequence = getKeySequenceFromSection(oldActionID, mutation.getSectionPrefixOld());
    if (oldKeySequence.first) {
      // The old shortcut is defined in the old section. No need to dig deeper into action ID evolution.
      return result;
    }
  }
  return result;
}

void SUIT_ShortcutHistorian::removeOldShortcutPreferences()
{
  ShCutDbg("SUIT_ShortcutHistorian::removeOldShortcutPreferences() started.");

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutHistorian: can't retrieve resource manager!");
    ShCutDbg("SUIT_ShortcutHistorian::removeOldShortcutPreferences() finished.");
    return;
  }

  for (const auto& oldPrefixAndContainer : myShortcutContainers) {
    const auto& oldSectionNamePrefix = oldPrefixAndContainer.first;
    const auto& container = oldPrefixAndContainer.second;

    const auto& moduleIDs = container.getIDsOfAllModules();
    for (const QString& moduleID : moduleIDs) {
      const QString sectionName = oldSectionNamePrefix + resMgr->sectionsToken() + moduleID;

      ShCutDbg("Section name to remove = \"" + sectionName + "\";");
      resMgr->remove(sectionName);
    }
  }

  ShCutDbg("SUIT_ShortcutHistorian::removeOldShortcutPreferences() finished.");
}

void SUIT_ShortcutHistorian::parseMutations()
{
  ShCutDbg() && ShCutDbg("Parsing action ID mutation files.");

  if (SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.size() < 2) {
    Warning("SUIT_ShortcutHistorian: shortcut settings' preference section name evolution is too short.");
    return;
  }

  if (SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.front() != SECTION_NAME_PREFIX) {
    Warning("SUIT_ShortcutHistorian: shortcut settings' preference section name evolution starts with a prefix, which differs from the actual one.");
    return;
  }

  for (size_t idx = 0; idx < SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION.size() - 1; idx++) {
    const QString& newPrefix = SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION[idx];
    const QString& oldPrefix = SUIT_ShortcutHistorian::SECTION_PREFIX_EVOLUTION[idx + 1];
    myOldPrefixToMutationList.emplace_back(std::pair<QString, SUIT_ShortcutHistorian::AIDSMutation>(oldPrefix, SUIT_ShortcutHistorian::AIDSMutation(newPrefix, oldPrefix)));
  }

  SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();
  if (!resMgr) {
    Warning("SUIT_ShortcutHistorian can't retrieve resource manager!");
    return;
  }

  QStringList mutationFilePaths = resMgr->parameters(SECTION_NAME_ACTION_ID_MUTATION_FILE_PATHS);
#ifdef SHORTCUT_MGR_DBG
  ShCutDbg("Action ID mutation files: " + mutationFilePaths.join(", ") + ".");
#endif
  for (const QString& mutationFilePath : mutationFilePaths) {
    const QString path = ::SUIT_tools::substituteVars(mutationFilePath);
    ShCutDbg("Parsing action ID mutation file \"" + path + "\".");
    QFile mutationFile(path);
    if (!mutationFile.open(QIODevice::ReadOnly)) {
      Warning("SUIT_ShortcutHistorian can't open action ID mutation file \"" + path + "\"!");
      continue;
    }

    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(mutationFile.readAll(), &jsonError);
    mutationFile.close();
    if (jsonError.error != QJsonParseError::NoError) {
      Warning("SUIT_ShortcutHistorian: error during parsing of action ID mutation file \"" + path + "\"!");
      continue;
    }

    if (document.isObject()) {
      const QJsonObject documentJSONObject = document.object();
      const auto itMutationsJSONVal = documentJSONObject.find(SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_MUTATIONS);
      if (itMutationsJSONVal == documentJSONObject.end()) {
        Warning("Action ID mutation file \"" + path + "\" does not contain \"" + SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_MUTATIONS + "\" array.");
        continue;
      }

      const auto& mutationsJSONVal = itMutationsJSONVal.value();
      if (!mutationsJSONVal.isArray()) {
        Warning("Action ID mutation file \"" + path + "\" has a property \"" + SUIT_ShortcutHistorian::AIDSMutation::PROP_ID_MUTATIONS + "\", but it is not array.");
        continue;
      }

      const auto& mutationsJSONArray = mutationsJSONVal.toArray();
      for (const auto& mutationJSONVal : mutationsJSONArray) {
        auto mutation = std::unique_ptr<SUIT_ShortcutHistorian::AIDSMutation>(nullptr);
        try {
          mutation.reset(new SUIT_ShortcutHistorian::AIDSMutation(mutationJSONVal.toObject()));
        }
        catch (const std::invalid_argument& e) {
          Warning(e.what());
          continue;
        }

        const auto predicate = [&mutation] (const std::pair<QString, SUIT_ShortcutHistorian::AIDSMutation>& thePair) { return thePair.first == mutation->getSectionPrefixOld(); };
        const auto itOldPrefixToMutationList = std::find_if(myOldPrefixToMutationList.begin(), myOldPrefixToMutationList.end(), predicate);
        if (itOldPrefixToMutationList == myOldPrefixToMutationList.end() || !mutation->isConcurrent(itOldPrefixToMutationList->second)) {
          Warning("Action ID mutation file \"" + path + "\" contains a Mutation, which is not concurrent with mutations from evolution. Old prefix \"" + mutation->getSectionPrefixOld() + "\"; new prefix \"" + mutation->getSectionPrefixNew() + "\".");
          continue;
        }

        itOldPrefixToMutationList->second.merge(*mutation);
      }
    }
  }
}

std::pair<bool, QKeySequence> SUIT_ShortcutHistorian::getKeySequenceFromSection(const QString& theActionID, const QString& theSectionPrefix) const
{
  auto result = std::pair<bool, QKeySequence>(false, QKeySequence());

  const auto moduleIDAndInModuleActionID = SUIT_ShortcutMgr::splitIntoModuleIDAndInModuleID(theActionID);
  const QString& moduleID = moduleIDAndInModuleActionID.first;
  const QString& inModuleActionID = moduleIDAndInModuleActionID.second;
  if (inModuleActionID.isEmpty())
    return result; // Invalid action ID.

  const auto itContainers = myShortcutContainers.find(theSectionPrefix);
  if (itContainers == myShortcutContainers.end())
    return result;

  const auto& container = itContainers->second;
  if (!container.hasShortcut(moduleID, inModuleActionID))
    return result;

  result.first = true;
  result.second = container.getKeySequence(moduleID, inModuleActionID);
  return result;
}