--[[

    Shaman Totem Bar Skin by Darth Android / Telroth-Black Dragonflight
    This script skins the totem bar to fit TukUI.
    
]]

local buttonsize = TukuiDB.Scale(27)
local flyoutsize = TukuiDB.Scale(24)
local buttonspacing = TukuiDB.Scale(3)
local borderspacing = TukuiDB.Scale(2)

local bordercolors = {
	{.23,.45,.13},    -- Earth
	{.58,.23,.10},    -- Fire
	{.19,.48,.60},   -- Water
	{.42,.18,.74},   -- Air
	{.39,.39,.12}    -- Summon / Recall
}

local function SkinFlyoutButton(button)
	button.skin = CreateFrame("Frame",nil,button)
	TukuiDB.SetTemplate(button.skin)
	button:GetNormalTexture():SetTexture(nil)
	button:ClearAllPoints()
	button.skin:ClearAllPoints()
	button.skin:SetFrameStrata("LOW")

	button:SetWidth(buttonsize+borderspacing)
	button:SetHeight(buttonspacing*3 + borderspacing-1)
	button.skin:SetWidth(buttonsize+borderspacing)
	button.skin:SetHeight(buttonspacing*2)
	button:SetPoint("BOTTOM",button:GetParent(),"TOP",0,0)    
	button.skin:SetPoint("TOP",button,"TOP",0,0)

	button:GetHighlightTexture():SetTexture([[Interface\Buttons\ButtonHilight-Square]],"HIGHLIGHT")
	button:GetHighlightTexture():ClearAllPoints()
	button:GetHighlightTexture():SetPoint("TOPLEFT",button.skin,"TOPLEFT",borderspacing,-borderspacing)
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT",button.skin,"BOTTOMRIGHT",-borderspacing,borderspacing)
end

local function SkinActionButton(button, colorr, colorg, colorb)
	TukuiDB.SetTemplate(button)
	button:SetBackdropBorderColor(colorr,colorg,colorb)
	button:SetBackdropColor(0,0,0,0)
	button:ClearAllPoints()
	button:SetAllPoints(button.slotButton)
	button.overlay:SetTexture(nil)
	button:GetRegions():SetDrawLayer("ARTWORK")
end

local function SkinButton(button,colorr, colorg, colorb)
	TukuiDB.SetTemplate(button)
	TukuiDB.SetTemplate(button.actionButton)
	button.background:SetDrawLayer("ARTWORK")
	button.background:ClearAllPoints()
	button.background:SetPoint("TOPLEFT",button,"TOPLEFT",borderspacing,-borderspacing)
	button.background:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-borderspacing,borderspacing)
	button.overlay:SetTexture(nil)
	button:SetSize(TukuiDB.Scale(27),TukuiDB.Scale(27))
	button:SetBackdropBorderColor(colorr,colorg,colorb)
end

local function SkinSummonButton(button,colorr, colorg, colorb)
	local icon = select(1,button:GetRegions())
	icon:SetDrawLayer("ARTWORK")
	icon:ClearAllPoints()
	icon:SetPoint("TOPLEFT",button,"TOPLEFT",borderspacing,-borderspacing)
	icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-borderspacing,borderspacing)
	icon:SetTexCoord(.09,.91,.09,.91)

	select(12,button:GetRegions()):SetTexture(nil)
	select(7,button:GetRegions()):SetTexture(nil)
	TukuiDB.SetTemplate(button)
	button:SetSize(buttonsize,buttonsize)
end

local function SkinFlyoutTray(tray)
	local parent = tray.parent
	local buttons = {select(2,tray:GetChildren())}
	local closebutton = tray:GetChildren()
	local numbuttons = 0


	for i,k in ipairs(buttons) do
		local prev = i > 1 and buttons[i-1] or tray

		if k:IsVisible() then numbuttons = numbuttons + 1 end

		if k.icon then
			k.icon:SetDrawLayer("ARTWORK")
			k.icon:ClearAllPoints()
			k.icon:SetPoint("TOPLEFT",k,"TOPLEFT",borderspacing,-borderspacing)
			k.icon:SetPoint("BOTTOMRIGHT",k,"BOTTOMRIGHT",-borderspacing,borderspacing)

			TukuiDB.SetTemplate(k)
			k:SetBackdropBorderColor(unpack(bordercolors[((parent.idx-1)%5)+1]))
			if k.icon:GetTexture() ~= [[Interface\Buttons\UI-TotemBar]] then
				k.icon:SetTexCoord(.09,.91,.09,.91)
			end
		end

		k:ClearAllPoints()
		k:SetPoint("BOTTOM",prev,"TOP",0,buttonspacing)
	end

	tray.middle:SetTexture(nil)
	tray.top:SetTexture(nil)
	TukuiDB.SetTemplate(tray)

	TukuiDB.SetTemplate(closebutton)
	closebutton:GetHighlightTexture():SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	closebutton:GetHighlightTexture():SetPoint("TOPLEFT",closebutton,"TOPLEFT",borderspacing,-borderspacing)
	closebutton:GetHighlightTexture():SetPoint("BOTTOMRIGHT",closebutton,"BOTTOMRIGHT",-borderspacing,borderspacing)
	closebutton:GetNormalTexture():SetTexture(nil)

	tray:ClearAllPoints()
	closebutton:ClearAllPoints()
	
	tray:SetWidth(flyoutsize + buttonspacing*2)
	tray:SetHeight((flyoutsize+buttonspacing) * numbuttons + buttonspacing)
	closebutton:SetHeight(buttonspacing * 2)
	closebutton:SetWidth(tray:GetWidth())

	tray:SetPoint("BOTTOM",parent,"TOP",0,buttonspacing + TukuiDB.Scale(1))
	closebutton:SetPoint("BOTTOM",tray,"TOP",0,TukuiDB.Scale(1))
	buttons[1]:SetPoint("BOTTOM",tray,"BOTTOM",0,buttonspacing)
end

function pack(...) return {...} end

local AddOn = CreateFrame("Frame")
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
AddOn:SetScript("OnEvent", OnEvent)

function AddOn:PLAYER_ENTERING_WORLD()
	if select(2,UnitClass("player")) == "SHAMAN" then
		local bgframe = CreateFrame("Frame","TotemBG",MultiCastSummonSpellButton)
		TukuiDB.SetTemplate(bgframe)
		bgframe:SetHeight(buttonsize + buttonspacing*2)
		bgframe:SetWidth(buttonspacing + (buttonspacing + buttonsize)*6)
		bgframe:SetFrameStrata("LOW")
		bgframe:ClearAllPoints()

		bgframe:SetHeight(buttonsize + buttonspacing*2)
		bgframe:SetWidth(buttonspacing + (buttonspacing + buttonsize)*6)
		bgframe:SetPoint("BOTTOMLEFT",MultiCastSummonSpellButton,"BOTTOMLEFT",-buttonspacing,-buttonspacing)

		for i = 1,12 do
			if i < 6 then
				local button = _G["MultiCastSlotButton"..i] or MultiCastRecallSpellButton
				local prev = _G["MultiCastSlotButton"..(i-1)] or MultiCastSummonSpellButton
				prev.idx = i - 1
				if i == 1 or i == 5 then
					SkinSummonButton(i == 5 and button or prev,unpack(bordercolors[5]))
				end
				if i < 5 then
					SkinButton(button,unpack(bordercolors[((i-1) % 4) + 1]))
				end
				button:ClearAllPoints()
				ActionButton1.SetPoint(button,"LEFT",prev,"RIGHT",buttonspacing,0)
			end
			SkinActionButton(_G["MultiCastActionButton"..i],unpack(bordercolors[((i-1) % 4) + 1]))
		end
		MultiCastFlyoutFrame:HookScript("OnShow",SkinFlyoutTray)
		MultiCastFlyoutFrameOpenButton:HookScript("OnShow", function(self) if MultiCastFlyoutFrame:IsShown() then MultiCastFlyoutFrame:Hide() end SkinFlyoutButton(self) end)
	end
end

AddOn:RegisterEvent("PLAYER_ENTERING_WORLD")
