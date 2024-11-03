-- ModernZ (https://github.com/Samillion/ModernZ)
--
-- This script is a derivative of the original mpv-osc-modern by maoiscat 
-- and subsequent forks:
--   * cyl0/ModernX
--   * dexeonify/ModernX
--   * zydezu/ModernX
--
-- It is based on the official osc.lua from mpv, licensed under the 
-- GNU Lesser General Public License v2.1 (LGPLv2.1). 
-- Full license: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html

local assdraw = require "mp.assdraw"
local msg = require "mp.msg"
local opt = require "mp.options"
local utils = require "mp.utils"

-- Parameters
-- default user option values
-- do not touch, change them in modernz.conf
local user_opts = {
    -- Language and display  
    language = "en",                       -- set language (for available options, see: https://github.com/Samillion/ModernZ/blob/main/docs/TRANSLATIONS.md) 
    font = "mpv-osd-symbols",              -- font for the OSC (default: mpv-osd-symbols or the one set in mpv.conf)
    
    idlescreen = true,                     -- show mpv logo when idle
    windowcontrols = "auto",               -- show OSC window controls: "auto", "yes", or "no"
    showwindowed = true,                   -- show OSC when windowed
    showfullscreen = true,                 -- show OSC when fullscreen
    showonpause = true,                    -- show OSC when paused
    keeponpause = true,                    -- disable OSC hide timeout when paused 
    greenandgrumpy = false,                -- disable Santa hat in December

    -- OSC behaviour and scaling
    hidetimeout = 1500,                    -- time (in ms) before OSC hides if no mouse movement
    seek_resets_hidetimeout = true,        -- if seeking should reset the hidetimeout
    fadeduration = 250,                    -- fade-out duration (in ms), set to 0 for no fade
    minmousemove = 0,                      -- minimum mouse movement (in pixels) required to show OSC
    bottomhover = true,                    -- show OSC only when hovering at the bottom
    bottomhover_zone = 160,                -- height of hover zone for bottomhover (in pixels)
    osc_on_seek = false,                   -- show OSC when seeking
    mouse_seek_pause = true,               -- pause video while seeking with mouse move (on button hold)

    vidscale = "auto",                     -- scale osc with the video
    scalewindowed = 1.0,                   -- osc scale factor when windowed
    scalefullscreen = 1.0,                 -- osc scale factor when fullscreen

    -- Time and title display
    showtitle = true,                      -- show title in the OSC (above seekbar)
    title = "${media-title}",              -- title above seekbar format: "${media-title}" or "${filename}"
    titlefontsize = 30,                    -- font size of the title text (above seekbar)
    
    show_chapter_title = true,             -- show chapter title alongside timestamp (below seekbar)
    chapter_fmt = "%s",                    -- format for chapter display on seekbar hover (set to "no" to disable)

    timetotal = true,                      -- show total time instead of remaining time
    timems = false,                        -- show timecodes with milliseconds
    unicodeminus = false,                  -- use the Unicode minus sign in remaining time
    time_format = "dynamic",               -- "dynamic" or "fixed". dynamic shows MM:SS when possible, fixed always shows HH:MM:SS
    timefontsize = 18,                     -- font size of the time display

    -- Title bar settings
    showwindowtitle = false,               -- show window title in borderless/fullscreen mode
    showwindowcontrols = true,             -- show window controls (close, minimize, maximize) in borderless/fullscreen
    titleBarStrip = false,                 -- show title bar as a single bar instead of a black fade
    windowcontrols_title = "${media-title}", -- same as title but for windowcontrols

    -- Subtitle display settings
    raisesubs = true,                      -- raise subtitles above the OSC when shown
    raisesubamount = 175,                  -- amount by which subtitles are raised when the OSC is shown (in pixels)

    -- Buttons display and functionality
    showjump = true,                       -- show "jump forward/backward 10 seconds" buttons
    jumpamount = 10,                       -- jump amount in seconds
    jumpiconnumber = true,                 -- show different icon for 5, 10, or 30 second jumps
    jumpmode = "relative",                 -- seek mode for jump buttons
    jump_softrepeat = true,                -- enable continuous jumping when holding down seek buttons
    showskip = false,                      -- show the skip back and forward (chapter) buttons
    chapter_softrepeat = true,             -- enable continuous skipping when holding down chapter skip buttons
    shownextprev = true,                   -- show next/previous playlist track buttons

    volumecontrol = true,                  -- show mute button and volume slider
    volumecontroltype = "linear",          -- volume scale type: "linear" or "logarithmic"
    showplaylist = false,                  -- show playlist button: Left-click for simple playlist, Right-click for interactive playlist
    hide_empty_playlist_button = true,     -- hide playlist button when no playlist exists
    gray_empty_playlist_button = true,     -- gray out the playlist button when no playlist exists

    downloadbutton = true,                 -- show download button on web videos (requires yt-dlp and ffmpeg)
    download_path = "~~desktop/mpv",       -- default download directory for videos (https://mpv.io/manual/master/#paths)
    showscreenshot = false,                -- show screenshot button
    screenshot_flag = "subtitles",         -- flag for screenshot button: "subtitles", "video", "window", "each-frame" (https://mpv.io/manual/master/#command-interface-screenshot-%3Cflags%3E)
    showontop = true,                      -- show window on top button
    showloop = true,                       -- show loop button
    loopinpause = true,                    -- enable looping by right-clicking pause
    showinfo = false,                      -- show info button
    showfullscreen_button = true,          -- show fullscreen toggle button

    playpause_size = 30,                   -- icon size for the play/pause button
    midbuttons_size = 24,                  -- icon size for the middle buttons
    sidebuttons_size = 24,                 -- icon size for the side buttons

    hide_elements_for_image = true,        -- hides irrelevant elements when viewing images

    -- Colors and style
    osc_color = "#000000",                 -- accent color of the OSC and title bar
    window_title_color = "#FFFFFF",        -- color of the title in borderless/fullscreen mode
    window_controls_color = "#FFFFFF",     -- color of the window controls (close, minimize, maximize) in borderless/fullscreen mode
    title_color = "#FFFFFF",               -- color of the title (above seekbar)
    seekbarfg_color = "#BE4D25",           -- color of the seekbar progress and handle
    seekbarbg_color = "#FFFFFF",           -- color of the remaining seekbar
    seekbar_cache_color = "#BE254A",       -- color of the cache ranges on the seekbar
    vol_bar_match_seek = false,            -- match volume bar color with seekbar color (ignores side_buttons_color)
    time_color = "#FFFFFF",                -- color of the timestamps (below seekbar)
    chapter_title_color = "#FFFFFF",       -- color of the chapter title next to timestamp (below seekbar)
    side_buttons_color = "#FFFFFF",        -- color of the side buttons (audio, subtitles, playlist, etc.)
    middle_buttons_color = "#FFFFFF",      -- color of the middle buttons (skip, jump, chapter, etc.)
    playpause_color = "#FFFFFF",           -- color of the play/pause button
    held_element_color = "#999999",        -- color of the element when held down (pressed)
    hovereffect_color = "#CB7050",         -- color of a hovered button when hovereffect includes "color"
    thumbnailborder_color = "#111111",     -- color of the border for thumbnails (with thumbfast)

    OSCfadealpha = 150,                    -- alpha of the OSC background box
    boxalpha = 75,                         -- alpha of the window title bar
    thumbnailborder = 2,                   -- width of the thumbnail border (for thumbfast)

    -- Button hover effects
    hovereffect = "size,glow,color",       -- active button hover effects: "glow", "size", "color"; can use multiple separated by commas
    hover_button_size = 115,               -- relative size of a hovered button if "size" effect is active
    button_glow_amount = 5,                -- glow intensity when "glow" hover effect is active
    hovereffect_for_sliders = true,        -- apply hover effects to slider handles

    -- Tooltips and hints
    tooltips_for_disabled_elements = true, -- enable tooltips for disabled buttons and elements
    tooltip_hints = true,                  -- enable text hints for info, loop, ontop, and screenshot buttons

    -- Progress bar settings 
    seekbarhandlesize = 0.8,               -- size ratio of the seekbar handle (range: 0 ~ 1)
    seekrange = true,                      -- show seek range overlay
    seekrangealpha = 150,                  -- transparency of the seek range
    livemarkers = true,                    -- update chapter markers on the seekbar when duration changes
    seekbarkeyframes = false,              -- use keyframes when dragging the seekbar
    
    automatickeyframemode = true,          -- automatically set keyframes for the seekbar based on video length
    automatickeyframelimit = 600,          -- videos longer than this (in seconds) will have keyframes on the seekbar 

    persistentprogress = false,            -- always show a small progress line at the bottom of the screen
    persistentprogressheight = 17,         -- height of the persistent progress bar
    persistentbuffer = false,              -- show buffer status on web videos in the persistent progress line

    -- Miscellaneous settings
    visibility = "auto",                   -- only used at init to set visibility_mode(...)
    tick_delay = 1 / 60,                   -- minimum interval between OSC redraws (in seconds)
    tick_delay_follow_display_fps = false, -- use display FPS as the minimum redraw interval

    -- Mouse commands
    -- customize the button function based on mouse action

    -- seekbar mouse wheel mode. accepts: "speed" or "seek". speed adjusts playback speed.
    seekbar_track_wheel_mode = "seek",

    -- title above seekbar mouse actions
    title_mbtn_left_command = "script-binding select/select-playlist; script-message-to modernz osc-hide",
    title_mbtn_right_command = "script-binding stats/display-page-5",

    -- playlist button mouse actions
    playlist_mbtn_left_command = "script-binding select/select-playlist; script-message-to modernz osc-hide",
    playlist_mbtn_right_command = "show-text ${playlist} 3000",

    -- volume mouse actions
    vol_ctrl_mbtn_right_command = "script-binding select/select-audio-device; script-message-to modernz osc-hide",

    -- audio button mouse actions
    audio_track_mbtn_left_command = "script-binding select/select-aid; script-message-to modernz osc-hide",
    audio_track_mbtn_right_command = "osd-msg cycle audio",
    audio_track_wheel_down_command = "osd-msg cycle audio",
    audio_track_wheel_up_command = "osd-msg cycle audio down",

    -- subtitle button mouse actions
    sub_track_mbtn_left_command = "script-binding select/select-sid; script-message-to modernz osc-hide",
    sub_track_mbtn_right_command = "osd-msg cycle sub",
    sub_track_wheel_down_command = "osd-msg cycle sub",
    sub_track_wheel_up_command = "osd-msg cycle sub down",

    -- chapter skip buttons mouse actions
    chapter_prev_mbtn_left_command = "osd-msg add chapter -1",
    chapter_prev_mbtn_right_command = "script-binding select/select-chapter; script-message-to modernz osc-hide",

    chapter_next_mbtn_left_command = "osd-msg add chapter 1",
    chapter_next_mbtn_right_command = "script-binding select/select-chapter; script-message-to modernz osc-hide",

    -- chapter title (below seekbar) mouse actions
    chapter_title_mbtn_left_command = "script-binding select/select-chapter; script-message-to modernz osc-hide",
    chapter_title_mbtn_right_command = "show-text ${chapter-list} 3000",
}

mp.observe_property("osc", "bool", function(name, value) if value == true then mp.set_property("osc", "no") end end)

local osc_param = { -- calculated by osc_init()
    playresy = 0,                           -- canvas size Y
    playresx = 0,                           -- canvas size X
    display_aspect = 1,
    unscaled_y = 0,
    areas = {},
}

local icons = {
    play = "\238\166\143",
    pause = "\238\163\140",
    replay = "\238\189\191",
    previous = "\239\152\167",
    next = "\239\149\168",
    rewind = "\238\168\158",
    forward = "\238\152\135",

    audio = "\238\175\139",
    subtitle = "\238\175\141",
    playlist = "\238\161\159",
    volume_mute = "\238\173\138",
    volume_quiet = "\238\172\184",
    volume_low = "\238\172\189",
    volume_high = "\238\173\130",

    download = "\239\133\144",
    downloading = "\239\140\174",
    screenshot = "\238\169\150",
    ontop_on = "\238\165\190",
    ontop_off = "\238\166\129",
    loop_off = "\239\133\178",
    loop_on = "\239\133\181",
    info = "\239\146\164",
    fullscreen = "\239\133\160",
    fullscreen_exit = "\239\133\166",

    jumpicons = { 
        [5] = {"\238\171\186", "\238\171\187"}, 
        [10] = {"\238\171\188", "\238\172\129"}, 
        [30] = {"\238\172\133", "\238\172\134"}, 
        default = {"\238\172\138", "\238\172\138"}, -- second icon is mirrored in layout() 
    }
}

--- localization
local language = {
    ["en"] = {
        welcome = "Drop files or URLs here to play",
        na = "Not available",
        video = "Video",
        audio = "Audio",
        subtitle = "Subtitle",
        nosub = "No subtitles available",
        noaudio = "No audio tracks available",
        playlist = "Playlist",
        nolist = "Playlist is empty",
        chapter = "Chapter",
        nochapter = "No chapters available",
        ontop = "Pin window",
        ontopdisable = "Unpin window",
        loopenable = "Enable loop",
        loopdisable = "Disable loop",
        screenshot = "Screenshot",
        statsinfo = "Information",
    },
}

-- locale JSON file handler
function get_locale_from_json(path)
    local expand_path = mp.command_native({'expand-path', path})

    local file_info = utils.file_info(expand_path)
    if not file_info or not file_info.is_file then
        return nil
    end

    local json_file = io.open(expand_path, 'r')
    if not json_file then
        return nil
    end

    local json = json_file:read('*all')
    json_file:close()

    local json_table, parse_error = utils.parse_json(json)
    if not json_table then
        mp.msg.error("JSON parse error:" .. parse_error)
    end
    return json_table
end

-- load external locales if available
local locale_path = "~~/script-opts/modernz-locale.json"
local external = get_locale_from_json(locale_path)

if external then
    for lang, strings in pairs(external) do
        if type(strings) == "table" then
            language[lang] = strings

            -- fill in missing locales with English defaults
            for key, value in pairs(language["en"]) do
                if strings[key] == nil then
                    strings[key] = value or ""  -- fallback to empty string if key is missing
                end

                -- debug log to verify all keys are populated
                if strings[key] == nil then
                    mp.msg.warn("Locale key '" .. key .. "' is nil in language: " .. lang)
                end
            end
        else
            mp.msg.warn("Locale data for language " .. lang .. " is not in the correct format.")
        end
    end
end

local texts
local function set_osc_texts()
    texts = language[user_opts.language] or language["en"]
    local welcome_ass_tags = "{\\fs24\\1c&H0&\\1c&HFFFFFF&}"
    texts.welcome = welcome_ass_tags .. texts.welcome
end

local function contains(list, item)
    local t = {}
    if type(list) ~= "table" then
        for str in string.gmatch(list, '([^,]+)') do
            str = str:gsub("%s+", "")
            table.insert(t, str)
        end
    else
        t = list
    end
    for _, v in ipairs(t) do
        if v == item then
            return true
        end
    end
    return false
end

local thumbfast = {
    width = 0,
    height = 0,
    disabled = true,
    available = false
}

local tick_delay = 1 / 60
local audio_track_count = 0
local sub_track_count = 0
local window_control_box_width = 138
local is_december = os.date("*t").month == 12
local UNICODE_MINUS = string.char(0xe2, 0x88, 0x92)  -- UTF-8 for U+2212 MINUS SIGN
local iconfont = "fluent-system-icons"

local function osc_color_convert(color)
    return color:sub(6,7) .. color:sub(4,5) ..  color:sub(2,3)
end

local osc_styles

local function set_osc_styles()
    local playpause_size = user_opts.playpause_size or 30
    local midbuttons_size = user_opts.midbuttons_size or 24
    local sidebuttons_size = user_opts.sidebuttons_size or 24
    osc_styles = {
        background_bar = "{\\1c&H" .. osc_color_convert(user_opts.osc_color) .. "&}",
        box_bg = "{\\blur100\\bord" .. user_opts.OSCfadealpha .. "\\1c&H000000&\\3c&H" .. osc_color_convert(user_opts.osc_color) .. "&}",
        chapter_title = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.chapter_title_color) .. "&\\3c&H000000&\\fs" .. user_opts.timefontsize .. "\\fn" .. user_opts.font .. "}",
        control_1 = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.playpause_color) .. "&\\3c&HFFFFFF&\\fs" .. playpause_size .. "\\fn" .. iconfont .. "}",
        control_2 = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.middle_buttons_color) .. "&\\3c&HFFFFFF&\\fs" .. midbuttons_size .. "\\fn" .. iconfont .. "}",
        control_2_flip = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.middle_buttons_color) .. "&\\3c&HFFFFFF&\\fs" .. midbuttons_size .. "\\fn" .. iconfont .. "\\fry180}",
        control_3 = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\3c&HFFFFFF&\\fs" .. sidebuttons_size .. "\\fn" .. iconfont .. "}",
        element_down = "{\\1c&H" .. osc_color_convert(user_opts.held_element_color) .. "&}",
        element_hover = "{" .. (contains(user_opts.hovereffect, "color") and "\\1c&H" .. osc_color_convert(user_opts.hovereffect_color) .. "&" or "") .."\\2c&HFFFFFF&" .. (contains(user_opts.hovereffect, "size") and string.format("\\fscx%s\\fscy%s", user_opts.hover_button_size, user_opts.hover_button_size) or "") .. "}",
        seekbar_bg = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.seekbarbg_color) .. "&}",
        seekbar_fg = "{\\blur1\\bord1\\1c&H" .. osc_color_convert(user_opts.seekbarfg_color) .. "&}",
        thumbnail = "{\\blur1\\bord0.5\\1c&H" .. osc_color_convert(user_opts.thumbnailborder_color) .. "&\\3c&H000000&}",
        time = "{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.time_color) .. "&\\3c&H000000&\\fs" .. user_opts.timefontsize .. "\\fn" .. user_opts.font .. "}",
        title = "{\\blur1\\bord0.5\\1c&H" .. osc_color_convert(user_opts.title_color) .. "&\\3c&H0&\\fs".. user_opts.titlefontsize .."\\q2\\fn" .. user_opts.font .. "}",
        tooltip = "{\\blur1\\bord0.5\\1c&HFFFFFF&\\3c&H000000&\\fs" .. user_opts.timefontsize .. "\\fn" .. user_opts.font .. "}",
        volumebar_bg = "{\\blur0\\bord0\\1c&H999999&}",
        volumebar_fg = "{\\blur1\\bord1\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&}",
        window_control = "{\\blur1\\bord0.5\\1c&H" .. osc_color_convert(user_opts.window_controls_color) .. "&\\3c&H0&\\fs25\\fnmpv-osd-symbols}",
        window_title = "{\\blur1\\bord0.5\\1c&H" .. osc_color_convert(user_opts.window_title_color) .. "&\\3c&H0&\\fs30\\q2\\fn" .. user_opts.font .. "}",
    }
end

-- internal states, do not touch
local state = {
    showtime = nil,                         -- time of last invocation (last mouse move)
    touchtime = nil,                        -- time of last invocation (last touch event)
    osc_visible = false,
    anistart = nil,                         -- time when the animation started
    anitype = nil,                          -- current type of animation
    animation = nil,                        -- current animation alpha
    mouse_down_counter = 0,                 -- used for softrepeat
    active_element = nil,                   -- nil = none, 0 = background, 1+ = see elements[]
    active_event_source = nil,              -- the "button" that issued the current event
    tc_right_rem = not user_opts.timetotal, -- if the right timecode should display total or remaining time
    tc_ms = user_opts.timems,               -- Should the timecodes display their time with milliseconds
    screen_sizeX = nil, screen_sizeY = nil, -- last screen-resolution, to detect resolution changes to issue reINITs
    initREQ = false,                        -- is a re-init request pending?
    marginsREQ = false,                     -- is a margins update pending?
    last_mouseX = nil, last_mouseY = nil,   -- last mouse position, to detect significant mouse movement
    mouse_in_window = false,
    fullscreen = false,
    tick_timer = nil,
    tick_last_time = 0,                     -- when the last tick() was run
    hide_timer = nil,
    cache_state = nil,
    idle = false,
    enabled = true,
    input_enabled = true,
    showhide_enabled = false,
    windowcontrols_buttons = false,
    windowcontrols_title = false,
    border = true,
    maximized = false,
    osd = mp.create_osd_overlay("ass-events"),
    chapter_list = {},                      -- sorted by time
    mute = false,
    looping = false,
    sliderpos = 0,
    touchingprogressbar = false,            -- if the mouse is touching the progress bar
    initialborder = mp.get_property("border"),
    playingWhilstSeeking = false,
    playingWhilstSeekingWaitingForEnd = false,
    persistentprogresstoggle = user_opts.persistentprogress,
    downloadedOnce = false,
    downloading = false,
    fileSizeBytes = 0,
    fileSizeNormalised = "Approximating size...",
    isURL = false,
    web_video_path = "",                    -- used for yt-dlp downloading
    videoCantBeDownloaded = false,
}

local logo_lines = {
    -- White border
    "{\\c&HE5E5E5&\\p6}m 895 10 b 401 10 0 410 0 905 0 1399 401 1800 895 1800 1390 1800 1790 1399 1790 905 1790 410 1390 10 895 10 {\\p0}",
    -- Purple fill
    "{\\c&H682167&\\p6}m 925 42 b 463 42 87 418 87 880 87 1343 463 1718 925 1718 1388 1718 1763 1343 1763 880 1763 418 1388 42 925 42{\\p0}",
    -- Darker fill
    "{\\c&H430142&\\p6}m 1605 828 b 1605 1175 1324 1456 977 1456 631 1456 349 1175 349 828 349 482 631 200 977 200 1324 200 1605 482 1605 828{\\p0}",
    -- White fill
    "{\\c&HDDDBDD&\\p6}m 1296 910 b 1296 1131 1117 1310 897 1310 676 1310 497 1131 497 910 497 689 676 511 897 511 1117 511 1296 689 1296 910{\\p0}",
    -- Triangle
    "{\\c&H691F69&\\p6}m 762 1113 l 762 708 b 881 776 1000 843 1119 911 1000 978 881 1046 762 1113{\\p0}",
}

local santa_hat_lines = {
    -- Pompoms
    "{\\c&HC0C0C0&\\p6}m 500 -323 b 491 -322 481 -318 475 -311 465 -312 456 -319 446 -318 434 -314 427 -304 417 -297 410 -290 404 -282 395 -278 390 -274 387 -267 381 -265 377 -261 379 -254 384 -253 397 -244 409 -232 425 -228 437 -228 446 -218 457 -217 462 -216 466 -213 468 -209 471 -205 477 -203 482 -206 491 -211 499 -217 508 -222 532 -235 556 -249 576 -267 584 -272 584 -284 578 -290 569 -305 550 -312 533 -309 523 -310 515 -316 507 -321 505 -323 503 -323 500 -323{\\p0}",
    "{\\c&HE0E0E0&\\p6}m 315 -260 b 286 -258 259 -240 246 -215 235 -210 222 -215 211 -211 204 -188 177 -176 172 -151 170 -139 163 -128 154 -121 143 -103 141 -81 143 -60 139 -46 125 -34 129 -17 132 -1 134 16 142 30 145 56 161 80 181 96 196 114 210 133 231 144 266 153 303 138 328 115 373 79 401 28 423 -24 446 -73 465 -123 483 -174 487 -199 467 -225 442 -227 421 -232 402 -242 384 -254 364 -259 342 -250 322 -260 320 -260 317 -261 315 -260{\\p0}",
    -- Main cap
    "{\\c&H0000F0&\\p6}m 1151 -523 b 1016 -516 891 -458 769 -406 693 -369 624 -319 561 -262 526 -252 465 -235 479 -187 502 -147 551 -135 588 -111 1115 165 1379 232 1909 761 1926 800 1952 834 1987 858 2020 883 2053 912 2065 952 2088 1000 2146 962 2139 919 2162 836 2156 747 2143 662 2131 615 2116 567 2122 517 2120 410 2090 306 2089 199 2092 147 2071 99 2034 64 1987 5 1928 -41 1869 -86 1777 -157 1712 -256 1629 -337 1578 -389 1521 -436 1461 -476 1407 -509 1343 -507 1284 -515 1240 -519 1195 -521 1151 -523{\\p0}",
    -- Cap shadow
    "{\\c&H0000AA&\\p6}m 1657 248 b 1658 254 1659 261 1660 267 1669 276 1680 284 1689 293 1695 302 1700 311 1707 320 1716 325 1726 330 1735 335 1744 347 1752 360 1761 371 1753 352 1754 331 1753 311 1751 237 1751 163 1751 90 1752 64 1752 37 1767 14 1778 -3 1785 -24 1786 -45 1786 -60 1786 -77 1774 -87 1760 -96 1750 -78 1751 -65 1748 -37 1750 -8 1750 20 1734 78 1715 134 1699 192 1694 211 1689 231 1676 246 1671 251 1661 255 1657 248 m 1909 541 b 1914 542 1922 549 1917 539 1919 520 1921 502 1919 483 1918 458 1917 433 1915 407 1930 373 1942 338 1947 301 1952 270 1954 238 1951 207 1946 214 1947 229 1945 239 1939 278 1936 318 1924 356 1923 362 1913 382 1912 364 1906 301 1904 237 1891 175 1887 150 1892 126 1892 101 1892 68 1893 35 1888 2 1884 -9 1871 -20 1859 -14 1851 -6 1854 9 1854 20 1855 58 1864 95 1873 132 1883 179 1894 225 1899 273 1908 362 1910 451 1909 541{\\p0}",
    -- Brim and tip pompom
    "{\\c&HF8F8F8&\\p6}m 626 -191 b 565 -155 486 -196 428 -151 387 -115 327 -101 304 -47 273 2 267 59 249 113 219 157 217 213 215 265 217 309 260 302 285 283 373 264 465 264 555 257 608 252 655 292 709 287 759 294 816 276 863 298 903 340 972 324 1012 367 1061 394 1125 382 1167 424 1213 462 1268 482 1322 506 1385 546 1427 610 1479 662 1510 690 1534 725 1566 752 1611 796 1664 830 1703 880 1740 918 1747 986 1805 1005 1863 991 1897 932 1916 880 1914 823 1945 777 1961 725 1979 673 1957 622 1938 575 1912 534 1862 515 1836 473 1790 417 1755 351 1697 305 1658 266 1633 216 1593 176 1574 138 1539 116 1497 110 1448 101 1402 77 1371 37 1346 -16 1295 15 1254 6 1211 -27 1170 -62 1121 -86 1072 -104 1027 -128 976 -133 914 -130 851 -137 794 -162 740 -181 679 -168 626 -191 m 2051 917 b 1971 932 1929 1017 1919 1091 1912 1149 1923 1214 1970 1254 2000 1279 2027 1314 2066 1325 2139 1338 2212 1295 2254 1238 2281 1203 2287 1158 2282 1116 2292 1061 2273 1006 2229 970 2206 941 2167 938 2138 918{\\p0}",
}

--
-- Helper functions
--

local function kill_animation()
    state.anistart = nil
    state.animation = nil
    state.anitype =  nil
end

local function set_osd(res_x, res_y, text, z)
    if state.osd.res_x == res_x and
       state.osd.res_y == res_y and
       state.osd.data == text then
        return
    end
    state.osd.res_x = res_x
    state.osd.res_y = res_y
    state.osd.data = text
    state.osd.z = z
    state.osd:update()
end

local function set_time_styles(timetotal_changed, timems_changed)
    if timetotal_changed then
        state.tc_right_rem = not user_opts.timetotal
    end
    if timems_changed then
        state.tc_ms = user_opts.timems
    end
end

-- scale factor for translating between real and virtual ASS coordinates
local function get_virt_scale_factor()
    local w, h = mp.get_osd_size()
    if w <= 0 or h <= 0 then
        return 0, 0
    end
    return osc_param.playresx / w, osc_param.playresy / h
end

-- return mouse position in virtual ASS coordinates (playresx/y)
local function get_virt_mouse_pos()
    if state.mouse_in_window then
        local sx, sy = get_virt_scale_factor()
        local x, y = mp.get_mouse_pos()
        return x * sx, y * sy
    else
        return -1, -1
    end
end

local function set_virt_mouse_area(x0, y0, x1, y1, name)
    local sx, sy = get_virt_scale_factor()
    mp.set_mouse_area(x0 / sx, y0 / sy, x1 / sx, y1 / sy, name)
end

local function scale_value(x0, x1, y0, y1, val)
    local m = (y1 - y0) / (x1 - x0)
    local b = y0 - (m * x0)
    return (m * val) + b
end

-- returns hitbox spanning coordinates (top left, bottom right corner)
-- according to alignment
local function get_hitbox_coords(x, y, an, w, h)
    local alignments = {
      [1] = function () return x, y-h, x+w, y end,
      [2] = function () return x-(w/2), y-h, x+(w/2), y end,
      [3] = function () return x-w, y-h, x, y end,

      [4] = function () return x, y-(h/2), x+w, y+(h/2) end,
      [5] = function () return x-(w/2), y-(h/2), x+(w/2), y+(h/2) end,
      [6] = function () return x-w, y-(h/2), x, y+(h/2) end,

      [7] = function () return x, y, x+w, y+h end,
      [8] = function () return x-(w/2), y, x+(w/2), y+h end,
      [9] = function () return x-w, y, x, y+h end,
    }

    return alignments[an]()
end

local function get_hitbox_coords_geo(geometry)
    return get_hitbox_coords(geometry.x, geometry.y, geometry.an,
        geometry.w, geometry.h)
end

local function get_element_hitbox(element)
    return element.hitbox.x1, element.hitbox.y1,
        element.hitbox.x2, element.hitbox.y2
end

local function mouse_hit_coords(bX1, bY1, bX2, bY2)
    local mX, mY = get_virt_mouse_pos()
    return (mX >= bX1 and mX <= bX2 and mY >= bY1 and mY <= bY2)
end

local function mouse_hit(element)
    return mouse_hit_coords(get_element_hitbox(element))
end

local function limit_range(min, max, val)
    if val > max then
        val = max
    elseif val < min then
        val = min
    end
    return val
end

-- translate value into element coordinates
local function get_slider_ele_pos_for(element, val)
    local ele_pos = scale_value(
        element.slider.min.value, element.slider.max.value,
        element.slider.min.ele_pos, element.slider.max.ele_pos,
        val)

    return limit_range(
        element.slider.min.ele_pos, element.slider.max.ele_pos,
        ele_pos)
end

-- translates global (mouse) coordinates to value
local function get_slider_value_at(element, glob_pos)
    if element then
        local val = scale_value(
            element.slider.min.glob_pos, element.slider.max.glob_pos,
            element.slider.min.value, element.slider.max.value,
            glob_pos)

        return limit_range(
            element.slider.min.value, element.slider.max.value,
            val)
    end
    -- fall back incase of loading errors
    return 0
end

-- get value at current mouse position
local function get_slider_value(element)
    return get_slider_value_at(element, get_virt_mouse_pos())
end

-- multiplies two alpha values, formular can probably be improved
local function mult_alpha(alphaA, alphaB)
    return 255 - (((1-(alphaA/255)) * (1-(alphaB/255))) * 255)
end

local function add_area(name, x1, y1, x2, y2)
    -- create area if needed
    if osc_param.areas[name] == nil then
        osc_param.areas[name] = {}
    end
    table.insert(osc_param.areas[name], {x1=x1, y1=y1, x2=x2, y2=y2})
end

local function ass_append_alpha(ass, alpha, modifier, inverse)
    local ar = {}

    for ai, av in pairs(alpha) do
        av = mult_alpha(av, modifier)
        if state.animation then
            local animpos = state.animation
            if inverse then
                animpos = 255 - animpos
            end
            av = mult_alpha(av, animpos)
        end
        ar[ai] = av
    end

    ass:append(string.format("{\\1a&H%X&\\2a&H%X&\\3a&H%X&\\4a&H%X&}",
               ar[1], ar[2], ar[3], ar[4]))
end

local function ass_draw_cir_cw(ass, x, y, r)
    ass:round_rect_cw(x-r, y-r, x+r, y+r, r)
end

local function ass_draw_rr_h_cw(ass, x0, y0, x1, y1, r1, hexagon, r2)
    if hexagon then
        ass:hexagon_cw(x0, y0, x1, y1, r1, r2)
    else
        ass:round_rect_cw(x0, y0, x1, y1, r1, r2)
    end
end

local function get_hidetimeout()
    if user_opts.visibility == "always" then
        return -1 -- disable autohide
    end
    return user_opts.hidetimeout
end

local function get_touchtimeout()
    if state.touchtime == nil then
        return 0
    end
    return state.touchtime + (get_hidetimeout() / 1000) - mp.get_time()
end

local tick
-- Request that tick() is called (which typically re-renders the OSC).
-- The tick is then either executed immediately, or rate-limited if it was
-- called a small time ago.
local function request_tick()
    if state.tick_timer == nil then
        state.tick_timer = mp.add_timeout(0, tick)
    end

    if not state.tick_timer:is_enabled() then
        local now = mp.get_time()
        local timeout = tick_delay - (now - state.tick_last_time)
        if timeout < 0 then
            timeout = 0
        end
        state.tick_timer.timeout = timeout
        state.tick_timer:resume()
    end
end

local function request_init()
    state.initREQ = true
    request_tick()
end

-- Like request_init(), but also request an immediate update
local function request_init_resize()
    request_init()
    -- ensure immediate update
    state.tick_timer:kill()
    state.tick_timer.timeout = 0
    state.tick_timer:resume()
end

local function render_wipe()
    msg.trace("render_wipe()")
    state.osd.data = "" -- allows set_osd to immediately update on enable
    state.osd:remove()
end

--
-- Tracklist Management
--

-- updates the OSC internal playlists, should be run each time the track-layout changes
local function update_tracklist()
    audio_track_count, sub_track_count = 0, 0

    for _, track in pairs(mp.get_property_native("track-list")) do
        if track.type == "audio" then
            audio_track_count = audio_track_count + 1
        elseif track.type == "sub" then
            sub_track_count = sub_track_count + 1
        end
    end
end

-- convert slider_pos to logarithmic depending on volumecontrol user_opts
local function set_volume(slider_pos)
    local volume = slider_pos
    if user_opts.volumecontroltype == "logarithmic" then
        volume = slider_pos^2 / 100
    end
    return math.floor(volume)
end

-- WindowControl helpers
local function window_controls_enabled()
    local val = user_opts.windowcontrols
    if val == "auto" then
        return not (state.border and state.title_bar) or state.fullscreen
    else
        return val ~= "no"
    end
end

--
-- Element Management
--
local elements = {}

local function prepare_elements()
    -- remove elements without layout or invisible
    local elements2 = {}
    for _, element in pairs(elements) do
        if element.layout ~= nil and element.visible then
            table.insert(elements2, element)
        end
    end
    elements = elements2

    local function elem_compare (a, b)
        return a.layout.layer < b.layout.layer
    end

    table.sort(elements, elem_compare)

    for _,element in pairs(elements) do

        local elem_geo = element.layout.geometry

        -- Calculate the hitbox
        local bX1, bY1, bX2, bY2 = get_hitbox_coords_geo(elem_geo)
        element.hitbox = {x1 = bX1, y1 = bY1, x2 = bX2, y2 = bY2}

        local style_ass = assdraw.ass_new()

        -- prepare static elements
        style_ass:append("{}") -- hack to troll new_event into inserting a \n
        style_ass:new_event()
        style_ass:pos(elem_geo.x, elem_geo.y)
        style_ass:an(elem_geo.an)
        style_ass:append(element.layout.style)

        element.style_ass = style_ass

        local static_ass = assdraw.ass_new()

        if element.type == "box" then
            --draw box
            static_ass:draw_start()
            ass_draw_rr_h_cw(static_ass, 0, 0, elem_geo.w, elem_geo.h,
                             element.layout.box.radius, element.layout.box.hexagon)
            static_ass:draw_stop()

        elseif element.type == "slider" then
            --draw static slider parts
            local slider_lo = element.layout.slider
            -- calculate positions of min and max points
            element.slider.min.ele_pos = user_opts.seekbarhandlesize * elem_geo.h / 2
            element.slider.max.ele_pos = elem_geo.w - element.slider.min.ele_pos
            element.slider.min.glob_pos = element.hitbox.x1 + element.slider.min.ele_pos
            element.slider.max.glob_pos = element.hitbox.x1 + element.slider.max.ele_pos

            static_ass:draw_start()
            -- a hack which prepares the whole slider area to allow center placements such like an=5
            static_ass:rect_cw(0, 0, elem_geo.w, elem_geo.h)
            static_ass:rect_ccw(0, 0, elem_geo.w, elem_geo.h)
            -- marker nibbles
            if element.slider.markerF ~= nil and slider_lo.gap > 0 then
                local markers = element.slider.markerF()
                for _,marker in pairs(markers) do
                    if marker >= element.slider.min.value and 
                    marker <= element.slider.max.value then
                        local s = get_slider_ele_pos_for(element, marker)
                        if slider_lo.gap > 5 then -- draw triangles
                            --top
                            if slider_lo.nibbles_top then
                                static_ass:move_to(s - 3, slider_lo.gap - 5)
                                static_ass:line_to(s + 3, slider_lo.gap - 5)
                                static_ass:line_to(s, slider_lo.gap - 1)
                            end
                            --bottom
                            if slider_lo.nibbles_bottom then
                                static_ass:move_to(s - 3, elem_geo.h - slider_lo.gap + 5)
                                static_ass:line_to(s, elem_geo.h - slider_lo.gap + 1)
                                static_ass:line_to(s + 3, elem_geo.h - slider_lo.gap + 5)
                            end
                        else -- draw 2x1px nibbles
                            --top
                            if slider_lo.nibbles_top then
                                static_ass:rect_cw(s - 1, 0, s + 1, slider_lo.gap);
                            end
                            --bottom
                            if slider_lo.nibbles_bottom then
                                static_ass:rect_cw(s - 1, elem_geo.h - slider_lo.gap, s + 1, elem_geo.h);
                            end
                        end
                    end
                end
            end
        end

        element.static_ass = static_ass

        -- if the element is supposed to be disabled,
        -- style it accordingly and kill the eventresponders
        if not element.enabled then
            element.layout.alpha[1] = 215
            if not (element.name == "sub_track" or element.name == "audio_track" or element.name == "tog_playlist") then -- keep these to display tooltips
                element.eventresponder = nil
            end
        end

        -- gray out the element if it is toggled off
        if element.off then
            element.layout.alpha[1] = 100
        end
    end
end

--
-- Element Rendering
--

-- returns nil or a chapter element from the native property chapter-list
local function get_chapter(possec)
    local cl = state.chapter_list  -- sorted, get latest before possec, if any

    for n=#cl,1,-1 do
        if possec >= cl[n].time then
            return cl[n]
        end
    end
end

local function render_elements(master_ass)
    -- when the slider is dragged or hovered and we have a target chapter name
    -- then we use it instead of the normal title. we calculate it before the
    -- render iterations because the title may be rendered before the slider.
    state.forced_title = nil
    
    -- disable displaying chapter name in title when thumbfast is available
    -- because thumbfast will render it above the thumbnail instead
    if thumbfast.disabled then
        local se, ae = state.slider_element, elements[state.active_element]
        if user_opts.chapter_fmt ~= "no" and state.touchingprogressbar then
            local dur = mp.get_property_number("duration", 0)
            if dur > 0 then
                local ch = get_chapter(state.sliderpos * dur / 100)
                if ch and ch.title and ch.title ~= "" then
                    state.forced_title = string.format(user_opts.chapter_fmt, ch.title)
                end
            end
        end
    end

    state.touchingprogressbar = false

    for n=1, #elements do
        local element = elements[n]
        local style_ass = assdraw.ass_new()
        style_ass:merge(element.style_ass)
        ass_append_alpha(style_ass, element.layout.alpha, 0)

        if element.eventresponder and (state.active_element == n) then
            -- run render event functions
            if element.eventresponder.render ~= nil then
                element.eventresponder.render(element)
            end
            if mouse_hit(element) then
                -- mouse down styling
                if element.styledown then
                    style_ass:append(osc_styles.element_down)
                end
                if element.softrepeat and state.mouse_down_counter >= 15
                    and state.mouse_down_counter % 5 == 0 then

                    element.eventresponder[state.active_event_source.."_down"](element)
                end
                state.mouse_down_counter = state.mouse_down_counter + 1
            end
        end
        
        local elem_ass = assdraw.ass_new()
        elem_ass:merge(style_ass)
        
        if element.type ~= "button" then
            elem_ass:merge(element.static_ass)
        end

        if element.type == "slider" then
            if element.name ~= "persistentseekbar" then
                local slider_lo = element.layout.slider
                local elem_geo = element.layout.geometry
                local s_min = element.slider.min.value
                local s_max = element.slider.max.value
                -- draw pos marker
                local pos = element.slider.posF()
                local seekRanges = element.slider.seekRangesF()
                local rh = user_opts.seekbarhandlesize * elem_geo.h / 2 -- Handle radius
                local xp
                
                if pos then
                    xp = get_slider_ele_pos_for(element, pos)
                    local handle_hovered = mouse_hit_coords(element.hitbox.x1+xp-rh, element.hitbox.y1+elem_geo.h/2-rh, element.hitbox.x1+xp+rh, element.hitbox.y1+elem_geo.h/2+rh) and element.enabled
                    if handle_hovered and user_opts.hovereffect_for_sliders then
                        -- apply size & color hovereffects (glow is not supported)
                        if contains(user_opts.hovereffect, "size") then
                            rh = rh*(user_opts.hover_button_size/100)
                        end
                        if contains(user_opts.hovereffect, "color") then
                            elem_ass.text = elem_ass.text:gsub(element.layout.style, element.layout.slider.hoverstyle)
                        end
                    end
                    ass_draw_cir_cw(elem_ass, xp, elem_geo.h/2, rh)
                    if handle_hovered and user_opts.hovereffect_for_sliders then
                        elem_ass:draw_stop()
                        elem_ass:merge(element.style_ass)
                        ass_append_alpha(elem_ass, element.layout.alpha, 0)
                        elem_ass:merge(element.static_ass)
                    end
                    elem_ass:rect_cw(0, slider_lo.gap, xp-rh, elem_geo.h - slider_lo.gap)
                end

                if seekRanges then
                    elem_ass:draw_stop()
                    elem_ass:merge(element.style_ass)
                    ass_append_alpha(elem_ass, element.layout.alpha, user_opts.seekrangealpha)
                    elem_ass:append("{\\1cH&" .. osc_color_convert(user_opts.seekbar_cache_color) .. "&}")
                    elem_ass:merge(element.static_ass)

                    for _,range in pairs(seekRanges) do
                        local pstart = get_slider_ele_pos_for(element, range["start"])
                        local pend = get_slider_ele_pos_for(element, range["end"])

                        local cache_starts_in_handle = pstart >= xp-rh and pstart <= xp + rh
                        local cache_ends_in_handle = pend >= xp-rh and pend <= xp
                        local cache_passes_handle = pstart < xp-rh and pend > xp
                        if cache_starts_in_handle or cache_ends_in_handle then
                            if cache_starts_in_handle and cache_ends_in_handle then
                                pstart = 0
                                pend = 0
                            elseif cache_starts_in_handle then
                                pstart = xp+rh
                            elseif cache_ends_in_handle then
                                pend = xp-rh
                            end
                        elseif cache_passes_handle then
                            -- split range rendering to avoid rendering above handle
                            elem_ass:rect_cw(pstart - rh, slider_lo.gap, xp - rh, elem_geo.h - slider_lo.gap)
                            pstart = xp + rh
                        else
                            pstart = pstart - rh
                        end

                        elem_ass:rect_cw(pstart, slider_lo.gap, pend + (cache_ends_in_handle and 0 or rh), elem_geo.h - slider_lo.gap)
                    end
                end

                elem_ass:draw_stop()
                
                -- add tooltip
                if element.slider.tooltipF ~= nil and element.enabled then
                    if mouse_hit(element) then
                        local sliderpos = get_slider_value(element)
                        local tooltiplabel = element.slider.tooltipF(sliderpos)
                        local an = slider_lo.tooltip_an
                        local ty
                        if an == 2 then
                            ty = element.hitbox.y1
                        else
                            ty = element.hitbox.y1 + elem_geo.h/2
                        end

                        local tx = get_virt_mouse_pos()
                        if slider_lo.adjust_tooltip then
                            if an == 2 then
                                if sliderpos < (s_min + 3) then
                                    an = an - 1
                                elseif sliderpos > (s_max - 3) then
                                    an = an + 1
                                end
                            elseif (sliderpos > (s_max+s_min)/2) then
                                an = an + 1
                                tx = tx - 5
                            else
                                an = an - 1
                                tx = tx + 10
                            end
                        end

                        if element.name == "seekbar" then
                            state.sliderpos = sliderpos
                        end    
                        
                        -- thumbfast
                        if element.thumbnailable and not thumbfast.disabled then
                            local osd_w = mp.get_property_number("osd-width")
                            local r_w, r_h = get_virt_scale_factor()

                            if osd_w then
                                local hover_sec = 0
                                if mp.get_property_number("duration") then hover_sec = mp.get_property_number("duration") * sliderpos / 100 end
                                local thumbPad = user_opts.thumbnailborder
                                local thumbMarginX = 18 / r_w
                                local thumbMarginY = user_opts.timefontsize + thumbPad + 2 / r_h
                                local thumbX = math.min(osd_w - thumbfast.width - thumbMarginX, math.max(thumbMarginX, tx / r_w - thumbfast.width / 2))
                                local thumbY = (ty - thumbMarginY) / r_h - thumbfast.height

                                thumbX = math.floor(thumbX + 0.5)
                                thumbY = math.floor(thumbY + 0.5)

                                if state.anitype == nil then
                                    elem_ass:new_event()
                                    elem_ass:pos(thumbX * r_w, ty - thumbMarginY - thumbfast.height * r_h)
                                    elem_ass:an(7)
                                    elem_ass:append(osc_styles.thumbnail)
                                    elem_ass:draw_start()
                                    elem_ass:rect_cw(-thumbPad * r_w, -thumbPad * r_h, (thumbfast.width + thumbPad) * r_w, (thumbfast.height + thumbPad) * r_h)
                                    elem_ass:draw_stop()

                                    -- force tooltip to be centered on the thumb, even at far left/right of screen
                                    tx = (thumbX + thumbfast.width / 2) * r_w
                                    an = 2

                                    mp.commandv("script-message-to", "thumbfast", "thumb", hover_sec, thumbX, thumbY)
                                end

                                -- chapter title tooltip
                                local se, ae = state.slider_element, elements[state.active_element]
                                if user_opts.chapter_fmt ~= "no" and state.touchingprogressbar then
                                    local dur = mp.get_property_number("duration", 0)
                                    if dur > 0 then
                                        local ch = get_chapter(state.sliderpos * dur / 100)
                                        if ch and ch.title and ch.title ~= "" then
                                            elem_ass:new_event()
                                            elem_ass:pos((thumbX + thumbfast.width / 2) * r_w, thumbY * r_h - user_opts.timefontsize / 2)
                                            elem_ass:an(an)
                                            elem_ass:append(slider_lo.tooltip_style)
                                            ass_append_alpha(elem_ass, slider_lo.alpha, 0)
                                            elem_ass:append(string.format(user_opts.chapter_fmt, ch.title))
                                        end
                                    end
                                end
                            end
                        end

                        -- chapter title tooltip on showtitle=false and no thumbfast
                        local tooltip_content = tooltiplabel
                        if thumbfast.disabled and not user_opts.showtitle then
                            if user_opts.chapter_fmt ~= "no" and state.touchingprogressbar then
                                local dur = mp.get_property_number("duration", 0)
                                if dur > 0 then
                                    local ch = get_chapter(state.sliderpos * dur / 100)
                                    if ch and ch.title and ch.title ~= "" then
                                        tooltip_content = tooltip_content .. " • " .. string.format(user_opts.chapter_fmt, ch.title)
                                    end
                                end
                            end
                        end

                        -- tooltip label
                        elem_ass:new_event()
                        elem_ass:pos(tx, ty)
                        elem_ass:an(an)
                        elem_ass:append(slider_lo.tooltip_style)
                        ass_append_alpha(elem_ass, slider_lo.alpha, 0)
                        elem_ass:append(tooltip_content)
                    elseif element.thumbnailable and thumbfast.available then
                        mp.commandv("script-message-to", "thumbfast", "clear")
                    end
                end
            end

        elseif element.type == "button" then
            local buttontext
            if type(element.content) == "function" then
                buttontext = element.content() -- function objects
            elseif element.content ~= nil then
                buttontext = element.content -- text objects
            end
            buttontext = buttontext:gsub(":%((.?.?.?)%) unknown ", ":%(%1%)")  --gsub('%) unknown %(\'', '')

            local maxchars = element.layout.button.maxchars
            if maxchars ~= nil and #buttontext > maxchars then
                local max_ratio = 1.25  -- up to 25% more chars while shrinking
                local limit = math.max(0, math.floor(maxchars * max_ratio) - 3)
                if #buttontext > limit then
                    while (#buttontext > limit) do
                        buttontext = buttontext:gsub(".[\128-\191]*$", "")
                    end
                    buttontext = buttontext .. "..."
                end
                local _, nchars2 = buttontext:gsub(".[\128-\191]*", "")
                local stretch = (maxchars/#buttontext) * 100
                buttontext = string.format("{\\fscx%f}%s{\\r}", stretch, buttontext)
            end

            -- add hover effects
            local button_lo = element.layout.button
            local is_clickable = element.eventresponder and (
                element.eventresponder["mbtn_left_down"] ~= nil or
                element.eventresponder["mbtn_left_up"] ~= nil
            )
            local hovered = mouse_hit(element) and is_clickable and element.enabled and state.mouse_down_counter == 0
            local hoverstyle = button_lo.hoverstyle
            if hovered and (contains(user_opts.hovereffect, "size") or contains(user_opts.hovereffect, "color")) then
                -- remove font scale tags for these elements, it looks out of place
                if element.name == "title" or element.name == "tc_left" or element.name == "tc_right" or element.name == "chapter_title" then
                    hoverstyle = hoverstyle:gsub("\\fscx%d+\\fscy%d+", "")
                end
                elem_ass:append(hoverstyle .. buttontext)
            else
                elem_ass:append(buttontext)
            end

            -- apply blur effect if "glow" is in hover effects
            if hovered and contains(user_opts.hovereffect, "glow") then
                local shadow_ass = assdraw.ass_new()
                shadow_ass:merge(style_ass)
                shadow_ass:append("{\\blur" .. user_opts.button_glow_amount .. "}" .. hoverstyle .. buttontext)
                elem_ass:merge(shadow_ass)
            end

            -- add tooltip for audio and subtitle tracks
            if element.tooltipF ~= nil and (user_opts.tooltips_for_disabled_elements or element.enabled) then
                if mouse_hit(element) then
                    local tooltiplabel = element.tooltipF
                    local an = 1
                    local ty = element.hitbox.y1
                    local tx = get_virt_mouse_pos()

                    if ty < osc_param.playresy / 2 then
                        ty = element.hitbox.y2
                        an = 7
                    end

                    -- tooltip label
                    if element.enabled then
                        if type(element.tooltipF) == "function" then
                            tooltiplabel = element.tooltipF()
                        else
                            tooltiplabel = element.tooltipF
                        end
                    else
                        tooltiplabel = element.nothingavailable
                    end

                    if tx > osc_param.playresx / 2 then --move tooltip to left side of mouse cursor
                        tx = tx - string.len(tooltiplabel) * 8
                    end

                    elem_ass:new_event()
                    elem_ass:pos(tx, ty)
                    elem_ass:an(an)
                    elem_ass:append(element.tooltip_style)
                    elem_ass:append(tooltiplabel)
                end
            end
        end

        master_ass:merge(elem_ass)
    end
end

local function render_persistentprogressbar(master_ass)
    for n=1, #elements do
        local element = elements[n]
        if element.name == "persistentseekbar" then
            local style_ass = assdraw.ass_new()
            style_ass:merge(element.style_ass)
            ass_append_alpha(style_ass, element.layout.alpha, 0, true)
            
            if not state.animation and state.osc_visible then
                ass_append_alpha(style_ass, element.layout.alpha, 255)
            end
            
            local elem_ass = assdraw.ass_new()
            elem_ass:merge(style_ass)
            if element.type ~= "button" then
                elem_ass:merge(element.static_ass)
            end

            local slider_lo = element.layout.slider
            local elem_geo = element.layout.geometry
            local s_min = element.slider.min.value
            local s_max = element.slider.max.value
            -- draw pos marker
            local pos = element.slider.posF()
            local seekRanges = element.slider.seekRangesF()
            local rh = 0 -- Handle radius
            local xp
                
            if pos then
                xp = get_slider_ele_pos_for(element, pos)
                ass_draw_cir_cw(elem_ass, xp, elem_geo.h/2, rh)
                elem_ass:rect_cw(0, slider_lo.gap, xp, elem_geo.h - slider_lo.gap)
            end

            if user_opts.persistentbuffer and seekRanges then
                elem_ass:draw_stop()
                elem_ass:merge(element.style_ass)
                ass_append_alpha(elem_ass, element.layout.alpha, user_opts.seekrangealpha, true)
                elem_ass:merge(element.static_ass)
                for _,range in pairs(seekRanges) do
                    local pstart = get_slider_ele_pos_for(element, range["start"])
                    local pend = get_slider_ele_pos_for(element, range["end"])
                    elem_ass:rect_cw(pstart - rh, slider_lo.gap, pend + rh, elem_geo.h - slider_lo.gap)
                end
            end

            elem_ass:draw_stop()
            master_ass:merge(elem_ass)
        end
    end
end

--
-- Initialisation and Layout
--
local function is_url(s)
    if not s then
        user_opts.downloadbutton = false
        return false
    end

    local url_pattern = "^[%w]+://[%w%.%-_]+%.[%a]+[-%w%.%-%_/?&=]*"
    return string.match(s, url_pattern) ~= nil
end

local function format_file_size(file_size)
    local units = {"bytes", "KB", "MB", "GB", "TB"}
    local unit_index = 1

    while file_size >= 1024 and unit_index < #units do
        file_size = file_size / 1024
        unit_index = unit_index + 1
    end

    return string.format("%.1f %s", file_size, units[unit_index])
end

local function exec_filesize(args)
    for i = #args, 1, -1 do
        if args[i] == nil or args[i] == "" then
            table.remove(args, i)
        end
    end

    mp.command_native_async({
        name = "subprocess",
        args = args,
        capture_stdout = true,
        capture_stderr = true
    }, function(res, val)
        local fileSizeString = val.stdout
        state.fileSizeBytes = tonumber(fileSizeString)

        if state.fileSizeBytes then
            state.fileSizeNormalised = "Download size: " .. format_file_size(state.fileSizeBytes)
            msg.info("File size: " .. state.fileSizeBytes .. " B (" .. state.fileSizeNormalised .. ")")
        else
            state.fileSizeNormalised = "Unknown"
            msg.info("Unable to retrieve file size.")
        end

        request_tick()
    end)
end

local function download_done(success, result, error)
    if success then
        local download_path = mp.command_native({"expand-path", user_opts.download_path})
        mp.command("show-text 'Download saved to " .. download_path .. "'")
        state.downloadedOnce = true
        msg.info("Download completed")
    else
        mp.command("show-text 'Download failed - " .. (error or "Unknown error") .. "'")
        msg.info("Download failed")
    end
    state.downloading = false
end

local function exec(args, callback)
    for i = #args, 1, -1 do
        if args[i] == nil or args[i] == "" then
            table.remove(args, i)
        end
    end

    msg.info("Executing command: " .. table.concat(args, " "))

    local ret = mp.command_native_async({
        name = "subprocess",
        args = args,
        capture_stdout = true,
        capture_stderr = true
    }, callback)

    return ret and ret.status or nil
end

local function check_path_url()
    state.isURL = false
    state.downloading = false

    local path = mp.get_property("path")
    if not path then return nil end

    if string.find(path, "https://") then
        path = string.gsub(path, "ytdl://", "") -- Remove "ytdl://" prefix
    else
        path = string.gsub(path, "ytdl://", "https://") -- Replace "ytdl://" with "https://"
    end

    -- use current or default ytdl-format
    local mpv_ytdl = mp.get_property("file-local-options/ytdl-format") or mp.get_property("ytdl-format") or ""
    local ytdl_format = (mpv_ytdl and mpv_ytdl ~= "") and "-f " .. mpv_ytdl or "-f " .. "bestvideo+bestaudio/best"

    if is_url(path) then
        state.isURL = true
        state.web_video_path = path
        msg.info("URL detected.")

        if user_opts.downloadbutton then
            msg.info("Fetching file size...")
            local command = { 
                "yt-dlp",
                ytdl_format,
                "--no-download",
                "-O",
                "%(filesize,filesize_approx)s", -- Fetch file size or approximate size
                path
            }
            exec_filesize(command)
        end
    end
end

local function new_element(name, type)
    elements[name] = {}
    elements[name].type = type
    elements[name].name = name

    -- add default stuff
    elements[name].eventresponder = {}
    elements[name].visible = true
    elements[name].enabled = true
    elements[name].softrepeat = false
    elements[name].styledown = (type == "button")
    elements[name].state = {}

    if type == "slider" then
        elements[name].slider = {min = {value = 0}, max = {value = 100}}
        elements[name].thumbnailable = false
    end

    return elements[name]
end

local function add_layout(name)
    if elements[name] ~= nil then
        -- new layout
        elements[name].layout = {}

        -- set layout defaults
        elements[name].layout.layer = 50
        elements[name].layout.alpha = {[1] = 0, [2] = 255, [3] = 255, [4] = 255}

        if elements[name].type == "button" then
            elements[name].layout.button = {
                maxchars = nil,
                hoverstyle = osc_styles.element_hover,
            }
        elseif elements[name].type == "slider" then
            -- slider defaults
            elements[name].layout.slider = {
                border = 1,
                gap = 1,
                nibbles_top = true,
                nibbles_bottom = true,
                adjust_tooltip = true,
                tooltip_style = "",
                tooltip_an = 2,
                alpha = {[1] = 0, [2] = 255, [3] = 88, [4] = 255},
                hoverstyle = osc_styles.element_hover:gsub("\\fscx%d+\\fscy%d+", ""), -- font scales messes with handle positions in werid ways
            }
        elseif elements[name].type == "box" then
            elements[name].layout.box = {radius = 0, hexagon = false}
        end

        return elements[name].layout
    else
        msg.error("Can't add_layout to element '"..name.."', doesn't exist.")
    end
end

-- Window Controls
local function window_controls()
    local wc_geo = {
        x = 0,
        y = 50,
        an = 1,
        w = osc_param.playresx,
        h = 50,
    }

    local controlbox_w = window_control_box_width
    local titlebox_w = wc_geo.w - controlbox_w

    -- Default alignment is "right"
    local controlbox_left = wc_geo.w - controlbox_w
    local titlebox_left = wc_geo.x
    local titlebox_right = wc_geo.w - controlbox_w

    add_area("window-controls",
             get_hitbox_coords(controlbox_left, wc_geo.y, wc_geo.an,
                               controlbox_w, wc_geo.h))

    local lo

    -- Background Bar
    if user_opts.titleBarStrip then
        new_element("wcbar", "box")
        lo = add_layout("wcbar")
        lo.geometry = wc_geo
        lo.layer = 10
        lo.style = osc_styles.background_bar
        lo.alpha[1] = user_opts.boxalpha
    end

    local button_y = wc_geo.y - (wc_geo.h / 2)
    local first_geo = {x = controlbox_left + 25, y = button_y, an = 5, w = 40, h = wc_geo.h}
    local second_geo = {x = controlbox_left + 69, y = button_y, an = 5, w = 40, h = wc_geo.h}
    local third_geo = {x = controlbox_left + 113, y = button_y, an = 5, w = 40, h = wc_geo.h}

    -- Window control buttons use symbols in the custom mpv osd font
    -- because the official unicode codepoints are sufficiently
    -- exotic that a system might lack an installed font with them,
    -- and libass will complain that they are not present in the
    -- default font, even if another font with them is available.

    if user_opts.showwindowcontrols then
        -- Close: 🗙
        local ne = new_element("close", "button")
        ne.content = "\238\132\149"
        ne.eventresponder["mbtn_left_up"] = function () mp.commandv("quit") end
        lo = add_layout("close")
        lo.geometry = third_geo
        lo.style = osc_styles.window_control
        lo.button.hoverstyle = "{\\c&H2311E8&}"

        -- Minimize: 🗕
        ne = new_element("minimize", "button")
        ne.content = "\238\132\146"
        ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", "window-minimized") end
        lo = add_layout("minimize")
        lo.geometry = first_geo
        lo.style = osc_styles.window_control
        lo.button.hoverstyle = "{\\c&H00D7FF&}" -- gold
    
        -- Maximize: 🗖 /🗗
        ne = new_element("maximize", "button")
        ne.content = (state.maximized or state.fullscreen) and "\238\132\148" or "\238\132\147"
        ne.eventresponder["mbtn_left_up"] = function ()
            if state.fullscreen then
                mp.commandv("cycle", "fullscreen")
            else
                mp.commandv("cycle", "window-maximized")
            end
        end
        lo = add_layout("maximize")
        lo.geometry = second_geo
        lo.style = osc_styles.window_control
        lo.button.hoverstyle = "{\\c&H00D7FF&}" -- gold
    end

    -- Window Title
    if user_opts.showwindowtitle then
        ne = new_element("windowtitle", "button")
        ne.content = function ()
            local title = mp.command_native({"expand-text", user_opts.windowcontrols_title}) or ""
            title = title:gsub("\n", " ")
            return title ~= "" and mp.command_native({"escape-ass", title}) or "mpv"
        end
        local left_pad = 0
        local right_pad = 0
        lo = add_layout("windowtitle")
        local geo = {x = 20, y = button_y + 16, an = 1, w = osc_param.playresx - 50, h = wc_geo.h}
        lo.geometry = geo

        local clip_x1 = titlebox_left + left_pad 
        local clip_y1 = wc_geo.y - wc_geo.h 
        local clip_x2 = titlebox_right - right_pad
        local clip_y2 = wc_geo.y + wc_geo.h
        lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.window_title, clip_x1, clip_y1, clip_x2, clip_y2)
        lo.button.maxchars = geo.w / 10

        add_area("window-controls-title", titlebox_left, 0, titlebox_right, wc_geo.h)
    end
end

--
-- ModernZ Layout
--

local layouts = {}

-- Default layout
layouts = function ()
    local osc_geo = {
        w = osc_param.playresx,
        h = 180
    }

    local current_track = mp.get_property_native("current-tracks/video")
    local is_image = current_track and current_track.image and not current_track.albumart and mp.get_property_number("estimated-frame-count", 0) < 2 and audio_track_count == 0
    local should_show = not is_image or not user_opts.hide_elements_for_image

    -- origin of the controllers, left/bottom corner
    local posX = 0
    local posY = osc_param.playresy

    osc_param.areas = {} -- delete areas

    -- area for active mouse input
    add_area("input", get_hitbox_coords(posX, posY, 1, osc_geo.w, osc_geo.h))

    -- area for show/hide
    add_area("showhide", 0, 0, osc_param.playresx, osc_param.playresy)

    -- fetch values
    local osc_w, osc_h = osc_geo.w, osc_geo.h

    -- Controller Background
    local lo, geo
    
    new_element("box_bg", "box")
    lo = add_layout("box_bg")
    lo.geometry = {x = posX, y = posY, an = 7, w = osc_w, h = 1}
    lo.style = osc_styles.box_bg
    lo.layer = 10
    lo.alpha[3] = 0

    if not user_opts.titleBarStrip and (not (state.border and state.title_bar) or state.fullscreen) then
        new_element("title_alpha_bg", "box")
        lo = add_layout("title_alpha_bg")
        lo.geometry = {x = posX, y = -100, an = 7, w = osc_w, h = -1}
        lo.style = osc_styles.box_bg
        lo.layer = 10
        lo.alpha[3] = 0
    end
        
    -- Alignment
    local refX = osc_w / 2
    local refY = posY
        
    -- Seekbar
    if should_show then
        new_element("seekbarbg", "box")
        lo = add_layout("seekbarbg")
        lo.geometry = {x = refX , y = refY - 100, an = 5, w = osc_geo.w - 50, h = 2}
        lo.layer = 13
        lo.style = osc_styles.seekbar_bg
        lo.alpha[1] = 128
        lo.alpha[3] = 128

        lo = add_layout("seekbar")
        lo.geometry = {x = refX, y = refY - 100, an = 5, w = osc_geo.w - 50, h = 16}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = 7
        lo.slider.tooltip_style = osc_styles.tooltip
        lo.slider.tooltip_an = 2
        
        if user_opts.persistentprogress or state.persistentprogresstoggle then
            lo = add_layout("persistentseekbar")
            lo.geometry = {x = refX, y = refY, an = 5, w = osc_geo.w, h = user_opts.persistentprogressheight}
            lo.style = osc_styles.seekbar_fg
            lo.slider.gap = 7
            lo.slider.tooltip_an = 0   
        end
    end

    local showjump = user_opts.showjump and should_show
    local showskip = user_opts.showskip and should_show
    local shownextprev = user_opts.shownextprev
    local showfullscreen = user_opts.showfullscreen_button
    local showloop = user_opts.showloop and should_show
    local showinfo = user_opts.showinfo
    local showontop = user_opts.showontop
    local showscreenshot = user_opts.showscreenshot and should_show
    local showplaylist = user_opts.showplaylist and (not user_opts.hide_empty_playlist_button or mp.get_property_number("playlist-count", 0) > 1)

    local offset = showjump and 60 or 0
    local outeroffset = (showskip and 0 or 100) + (showjump and 20 or 100)

    -- Title
    geo = {
        x = should_show and 25 or (50 - (showplaylist and 0 or 25)), 
        y = refY - (should_show and 122 or 26), an = 1, 
        w = (should_show and osc_geo.w - 50 or osc_geo.w * 0.25), h = 35,
    }
    lo = add_layout("title")
    lo.geometry = geo
    lo.style = string.format("%s{\\clip(0,%f,%f,%f)}", osc_styles.title, geo.y - geo.h, geo.x + geo.w, geo.y + geo.h)
    lo.alpha[3] = 0
    lo.button.maxchars = geo.w / (should_show and 11 or 1)

    -- buttons
    if shownextprev then
        lo = add_layout("playlist_prev")
        lo.geometry = {x = refX - ((should_show and 60 or 20) + (showskip and 60 or 0)) - offset, y = refY - 40 , an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if showskip then 
        lo = add_layout("chapter_backward")
        lo.geometry = {x = refX - 60 - offset, y = refY - 40 , an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if showjump then
        lo = add_layout("jump_backward")
        lo.geometry = {x = refX - 60, y = refY - 40 , an = 5, w = 30, h = 24}
        lo.style = (user_opts.jumpiconnumber and icons.jumpicons[user_opts.jumpamount] ~= nil) and osc_styles.control_2 or osc_styles.control_2_flip
    end

    if should_show then
        lo = add_layout("play_pause")
        lo.geometry = {x = refX, y = refY - 40 , an = 5, w = 45, h = 45}
        lo.style = osc_styles.control_1
    end

    if showjump then
        lo = add_layout("jump_forward")
        lo.geometry = {x = refX + 60, y = refY - 40 , an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if showskip then
        lo = add_layout("chapter_forward")
        lo.geometry = {x = refX + 60 + offset, y = refY - 40 , an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if shownextprev then
        lo = add_layout("playlist_next")
        lo.geometry = {x = refX + ((should_show and 60 or 20) + (showskip and 60 or 0)) + offset, y = refY - 40 , an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    -- Time
    local remsec = mp.get_property_number("playtime-remaining", 0)
    local possec = mp.get_property_number("playback-time", 0)
    local dur = mp.get_property_number("duration", 0)

    local show_hours = possec >= 3600 or user_opts.time_format ~= "dynamic"
    if should_show then
        lo = add_layout("tc_left")
        lo.geometry = {x = 25, y = refY - 84, an = 7, w = 45 + (state.tc_ms and 30 or 0) + (show_hours and 20 or 0), h = 20}
        lo.style = osc_styles.time
    end

    local show_remhours = (state.tc_right_rem and remsec >= 3600) or (not state.tc_right_rem and dur >= 3600) or user_opts.time_format ~= "dynamic"
    lo = add_layout("tc_right")
    lo.geometry = {x = osc_geo.w - 25 , y = refY -84, an = 9, w = 50 + (state.tc_ms and 30 or 0) + (show_remhours and 25 or 0), h = 20}
    lo.style = osc_styles.time

    -- Chapter Title (next to timestamp)
    if user_opts.show_chapter_title then
        lo = add_layout("separator")
        lo.geometry = {x = 73 + (state.tc_ms and 32 or 0) + (show_hours and 20 or 0), y = refY - 84, an = 7, w = 30, h = 20}
        lo.style = osc_styles.time

        lo = add_layout("chapter_title")
        lo.geometry = {x = 86 + (state.tc_ms and 32 or 0) + (show_hours and 20 or 0), y = refY - 84, an = 7, w = 200, h = 20}
        lo.style = osc_styles.chapter_title
    end

    -- Audio
    if should_show then
        lo = add_layout("audio_track")
        lo.geometry = {x = 37, y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 500 - outeroffset)
    end

    -- Subtitle
    if should_show then
        lo = add_layout("sub_track")
        lo.geometry = {x = 82, y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 600 - outeroffset)
    end

    -- Playlist
    if showplaylist then
        lo = add_layout("tog_playlist")
        lo.geometry = {x = should_show and 127 or 25, y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 600 - outeroffset)
    end

    -- Volume
    if should_show then
        lo = add_layout("vol_ctrl")
        lo.geometry = {x = 172 - (showplaylist and 0 or 45), y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 600 - outeroffset)
    end

    -- Volumebar
    if should_show then
        lo = new_element("volumebarbg", "box")
        lo.visible = (osc_param.playresx >= 950 - outeroffset) and user_opts.volumecontrol
        lo = add_layout("volumebarbg")
        lo.geometry = {x = 200 - (showplaylist and 0 or 45), y = refY - 40, an = 4, w = 80, h = 2}
        lo.layer = 13
        lo.alpha[1] = 128
        lo.style = user_opts.vol_bar_match_seek and osc_styles.seekbar_bg or osc_styles.volumebar_bg
        
        lo = add_layout("volumebar")
        lo.geometry = {x = 200 - (showplaylist and 0 or 45), y = refY - 40, an = 4, w = 80, h = 8}
        lo.style = user_opts.vol_bar_match_seek and osc_styles.seekbar_fg or osc_styles.volumebar_fg
        lo.slider.gap = 3
        lo.slider.tooltip_style = osc_styles.tooltip
        lo.slider.tooltip_an = 2
    end

    -- Fullscreen/Info/Loop/Pin/Screenshot
    if showfullscreen then
        lo = add_layout("tog_fullscreen")
        lo.geometry = {x = osc_geo.w - 37, y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 250 - outeroffset)
    end

    if showinfo then
        lo = add_layout("tog_info")
        lo.geometry = {x = osc_geo.w - 82 + (showfullscreen and 0 or 45), y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 300 - outeroffset)
    end

    if showloop then
        lo = add_layout("tog_loop")
        lo.geometry = {x = osc_geo.w - 127 + (showinfo and 0 or 45) + (showfullscreen and 0 or 45), y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 400 - outeroffset)
    end

    if showontop then
        lo = add_layout("tog_ontop")
        lo.geometry = {x = osc_geo.w - 172 + (showloop and 0 or 45) + (showinfo and 0 or 45) + (showfullscreen and 0 or 45), y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 500 - outeroffset)
    end

    if showscreenshot then
        lo = add_layout("screenshot")
        lo.geometry = {x = osc_geo.w - 217 + (showontop and 0 or 45) + (showloop and 0 or 45) + (showinfo and 0 or 45) + (showfullscreen and 0 or 45), y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 600 - outeroffset)
    end
    
    if user_opts.downloadbutton then
        lo = add_layout("download")
        lo.geometry = {x = osc_geo.w - 262 + (showscreenshot and 0 or 45) + (showontop and 0 or 45) + (showloop and 0 or 45) + (showinfo and 0 or 45) + (showfullscreen and 0 or 45), y = refY - 40, an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        lo.visible = (osc_param.playresx >= 400 - outeroffset)
    end
end

local function adjust_subtitles(visible)
    local scale
    if state.fullscreen then
        scale = user_opts.scalefullscreen
    else
        scale = user_opts.scalewindowed
    end

    if visible and user_opts.raisesubs and state.osc_visible == true then
        local w, h = mp.get_osd_size()
        if h > 0 then
            local raise_factor = user_opts.raisesubamount

            -- adjust for extreme scales
            if scale > 1 then
                raise_factor = raise_factor * (1 + (scale - 1) * 0.2)  -- slight increase when scale > 1
            elseif scale < 1 then
                raise_factor = raise_factor * (0.8 + (scale - 0.5) * 0.5)  -- slight decrease when scale < 1
            end

            local subpos = math.floor((osc_param.playresy - raise_factor) / osc_param.playresy * 100)
            if subpos < 0 then
                subpos = 100 -- original position if out of bounds
            end
            mp.commandv("set", "sub-pos", subpos)
        end
    elseif user_opts.raisesubs then
        mp.commandv("set", "sub-pos", 100)
    end
end

local function osc_visible(visible)
    if state.osc_visible ~= visible then
        state.osc_visible = visible
        adjust_subtitles(true)
    end
    request_tick()
end

local function command_callback(command)
    if command ~= "" then
        return function ()
            mp.command(command)
        end
    end
end

local function osc_init()
    msg.debug("osc_init")

    -- set canvas resolution according to display aspect and scaling setting
    local baseResY = 720
    local _, display_h, display_aspect = mp.get_osd_size()
    local scale

    if state.fullscreen then
        scale = user_opts.scalefullscreen
    else
        scale = user_opts.scalewindowed
    end

    local scale_with_video
    if user_opts.vidscale == "auto" then
        scale_with_video = mp.get_property_native("osd-scale-by-window")
    else
        scale_with_video = user_opts.vidscale == "yes"
    end

    if scale_with_video then
        osc_param.unscaled_y = baseResY
    else
        osc_param.unscaled_y = display_h
    end
    osc_param.playresy = osc_param.unscaled_y / scale
    if display_aspect > 0 then
        osc_param.display_aspect = display_aspect
    end
    osc_param.playresx = osc_param.playresy * osc_param.display_aspect

    -- stop seeking with the slider to prevent skipping files
    state.active_element = nil

    elements = {}

    -- some often needed stuff
    local pl_count = mp.get_property_number("playlist-count", 0)
    local have_pl = pl_count > 1
    local pl_pos = mp.get_property_number("playlist-pos", 0) + 1
    local have_ch = mp.get_property_number("chapters", 0) > 0
    local loop = mp.get_property("loop-playlist", "no")
    local current_track = mp.get_property_native("current-tracks/video")
    local is_image = current_track and current_track.image and not current_track.albumart and mp.get_property_number("estimated-frame-count", 0) < 2 and audio_track_count == 0

    local nojumpoffset = user_opts.showjump and 0 or 100
    local noskipoffset = user_opts.showskip and 0 or 100
    local outeroffset = (user_opts.showskip and 0 or 140) + (user_opts.showjump and 0 or 140)

    local ne

    -- title
    ne = new_element("title", "button")
    ne.visible = user_opts.showtitle
    ne.content = function ()
        local title = state.forced_title or mp.command_native({"expand-text", user_opts.title})
        title = title:gsub("\n", " ")
        return title ~= "" and mp.command_native({"escape-ass", title}) or "mpv"
    end
    ne.eventresponder["mbtn_left_up"] = command_callback(user_opts.title_mbtn_left_command)
    ne.eventresponder["mbtn_right_up"] = command_callback(user_opts.title_mbtn_right_command)

    -- playlist buttons
    -- prev
    ne = new_element("playlist_prev", "button")
    ne.visible = (osc_param.playresx >= 500 - nojumpoffset - noskipoffset*(nojumpoffset == 0 and 1 or 10))
    ne.content = icons.previous
    ne.enabled = (pl_pos > 1) or (loop ~= "no")
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("playlist-prev", "weak") end
    ne.eventresponder["mbtn_right_up"] = function () mp.command("show-text ${playlist} 3000") end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.command("show-text ${playlist} 3000") end

    --next
    ne = new_element("playlist_next", "button")
    ne.visible = (osc_param.playresx >= 500 - nojumpoffset - noskipoffset*(nojumpoffset == 0 and 1 or 10))
    ne.content = icons.next
    ne.enabled = (have_pl and (pl_pos < pl_count)) or (loop ~= "no")
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("playlist-next", "weak") end
    ne.eventresponder["mbtn_right_up"] = function () mp.command("show-text ${playlist} 3000") end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.command("show-text ${playlist} 3000") end

    --play control buttons
    --play_pause
    ne = new_element("play_pause", "button")
    ne.enabled = not is_image
    ne.content = function ()
        if mp.get_property("eof-reached") == "yes" then
            return icons.replay
        elseif mp.get_property("pause") == "yes" and not state.playingWhilstSeeking then
            return icons.play
        else
            return icons.pause
        end
    end
    ne.eventresponder["mbtn_left_up"] = function ()
        if mp.get_property("eof-reached") == "yes" then
            mp.commandv("seek", 0, "absolute-percent")
            mp.commandv("set", "pause", "no")
        else
            mp.commandv("cycle", "pause")
        end
    end
    ne.eventresponder["mbtn_right_down"] = function ()
        if user_opts.loopinpause then
            if state.looping then
                mp.command("show-text '" .. texts.loopdisable .. "'")
            else
                mp.command("show-text '" .. texts.loopenable .. "'")
            end    
            state.looping = not state.looping
            mp.set_property_native("loop-file", state.looping)
        end
    end

    local jumpamount = user_opts.jumpamount
    local jumpmode = user_opts.jumpmode
    local jump_icon = user_opts.jumpiconnumber and icons.jumpicons[jumpamount] or icons.jumpicons.default

    --jump_backward
    ne = new_element("jump_backward", "button")
    ne.enabled = not is_image
    ne.softrepeat = user_opts.jump_softrepeat == true
    ne.content = jump_icon[1]
    ne.eventresponder["mbtn_left_down"] = function () mp.commandv("seek", -jumpamount, jumpmode) end
    ne.eventresponder["mbtn_right_down"] = function () mp.commandv("seek", -60, jumpmode) end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("frame-back-step") end

    --jump_forward
    ne = new_element("jump_forward", "button")
    ne.enabled = not is_image
    ne.softrepeat = user_opts.jump_softrepeat == true
    ne.content = jump_icon[2]
    ne.eventresponder["mbtn_left_down"] = function () mp.commandv("seek", jumpamount, jumpmode) end
    ne.eventresponder["mbtn_right_down"] = function () mp.commandv("seek", 60, jumpmode) end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("frame-step") end

    --chapter_backward
    ne = new_element("chapter_backward", "button")
    ne.visible = (osc_param.playresx >= 400 - nojumpoffset*10)
    ne.softrepeat = user_opts.chapter_softrepeat == true
    ne.content = icons.rewind
    ne.enabled = (have_ch) -- disables button when no chapters available.
    ne.eventresponder["mbtn_left_down"] = command_callback(user_opts.chapter_prev_mbtn_left_command)
    ne.eventresponder["mbtn_right_down"] = command_callback(user_opts.chapter_prev_mbtn_right_command)
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("seek", -60, jumpmode) end
    ne.eventresponder["shift+mbtn_right_down"] = function () mp.command("show-text ${chapter-list} 3000") end

    --chapter_forward
    ne = new_element("chapter_forward", "button")
    ne.visible = (osc_param.playresx >= 400 - nojumpoffset*10)
    ne.softrepeat = user_opts.chapter_softrepeat == true
    ne.content = icons.forward
    ne.enabled = (have_ch) -- disables button when no chapters available.
    ne.eventresponder["mbtn_left_down"] = command_callback(user_opts.chapter_next_mbtn_left_command)
    ne.eventresponder["mbtn_right_down"] = command_callback(user_opts.chapter_next_mbtn_right_command)
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("seek", 60, jumpmode) end
    ne.eventresponder["shift+mbtn_right_down"] = function () mp.command("show-text ${chapter-list} 3000") end

    update_tracklist()
    
    --audio_track
    ne = new_element("audio_track", "button")
    ne.enabled = audio_track_count > 0
    ne.off = audio_track_count == 0 or not mp.get_property_native("aid")
    ne.visible = (osc_param.playresx >= 550 - outeroffset)
    ne.content = icons.audio
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltipF = function ()
        local prop = mp.get_property("current-tracks/audio/title") or mp.get_property("current-tracks/audio/lang") or texts.na
        return (texts.audio .. " " ..
               (mp.get_property_native("aid") or "-") .. "/" .. audio_track_count .. " [" .. prop .. "]")
    end
    ne.nothingavailable = texts.noaudio
    ne.eventresponder["mbtn_left_up"] = command_callback(user_opts.audio_track_mbtn_left_command)
    ne.eventresponder["mbtn_right_up"] = command_callback(user_opts.audio_track_mbtn_right_command)
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.command("show-text ${track-list} 3000") end
    ne.eventresponder["wheel_down_press"] = command_callback(user_opts.audio_track_wheel_down_command)
    ne.eventresponder["wheel_up_press"] = command_callback(user_opts.audio_track_wheel_up_command)

    --sub_track
    ne = new_element("sub_track", "button")
    ne.enabled = sub_track_count > 0
    ne.off = sub_track_count == 0 or not mp.get_property_native("sid")
    ne.visible = (osc_param.playresx >= 650 - outeroffset)
    ne.content = icons.subtitle
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltipF = function ()
        local prop = mp.get_property("current-tracks/sub/title") or mp.get_property("current-tracks/sub/lang") or texts.na
        return (texts.subtitle .. " " ..
               (mp.get_property_native("sid") or "-") .. "/" .. sub_track_count .. " [" .. prop .. "]")
    end
    ne.nothingavailable = texts.nosub
    ne.eventresponder["mbtn_left_up"] = command_callback(user_opts.sub_track_mbtn_left_command)
    ne.eventresponder["mbtn_right_up"] = command_callback(user_opts.sub_track_mbtn_right_command)
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.command("show-text ${track-list} 3000") end
    ne.eventresponder["wheel_down_press"] = command_callback(user_opts.sub_track_wheel_down_command)
    ne.eventresponder["wheel_up_press"] = command_callback(user_opts.sub_track_wheel_up_command)

    --tog_playlist
    ne = new_element("tog_playlist", "button")
    ne.enabled = have_pl or not user_opts.gray_empty_playlist_button
    ne.off = not have_pl and user_opts.gray_empty_playlist_button
    ne.visible = (osc_param.playresx >= 750 - outeroffset)
    ne.content = icons.playlist
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltipF = have_pl and texts.playlist .. " [" .. pl_pos .. "/" .. pl_count .. "]" or texts.playlist
    ne.nothingavailable = texts.nolist
    ne.eventresponder["mbtn_left_up"] = command_callback(user_opts.playlist_mbtn_left_command)
    ne.eventresponder["mbtn_right_up"] = command_callback(user_opts.playlist_mbtn_right_command)

    -- vol_ctrl
    ne = new_element("vol_ctrl", "button")
    ne.enabled = audio_track_count > 0
    ne.off = audio_track_count == 0
    ne.visible = (osc_param.playresx >= 850 - outeroffset) and user_opts.volumecontrol
    ne.content = function ()
        local volume = mp.get_property_number("volume", 0)
        if state.mute then
            return icons.volume_mute
        else
            if volume >= 75 then
                return icons.volume_high
            elseif volume >= 25 then
                return icons.volume_low
            else
                return icons.volume_quiet
            end
        end
    end
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", "mute") end
    ne.eventresponder["mbtn_right_up"] = command_callback(user_opts.vol_ctrl_mbtn_right_command)
    ne.eventresponder["wheel_up_press"] = function () 
        if state.mute then mp.commandv("cycle", "mute") end
        mp.commandv("osd-msg", "add", "volume", 5)
    end
    ne.eventresponder["wheel_down_press"] = function () 
        if state.mute then mp.commandv("cycle", "mute") end
        mp.commandv("osd-msg", "add", "volume", -5)
    end

    --volumebar
    local volume_max = mp.get_property_number("volume-max") > 0 and mp.get_property_number("volume-max") or 100
    ne = new_element("volumebar", "slider")
    ne.visible = (osc_param.playresx >= 950 - outeroffset) and user_opts.volumecontrol
    ne.enabled = audio_track_count > 0
    ne.slider = {min = {value = 0}, max = {value = volume_max}}
    ne.slider.markerF = function () return {} end
    ne.slider.seekRangesF = function() return nil end
    ne.slider.posF = function ()
        local volume = mp.get_property_number("volume")
        if user_opts.volumecontrol == "logarithmic" then
            return math.sqrt(volume * 100)
        else
            return volume
        end
    end
    ne.slider.tooltipF = function (pos) return (audio_track_count > 0) and set_volume(pos) or "" end
    ne.eventresponder["mouse_move"] = function (element)
        local pos = get_slider_value(element)
        local setvol = set_volume(pos)
        if element.state.lastseek == nil or
            element.state.lastseek ~= setvol then
                mp.commandv("osd-msg", "set", "volume", setvol)
                element.state.lastseek = setvol
        end
    end
    ne.eventresponder["mbtn_left_down"] = function (element)
        local pos = get_slider_value(element)
        mp.commandv("osd-msg", "set", "volume", set_volume(pos))
    end
    ne.eventresponder["reset"] = function (element) element.state.lastseek = nil end
    ne.eventresponder["wheel_up_press"] = function () mp.commandv("osd-msg", "add", "volume", 5) end
    ne.eventresponder["wheel_down_press"] = function () mp.commandv("osd-msg", "add", "volume", -5) end

    --tog_fullscreen
    ne = new_element("tog_fullscreen", "button")
    ne.content = function () return state.fullscreen and icons.fullscreen_exit or icons.fullscreen end
    ne.visible = (osc_param.playresx >= 250)
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", "fullscreen") end

    --tog_info
    ne = new_element("tog_info", "button")
    ne.content = icons.info
    ne.tooltip_style = osc_styles.tooltip
    if user_opts.tooltip_hints then
        ne.tooltipF = texts.statsinfo
    end
    ne.visible = (osc_param.playresx >= 650 - outeroffset - (user_opts.showfullscreen and 0 or 100))
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("script-binding", "stats/display-stats-toggle") end

    --tog_loop
    ne = new_element("tog_loop", "button")
    ne.enabled = not is_image
    ne.content = function () return state.looping and icons.loop_on or icons.loop_off end
    ne.visible = (osc_param.playresx >= 750 - outeroffset - (user_opts.showinfo and 0 or 100) - (user_opts.showfullscreen and 0 or 100))
    ne.tooltip_style = osc_styles.tooltip
    if user_opts.tooltip_hints then
        ne.tooltipF = function () return state.looping and texts.loopdisable or texts.loopenable end
    end
    ne.eventresponder["mbtn_left_up"] = function ()
        if state.looping then
            mp.command("show-text '" .. texts.loopdisable .. "'")
        else
            mp.command("show-text '" .. texts.loopenable .. "'")
        end
        state.looping = not state.looping
        mp.set_property_native("loop-file", state.looping)
    end    

    --tog_ontop
    ne = new_element("tog_ontop", "button")
    ne.content = function () return mp.get_property("ontop") == "no" and icons.ontop_on or icons.ontop_off end
    ne.tooltip_style = osc_styles.tooltip
    if user_opts.tooltip_hints then
        ne.tooltipF = function () return mp.get_property("ontop") == "no" and texts.ontop or texts.ontopdisable end
    end
    ne.visible = (osc_param.playresx >= 850 - outeroffset - (user_opts.showloop and 0 or 100) - (user_opts.showinfo and 0 or 100) - (user_opts.showfullscreen and 0 or 100))
    ne.eventresponder["mbtn_left_up"] = function () 
        mp.commandv("cycle", "ontop") 
        if state.initialborder == "yes" then
            if mp.get_property("ontop") == "yes" then
                mp.commandv("set", "border", "no")
            else
                mp.commandv("set", "border", "yes")
            end
        end
    end
    ne.eventresponder["mbtn_right_up"] = function () 
        mp.commandv("cycle", "ontop")
        if mp.get_property("border") == "no" then
            mp.commandv("set", "border", "yes")
        end
    end

    --screenshot
    ne = new_element("screenshot", "button")
    ne.enabled = not is_image
    ne.content = icons.screenshot
    ne.tooltip_style = osc_styles.tooltip
    if user_opts.tooltip_hints then
        ne.tooltipF = texts.screenshot
    end
    ne.visible = (osc_param.playresx >= 950 - outeroffset - (user_opts.showontop and 0 or 100) - (user_opts.showloop and 0 or 100) - (user_opts.showinfo and 0 or 100) - (user_opts.showfullscreen and 0 or 100))
    ne.eventresponder["mbtn_left_up"] = function ()
        local tempSubPosition = mp.get_property("sub-pos")
        if user_opts.screenshot_flag == "subtitles" or user_opts.screenshot_flag == "subtitles+each-frame" then 
            mp.commandv("set", "sub-pos", 100) 
        end
        mp.commandv("osd-msg", "screenshot", user_opts.screenshot_flag)
        mp.commandv("set", "sub-pos", tempSubPosition)
    end

    --download
    ne = new_element("download", "button")
    ne.content = function () return state.downloading and icons.downloading or icons.download end
    ne.visible = (osc_param.playresx >= 1050 - outeroffset - (user_opts.showscreenshot and 0 or 100) - (user_opts.showontop and 0 or 100) - (user_opts.showloop and 0 or 100) - (user_opts.showinfo and 0 or 100) - (user_opts.showfullscreen and 0 or 100)) and state.isURL
    ne.tooltip_style = osc_styles.tooltip
    ne.tooltipF = function () return state.downloading and "Downloading..." or state.fileSizeNormalised end
    ne.eventresponder["mbtn_left_up"] = function ()
        if not state.videoCantBeDownloaded then
            local localpath = mp.command_native({"expand-path", user_opts.download_path})

            if state.downloadedOnce then
                mp.command("show-text 'Already downloaded'")
            elseif state.downloading then
                mp.command("show-text 'Already downloading'")
            else
                mp.command("show-text Downloading...")
                state.downloading = true
                -- use current or default ytdl-format
                local mpv_ytdl = mp.get_property("file-local-options/ytdl-format") or mp.get_property("ytdl-format") or ""
                local ytdl_format = (mpv_ytdl and mpv_ytdl ~= "") and "-f " .. mpv_ytdl or "-f " .. "bestvideo+bestaudio/best"
                local command = {
                    "yt-dlp",
                    is_image and "" or ytdl_format,
                    is_image and "" or "--remux", is_image and "" or "mp4",
                    "--add-metadata",
                    "--embed-subs",
                    "-o", "%(title)s.%(ext)s",
                    "-P", localpath,
                    state.web_video_path
                }

                local status = exec(command, download_done)
            end
        else
            mp.command("show-text 'Unable to download'")
        end
    end

    --seekbar
    ne = new_element("seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil and not is_image
    ne.thumbnailable = true
    state.slider_element = ne.enabled and ne or nil  -- used for forced_title
    ne.slider.markerF = function ()
        local duration = mp.get_property_number("duration")
        if duration ~= nil then
            local chapters = mp.get_property_native("chapter-list", {})
            local markers = {}
            for n = 1, #chapters do
                markers[n] = (chapters[n].time / duration * 100)
            end
            return markers
        else
            return {}
        end
    end
    ne.slider.posF = function () 
        if mp.get_property_bool("eof-reached") then return 100 end
        return mp.get_property_number("percent-pos") 
    end
    ne.slider.tooltipF = function (pos)
        state.touchingprogressbar = true
        local duration = mp.get_property_number("duration")
        if duration ~= nil and pos ~= nil then
            local possec = duration * (pos / 100)
            local time = mp.format_time(possec)
            -- If video is less than 1 hour, and the time format is not fixed, strip the "00:" prefix
            if possec < 3600 and user_opts.time_format ~= "fixed" then
                time = time:gsub("^00:", "")
            end
            return time
        else
            return ""
        end
    end
    ne.slider.seekRangesF = function()
        if not user_opts.seekrange then
            return nil
        end
        local cache_state = state.cache_state
        if not cache_state then
            return nil
        end
        local duration = mp.get_property_number("duration")
        if duration == nil or duration <= 0 then
            return nil
        end
        local ranges = cache_state["seekable-ranges"]
        if #ranges == 0 then
            return nil
        end
        local nranges = {}
        for _, range in pairs(ranges) do
            nranges[#nranges + 1] = {
                ["start"] = 100 * range["start"] / duration,
                ["end"] = 100 * range["end"] / duration,
            }
        end
        return nranges
    end
    ne.eventresponder["mouse_move"] = function (element)
        if not element.state.mbtnleft then return end -- allow drag for mbtnleft only!
        -- mouse move events may pile up during seeking and may still get
        -- sent when the user is done seeking, so we need to throw away
        -- identical seeks
        if mp.get_property("pause") == "no" and user_opts.mouse_seek_pause then
            state.playingWhilstSeeking = true
            mp.commandv("cycle", "pause")
        end
        local seekto = get_slider_value(element)
        if element.state.lastseek == nil or
          element.state.lastseek ~= seekto then
            local flags = "absolute-percent"
            if not user_opts.seekbarkeyframes then
                flags = flags .. "+exact"
            end
            mp.commandv("seek", seekto, flags)
            element.state.lastseek = seekto
        end

    end
    ne.eventresponder["mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        mp.commandv("seek", get_slider_value(element), "absolute-percent+exact")
    end
    ne.eventresponder["shift+mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        mp.commandv("seek", get_slider_value(element), "absolute-percent")
    end
    ne.eventresponder["mbtn_left_up"] = function (element)
        element.state.mbtnleft = false
    end
    ne.eventresponder["mbtn_right_down"] = function (element)
        local chapter
        local pos = get_slider_value(element)
        local diff = math.huge

        for i, marker in ipairs(element.slider.markerF()) do
            if math.abs(pos - marker) < diff then
                diff = math.abs(pos - marker)
                chapter = i
            end
        end

        if chapter then
            mp.set_property("chapter", chapter - 1)
        end
    end
    ne.eventresponder["reset"] = function (element)
        element.state.lastseek = nil
        if state.playingWhilstSeeking then
            if mp.get_property("eof-reached") == "no" then
                mp.commandv("cycle", "pause")
            end
            state.playingWhilstSeeking = false
        end
    end
    ne.eventresponder["wheel_up_press"] = function () 
        if user_opts.seekbar_track_wheel_mode == "speed" then
            local current_speed = mp.get_property_number("speed")
            mp.commandv("osd-msg", "set", "speed", math.min(100, current_speed + 0.1))
        else
            mp.commandv("seek", 10)
        end
    end
    ne.eventresponder["wheel_down_press"] = function () 
        if user_opts.seekbar_track_wheel_mode == "speed" then
            local current_speed = mp.get_property_number("speed")
            mp.commandv("osd-msg", "set", "speed", math.max(0.1, current_speed - 0.1))
        else
            mp.commandv("seek", -10)
        end
    end

    --persistent seekbar
    ne = new_element("persistentseekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    state.slider_element = ne.enabled and ne or nil  -- used for forced_title
    ne.slider.markerF = function () return {} end
    ne.slider.posF = function () 
        if mp.get_property_bool("eof-reached") then return 100 end
        return mp.get_property_number("percent-pos") 
    end 
    ne.slider.tooltipF = function() return "" end
    ne.slider.seekRangesF = function()
        if user_opts.persistentbuffer then
            if not user_opts.seekrange then
                return nil
            end
            local cache_state = state.cache_state
            if not cache_state then
                return nil
            end
            local duration = mp.get_property_number("duration")
            if duration == nil or duration <= 0 then
                return nil
            end
            local ranges = cache_state["seekable-ranges"]
            if #ranges == 0 then
                return nil
            end
            local nranges = {}
            for _, range in pairs(ranges) do
                nranges[#nranges + 1] = {
                    ["start"] = 100 * range["start"] / duration,
                    ["end"] = 100 * range["end"] / duration,
                }
            end
            return nranges
        end
        return nil
    end

    -- Helper function to format time
    local function format_time(seconds)
        if not seconds then return "--:--" end
        
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local whole_seconds = math.floor(seconds % 60)
        local milliseconds = state.tc_ms and math.floor((seconds % 1) * 1000) or nil
        
        -- Always show HH:MM:SS if user_opts.time_format is "fixed"
        local force_hours = user_opts.time_format == "fixed"
        
        -- Format string templates
        local format_with_ms = (hours > 0 or force_hours) and "%02d:%02d:%02d.%03d" or "%02d:%02d.%03d"
        local format_without_ms = (hours > 0 or force_hours) and "%02d:%02d:%02d" or "%02d:%02d"
        
        if state.tc_ms then
            return string.format(format_with_ms, 
                (hours > 0 or force_hours) and hours or minutes,
                (hours > 0 or force_hours) and minutes or whole_seconds,
                (hours > 0 or force_hours) and whole_seconds or milliseconds,
                (hours > 0 or force_hours) and milliseconds or nil)
        else
            return string.format(format_without_ms,
                (hours > 0 or force_hours) and hours or minutes,
                (hours > 0 or force_hours) and minutes or whole_seconds,
                (hours > 0 or force_hours) and whole_seconds or nil)
        end
    end

    -- Current position time display
    ne = new_element("tc_left", "button")
    ne.enabled = not is_image
    ne.content = function()
        local playback_time = mp.get_property_number("playback-time", 0)
        return format_time(playback_time)
    end
    ne.eventresponder["mbtn_left_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end

    -- Chapter title (below seekbar)
    local chapter_index = mp.get_property_number("chapter", -1)
    ne = new_element("separator", "button")
    ne.visible = chapter_index >= 0
    ne.content = " • "

    ne = new_element("chapter_title", "button")
    ne.visible = chapter_index >= 0
    ne.content = function()
        if user_opts.chapter_fmt ~= "no" and chapter_index >= 0 then
            request_init()
            local chapters = mp.get_property_native("chapter-list", {})
            local chapter_title = (chapters[chapter_index + 1] and chapters[chapter_index + 1].title ~= "") and chapters[chapter_index + 1].title or texts.na
            chapter_title = mp.command_native({"escape-ass", chapter_title})
            return string.format(user_opts.chapter_fmt, chapter_title)
        end
        return "" -- fallback
    end
    ne.eventresponder["mbtn_left_up"] = command_callback(user_opts.chapter_title_mbtn_left_command)
    ne.eventresponder["mbtn_right_up"] = command_callback(user_opts.chapter_title_mbtn_right_command)

    -- Total/remaining time display
    ne = new_element("tc_right", "button")
    ne.enabled = not is_image
    ne.visible = (mp.get_property_number("duration", 0) > 0)
    ne.content = function()
        local duration = mp.get_property_number("duration", 0)
        if duration <= 0 then return "--:--" end

        local time_to_display = state.tc_right_rem and 
            mp.get_property_number("playtime-remaining", 0) or duration

        local prefix = state.tc_right_rem and 
            (user_opts.unicodeminus and UNICODE_MINUS or "-") or ""

        return prefix .. format_time(time_to_display)
    end
    ne.eventresponder["mbtn_left_up"] = function()
        state.tc_right_rem = not state.tc_right_rem
    end

    -- load layout
    layouts()

    -- load window controls
    if window_controls_enabled() then
        window_controls()
    end

    --do something with the elements
    prepare_elements()
end

local function show_osc()
    -- show when disabled can happen (e.g. mouse_move) due to async/delayed unbinding
    if not state.enabled then return end

    msg.trace("show_osc")
    --remember last time of invocation (mouse move)
    state.showtime = mp.get_time()

    osc_visible(true)

    if user_opts.fadeduration > 0 then
        state.anitype = nil
    end
end

local function hide_osc()
    msg.trace("hide_osc")
    if thumbfast.width ~= 0 and thumbfast.height ~= 0 then
        mp.commandv("script-message-to", "thumbfast", "clear")
    end

    local mode = mp.get_property_native("user-data/osc/visibility") or ""

    if not state.enabled and mode ~= "always" then
        -- typically hide happens at render() from tick(), but now tick() is
        -- no-op and won't render again to remove the osc, so do that manually.
        state.osc_visible = false
        adjust_subtitles(false)
        render_wipe()
    elseif user_opts.fadeduration > 0 then
        if state.osc_visible then
            state.anitype = "out"
            request_tick()
        end
    else
        osc_visible(false)
    end
end

local function pause_state(_, enabled)
    state.paused = enabled
    request_tick()
end

local function cache_state(_, st)
    state.cache_state = st
    request_tick()
end

local function mouse_leave()
    state.touchtime = nil  

    if get_hidetimeout() >= 0 and get_touchtimeout() <= 0 then
        local elapsed_time = mp.get_time() - state.showtime
        
        if elapsed_time >= (get_hidetimeout() / 1000) then
            hide_osc()
        end
    end

    -- reset mouse position
    state.last_mouseX, state.last_mouseY = nil, nil
    state.mouse_in_window = false
end

local function handle_touch()
    --remember last time of invocation (touch event)
    state.touchtime = mp.get_time()
end

--
-- Event handling
--
local function reset_timeout()
    state.showtime = mp.get_time() 
end

local function element_has_action(element, action)
    return element and element.eventresponder and
        element.eventresponder[action]
end

local function process_event(source, what)
    local action = string.format("%s%s", source,
        what and ("_" .. what) or "")

    if what == "down" or what == "press" then
        reset_timeout() -- clicking resets the hideosc timer

        for n = 1, #elements do
            if mouse_hit(elements[n]) and
                elements[n].eventresponder and
                (elements[n].eventresponder[source .. "_up"] or
                    elements[n].eventresponder[action]) then

                if what == "down" then
                    state.active_element = n
                    state.active_event_source = source
                end
                -- fire the down or press event if the element has one
                if element_has_action(elements[n], action) then
                    elements[n].eventresponder[action](elements[n])
                end
            end
        end
    elseif what == "up" then
        if elements[state.active_element] then
            local n = state.active_element

            if n == 0 then
                --click on background (does not work)
            elseif element_has_action(elements[n], action) and
                mouse_hit(elements[n]) then

                elements[n].eventresponder[action](elements[n])
            end

            --reset active element
            if element_has_action(elements[n], "reset") then
                elements[n].eventresponder["reset"](elements[n])
            end
        end
        state.active_element = nil
        state.mouse_down_counter = 0
    elseif source == "mouse_move" then
        state.mouse_in_window = true

        local mouseX, mouseY = get_virt_mouse_pos()
        if user_opts.minmousemove == 0 or
            ((state.last_mouseX ~= nil and state.last_mouseY ~= nil) and
                ((math.abs(mouseX - state.last_mouseX) >= user_opts.minmousemove)
                    or (math.abs(mouseY - state.last_mouseY) >= user_opts.minmousemove)
                )
            ) then
                if user_opts.bottomhover then -- if enabled, only show osc if mouse is hovering at the bottom of the screen (where the UI elements are)
                    if mouseY > osc_param.playresy - (user_opts.bottomhover_zone or 160) or (not (state.border and state.title_bar) or state.fullscreen) and mouseY < 40 then -- account for scaling options
                        show_osc()
                    else
                        state.touchtime = nil  

                        if get_hidetimeout() >= 0 and get_touchtimeout() <= 0 then
                            local elapsed_time = mp.get_time() - state.showtime
                            
                            if elapsed_time >= (get_hidetimeout() / 1000) then
                                hide_osc()
                            end
                        end
                    end
                else
                    show_osc()
                end
        end
        state.last_mouseX, state.last_mouseY = mouseX, mouseY

        local n = state.active_element
        if element_has_action(elements[n], action) then
            elements[n].eventresponder[action](elements[n])
        end
    end

    -- ensure rendering after any (mouse) event - icons could change etc
    request_tick()
end

local function do_enable_keybindings()
    if state.enabled then
        if not state.showhide_enabled then
            mp.enable_key_bindings("showhide", "allow-vo-dragging+allow-hide-cursor")
            mp.enable_key_bindings("showhide_wc", "allow-vo-dragging+allow-hide-cursor")
        end
        state.showhide_enabled = true
    end
end

local function enable_osc(enable)
    state.enabled = enable
    if enable then
        do_enable_keybindings()
    else
        hide_osc() -- acts immediately when state.enabled == false
        if state.showhide_enabled then
            mp.disable_key_bindings("showhide")
            mp.disable_key_bindings("showhide_wc")
        end
        state.showhide_enabled = false
    end
end

local function render()
    msg.trace("rendering")
    local current_screen_sizeX, current_screen_sizeY = mp.get_osd_size()
    local mouseX, mouseY = get_virt_mouse_pos()
    local now = mp.get_time()

    -- check if display changed, if so request reinit
    if state.screen_sizeX ~= current_screen_sizeX
        or state.screen_sizeY ~= current_screen_sizeY then

        request_init_resize()

        state.screen_sizeX = current_screen_sizeX
        state.screen_sizeY = current_screen_sizeY
    end

    -- init management
    if state.active_element then
        -- mouse is held down on some element - keep ticking and ignore initReq
        -- till it's released, or else the mouse-up (click) will misbehave or
        -- get ignored. that's because osc_init() recreates the osc elements,
        -- but mouse handling depends on the elements staying unmodified
        -- between mouse-down and mouse-up (using the index active_element).
        request_tick()
    elseif state.initREQ then
        osc_init()
        state.initREQ = false

        -- store initial mouse position
        if (state.last_mouseX == nil or state.last_mouseY == nil)
            and not (mouseX == nil or mouseY == nil) then

            state.last_mouseX, state.last_mouseY = mouseX, mouseY
        end
    end

    -- fade animation
    if state.anitype ~= nil then
        if state.anistart == nil then
            state.anistart = now
        end

        if now < state.anistart + (user_opts.fadeduration / 1000) then

            if state.anitype == "in" then --fade in
                osc_visible(true)
                state.animation = scale_value(state.anistart,
                    (state.anistart + (user_opts.fadeduration / 1000)),
                    255, 0, now)
            elseif state.anitype == "out" then --fade out
                state.animation = scale_value(state.anistart,
                    (state.anistart + (user_opts.fadeduration / 1000)),
                    0, 255, now)
            end

        else
            if state.anitype == "out" then
                osc_visible(false)
            end
            kill_animation()
        end
    else
        kill_animation()
    end

    --mouse show/hide area
    for _, cords in pairs(osc_param.areas["showhide"]) do
        set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide")
    end
    if osc_param.areas["showhide_wc"] then
        for _, cords in pairs(osc_param.areas["showhide_wc"]) do
            set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide_wc")
        end
    else
        set_virt_mouse_area(0, 0, 0, 0, "showhide_wc")
    end
    do_enable_keybindings()

    --mouse input area
    local mouse_over_osc = false

    for _,cords in ipairs(osc_param.areas["input"]) do
        if state.osc_visible then -- activate only when OSC is actually visible
            set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "input")
        end
        if state.osc_visible ~= state.input_enabled then
            if state.osc_visible then
                mp.enable_key_bindings("input")
            else
                mp.disable_key_bindings("input")
            end
            state.input_enabled = state.osc_visible
        end

        if mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2) then
            mouse_over_osc = true
        end
    end

    if osc_param.areas["window-controls"] then
        for _,cords in ipairs(osc_param.areas["window-controls"]) do
            if state.osc_visible then -- activate only when OSC is actually visible
                set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "window-controls")
                mp.enable_key_bindings("window-controls")
            else
                mp.disable_key_bindings("window-controls")
            end

            if mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2) then
                mouse_over_osc = true
            end
        end
    end

    if osc_param.areas["window-controls-title"] then
        for _,cords in ipairs(osc_param.areas["window-controls-title"]) do
            if state.osc_visible then -- activate only when OSC is actually visible
                set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "window-controls-title")
            end
            if state.osc_visible ~= state.windowcontrols_title then
                if state.osc_visible then
                    mp.enable_key_bindings("window-controls-title", "allow-vo-dragging")
                else
                    mp.disable_key_bindings("window-controls-title", "allow-vo-dragging")
                end
                state.windowcontrols_title = state.osc_visible
            end

            if mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2) then
                mouse_over_osc = true
            end
        end
    end

    -- autohide
    if state.showtime ~= nil and get_hidetimeout() >= 0 then
        local timeout = state.showtime + (get_hidetimeout() / 1000) - now
        if timeout <= 0 and get_touchtimeout() <= 0 then
            if state.active_element == nil and not mouse_over_osc then
                if not (state.paused and user_opts.keeponpause) then
                    hide_osc()
                end
            end
        else
            -- the timer is only used to recheck the state and to possibly run
            -- the code above again
            if not state.hide_timer then
                state.hide_timer = mp.add_timeout(0, tick)
            end
            state.hide_timer.timeout = timeout
            -- re-arm
            state.hide_timer:kill()
            state.hide_timer:resume()
        end
    end

    -- actual rendering
    local ass = assdraw.ass_new()

    -- actual OSC
    if state.osc_visible then
        render_elements(ass)
    end

    if user_opts.persistentprogress or state.persistentprogresstoggle then
        render_persistentprogressbar(ass)
    end

    -- submit
    set_osd(osc_param.playresy * osc_param.display_aspect,
            osc_param.playresy, ass.text, 1000)
end

-- called by mpv on every frame
tick = function()
    if state.marginsREQ == true then
        state.marginsREQ = false
    end

    if not state.enabled then return end

    if state.idle then
        -- render idle message
        msg.trace("idle message")
        local _, _, display_aspect = mp.get_osd_size()
        if display_aspect == 0 then
            return
        end
        local display_h = 360
        local display_w = display_h * display_aspect
        -- logo is rendered at 2^(6-1) = 32 times resolution with size 1800x1800
        local icon_x, icon_y = (display_w - 1800 / 32) / 2, 140
        local line_prefix = ("{\\rDefault\\an7\\1a&H00&\\bord0\\shad0\\pos(%f,%f)}"):format(icon_x, icon_y)

        local ass = assdraw.ass_new()
        -- mpv logo
        if user_opts.idlescreen then
            for _, line in ipairs(logo_lines) do
                ass:new_event()
                ass:append(line_prefix .. line)
            end
        end

        -- Santa hat
        if is_december and user_opts.idlescreen and not user_opts.greenandgrumpy then
            for _, line in ipairs(santa_hat_lines) do
                ass:new_event()
                ass:append(line_prefix .. line)
            end
        end

        if user_opts.idlescreen then
            ass:new_event()
            ass:pos(display_w / 2, icon_y + 65)
            ass:an(8)
            ass:append(texts.welcome)
        end
        set_osd(display_w, display_h, ass.text, -1000)

        if state.showhide_enabled then
            mp.disable_key_bindings("showhide")
            mp.disable_key_bindings("showhide_wc")
            state.showhide_enabled = false
        end
    elseif (state.fullscreen and user_opts.showfullscreen)
        or (not state.fullscreen and user_opts.showwindowed) then

        -- render the OSC
        render()
    else
        -- Flush OSD
        render_wipe()
    end

    state.tick_last_time = mp.get_time()

    if state.anitype ~= nil then
        -- state.anistart can be nil - animation should now start, or it can
        -- be a timestamp when it started. state.idle has no animation.
        if not state.idle and
           (not state.anistart or
            mp.get_time() < 1 + state.anistart + user_opts.fadeduration/1000)
        then
            -- animating or starting, or still within 1s past the deadline
            request_tick()
        else
            kill_animation()
        end
    end
end

local function shutdown()
    mp.del_property("user-data/osc")
end

-- duration is observed for the sole purpose of updating chapter markers
-- positions. live streams with chapters are very rare, and the update is also
-- expensive (with request_init), so it's only observed when we have chapters
-- and the user didn't disable the livemarkers option (update_duration_watch).
local function on_duration() request_init() end

local duration_watched = false
local function update_duration_watch()
    local want_watch = user_opts.livemarkers and
                       (mp.get_property_number("chapters", 0) or 0) > 0 and
                       true or false  -- ensure it's a boolean

    if want_watch ~= duration_watched then
        if want_watch then
            mp.observe_property("duration", "native", on_duration)
        else
            mp.unobserve_property(on_duration)
        end
        duration_watched = want_watch
    end
end

local function set_tick_delay(_, display_fps)
    -- may be nil if unavailable or 0 fps is reported
    if not display_fps or not user_opts.tick_delay_follow_display_fps then
        tick_delay = user_opts.tick_delay
        return
    end
    tick_delay = 1 / display_fps
end
local new_file_flag = false -- flag to detect new file starts
mp.register_event("file-loaded", function() 
    new_file_flag = true
    state.fileSizeNormalised = "Approximating size..."
    check_path_url()
end)
mp.register_event("shutdown", shutdown)
mp.register_event("start-file", request_init)
mp.observe_property("track-list", "native", request_init)
mp.observe_property("playlist", "native", request_init)
mp.observe_property("chapter-list", "native", function(_, list)
    list = list or {}  -- safety, shouldn't return nil
    table.sort(list, function(a, b) return a.time < b.time end)
    state.chapter_list = list
    update_duration_watch()
    request_init()
end)

mp.observe_property("playback-time", "native", function(_, time)
    request_tick()
end)
mp.observe_property("seeking", "native", function(_, seeking)
    if user_opts.seek_resets_hidetimeout then
        reset_timeout()
    end
    if seeking and user_opts.osc_on_seek and not new_file_flag then
        show_osc()
    elseif new_file_flag then
        new_file_flag = false
    end
end)

mp.observe_property("fullscreen", "bool", function(_, val)
    state.fullscreen = val
    state.marginsREQ = true
    adjust_subtitles(state.osc_visible)
    request_init_resize()
end)
mp.observe_property("border", "bool", function(_, val)
    state.border = val
    request_init_resize()
end)
mp.observe_property("title-bar", "bool", function(_, val)
    state.title_bar = val
    request_init_resize()
end)
mp.observe_property("window-maximized", "bool", function(_, val)
    state.maximized = val
    request_init_resize()
end)
mp.observe_property("idle-active", "bool", function(_, val)
    state.idle = val
    request_tick()
end)

mp.observe_property("display-fps", "number", set_tick_delay)
mp.observe_property("demuxer-cache-state", "native", cache_state)
mp.observe_property("vo-configured", "bool", request_tick)
mp.observe_property("osd-dimensions", "native", function()
    -- (we could use the value instead of re-querying it all the time, but then
    --  we might have to worry about property update ordering)
    request_init_resize()
    adjust_subtitles(state.osc_visible)
end)
mp.observe_property("osd-scale-by-window", "native", request_init_resize)
mp.observe_property("touch-pos", "native", handle_touch)
mp.observe_property("mute", "bool", function(_, val)
    state.mute = val
    request_tick()
end)

-- ensure compatibility with auto looping scripts (eg: a script that sets videos under 2 seconds to loop by default)
mp.observe_property("loop-file", "bool", function(_, val)
    if (val == nil) then
        state.looping = true
    else 
        state.looping = false
    end
end)

-- mouse show/hide bindings
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
    {"mouse_leave",             mouse_leave},
}, "showhide", "force")
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
    {"mouse_leave",             mouse_leave},
}, "showhide_wc", "force")
do_enable_keybindings()

--mouse input bindings
mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
    {"shift+mbtn_left",     function() process_event("shift+mbtn_left", "up") end,
                            function() process_event("shift+mbtn_left", "down")  end},
    {"mbtn_right",          function() process_event("mbtn_right", "up") end,
                            function() process_event("mbtn_right", "down")  end},
    {"shift+mbtn_right",    function(e) process_event("shift+mbtn_right", "up") end,
                            function(e) process_event("shift+mbtn_right", "down")  end},
    -- alias to shift_mbtn_left for single-handed mouse use
    {"mbtn_mid",            function() process_event("shift+mbtn_left", "up") end,
                            function() process_event("shift+mbtn_left", "down")  end},
    {"wheel_up",            function() process_event("wheel_up", "press") end},
    {"wheel_down",          function() process_event("wheel_down", "press") end},
    {"mbtn_left_dbl",       "ignore"},
    {"shift+mbtn_left_dbl", "ignore"},
    {"mbtn_right_dbl",      "ignore"},
}, "input", "force")
mp.enable_key_bindings("input")

mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
}, "window-controls", "force")
mp.enable_key_bindings("window-controls")

local function always_on(val)
    if state.enabled then
        if val then
            show_osc()
        else
            hide_osc()
        end
    end
end

-- mode can be auto/always/never/cycle
-- the modes only affect internal variables and not stored on its own.
local function visibility_mode(mode, no_osd)
    if mode == "cycle" then
        if not state.enabled then
            mode = "auto"
        elseif user_opts.visibility ~= "always" then
            mode = "always"
        else
            mode = "never"
        end
    end

    if mode == "auto" then
        always_on(false)
        enable_osc(true)
    elseif mode == "always" then
        enable_osc(true)
        always_on(true)
    elseif mode == "never" then
        enable_osc(false)
    else
        msg.warn("Ignoring unknown visibility mode '" .. mode .. "'")
        return
    end

    user_opts.visibility = mode
    mp.set_property_native("user-data/osc/visibility", mode)

    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC visibility: " .. mode)
    end

    -- Reset the input state on a mode change. The input state will be
    -- recalculated on the next render cycle, except in 'never' mode where it
    -- will just stay disabled.
    mp.disable_key_bindings("input")
    mp.disable_key_bindings("window-controls")
    state.input_enabled = false
    request_tick()
end

local function idlescreen_visibility(mode, no_osd)
    if mode == "cycle" then
        if user_opts.idlescreen then
            mode = "no"
        else
            mode = "yes"
        end
    end

    if mode == "yes" then
        user_opts.idlescreen = true
    else
        user_opts.idlescreen = false
    end

    mp.set_property_native("user-data/osc/idlescreen", user_opts.idlescreen)

    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC logo visibility: " .. tostring(mode))
    end

    request_tick()
end

mp.observe_property("pause", "bool", function(name, enabled)
    pause_state(name, enabled)
    if user_opts.showonpause then
        if enabled then
            if user_opts.keeponpause then
                visibility_mode("always", true)
            else
                visibility_mode("auto", true)
            end
            show_osc()
        else
            visibility_mode("auto", true)
        end
    end
end)

mp.register_script_message("osc-visibility", visibility_mode)
mp.register_script_message("osc-show", show_osc)
mp.register_script_message("osc-hide", function() osc_visible(false) end)
mp.add_key_binding(nil, "visibility", function() visibility_mode("cycle") end)
mp.add_key_binding(nil, "progress-toggle", function()
    state.persistentprogresstoggle = not state.persistentprogresstoggle
    request_init()
end)
mp.register_script_message("osc-idlescreen", idlescreen_visibility)
mp.register_script_message("thumbfast-info", function(json)
    local data = utils.parse_json(json)
    if type(data) ~= "table" or not data.width or not data.height then
        msg.error("thumbfast-info: received json didn't produce a table with thumbnail information")
    else
        thumbfast = data
    end
end)

-- Validate string type user options
local function validate_user_opts()
    if user_opts.windowcontrols ~= "auto" and 
       user_opts.windowcontrols ~= "yes" and
       user_opts.windowcontrols ~= "no" then
          msg.warn("windowcontrols cannot be '" .. user_opts.windowcontrols .. "'. Ignoring.")
          user_opts.windowcontrols = "auto"
    end

    if user_opts.volumecontroltype ~= "linear" and
       user_opts.volumecontroltype ~= "logarithmic" then
          msg.warn("volumecontrol cannot be '" .. user_opts.volumecontroltype .. "'. Ignoring.")
          user_opts.volumecontroltype = "linear"
    end

    if user_opts.automatickeyframemode then
       if mp.get_property_number("duration", 0) > user_opts.automatickeyframelimit then
            user_opts.seekbarkeyframes = true
       else
            user_opts.seekbarkeyframes = false
       end
    end

    if user_opts.screenshot_flag ~= "subtitles" and
       user_opts.screenshot_flag ~= "video" and
       user_opts.screenshot_flag ~= "window" and
       user_opts.screenshot_flag ~= "each-frame" and
       user_opts.screenshot_flag ~= "subtitles+each-frame" and
       user_opts.screenshot_flag ~= "video+each-frame" and
       user_opts.screenshot_flag ~= "window+each-frame" then
          msg.warn("screenshot_flag cannot be '" .. user_opts.screenshot_flag .. "'. Ignoring.")
          user_opts.screenshot_flag = "subtitles"
    end

    if not language[user_opts.language] then
       msg.warn("language '" .. user_opts.language .. "' not found. Ignoring.")
       user_opts.language = "en"
       if not language["en"] then
          msg.warn("ERROR: can't find the default 'en' language or the one set by user_opts.")
       end
    end

    local colors = {
        user_opts.osc_color, user_opts.seekbarfg_color, user_opts.seekbarbg_color, 
        user_opts.title_color, user_opts.time_color, user_opts.side_buttons_color, 
        user_opts.middle_buttons_color, user_opts.playpause_color, user_opts.window_title_color, 
        user_opts.window_controls_color, user_opts.held_element_color, user_opts.thumbnailborder_color, 
        user_opts.chapter_title_color, user_opts.seekbar_cache_color, user_opts.hovereffect_color
    }

    for _, color in pairs(colors) do
        if color:find("^#%x%x%x%x%x%x$") == nil then
            msg.warn("'" .. color .. "' is not a valid color")
        end
    end
end

-- read options from config and command-line
opt.read_options(user_opts, "modernz", function(changed)
    validate_user_opts()
    set_osc_texts()
    set_osc_styles()
    set_time_styles(changed.timetotal, changed.timems)
    if changed.tick_delay or changed.tick_delay_follow_display_fps then
        set_tick_delay("display_fps", mp.get_property_number("display_fps"))
    end
    request_tick()
    visibility_mode(user_opts.visibility, true)
    update_duration_watch()
    request_init()
end)

validate_user_opts()
set_osc_texts()
set_osc_styles()
set_time_styles(true, true)
set_tick_delay("display_fps", mp.get_property_number("display_fps"))
visibility_mode(user_opts.visibility, true)
update_duration_watch()

set_virt_mouse_area(0, 0, 0, 0, "input")
set_virt_mouse_area(0, 0, 0, 0, "window-controls")
set_virt_mouse_area(0, 0, 0, 0, "window-controls-title")
