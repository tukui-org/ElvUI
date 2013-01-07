local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "SkadaSkin"
local windows = {}

local function SkinSkada(self)
	local Skada = Skada
	local barSpacing = 1
	local borderWidth = 1
	local barmod = Skada.displays["bar"]

	local function StripOptions(options)
		options.baroptions.args.barspacing = nil
		options.titleoptions.args.texture = nil
		options.titleoptions.args.bordertexture = nil
		options.titleoptions.args.thickness = nil
		options.titleoptions.args.margin = nil
		options.titleoptions.args.color = nil
		options.windowoptions = nil
	--	options.baroptions.args.barfont = nil
	--	options.titleoptions.args.font = nil
	end

	local barmod = Skada.displays["bar"]
	barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
	barmod.AddDisplayOptions = function(self, win, options)
		self:AddDisplayOptions_(win, options)
		StripOptions(options)
	end

	for k, options in pairs(Skada.options.args.windows.args) do
		if(options.type == "group") then
			StripOptions(options.args)
		end
	end

	local titleBG = {
		bgFile = E["media"].normTex,
		tile = false,
		tileSize = 0
	}

	barmod.ApplySettings_ = barmod.ApplySettings
	barmod.ApplySettings = function(self, win)
		barmod.ApplySettings_(self, win)

		local skada = win.bargroup

		if(win.db.enabletitle) then
			skada.button:SetBackdrop(titleBG)
		end

		skada:SetTexture(AS.LSM:Fetch("statusbar",E.private.general.normTex))
		skada:SetSpacing(barSpacing)
		skada:SetFrameLevel(5)
		
		if not skada.TitleBackGround then
			skada.TitleBackGround = CreateFrame("Frame", nil, skada.button)
			skada.TitleBackGround:SetPoint("TOP")
			skada.TitleBackGround:SetPoint("LEFT")
			skada.TitleBackGround:SetPoint("RIGHT")
			skada.TitleBackGround:SetPoint("BOTTOM", 0, 1)
			skada.TitleBackGround:SetTemplate("Default")
			skada.TitleBackGround:SetFrameLevel(skada.button:GetFrameLevel() -1)
		end
		
		local titlefont = CreateFont("TitleFont" .. win.db.name)
		skada.button:SetNormalFontObject(titlefont)
		win.bargroup.button:SetBackdropColor(unpack(E["media"].backdropcolor))
		skada:SetBackdrop(nil)
		if not skada.backdrop then
			skada:CreateBackdrop("Default")
		end
		skada.backdrop:ClearAllPoints()
		if(win.db.enabletitle) then
			skada.backdrop:Point("TOPLEFT", skada.button, "TOPLEFT", -2, 2)
		else
			skada.backdrop:Point("TOPLEFT", skada, "TOPLEFT", -2, 2)
		end
		skada.backdrop:Point("BOTTOMRIGHT", skada, "BOTTOMRIGHT", 2, -2)
		if (not AS:CheckOption("SkadaBackdrop")) then skada.backdrop:Hide() end
		if (AS:CheckOption("EmbedSkada")) then
			win.bargroup.button:SetFrameStrata("HIGH")
			win.bargroup.button:SetFrameLevel(5)	
			win.bargroup:SetFrameStrata("HIGH")
			if (AS:CheckOption("EmbedRight") and RightChatPanel or LeftChatPanel) then win.bargroup:SetParent((AS:CheckOption("EmbedRight") and RightChatPanel or LeftChatPanel)) end
		end
	end
end

AS:RegisterSkin(name,SkinSkada)