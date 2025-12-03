local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local ITEMQUALITY_EPIC = Enum.ItemQuality.Epic or 4

-- Credits Siweia | AuroraClassic

local function SkinRewardIcon(itemFrame)
	if not itemFrame.IsSkinned then
		local r, g, b = E:GetItemQualityColor(ITEMQUALITY_EPIC)

		itemFrame:CreateBackdrop('Transparent')
		itemFrame:DisableDrawLayer('BORDER')
		itemFrame.Icon:Point('LEFT', 6, 0)
		S:HandleIcon(itemFrame.Icon, true)
		itemFrame.backdrop:SetBackdropBorderColor(r, g, b)
		itemFrame.IsSkinned = true
	end
end

local function UpdateSelection(frame)
	if not frame.backdrop then return end

	if frame.SelectedTexture:IsShown() then
		frame.backdrop:SetBackdropBorderColor(1, 0.8, 0)
	else
		frame.backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

local function SkinActivityFrame(frame, isObject)
	if not frame then return end

	if isObject then
		if frame.Border then
			frame.Border:SetAlpha(0)
		end

		if frame.ItemFrame then
			hooksecurefunc(frame.ItemFrame, 'SetDisplayedItem', SkinRewardIcon)
		elseif frame.UnselectedFrame and E.private.skins.parchmentRemoverEnable then -- the button
			frame:CreateBackdrop('Transparent')
			frame.SelectedTexture:SetAlpha(0)
			frame.UnselectedFrame:SetAlpha(0)

			hooksecurefunc(frame, 'SetSelectionState', UpdateSelection)
		end
	else
		if frame.Border then
			frame.Border:SetTexCoord(.926, 1, 0, 1)
			frame.Border:Point('LEFT', frame, 'RIGHT', 3, 0)
			frame.Border:Size(25, 137)
		end

		if frame.Background and frame.Name then
			frame.Background:Size(390, 140) -- manually adjust it, so it don't looks ugly af
			frame.Background:SetDrawLayer('ARTWORK', 2)

			frame.Background:CreateBackdrop('Transparent')
			frame.Background.backdrop.Center:SetDrawLayer('ARTWORK', 1)
		end
	end
end

local function ReskinConfirmIcon(frame)
	S:HandleIcon(frame.Icon, true)
	S:HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
end

local function SelectReward(reward)
	local selection = reward.confirmSelectionFrame
	if selection then
		_G.WeeklyRewardsFrameNameFrame:Hide()
		ReskinConfirmIcon(selection.ItemFrame)

		local alsoItems = selection.AlsoItemsFrame
		if alsoItems and alsoItems.pool then
			for items in alsoItems.pool:EnumerateActive() do
				ReskinConfirmIcon(items)
			end
		end
	end
end

local function UpdateOverlay(frame)
	local overlay = frame.Overlay
	if overlay then
		overlay:StripTextures()
		overlay:SetTemplate()
	end
end

local function HandleWarning(frame)
	frame:SetTemplate('Transparent')
	frame.ExtraBG:Hide()
end

function S:Blizzard_WeeklyRewards()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.weeklyRewards) then return end

	-- /run UIParent_OnEvent({}, 'WEEKLY_REWARDS_SHOW')
	local frame = _G.WeeklyRewardsFrame

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
		frame:SetTemplate('Transparent')

		local header = frame.HeaderFrame
		if header then
			header:ClearAllPoints()
			header:Point('TOP', 1, -42)
			header:StripTextures()
			header:SetTemplate('Transparent')
		end

		frame.BorderContainer:StripTextures()
		frame.ConcessionFrame:StripTextures()
	end

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.SelectRewardButton)

	SkinActivityFrame(frame.RaidFrame)
	SkinActivityFrame(frame.MythicFrame)
	SkinActivityFrame(frame.PVPFrame)
	SkinActivityFrame(frame.WorldFrame)

	for _, activity in pairs(frame.Activities) do
		SkinActivityFrame(activity, true)
	end

	local rewardText = frame.ConcessionFrame.RewardsFrame.Text
	if rewardText then
		S.ReplaceIconString(rewardText)
		hooksecurefunc(rewardText, 'SetText', S.ReplaceIconString)
	end

	local warningDialog = _G.WeeklyRewardExpirationWarningDialog
	if warningDialog then -- doesn't always exist
		warningDialog:Point('TOP', frame, 'BOTTOM', 0, -1)
		warningDialog.NineSlice:HookScript('OnShow', HandleWarning)
	end

	hooksecurefunc(frame, 'SelectReward', SelectReward)
	hooksecurefunc(frame, 'UpdateOverlay', UpdateOverlay)
end

S:AddCallbackForAddon('Blizzard_WeeklyRewards')
