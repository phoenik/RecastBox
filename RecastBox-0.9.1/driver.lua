---------------------
-- RecastBox v0.8
-- driver.lua
---------------------

-- Local Variables --
local list = Inspect.Ability.List()

-- Init --
local init = false

-- Delay Updates for Performance Increase --
local t = Inspect.Time.Frame()
local delay = 0.25

local update, oncooldown, onavailability, init

-- Local Functions --
function update()
	-- Trigger INIT --
	if not init then
		list = Inspect.Ability.List()
		if not list then return else
			init  = true
			RecastBox.UI.Render() -- For alpha to work properly
			oncooldown()
			return
		end
	end
	
	-- Make sure UI is loaded --
	if not RecastBox.UI.IsLoaded() then return end
	
	-- Delay --
	local i = Inspect.Time.Frame()
	if (i - t) > delay then t = i else return end

	-- Prevent List crash --
	list = Inspect.Ability.List()
	if not list then return end

	-- Get Abilities --
	local index = RecastBox.UI.GetIndex()

	-- Get Details --
	local details = Inspect.Ability.Detail(index)
	
	-- Trigger Updates --
	for v, k in pairs(details) do
		if not k.currentCooldownRemaining then k.currentCooldownRemaining = 0 end
		RecastBox.UI.Update(v, k.currentCooldownRemaining)
	end
end

function oncooldown()
	-- Prevent List crash --
	list = Inspect.Ability.List()
	if not list then return end
	
	local index = RecastBox.UI.GetIndex()
	local details = Inspect.Ability.Detail(list)
	
	-- Filter out abilities --
	for v, k in pairs(details) do
		-- Filter out passive abilities and filtered abilities --
		if not k.passive and k.cooldown and not RecastBoxSettings.Filtered[v] then
			-- Filter out global cooldowns --
			if k.currentCooldownDuration and k.currentCooldownRemaining then
				if math.floor(k.cooldown) == math.floor(k.currentCooldownDuration) then
					if index[v] then
						RecastBox.UI.Update(v, k.currentCooldownRemaining)
					else
						RecastBox.UI.Insert(v, k.name, k.icon, k.currentCooldownRemaining, k.cooldown)
					end
				end
			else
				if RecastBoxSettings.Pinned[v] and not index[v] then
					RecastBox.UI.Insert(v, k.name, k.icon, 0, k.cooldown)
				end
			end
		else
			if index[v] and RecastBoxSettings.Filtered[v] then
				RecastBox.UI.Remove(v)
			end
		end
	end
end

function onavailability()
	-- Prevent list crash --
	list = Inspect.Ability.List()
	if not list then return end
	
	-- Get Index --
	local index = RecastBox.UI.GetIndex()
	
	-- Remove unusable abilities --
	for v, k in pairs(index) do
		if not list[v] then
			RecastBox.UI.Remove(v, true)
		end
	end
	
	-- Close the menu --
	RecastBox.Menu.Close()
	
	-- Call oncooldown() So we can reload pinned abilities 
	-- and anything else on cooldown
	oncooldown()	
end

-- Events --
table.insert(Event.System.Update.Begin, {update, RecastBox.Version.Name, "OnUpdate"})
table.insert(Event.Ability.Cooldown.Begin, {oncooldown, RecastBox.Version.Name, "OnCooldown"})
table.insert(Event.Ability.Add, {onavailability, RecastBox.Version.Name, "OnAvailability"})