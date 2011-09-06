---------------------
-- RecastBox v0.8
-- ui.lua
---------------------
local main = UI.CreateFrame("Frame", "RecastBoxMain", RecastBox.Context)
local loader = UI.CreateFrame("Frame", "RecastBoxLoader", main)

local active = {}
local index = {}
local trash = {}

local init = false

-- Local Functions --
local function GetRecastText(current)
	local text = ""
	current = current + 1
	if current >= 3600 then
		text = string.format("%d:%02d:%02d", current / 3600, current / 60 % 60, current % 60)
	else
		text = string.format("%d:%02d", current / 60, current % 60)
	end
	return text
end

local function CreateRecastBox()
	local box = UI.CreateFrame("Frame", "Bar", loader)
	
	-- Box Settings --
	box.id = nil
	box.current = nil
	box.cooldown = 0
	box.pinned = false
	------------------
	
	-- Elements --
	box.text = UI.CreateFrame("Text", "Name", box)
	box.time = UI.CreateFrame("Text", "Time", box)
	box.icon = UI.CreateFrame("Texture", "Icon", box)
	
	-- Init Contents --
	box.text:SetText("Ability")
	box.time:SetText("00:00:00")
	box.icon:SetLayer(-1)
	
	-- Hide Frame --
	box:SetVisible(false)
	
	-- LeftClick Event --
	function box.Event:LeftDown()
		self.pinned = not self.pinned
		RecastBox.Func.Pin(self.id, self.pinned)
		RecastBox.UI.Refresh()
	end
	
	-- Set Functions --
	function box:SetID(id)
		self.id = id
	end
	
	function box:SetName(name)
		self.text:SetText(name)
	end
	
	function box:SetCurrent(current)
		self.current = current
	end
	
	function box:SetCooldown(cooldown)
		self.cooldown = cooldown
	end
	
	function box:SetTime(text)
		self.time:SetText(text)
		self.time:SetWidth(self.time:GetFullWidth())
	end
	
	function box:SetIcon(icon)
		self.icon:SetTexture("Rift", icon)
	end
	
	function box:SetPinned(bool)
		self.pinned = bool
	end
	
	function box:FlagWarn()
		self:SetBackgroundColor(0.5, 0, 0, 0.75)
	end
	
	function box:FlagReady()
		self:SetBackgroundColor(0, 0.5, 0, 0.75)
	end
	
	function box:NoFlag()
		if RecastBoxSettings.Pinned[self.id] then
			self:SetBackgroundColor(0, 0, 0.3, 0.75)
		else
			self:SetBackgroundColor(0, 0, 0, 0.75)
		end
	end
	
	function box:Refresh()
		-- Pinned Settings --
		if not RecastBoxSettings.Pinned[self.id] then self:SetPinned(false) end
		-- Point Settings --
		if RecastBoxSettings.useicons then
			self.icon:SetPoint("TOPLEFT", self, "TOPLEFT")
			self.text:SetPoint("TOPLEFT", self.icon, "TOPRIGHT", 6, 0)
			self.time:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, 0)
			self.text:SetPoint("TOPRIGHT", self.time, "TOPLEFT")
			self.icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
			self.icon:SetWidth(self.text:GetFullHeight())
			self:SetPoint("BOTTOM", self.text, "BOTTOM")
			self.icon:SetVisible(true)
		else
			self.text:SetPoint("TOPLEFT", self, "TOPLEFT", 2, 0)
			self.time:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.text:SetPoint("TOPRIGHT", self.time, "TOPLEFT")
			self:SetPoint("BOTTOM", self.text, "BOTTOM")
			self.icon:SetVisible(false)
		end
	end
	
	function box:Render()
		self:SetVisible(false)
		self:SetBackgroundColor(0, 0, 0, 0.75)
		
		-- Text Settings --
		self.text:SetFontSize(RecastBoxSettings.fontsize)
		self.time:SetFontSize(RecastBoxSettings.fontsize)
		self.text:SetHeight(self.text:GetFullHeight())
		self.time:SetHeight(self.time:GetFullHeight())
		self.time:SetWidth(self.time:GetFullWidth())
		
		-- No Flag --
		self:NoFlag()
		
		-- Set Points --
		self:Refresh()
		
		-- Set Position and Width --
		self:SetPoint("LEFT", main, "LEFT")
		self:SetPoint("RIGHT", main, "RIGHT")
		
		-- Set Visibility --
		self:SetVisible(true)
	end
	
	-- Return Reference --
	return box
end
---------------------

-- UI Functions --
-- Init Stage --
function RecastBox.UI.Init()
	main:SetPoint(RecastBoxSettings.align, RecastBox.Context, RecastBoxSettings.align, (RecastBox.Context:GetWidth()*(RecastBoxSettings.xp/100)), (RecastBox.Context:GetHeight()*(RecastBoxSettings.yp/100)))
	main:SetWidth(RecastBoxSettings.w)
	main:SetAlpha(RecastBoxSettings.alpha/100)
	loader:SetPoint("TOPLEFT", RecastBox.Context, "TOPLEFT", (0 - RecastBoxSettings.w), 0)
	init = true
end

function RecastBox.UI.IsLoaded()
	return init
end

function RecastBox.UI.Insert(id, name, icon, current, cooldown)
	local box = table.remove(trash)
	if not box then box = CreateRecastBox() end
	if not box then return end
	
	-- Set Frame Information --
	box:SetID(id)
	box:SetName(name)
	box:SetIcon(icon)
	box:SetTime(GetRecastText(current))
	box:SetCurrent(current)
	box:SetCooldown(cooldown)
	if RecastBoxSettings.Pinned[id] then box:SetPinned(true) else box:SetPinned(false) end
	
	-- Render Box --
	box:Render()
	
	-- Add it to the list --
	active[id] = box
	table.insert(index, id)
	
	-- Refresh Frames --
	RecastBox.UI.Refresh()
end

function RecastBox.UI.Remove(id, force)
	-- Prevent nil --
	if not active[id] then return end
	
	-- Prevent Removing Pinned only if not filtered --
	if RecastBoxSettings.Pinned[id] and not force and not RecastBoxSettings.Filtered[id] then return end
	
	-- Find in index --
	for v, k in pairs(index) do
		if k == id then
			table.remove(index, v)
			break
		end
	end
	
	-- Add to the trash then remove --
	active[id]:SetVisible(false)
	table.insert(trash, active[id])
	active[id] = nil
	
	-- Re-Sort --
	RecastBox.UI.Refresh()
end

function RecastBox.UI.Update(id, current)
	-- Prevent nil --
	if not active[id] then return end

	if not current then current = 0 end
	
	-- Set Value --
	active[id].current = current
	active[id]:NoFlag()
	
	-- If it's ready to be removed --
	if current == 0 then 
		active[id]:SetTime("Ready")
		active[id]:FlagReady()
		RecastBox.UI.Remove(id)
		return
	end
	
	-- Set Text --
	active[id]:SetTime(GetRecastText(current))
	
	if current < RecastBoxSettings.warn then active[id]:FlagWarn() end
	
end

function RecastBox.UI.Refresh()
	-- Sort Abilities --
	if RecastBoxSettings.autosort then
		table.sort(index, function(a, b)
			if not active[a] then return false end
			if not active[b] then return true end
			if RecastBoxSettings.Pinned[a] and RecastBoxSettings.Pinned[b] then
				return active[a].cooldown < active[b].cooldown
			end
			if RecastBoxSettings.Pinned[a] then return true end
			if RecastBoxSettings.Pinned[b] then return false end
			return active[a].current < active[b].current
		end)
	end
	
	-- Check for Filtered --
	for v, k in pairs(index) do
		if RecastBoxSettings.Filtered[k] then
			RecastBox.UI.Remove(k)
		end
	end
	
	-- Realign Abilities --
	local last = nil
	for v, k in pairs(index) do
		if not last then
			active[k]:SetPoint("TOPLEFT", main, "TOPLEFT")
		else
			active[k]:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
		end
		last = active[k]
	end
end

function RecastBox.UI.GetIndex()
	local ret = {}
	for v, k in pairs(index) do
		ret[k] = true
	end
	return ret
end

function RecastBox.UI.Render()
	main:SetPoint(RecastBoxSettings.align, RecastBox.Context, RecastBoxSettings.align, (RecastBox.Context:GetWidth()*(RecastBoxSettings.xp/100)), (RecastBox.Context:GetHeight()*(RecastBoxSettings.yp/100)))
	main:SetWidth(RecastBoxSettings.w)
	main:SetAlpha(RecastBoxSettings.alpha/100)
	loader:SetPoint("TOPLEFT", RecastBox.Context, "TOPLEFT", (0 - RecastBoxSettings.w), 0)
	for v, k in pairs(active) do
		k:Render()
	end
end
