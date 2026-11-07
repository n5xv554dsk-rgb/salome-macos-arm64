 # ShortcutMgr ReadMe
 At first, read SUIT_ShortcutMgr class documentation in code.

For all identified actions, assets must be placed into asset files. People who do/refine localizations should keep this in mind and also process JSON files, which are referred in resource files in sections `<section name="action_assets">`.

To alleviate process of composing resource and asset files, a development tool `DevTools` has been made. See documentations of the class in code.

Shortcuts and assets for all actions of SHAPER and GEOM and those actions of desktop, which were bound (hardcoded) to non-empty key sequences, have been added to preference and asset files. Now they are available for hot key remapping via GUI, no conflicts guaranteed. A hardcoded shortcut may be changed or disabled, if preference files override its key sequence.

## Conflicts between shortcuts of desktop and modules, except SHAPER and GEOM

Most of remaining actions (which have no action IDs) can not be made available for shortcut customization without further meticulous inspection of all other modules' code, devising and typing proper action IDs for all such occurrences.

Since desktop shortcuts are allowed for remapping, user could end up with conflicting shortcuts of desktop actions and those actions of unprocessed modules (all, except SHAPER and GEOM), which are hardcoded to non-empty key sequences.

Actions without action IDs or with invalid ones are called anonymous actions. Now they are handled as following.
All anonymous actions with non-empty shortcut key sequences are also registered by `SUIT_ShortcutMgr`.
If a shortcut for an anonymous action clashes with a shortcut for an action with defined ID (identified action/shortcut),
the shortcut for the anonymous action is disabled, but [the anonymous action, the hard-coded key sequence] pair remains within the `SUIT_ShortcutMgr`.
If user redefines key sequences for identified actions, and the clash is gone, `SUIT_ShortcutMgr` enables back the shortcut for the anonymous action.
It is not possible to reassign key sequences for anonymous actions using the `SUIT_ShortcutTree` GUI.
It is not possible to always warn user, if a key sequence, he assigns to an identified action,
disables an anonymous shortcut, because SUIT_ShortcutMgr has no data about anonymous actions until they appear in runtime.
To prevent the user from relying on such warnings, they are completely disabled.

There are other approaches how to handle anonymous actions:

1. Go through unprocessed repositories and add valid ID in every occurrence of action creation. Or at least only for those invalid-ID actions, which are currently assigned non-empty key sequences. It should not be just dumb slapping of unique IDs: some actions comprise meta-action (see `SUIT_ShortcutMgr` class documentation) and must get the same ID, e.g. “Undo”, and some actions with similar names do absolutely unrelated things and must be given with different IDs.

2. Forbid user to edit shortcuts of desktop and shortcuts of unprocessed modules. When another module will be processed, allow to modify its shortcuts. When all modules will be processed, make desktop shortcuts available for customization.

## Issue with ampersand-shortcuts

`QPushButton::QPushButton(const QString&)`, being fed with an action name with an ampersand preceding a char, automatically creates a shortcut, bound to *Alt+\<char>* key sequence.

E.g. `auto button = QPushButton(tr("&Help")` may create language-depdendent shortcuts. Suppose that \*_fr.ts file contains this:
```
<message>
	<source>&amp;Help</source>
	<translation>A&amp;ide</translation>
<message>

```

Then help menu has different shortcuts if the application is run in EN or FR.

**A part of the issue** is that some ampersand-shortcuts interfere between each other. You can witness this in master-native application. Switch language to FR, run the app, click on the area, where viewers appear, and stroke *Alt+A*. You will get a Qt-generated notification *"Ambiguous shortcut detected"*, because *Alt+A* is bound to *"New ParaView window"* and to *"Affichage"* simultaneously. If you stroke the sequence again, *"Affichage"* menu expands, since the button tray, where the menu-button resides, has gained focus.

**Another part of the issue** is that ampersand-shortcuts are not always intercepted by `SUIT_ShortcutMgr::eventFilter(_)`. Normally, the manager catches an unregistered `QAction`. But, non-intercepted ampersand-shortcut always remains enabled, and, if user binds some action to the same key sequence in the shortcut editor, the editor is not able to detect conflict and prevent interfering binding. Then user faces with the *"Ambiguous shortcut detected"* notification or button-menu is opened instead of executing the action, mapped to the key sequence in shortcut editor.

**The question is how to handle ampersand-shortcuts?**
1. Resolve conflicts between ampersand-shortcuts for all localizations. Prohibit binding actions to *Alt+\<char>* key sequences in shortcut editor.
2. After every occurrence of `QPushButton` creation type something like this:
```
// Occurrence
const auto helpButton = new QPushButton(tr("&Help"));
SUIT_ShortcutMgr::get()->registerButtonActions("/#AltHelp", *helpButton);

----------------------------------------------------
// SUIT_ShortcutMgr.cpp
void SUIT_ShortcutMgr::registerButtonActions(const QString& theActionID, const QPushButton& theButton) const {
	for (QAction* const action : theButton.actions()) {
		registerAction(theActionID, action);
	}
}
----------------------------------------------------
// Resource file
	<section name="shortcuts_vA1.0:">
  		<parameter name="#AltHelp" value="Alt+H"/>
	</section>
```
Thus, ampersand-shortcuts will appear and be treated in shortcut editor as regular shortcuts.
If the second option is preferable, should different ampersand-shortcuts for every target language be placed in resource files?

## Minor issues
1. Selection of `SUIT_ShortcutTree`' item shadows "modified" highlighter. Selection of module tab in `SUIT_ShortcutTabWidget` shadows "modified" highlighter.
2. `SUIT_ShortcutMgr` introduces concept of module, but the first module class is `CAM_Module` is introduced along with `CAM_Application`, which is descendant of `SUIT_Application`.
