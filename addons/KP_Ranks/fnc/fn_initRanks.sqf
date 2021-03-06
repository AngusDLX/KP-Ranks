/*
    KPR_fnc_initRanks

    File: fn_initRanks.sqf
    Author: Wyqer - https://github.com/KillahPotatoes
    Date: 2018-07-09
    Last Update: 2018-07-19
    License: GNU General Public License v3.0 - https://www.gnu.org/licenses/gpl-3.0.html

    Description:
    Initializes the mod with the saved data and provide them to the clients.

    Parameter(s):
    NONE

    Returns:
    BOOL
*/

if (!isMultiplayer) exitWith {};

// Check for ACE
    KPR_ace = isClass (configfile >> "CfgPatches" >> "ace_common");

if (isServer) then {
    diag_log "[KP RANKS] [SERVER] Initializing KP Ranks...";

    // Get the servers player list and provide it for clients
    KPR_players = profileNamespace getVariable ["KPR_players", []];
    if (KPR_players isEqualTo []) then {
        diag_log "[KP RANKS] [SERVER] No player list on server, initialize empty list...";
    } else {
        diag_log "[KP RANKS] [SERVER] Sending player list to clients...";
    };
    publicVariable "KPR_players";

    // Load saved or set default uniform list
    KPR_uniforms = profileNamespace getVariable ["KPR_uniforms", []];

    if (KPR_uniforms isEqualTo []) then {
        diag_log "[KP RANKS] [SERVER] No uniform list on server, initialize default list...";

        // Get default list
        call KPR_fnc_setDefaultUniforms;

        // Save the default list initially on the server
        profileNamespace setVariable ["KPR_uniforms", KPR_uniforms];
        saveProfileNamespace;
    } else {
        diag_log "[KP RANKS] [SERVER] Sending uniform list to clients...";
    };
    // Provide list of uniforms for clients
    publicVariable "KPR_uniforms";

    // Add mission eventhandler for killed entities
    addMissionEventHandler ["EntityKilled", {
        // Leave if the leveling system isn't enabled
        if (!KPR_levelSystem) exitWith {};

        if (KPR_ace) then {
            [_this select 0, _this select 1, _this select 2] call KPR_fnc_getAceKiller;
        } else {
            [_this select 0, _this select 1, _this select 2] call KPR_fnc_entityKilled;
        };
    }];

    // Add mission eventhandler for player respawn
    addMissionEventHandler ["EntityRespawned", {
        // Leave if the leveling system isn't enabled
        if (!KPR_levelSystem) exitWith {};

        [_this select 0, _this select 1] call KPR_fnc_playerDeath;
    }];

    // Start score updater
    call KPR_fnc_scoreUpdate;

    diag_log format ["[KP RANKS] [SERVER] Finished initialization - Listed Players: %1 - Listed Uniforms: %2 - Auto Mode: %3 - Level System: %4 - Nation by: %5", count KPR_players, count KPR_uniforms, KPR_autoMode, KPR_levelSystem, if (KPR_playerNation) then {"Player"} else {"Uniform"}];
};

if (hasInterface) then {
    if (KPR_extendedLog) then {
        private _text = format ["[KP RANKS] [%1 (%2)] Connected", name player, getPlayerUID player];
        _text remoteExecCall ["diag_log", 2];
    };

    KPR_isAdmin = false;

    // Get players name with clan prefix
    private _displayname = "";
    if !(squadParams player isEqualTo []) then {
        _displayname = "[" + ((squadParams player select 0) select 0) + "] ";
    };
    _displayname = _displayname + name player;

    // Get and set player rank
    private _index = KPR_players findIf {_x select 1 == getPlayerUID player};
    if (_index != -1) then {
        if (KPR_extendedLog) then {
            private _text = format ["[KP RANKS] [%1 (%2)] Found in server list with rank: %3", name player, getPlayerUID player, KPR_players select _index select 2];
            _text remoteExecCall ["diag_log", 2];
        };

        // Update player name, if it has changed
        if (KPR_players select _index select 0 != _displayname) then {
            if (KPR_extendedLog) then {
                private _text = format ["[KP RANKS] [%1 (%2)] Renamed from %3 to %4", name player, getPlayerUID player, KPR_players select _index select 0, _displayname];
                _text remoteExecCall ["diag_log", 2];
            };

            [[_displayname, getPlayerUID player]] remoteExecCall ["KPR_fnc_updatePlayer", 2];
        };
    } else {
        // Add player if not in server list
        if (KPR_extendedLog) then {
            private _text = format ["[KP RANKS] [%1 (%2)] Not in server list, adding player to server list.", name player, getPlayerUID player];
            _text remoteExecCall ["diag_log", 2];
        };

        [[_displayname, getPlayerUID player, 0, 3, 0, 0, 0]] remoteExecCall ["KPR_fnc_addPlayer", 2];
    };

    // Check for ACE
    if (KPR_ace) then {
        if (KPR_extendedLog) then {
            private _text = format ["[KP RANKS] [%1 (%2)] ACE detected", name player, getPlayerUID player];
            _text remoteExecCall ["diag_log", 2];
        };

        // Add self interaction menu entries
        call KPR_fnc_initACE;
    } else {
        // Add vanilla actions and respawn EH
        player addEventHandler ["Respawn", {
            params ["_unit", "_corpse"];
            [_corpse] call KPR_fnc_addActions;
        }];
        call KPR_fnc_addActions;
    };

    call KPR_fnc_isAdmin;

    if (KPR_extendedLog) then {
        private _text = format ["[KP RANKS] [%1 (%2)] Initialization finished", name player, getPlayerUID player];
        _text remoteExecCall ["diag_log", 2];
    };
};

true
