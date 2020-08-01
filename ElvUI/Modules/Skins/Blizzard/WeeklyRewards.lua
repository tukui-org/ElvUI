local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

-- Credits Siweia | AuroraClassic

local function SkinActivityFrame(frame, isObject)
	if frame.Border then
		if isObject then
			frame.Border:SetAlpha(0)
		else
			frame.Border:SetTexCoord(.926, 1, 0, 1)
			frame.Border:SetSize(25, 137)
			frame.Border:SetPoint("LEFT", frame, "RIGHT", 3, 0)
		end
	end
	frame:CreateBackdrop()
end

function S:Blizzard_WeeklyRewards()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.weeklyRewards) then return end

	-- /run UIParent_OnEvent({}, "WEEKLY_REWARDS_SHOW")
	local frame = _G.WeeklyRewardsFrame

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
	end
	frame:CreateBackdrop('Transparent')
	S:HandleCloseButton(frame.CloseButton)

	local header = frame.HeaderFrame
	if E.private.skins.parchmentRemoverEnable then
		header:StripTextures()
	end
	header:CreateBackdrop('Transparent')
	header:Point('TOP', 1, -42)

	SkinActivityFrame(frame.RaidFrame)
	SkinActivityFrame(frame.MythicFrame)
	SkinActivityFrame(frame.PVPFrame)

	for _, frame in pairs(frame.Activities) do
		SkinActivityFrame(frame, true)
	end
end

S:AddCallbackForAddon('Blizzard_WeeklyRewards')
