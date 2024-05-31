Locale["en"] = {
    -- Command notifications
    ["force_server_settings"] = "The server does not allow players to change their own settings",
    ["not_enough_permissions"] = "You don't have enough permissions to use this command",

    -- Commands
    ["command_settings_desc"] = "Vibration manager menu",
    ["command_desc"] = "Makes players vibrate",
    ["command_mode"] = "Mode",
    ["command_mode_desc"] = "\"all\" = All the players in the server | \"range\" = All the players in a given range | \"id\" = Player Id",
    ["command_intensity"] = "Intensity",
    ["command_intensity_desc"] = "Vibration itensity (1-20)",
    ["command_duration"] = "Duration",
    ["command_duration_desc"] = "Vibration duration (1-60)",
    ["command_range"] = "Range",
    ["command_range_desc"] = "Range in wich players will vibrate (only works in range mode)",
    ["command_help_desc"] = "Use this command if you have issues with starting the script",
    ["command_help_text"] = "Make sure you have opened \"Intiface Central\", navigate to the \"device\" tab using the buttons on the left, click on the big play button in the top left (Status should change from \"Engine not running\" to \"Engine running, waiting for client\"), now the text \"Start Scanning\" should be highlighted, click on it and wait until the toys are connected (If you are using a toy with a cable make sure it is connected to the pc, if you are instead using a toy via bluetooth make sure that bluetooth is enabled on your pc), when the toys are connected come back to the game and try again",

    -- Menu titles
    ["main_menu_title"] = "Vibration menu",
    ["dmg_title"] = "Damage",
    ["dmg_desc"] = "Every time you take damage you will vibrate",
    ["speed_title"] = "Speed",
    ["speed_desc"] = "Surpassing a given speed will make you vibrate",
    ["shooting_title"] = "Shooting",
    ["shooting_desc"] = "Every time you shoot with a gun you will vibrate",
    ["server_title"] = "Commands",
    ["server_desc"] = "Accept commands from the server to make you vibrate",
    ["activate_deactivate"] = "Activate/deactivate",

    -- Interaction menu texts
    ["speed_treshold"] = "Speed limit (Km/h)",
    ["active"] = "Active",
    ["randomize_intensity"] = "Randomize intensity",
    ["min_intensity"] = "Min intensity",
    ["max_intensity"] = "Max intensity",
    ["randomize_duration"] = "Randomize duration",
    ["min_duration"] = "Min duration",
    ["max_duration"] = "Max duration",

    -- Link notifications
    ["toy_connection_error"] = "Link with toy failed, use \"/brrhelp\" to get more info",
    ["toy_connection_success"] = "Link with Toy successful",
    ["toy_disconnected"] = "Link with Toy just dropped",
}