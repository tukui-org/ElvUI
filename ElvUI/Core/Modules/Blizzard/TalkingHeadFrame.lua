local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local ipairs, tremove = ipairs, tremove

function B:ScaleTalkingHeadFrame()
	local frame = _G.TalkingHeadFrame
	frame:SetScale(E.db.general.talkingHeadFrameScale or 1)

	--Reset Model Camera
	local model = frame.MainFrame.Model
	if model.uiCameraID then
		model:RefreshCamera()

		_G.Model_ApplyUICamera(model, model.uiCameraID)
	end

	--Use this to prevent the frame from auto closing, so you have time to test things.
	-- frame:UnregisterEvent('SOUNDKIT_FINISHED')
	-- frame:UnregisterEvent('TALKINGHEAD_CLOSE')
	-- frame:UnregisterEvent('LOADING_SCREEN_ENABLED')
end

local function InitializeTalkingHead()
	--Prevent WoW from moving the frame around
	if not E.WoW10 then
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil
	end

	--Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	--We do this to prevent alerts from anchoring to this frame when it is shown.
	for index, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == _G.TalkingHeadFrame then
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
