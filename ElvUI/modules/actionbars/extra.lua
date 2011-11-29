local E, L, DF = unpack(select(2, ...)); --Engine
local AB = E:GetModule('ActionBars');

function AB:SetupExtraButton()
	if not E:IsPTRVersion() then return end

	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Point('TOP', E.UIParent, 'TOP', 0, -250)
	holder:Size(ExtraActionBarFrame:GetSize())
	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
	--Fuck I bet this taints.
	--ExtraActionBarFrame.SetPoint = E.noop; ExtraActionBarFrame.ClearAllPoints = E.noop;
	UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil;
	UIPARENT_MANAGED_FRAME_POSITIONS.PlayerPowerBarAlt.extraActionBarFrame = nil;
	UIPARENT_MANAGED_FRAME_POSITIONS.CastingBarFrame.extraActionBarFrame = nil;
	--[[ExtraActionBarFrame:Show(); ExtraActionBarFrame:SetAlpha(1); ExtraActionBarFrame.Hide = ExtraActionBarFrame.Show; ExtraActionBarFrame.SetAlpha = E.noop
	ExtraActionButton1.action = 2; ExtraActionButton1:Show(); ExtraActionButton1:SetAlpha(1); ExtraActionButton1.Hide = ExtraActionButton1.Show; ExtraActionButton1.SetAlpha = E.noop]]
	ExtraActionButton1.noResize = true;
	
	self:CreateMover(holder, 'BossButton', 'BossButton');
end