local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local ipairs, tremove = ipairs, tremove

function B:ScaleTalkingHeadFrame()
	local scale = E.db.general.talkingHeadFrameScale or 1
	local TalkingHeadFrame = _G.TalkingHeadFrame
	local width, height = TalkingHeadFrame:GetSize()
	TalkingHeadFrame.mover:Size(width * scale, height * scale)
	TalkingHeadFrame:SetScale(scale)

	--Reset Model Camera
	local model = TalkingHeadFrame.MainFrame.Model
	if model.uiCameraID then
		model:RefreshCamera()
		_G.Model_ApplyUICamera(model, model.uiCameraID)
	end

	--Use this to prevent the frame from auto closing, so you have time to test things.
	-- TalkingHeadFrame:UnregisterEvent('SOUNDKIT_FINISHED')
	-- TalkingHeadFrame:UnregisterEvent('TALKINGHEAD_CLOSE')
	-- TalkingHeadFrame:UnregisterEvent('LOADING_SCREEN_ENABLED')
end

local function InitializeTalkingHead()
	local TalkingHeadFrame = _G.TalkingHeadFrame

	--Prevent WoW from moving the frame around
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil

	--Set default position
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:Point('BOTTOM', E.UIParent, 'BOTTOM', -1, 373)

	E:CreateMover(TalkingHeadFrame, 'TalkingHeadFrameMover', L["Talking Head Frame"], nil, nil, nil, nil, nil, 'skins')

	--Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	--We do this to prevent alerts from anchoring to this frame when it is shown.
	for index, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			tremove(_G.AlertFrame.alertFrameSubSystems, index)
		end
	end
end

local function LoadTalkingHead()
	if not _G.TalkingHeadFrame then
		_G.TalkingHead_LoadUI()
	end

	InitializeTalkingHead()
	B:ScaleTalkingHeadFrame()
end

function B:PositionTalkingHead()
	if not E:IsAddOnEnabled('Blizzard_TalkingHeadUI') then return end

	-- wait until first frame, then load talking head (if it isnt yet) and spawn the mover
	E:Delay(1, LoadTalkingHead)
end
