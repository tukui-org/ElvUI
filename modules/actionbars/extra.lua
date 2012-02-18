local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

function AB:SetupExtraButton()
	if not E:IsPTRVersion() then return end

	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Point('BOTTOM', ElvUI_Bar1, 'TOP', 0, 100)
	holder:Size(ExtraActionBarFrame:GetSize())
	
	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
		
	UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil;
	UIPARENT_MANAGED_FRAME_POSITIONS.PlayerPowerBarAlt.extraActionBarFrame = nil;
	
	if UIPARENT_MANAGED_FRAME_POSITIONS.CastingBarFrame then
		UIPARENT_MANAGED_FRAME_POSITIONS.CastingBarFrame.extraActionBarFrame = nil;
	end

	--[[ExtraActionBarFrame:Show(); ExtraActionBarFrame:SetAlpha(1); ExtraActionBarFrame.Hide = ExtraActionBarFrame.Show; ExtraActionBarFrame.SetAlpha = E.noop
	ExtraActionButton1.action = 2; ExtraActionButton1:Show(); ExtraActionButton1:SetAlpha(1); ExtraActionButton1.Hide = ExtraActionButton1.Show; ExtraActionButton1.SetAlpha = E.noop]]
	
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		if _G["ExtraActionButton"..i] then
			_G["ExtraActionButton"..i].noResize = true;
			self:StyleButton(_G["ExtraActionButton"..i])
		end
	end
	
	-- hook the texture, idea by roth via WoWInterface forums
	-- code taken from Tukui
	local button = ExtraActionButton1
	local icon = button.icon
	local texture = button.style
	local disableTexture = function(style, texture)
		if string.sub(texture,1,9) == "Interface" then
			style:SetTexture("")
		end
	end
	button.style:SetTexture("")
	hooksecurefunc(texture, "SetTexture", disableTexture)
	
	self:CreateMover(holder, 'BossButton', 'BossButton');
end