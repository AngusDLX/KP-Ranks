/*
    KPR_fnc_savePlayers

    File: fn_savePlayers.sqf
    Author: Wyqer - https://github.com/KillahPotatoes
    Date: 2018-07-10
    Last Update: 2018-07-10
    License: GNU General Public License v3.0 - https://www.gnu.org/licenses/gpl-3.0.html

    Description:
    Updates and saves the list of player ranks in the servers profile namespace.

    Parameter(s):
        0: ARRAY - Array of player data arrays, e.g [[Steam UID, Name, Rank], [Steam UID, Name, Rank]]

    Returns:
    BOOL
*/

if (!isServer) exitWith {};

params [["_newList",[]]];

if (_newList isEqualTo []) then {
    diag_log "[KP RANKS] KPR_fnc_savePlayers called with no data. Skipping the saving.";
} else {
    diag_log format ["[KP RANKS] KPR_fnc_savePlayers called with %1 entries.", count _newList];

    KPR_players = _newList;
    profileNamespace setVariable ["KPR_players", KPR_players];
    saveProfileNamespace;
    publicVariable "KPR_players";
};

true
