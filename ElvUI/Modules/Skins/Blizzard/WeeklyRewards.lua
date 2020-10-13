local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs, unpack = pairs, unpack
local hooksecurefunc = hooksecurefunc

-- Credits Siweia | AuroraClassic

local function UpdateSelection(frame)
	if not frame.backdrop then return end

	if frame.SelectedTexture:IsShown() then
		frame.backdrop:SetBackdropBorderColor(1, .8, 0)
	else
		frame.backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

local IconColor = E.QualityColors[Enum.ItemQuality.Epic or 4] -- epic color only
local function SkinRewardIcon(itemFrame)
	if not itemFrame.IsSkinned then
		itemFrame:CreateBackdrop('Transparent')
		itemFrame:DisableDrawLayer('BORDER')
		itemFrame.Icon:SetPoint('LEFT', 6, 0)
		S:HandleIcon(itemFrame.Icon, true)
		itemFrame.backdrop:SetBackdropBorderColor(IconColor.r, IconColor.g, IconColor.b)
		itemFrame.IsSkinned = true
	end
end

local function SkinActivityFrame(frame, isObject)
	if frame.Border then
		if isObject then
			frame.Border:SetAlpha(0)
			frame.SelectedTexture:SetAlpha(0)
			frame.LockIcon:SetVertexColor(unpack(E.media.rgbvaluecolor))
			hooksecurefunc(frame, "SetSelectionState", UpdateSelection)
			hooksecurefunc(frame.ItemFrame, 'SetDisplayedItem', SkinRewardIcon)
		else
			frame.Border:SetTexCoord(.926, 1, 0, 1)
			frame.Border:Size(25, 137)
			frame.Border:Point('LEFT', frame, 'RIGHT', 3, 0)
		end
	end

	if frame.Background then
		frame.Background:CreateBackdrop()
	end
end

function S:Blizzard_WeeklyRewards()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.weeklyRewards) then return end

	-- /run UIParent_OnEvent({}, 'WEEKLY_REWARDS_SHOW')
	local frame = _G.WeeklyRewardsFrame
	local header = frame.HeaderFrame

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
		header:StripTextures()
	end

	frame:CreateBackdrop('Transparent')
	header:CreateBackdrop('Transparent')
	header:Point('TOP', 1, -42)

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.SelectRewardButton)

	SkinActivityFrame(frame.RaidFrame)
	SkinActivityFrame(frame.MythicFrame)
	SkinActivityFrame(frame.PVPFrame)

	for _, activity in pairs(frame.Activities) do
		SkinActivityFrame(activity, true)
	end

	hooksecurefunc(frame, 'SelectReward', function(self)
		local confirmSelectionFrame = self.confirmSelectionFrame
		if confirmSelectionFrame and not confirmSelectionFrame.IsSkinned then
			local itemFrame = confirmSelectionFrame.ItemFrame
			S:HandleIcon(itemFrame.Icon, true)
			S:HandleIconBorder(itemFrame.IconBorder, itemFrame.IconBorder.backdrop)  --Monitor this

			local nameframe = _G[confirmSelectionFrame:GetName()..'NameFrame']
			if nameframe then
				nameframe:Hide()
			end

			confirmSelectionFrame.IsSkinned = true
		end
	end)
end

S:AddCallbackForAddon('Blizzard_WeeklyRewards')
