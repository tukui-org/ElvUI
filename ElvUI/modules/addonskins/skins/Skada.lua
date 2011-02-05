--[[
    Skada skin for Elvui by Darth Android / Telroth - Black Dragonflight
    Skins all Skada windows to fit Elvui
    All overridden options are removed from Skada's config to reduce confusion
    
    Window height is moved to the Bars config pane - it works a bit differently now.
    If set to 0, window auto-sizes to the number of bars as before, with a minimum of 1 bar.
    If set to 1, then it sizes to accomodate the number of bars defined by the "Max bars" setting
    
    TODO:
     + Add Integration options

	(C)2010 Darth Android / Telroth - Black Dragonflight
	File version v15.37
]]
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not Mod_AddonSkins or not Skada or not C["skin"].skada == true then return end
local Skada = Skada

Mod_AddonSkins:RegisterSkin("Skada",function(Skin,skin,Layout,layout,config)
	Layout.PositionSkadaWindow = dummy
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
    --if not E.skins.Skada.nofont or E.skins.Skada.nofont ~= true then
        options.baroptions.args.barfont = nil
        options.titleoptions.args.font = nil
    --end
	end
	-- Hook the bar mod
	local barmod = Skada.displays["bar"]
	-- Strip options
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
		    local height = numbars * (win.db.barheight + config.barSpacing) + config.barSpacing + config.borderWidth
            --if win.db.enabletitle then height = height + 1 end
		    if win.bargroup.bgframe:GetHeight() ~= height then
			    win.bargroup.bgframe:SetHeight(height)
		    end
	    end
    end
	-- Override settings from in-game GUI
	local titleBG = {
		bgFile = config.normTexture,
		tile = false,
		tileSize = 0
	}
	barmod.ApplySettings_ = barmod.ApplySettings
	barmod.ApplySettings = function(self, win)
		if C["skin"].embedright == "Skada" then
			win.db.barwidth = (C["chat"].chatwidth - 4)
			win.db.barheight = (C["chat"].chatheight*0.965) / 8
			win.db.barmax = (math.floor(C["chat"].chatheight / win.db.barheight) - 1)
			win.db.background.height = 1
			win.db.spark = false
			win.db.barslocked = true
		end
        win.db.enablebackground = true
        win.db.background.borderthickness = config.borderWidth
		barmod:ApplySettings_(win)
		layout:PositionSkadaWindow(win)
        if win.db.enabletitle then
            win.bargroup.button:SetBackdrop(titleBG)
        end
        win.bargroup:SetTexture(config.normTexture)
        win.bargroup:SetSpacing(config.barSpacing)
		win.bargroup:SetFont(config.font,config.fontSize, config.fontFlags)
		local titlefont = CreateFont("TitleFont"..win.db.name)
		titlefont:SetFont(config.font,config.fontSize, config.fontFlags)
		win.bargroup.button:SetNormalFontObject(titlefont)
        local color = win.db.title.color
	    win.bargroup.button:SetBackdropColor(unpack(C["media"].bordercolor))
		if win.bargroup.bgframe then
            win.bargroup.bgframe:SetTemplate("Transparent")
			if win.db.reversegrowth then
				win.bargroup.bgframe:SetPoint("BOTTOM", win.bargroup.button, "BOTTOM", 0, -1 * (win.db.enabletitle and 2 or 1))
			else
				win.bargroup.bgframe:SetPoint("TOP", win.bargroup.button, "TOP", 0,1 * (win.db.enabletitle and 2 or 1))
			end
		end
        self:AdjustBackgroundHeight(win)
        win.bargroup:SetMaxBars(win.db.barmax)
        win.bargroup:SortBars()
	end
	-- Update pre-existing displays
	for k, window in ipairs(Skada:GetWindows()) do
		window:UpdateDisplay()
	end
end)


	