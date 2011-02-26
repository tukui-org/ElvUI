local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not Skada or not C["skin"].skada == true then return end

local Skada = Skada
local barSpacing = E.Scale(1, 1)
local borderWidth = E.Scale(2, 2)

-- Used to strip unecessary options from the in-game config
local function StripOptions(options)
	options.baroptions.args.bartexture = options.windowoptions.args.height
	options.baroptions.args.bartexture.order = 12
	options.baroptions.args.bartexture.max = 1
	options.baroptions.args.barspacing = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil
	options.windowoptions = nil
	options.baroptions.args.barfont = nil
	options.titleoptions.args.font = nil
end

local barmod = Skada.displays["bar"]
barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
barmod.AddDisplayOptions = function(self, win, options)
	self:AddDisplayOptions_(win, options)
	StripOptions(options)
end

for k, options in pairs(Skada.options.args.windows.args) do
	if options.type == "group" then
		StripOptions(options.args)
	end
end

-- Size height correctly
barmod.AdjustBackgroundHeight = function(self,win)
	local numbars = 0
	if win.bargroup:GetBars() ~= nil then
		if win.db.background.height == 0 then
			for name, bar in pairs(win.bargroup:GetBars()) do if bar:IsShown() then numbars = numbars + 1 end end
		else
			numbars = win.db.barmax
		end
		if win.db.enabletitle then numbars = numbars + 1 end
		if numbars < 1 then numbars = 1 end
		local height = numbars * (win.db.barheight + barSpacing) + barSpacing + borderWidth
		if win.bargroup.bgframe:GetHeight() ~= height then
			win.bargroup.bgframe:SetHeight(height)
		end
	end
end

-- Override settings from in-game GUI
local titleBG = {
	bgFile = C["media"].normTex,
	tile = false,
	tileSize = 0
}

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	win.db.enablebackground = true
	win.db.background.borderthickness = borderWidth
	barmod:ApplySettings_(win)

	if win.db.enabletitle then
		win.bargroup.button:SetBackdrop(titleBG)
	end
	
	win.bargroup:SetTexture(C["media"].normTex)
	win.bargroup:SetSpacing(barSpacing)
	win.bargroup:SetFont(C["media"].font, C["general"].fontscale)
	win.bargroup:SetFrameLevel(5)
	
	local titlefont = CreateFont("TitleFont"..win.db.name)
	titlefont:SetFont(C["media"].font, C["general"].fontscale)
	win.bargroup.button:SetNormalFontObject(titlefont)
	win.bargroup.button:SetFrameStrata("HIGH")
	win.bargroup.button:SetFrameLevel(5)
	
	
	local color = win.db.title.color
	win.bargroup.button:SetBackdropColor(unpack(C["media"].bordercolor))
	if win.bargroup.bgframe then
		win.bargroup.bgframe:SetTemplate("Default")
		if win.db.reversegrowth then
			win.bargroup.bgframe:SetPoint("BOTTOM", win.bargroup.button, "BOTTOM", 0, -1 * (win.db.enabletitle and 2 or 1))
		else
			win.bargroup.bgframe:SetPoint("TOP", win.bargroup.button, "TOP", 0,1 * (win.db.enabletitle and 2 or 1))
		end
	end
	
	win.bargroup.bgframe:SetFrameStrata("HIGH")
	win.bargroup:SetFrameStrata("HIGH")
	
	self:AdjustBackgroundHeight(win)
	win.bargroup:SetMaxBars(win.db.barmax)
	win.bargroup:SortBars()
end

local windows = {}
function EmbedSkada()
	if #windows == 1 then
		windows[1].db.barwidth = (C["chat"].chatwidth - 4)
		windows[1].db.barheight = (C["chat"].chatheight - (barSpacing * 5)) / 8
		windows[1].db.barmax = (math.floor(C["chat"].chatheight / windows[1].db.barheight) - 1)
		windows[1].db.background.height = 1
		windows[1].db.spark = false
		windows[1].db.barslocked = true
		windows[1].bargroup:ClearAllPoints()
		windows[1].bargroup:SetPoint("TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
		
		barmod.ApplySettings(barmod, windows[1])
	elseif #windows == 2 then
		windows[1].db.barwidth = ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult)
		windows[1].db.barheight = (C["chat"].chatheight - (barSpacing * 5)) / 8
		windows[1].db.barmax = (math.floor(C["chat"].chatheight / windows[1].db.barheight) - 1)
		windows[1].db.background.height = 1
		windows[1].db.spark = false
		windows[1].db.barslocked = true
		windows[1].bargroup:ClearAllPoints()
		windows[1].bargroup:SetPoint("TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
		
		windows[2].db.barwidth = ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult)
		windows[2].db.barheight = (C["chat"].chatheight - (barSpacing * 5)) / 8
		windows[2].db.barmax = (math.floor(C["chat"].chatheight / windows[2].db.barheight) - 1)
		windows[2].db.background.height = 1
		windows[2].db.spark = false
		windows[2].db.barslocked = true
		windows[2].bargroup:ClearAllPoints()
		windows[2].bargroup:SetPoint("TOPLEFT", ChatRBackground2, "TOPLEFT", 2, -2)		
		
		barmod.ApplySettings(barmod, windows[1])
		barmod.ApplySettings(barmod, windows[2])	
	elseif #windows > 2 then
		windows[1].db.barwidth = ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult)
		windows[1].db.barheight = (C["chat"].chatheight - (barSpacing * 5)) / 8
		windows[1].db.barmax = (math.floor(C["chat"].chatheight / windows[1].db.barheight) - 1)
		windows[1].db.background.height = 1
		windows[1].db.spark = false
		windows[1].db.barslocked = true
		windows[1].bargroup:ClearAllPoints()
		windows[1].bargroup:SetPoint("TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
		
		windows[2].db.barwidth = ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult)
		windows[2].db.barheight = (C["chat"].chatheight - (barSpacing * 8)) / 8
		windows[2].db.barmax = (math.floor((C["chat"].chatheight / 2) / windows[2].db.barheight) - 1)
		windows[2].db.background.height = 1
		windows[2].db.spark = false
		windows[2].db.barslocked = true
		windows[2].bargroup:ClearAllPoints()
		windows[2].bargroup:SetPoint("TOPLEFT", ChatRBackground2, "TOPLEFT", 2, -2)		
		
		windows[3].db.barwidth = ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult)
		windows[3].db.barheight = (C["chat"].chatheight - (barSpacing * 8)) / 8
		windows[3].db.barmax = (math.floor((C["chat"].chatheight / 2) / windows[3].db.barheight) - 1)
		windows[3].db.background.height = 1
		windows[3].db.spark = false
		windows[3].db.barslocked = true
		windows[3].bargroup:ClearAllPoints()
		windows[3].bargroup:SetPoint("TOPLEFT", windows[2].bargroup.bgframe, "BOTTOMLEFT", 2, -2)				
		
		barmod.ApplySettings(barmod, windows[1])
		barmod.ApplySettings(barmod, windows[2])
		barmod.ApplySettings(barmod, windows[3])		
	end
end

-- Update pre-existing displays
for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
	tinsert(windows, window)
end

if C["skin"].embedright == "Skada" then
	local Skada_Skin = CreateFrame("Frame")
	Skada_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
	Skada_Skin:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		self = nil
		
		EmbedSkada()
	end)	
end