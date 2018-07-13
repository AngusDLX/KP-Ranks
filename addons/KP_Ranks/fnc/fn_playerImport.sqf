/*
    KPR_fnc_playerImport

    File: fn_playerImport.sqf
    Author: Wyqer - https://github.com/KillahPotatoes
    Date: 2018-07-13
    Last Update: 2018-07-13
    License: GNU General Public License v3.0 - https://www.gnu.org/licenses/gpl-3.0.html

    Description:
    Imports the KPR_players array from the players profileNamespace variable.
    Unsets the variable in the profileNamespace afterwards.

    Parameter(s):
    NONE

    Returns:
    BOOL
*/

KPR_players = player getVariable ["KPR_pClipboard", []];
player setVariable ["KPR_pClipboard", nil];
[KPR_players] remoteExecCall ["KPR_fnc_savePlayers", 2];
closeDialog 0;
call KPR_fnc_openDialogPlayers;

true
