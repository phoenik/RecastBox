---------------------
-- RecastBox v0.8
-- core.lua
---------------------
RecastBox = {}

-- Version Information --
RecastBox.Version = {}
RecastBox.Version.Build = "0.8"
RecastBox.Version.Name = Inspect.Addon.Current()

-- Default Settings --
RecastBox.Default = {
	align = "TOPLEFT",
	xp = 2,
	yp = 25,
	w = 320,
	alpha = 100,
	warn = 5,
	fontsize = 16,
	useicons = true,
	autosort = true
}
RecastBox.Default.Pinned = {}
RecastBox.Default.Filtered = {}

-- SavedVariables Default --
RecastBoxSettings = RecastBox.Default

-- RecastBox UI --
RecastBox.UI = {}
	-- Function Delarations --
	RecastBox.UI.Remove = nil
	RecastBox.UI.Update = nil
	RecastBox.UI.Insert = nil
	RecastBox.UI.Refresh = nil
	RecastBox.UI.GetIndex = nil
	RecastBox.UI.Render = nil
	RecastBox.UI.Init = nil
	RecastBox.UI.IsLoaded = nil
	
-- RecastBox Menu --
RecastBox.Menu = {}
	RecastBox.Menu.Open = nil
	RecastBox.Menu.Close = nil
	
-- RecastBox Func --
RecastBox.Func = {}

-- Context and Resolution Control --
RecastBox.Context = UI.CreateContext("RecastBoxContext")
RecastBox.Context:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
RecastBox.Context:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT")
function RecastBox.Context.Event:Size()
	RecastBox.UI.Render()
end

-- Functions --
function RecastBox.Func.Pin(id, bool)
	if bool then
		RecastBoxSettings.Pinned[id] = true
	else
		RecastBoxSettings.Pinned[id] = nil
	end
end

function RecastBox.Func.Filter(id, bool)
	if bool then
		RecastBoxSettings.Filtered[id] = true
	else
		RecastBoxSettings.Filtered[id] = nil
	end
end

-- Make sure saved variables are loaded, otherwise load default --
local function savedvars(args)
	if args == RecastBox.Version.Name then
		if not RecastBoxSettings then RecastBoxSettings = RecastBox.Default else
			-- Make Sure no Variables are missing --
			for v, k in pairs(RecastBox.Default) do
				if not RecastBoxSettings[v] then RecastBoxSettings[v] = RecastBox.Default[v] end
			end
		end
		RecastBox.UI.Init()
	end
end

table.insert(Event.Addon.SavedVariables.Load.End, {savedvars, RecastBox.Version.Name, "SavedVariablesLoaded"})

----------------------
-- Console Commands --
----------------------
local function setwidth(param)
	local w = param:match("(%d+)")
	w = tonumber(w)
	if not w then
		print("RecastBox Width = " .. tostring(RecastBoxSettings.w))
		print("RecastBox: /rbwidth [width]")
		return
	end
	RecastBoxSettings.w = w
	print("RecastBox Width = " .. tostring(RecastBoxSettings.w))
	RecastBox.UI.Render()
end

local function setpos(param)
	local x, y = param:match("(%d+) (%d+)")
	x, y = tonumber(x), tonumber(y)
	if not x or not y then
		print("RecastBox X = " .. tostring(RecastBoxSettings.x) .. "%, Y = " .. tostring(RecastBoxSettings.y) .. "%")
		print("RecastBox: /rbpos [x 0-100] [y 0-100]")
		return
	end
	if x > 100 or x < 0 then x = RecastBox.Default.x end
	if y > 100 or y < 0 then y = RecastBox.Default.y end
	RecastBoxSettings.x = x
	RecastBoxSettings.y = y
	print("RecastBox X = " .. tostring(RecastBoxSettings.x) .. "%, Y = " .. tostring(RecastBoxSettings.y) .. "%")
	RecastBox.UI.Render()
end

local function setfontsize(param)
	local s = param:match("(%d+)")
	s = tonumber(s)
	if not s then
		print("RecastBox Fontsize = " .. tostring(RecastBoxSettings.fontsize) .. "pt")
		print("RecastBox: /rbfontsize [size]")
	end
	RecastBoxSettings.fontsize = s
	print("RecastBox Fontsize = " .. tostring(RecastBoxSettings.fontsize) .. "pt")
	RecastBox.UI.Render()
end

local function setalpha(param)
	local a = param:match("(%d+)")
	a = tonumber(a)
	if not a then
		print("RecastBox Alpha = " .. tostring(RecastBoxSettings.alpha) .. "%")
		print("RecastBox: /rbalpha [0 - 100]")
		return
	elseif a < 0 or a > 100 then
		print("RecastBox Alpha = " .. tostring(RecastBoxSettings.alpha) .. "%")
		print("RecastBox: /rbalpha [0 - 100]")
		return
	end
	RecastBoxSettings.alpha = a
	print("RecastBox Alpha = " .. tostring(RecastBoxSettings.alpha) .. "%")
	RecastBox.UI.Render()
end

local function setwarn(param)
	local w = param:match("(%d+)")
	w = tonumber(w)
	if not w then
		print("RecastBox Warn Level: " .. tostring(RecastBoxSettings.warn) .. "s")
		print("RecastBox: /rbwarn [seconds]")
	end
	RecastBoxSettings.warn = w
	print("RecastBox Warn Level: " .. tostring(RecastBoxSettings.warn) .. "s")
end

local function setautosort()
	RecastBoxSettings.autosort = not RecastBoxSettings.autosort
	if RecastBoxSettings.autosort then
		print("RecastBox Autosort Enabled")
	else
		print("RecastBox Autosort Disabled")
	end
	if RecastBoxSettings.autosort then RecastBox.UI.Refresh() end
end

local function setuseicons()
	RecastBoxSettings.useicons = not RecastBoxSettings.useicons
	if RecastBoxSettings.useicons then
		print("RecastBox Icons Enabled")
	else
		print("RecastBox Icons Disabled")
	end
	RecastBox.UI.Render()
end

local function clearpinned()
	print("RecastBox: Clearing Pinned")
	RecastBoxSettings.Pinned = {}
	RecastBox.UI.Render()
end

local function clearfilters()
	print("RecastBox: Clearing Filters")
	RecastBoxSettings.Filtered = {}
	RecastBox.UI.Render()
end

local function config()
	RecastBox.Menu.Open()
end

local function help()
	print("RecastBox: /rbwidth [width]")
	print("RecastBox: /rbpos [x 0-100%] [y 0-100%]")
	print("RecastBox: /rbfontsize [size]")
	print("RecastBox: /rbalpha [0 - 100]")
	print("RecastBox: /rbwarn [seconds]")
	print("RecastBox: /rbautosort")
	print("RecastBox: /rbclearpins")
	print("RecastBox: /rbclearfilters")
	print("RecastBox: /rbconfig")
	print("RecastBox: /rbhelp")
end

-- Register Console Commands --
table.insert(Command.Slash.Register("rbwidth"), {setwidth, RecastBox.Version.Name, "RecastBoxSetWidth"})
table.insert(Command.Slash.Register("rbpos"), {setpos, RecastBox.Version.Name, "RecastBoxSetPos"})
table.insert(Command.Slash.Register("rbalpha"), {setalpha, RecastBox.Version.Name, "RecastBoxSetAlpha"})
table.insert(Command.Slash.Register("rbfontsize"), {setfontsize, RecastBox.Version.Name, "RecastBoxFontSize"})
table.insert(Command.Slash.Register("rbwarn"), {setwarn, RecastBox.Version.Name, "RecastBoxWarn"})
table.insert(Command.Slash.Register("rbautosort"), {setautosort, RecastBox.Version.Name, "RecastBoxAutosort"})
table.insert(Command.Slash.Register("rbicons"), {setuseicons, RecastBox.Version.Name, "RecastBoxUseicons"})
table.insert(Command.Slash.Register("rbclearpins"), {clearpinned, RecastBox.Version.Name, "RecastBoxClearPins"})
table.insert(Command.Slash.Register("rbclearfilters"), {clearfilters, RecastBox.Version.Name, "RecastBoxClearFilters"})
table.insert(Command.Slash.Register("rbconfig"), {config, RecastBox.Version.Name, "RecastBoxConfig"})
table.insert(Command.Slash.Register("rbhelp"), {help, RecastBox.Version.Name, "RecastBoxHelp"})