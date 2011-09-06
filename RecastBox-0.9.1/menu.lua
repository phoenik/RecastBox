---------------------
-- RecastBox v0.8
-- menu.lua
---------------------

-- Local Variables --
local main = UI.CreateFrame("Frame", "RecastBoxMenuMain", RecastBox.Context)
main:SetVisible(false)

local active = {}
local trash = {}

local init = false

local detail = {}
local index = 1

local fontsize = 18

-- Local Functions --
local CreateMenuItem, CreateMenuItemButton, MenuNext, MenuPrev, MenuInit, ShowMenu, HideMenu, ListAbilities, MenuClear

-- Menu Functions --
function RecastBox.Menu.Open()
	if not init then
		MenuInit()
		init = true
	end
	ShowMenu()
end

function RecastBox.Menu.Close()
	HideMenu()
end

-- Local Functions --
function ShowMenu()
	local abilities = Inspect.Ability.Detail(Inspect.Ability.List())
	
	-- Set up our detail list as index based --
	for v, k in pairs(abilities) do
		if not k.passive then
			k.id = v
			table.insert(detail, k)
		end
	end
	
	-- reset the index --
	index = 1
	
	ListAbilities()
	main:SetVisible(true)
end

function HideMenu()
	-- Empty Detail List --
	for v, k in pairs(detail) do
		detail[v] = nil
	end
	-- Remove Active Frames --
	MenuClear()
	-- Hide the menu --
	main:SetVisible(false)
	-- Refresh RecastBox --
	RecastBox.UI.Render()
	RecastBox.UI.Refresh()
end

function ListAbilities()
	local last = main.title
	for i=index,(index+9) do
		if detail[i] then
			local box = table.remove(trash)
			if not box then box = CreateMenuItem() end
			table.insert(active, box)
			
			-- Set Information --
			box:SetID(detail[i].id)
			box.text:SetText(detail[i].name)
			box.icon:SetTexture("Rift", detail[i].icon)
			box.pin:On(RecastBoxSettings.Pinned[detail[i].id])
			box.flt:On(RecastBoxSettings.Filtered[detail[i].id])
			
			box:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0 , 2)
			
			box:SetVisible(true)
			
			last = box
		end
	end
	-- Hide/Show Prev
	if index == 1 then main.prev:SetVisible(false) else main.prev:SetVisible(true) end
	if index > (#detail-9) then main.next:SetVisible(false) else main.next:SetVisible(true) end
end

function CreateMenuItemButton(name, parent)
	local btn = UI.CreateFrame("Frame", "MenuItemButton", parent)
	btn.id = nil
	btn.text = UI.CreateFrame("Text", "ButtonText", btn)
	btn.text:SetPoint("TOPLEFT", btn, "TOPLEFT", 8, 0)
	btn.text:SetFontSize(fontsize)
	btn.text:SetText(name)
	btn.text:SetHeight(btn.text:GetFullHeight())
	btn:SetHeight(btn.text:GetFullHeight())
	btn:SetWidth(btn.text:GetFullWidth()+16)
	
	function btn:On(bool)
		if bool then
			self.text:SetFontColor(0, 1, 0)
			self.text:SetWidth(self.text:GetFullWidth())
		else
			self.text:SetFontColor(0.75, 0.75, 0.75)
			self.text:SetWidth(self.text:GetFullWidth())
		end
	end
	
	return btn
end

function CreateMenuItem()
	local box = UI.CreateFrame("Frame", "MenuItem", main)
	box.id = nil
	
	box:SetPoint("RIGHT", main, "RIGHT")
	
	box.icon = UI.CreateFrame("Texture", "ItemIcon", box)
	box.icon:SetPoint("TOPLEFT", box, "TOPLEFT")
	box.icon:SetPoint("BOTTOM", box, "BOTTOM")
	
	box.text = UI.CreateFrame("Text", "ItemText", box)
	box.text:SetFontSize(fontsize)
	box.text:SetText("Ability")
	box.text:SetHeight(box.text:GetFullHeight())
	box.text:SetPoint("TOPLEFT", box.icon, "TOPRIGHT", 4, 0)
	box:SetPoint("BOTTOM", box.text, "BOTTOM")
	
	box.icon:SetWidth(box.text:GetFullHeight())
	
	box.pin = CreateMenuItemButton("Pinned", box)
	box.flt = CreateMenuItemButton("Filtered", box)
	
	box.flt:SetPoint("TOPRIGHT", box, "TOPRIGHT")
	box.pin:SetPoint("TOPRIGHT", box.flt, "TOPLEFT")
	box.text:SetPoint("RIGHT", box.pin, "LEFT")
	
	function box:SetID(id)
		self.id = id
		box.pin.id = id
		box.flt.id = id
	end
	
	function box.flt.Event:LeftDown()
		RecastBox.Func.Filter(self.id, (not RecastBoxSettings.Filtered[self.id]))
		self:On(RecastBoxSettings.Filtered[self.id])
	end
	
	function box.pin.Event:LeftDown()
		RecastBox.Func.Pin(self.id, not RecastBoxSettings.Pinned[self.id])
		self:On(RecastBoxSettings.Pinned[self.id])
	end
	
	return box
end

function MenuClear()
	for v, k in pairs(active) do
		table.insert(trash, k)
		active[v]:SetVisible(false)
		active[v] = nil
	end
end

function MenuNext()
	MenuClear()
	index = index + 10
	ListAbilities()
end

function MenuPrev()
	MenuClear()
	index = index - 10
	ListAbilities()
end

function MenuInit()
	-- Menu Window Settings --
	main:SetWidth(420)
	main:SetHeight(310)
	main:SetBackgroundColor(0, 0, 0, 0.8)
	main:SetPoint("TOPLEFT", RecastBox.Context, "TOPLEFT", (RecastBox.Context:GetWidth()*0.5-(main:GetWidth()/2)), (RecastBox.Context:GetHeight()*0.4-(main:GetHeight()/2)))

	main.title = UI.CreateFrame("Text", "RecastBoxMenuTitle", main)
	main.close = UI.CreateFrame("Text", "RecastBoxMenuCloseButton", main)

	main.title:SetPoint("TOPLEFT", main, "TOPLEFT")
	main.title:SetPoint("RIGHT", main.close, "LEFT")
	main.title:SetFontSize(fontsize)
	main.title:SetBackgroundColor(24/255, 41/255, 69, 1)
	main.title:SetText("RecastBox Config")
	main.title:SetHeight(main.title:GetFullHeight())

	main.close:SetPoint("TOPRIGHT", main, "TOPRIGHT", -2, 0)
	main.close:SetFontSize(fontsize)
	main.close:SetText("close")
	main.close:SetHeight(main.close:GetFullHeight()+2)
	function main.close.Event:LeftDown()
		RecastBox.Menu.Close()
	end
	
	main.prev = CreateMenuItemButton("Prev", main)
	main.next = CreateMenuItemButton("Next", main)
	main.prev:SetPoint("TOPLEFT", main, "BOTTOMLEFT", 0, 8)
	main.prev:SetBackgroundColor(0, 0, 0, 1)
	main.next:SetPoint("TOPRIGHT", main, "BOTTOMRIGHT", 0, 8)
	main.next:SetBackgroundColor(0, 0, 0, 1)
	
	function main.prev.Event:LeftDown()
		MenuPrev()
	end
	
	function main.next.Event:LeftDown()
		MenuNext()
	end
end