local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AFK = E:GetModule('AFK')
local CH = E:GetModule('Chat')

local _G = _G
local floor = floor
local unpack = unpack
local tostring, pcall = tostring, pcall
local format, strsub, gsub = format, strsub, gsub

local Chat_GetChatCategory = Chat_GetChatCategory
local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK
local CinematicFrame = CinematicFrame
local MovieFrame = MovieFrame
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local DNDstr = _G.DND
local AFKstr = _G.AFK

local CAMERA_SPEED = 0.035
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}
local printKeys = {
	PRINTSCREEN = true,
}

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime
	AFK.AFKMode.bottom.time:SetFormattedText('%02d:%02d', floor(time/60), time % 60)
end

function AFK:SetAFK(status)
	if status then
		MoveViewLeftStart(CAMERA_SPEED)
		AFK.AFKMode:Show()
		CloseAllWindows()
		_G.UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo('player')
			AFK.AFKMode.bottom.guild:SetFormattedText('%s-%s', guildName, guildRankName)
		else
			AFK.AFKMode.bottom.guild:SetText(L["No Guild"])
		end

		AFK.AFKMode.bottom.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))
		AFK.AFKMode.bottom.model.curAnimation = 'wave'
		AFK.AFKMode.bottom.model.startTime = GetTime()
		AFK.AFKMode.bottom.model.duration = 2.3
		AFK.AFKMode.bottom.model:SetUnit('player')
		AFK.AFKMode.bottom.model.isIdle = nil
		AFK.AFKMode.bottom.model:SetAnimation(67)
		AFK.AFKMode.bottom.model.idleDuration = 40
		AFK.startTime = GetTime()
		AFK.timer = AFK:ScheduleRepeatingTimer('UpdateTimer', 1)

		AFK.AFKMode.chat:RegisterEvent('CHAT_MSG_WHISPER')
		AFK.AFKMode.chat:RegisterEvent('CHAT_MSG_BN_WHISPER')
		AFK.AFKMode.chat:RegisterEvent('CHAT_MSG_GUILD')

		AFK.isAFK = true
	elseif AFK.isAFK then
		_G.UIParent:Show()
		AFK.AFKMode:Hide()
		MoveViewLeftStop()

		AFK:CancelTimer(AFK.timer)
		AFK:CancelTimer(AFK.animTimer)
		AFK.AFKMode.bottom.time:SetText('00:00')

		AFK.AFKMode.chat:UnregisterAllEvents()
		AFK.AFKMode.chat:Clear()

		if _G.PVEFrame:IsShown() then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		AFK.isAFK = false
	end
end

function AFK:OnEvent(event, ...)
	if event == 'PLAYER_REGEN_DISABLED' or event == 'LFG_PROPOSAL_SHOW' or event == 'UPDATE_BATTLEFIELD_STATUS' then
		if event ~= 'UPDATE_BATTLEFIELD_STATUS' or (GetBattlefieldStatus(...) == 'confirm') then
			AFK:SetAFK(false)
		end

		if event == 'PLAYER_REGEN_DISABLED' then
			AFK:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnEvent')
		end

		return
	end

	if event == 'PLAYER_REGEN_ENABLED' then
		AFK:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end

	if not E.db.general.afk or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end

	if UnitCastingInfo('player') then --Don't activate afk if player is crafting stuff, check back in 30 seconds
		AFK:ScheduleTimer('OnEvent', 30)
		return
	end

	AFK:SetAFK(UnitIsAFK('player') and not C_PetBattles_IsInBattle())
end

function AFK:Toggle()
	if E.db.general.afk then
		AFK:RegisterEvent('PLAYER_FLAGS_CHANGED', 'OnEvent')
		AFK:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEvent')
		AFK:RegisterEvent('LFG_PROPOSAL_SHOW', 'OnEvent')
		AFK:RegisterEvent('UPDATE_BATTLEFIELD_STATUS', 'OnEvent')
		SetCVar('autoClearAFK', '1')
	else
		AFK:UnregisterEvent('PLAYER_FLAGS_CHANGED')
		AFK:UnregisterEvent('PLAYER_REGEN_DISABLED')
		AFK:UnregisterEvent('LFG_PROPOSAL_SHOW')
		AFK:UnregisterEvent('UPDATE_BATTLEFIELD_STATUS')
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer('OnEvent', 60)
	end
end

local function Chat_OnMouseWheel(self, delta)
	if delta == 1 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	elseif delta == -1 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	end
end

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local type = strsub(event, 10)
	local info = _G.ChatTypeInfo[type]

	local coloredName
	if event == 'CHAT_MSG_BN_WHISPER' then
		coloredName = CH:GetBNFriendColor(arg2, arg13)
	else
		coloredName = CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	end

	arg1 = RemoveExtraSpaces(arg1)

	local chatTarget, body
	local chatGroup = Chat_GetChatCategory(type)
	if chatGroup == 'BN_CONVERSATION' then
		chatTarget = tostring(arg8)
	elseif chatGroup == 'WHISPER' or chatGroup == 'BN_WHISPER' then
		if not(strsub(arg2, 1, 2) == '|K') then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2
		end
	end

	local playerLink
	if type ~= 'BN_WHISPER' and type ~= 'BN_CONVERSATION' then
		playerLink = '|Hplayer:'..arg2..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h'
	else
		playerLink = '|HBNplayer:'..arg2..':'..arg13..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h'
	end

	local message = arg1
	if arg14 then --isMobile
		message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message
	end

	--Escape any % characters, as it may otherwise cause an 'invalid option in format' error in the next step
	message = gsub(message, '%%', '%%%%')

	local success
	success, body = pcall(format, _G['CHAT_'..type..'_GET']..message, playerLink..'['..coloredName..']'..'|h')
	if not success then
		E:Print('An error happened in the AFK Chat module. Please screenshot this message and report it. Info:', type, message, _G['CHAT_'..type..'_GET'])
	end

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
	local typeID = ChatHistory_GetAccessID(type, chatTarget, arg12 == '' and arg13 or arg12)
	if CH.db.shortChannels then
		body = body:gsub('|Hchannel:(.-)|h%[(.-)%]|h', CH.ShortChannel)
		body = body:gsub('^(.-|h) '..L["whispers"], '%1')
		body = body:gsub('<'..AFKstr..'>', '[|cffFF0000'..L["AFK"]..'|r] ')
		body = body:gsub('<'..DNDstr..'>', '[|cffE7E716'..L["DND"]..'|r] ')
		body = body:gsub('%[BN_CONVERSATION:', '%['..'')
	end

	self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

function AFK:LoopAnimations()
	local ElvUIAFKPlayerModel = _G.ElvUIAFKPlayerModel
	if ElvUIAFKPlayerModel.curAnimation == 'wave' then
		ElvUIAFKPlayerModel:SetAnimation(69)
		ElvUIAFKPlayerModel.curAnimation = 'dance'
		ElvUIAFKPlayerModel.startTime = GetTime()
		ElvUIAFKPlayerModel.duration = 300
		ElvUIAFKPlayerModel.isIdle = false
		ElvUIAFKPlayerModel.idleDuration = 120
	end
end

function AFK:Initialize()
	AFK.Initialized = true

	AFK.AFKMode = CreateFrame('Frame', 'ElvUIAFKFrame')
	AFK.AFKMode:SetFrameLevel(1)
	AFK.AFKMode:SetScale(_G.UIParent:GetScale())
	AFK.AFKMode:SetAllPoints(_G.UIParent)
	AFK.AFKMode:Hide()
	AFK.AFKMode:EnableKeyboard(true)
	AFK.AFKMode:SetScript('OnKeyDown', OnKeyDown)

	AFK.AFKMode.chat = CreateFrame('ScrollingMessageFrame', nil, AFK.AFKMode)
	AFK.AFKMode.chat:Size(500, 200)
	AFK.AFKMode.chat:Point('TOPLEFT', AFK.AFKMode, 'TOPLEFT', 4, -4)
	AFK.AFKMode.chat:FontTemplate()
	AFK.AFKMode.chat:SetJustifyH('LEFT')
	AFK.AFKMode.chat:SetMaxLines(500)
	AFK.AFKMode.chat:EnableMouseWheel(true)
	AFK.AFKMode.chat:SetFading(false)
	AFK.AFKMode.chat:SetMovable(true)
	AFK.AFKMode.chat:EnableMouse(true)
	AFK.AFKMode.chat:RegisterForDrag('LeftButton')
	AFK.AFKMode.chat:SetScript('OnDragStart', AFK.AFKMode.chat.StartMoving)
	AFK.AFKMode.chat:SetScript('OnDragStop', AFK.AFKMode.chat.StopMovingOrSizing)
	AFK.AFKMode.chat:SetScript('OnMouseWheel', Chat_OnMouseWheel)
	AFK.AFKMode.chat:SetScript('OnEvent', Chat_OnEvent)

	AFK.AFKMode.bottom = CreateFrame('Frame', nil, AFK.AFKMode)
	AFK.AFKMode.bottom:SetFrameLevel(0)
	AFK.AFKMode.bottom:SetTemplate('Transparent')
	AFK.AFKMode.bottom:Point('BOTTOM', AFK.AFKMode, 'BOTTOM', 0, -E.Border)
	AFK.AFKMode.bottom:Width(GetScreenWidth() + (E.Border*2))
	AFK.AFKMode.bottom:Height(GetScreenHeight() * (1 / 10))

	AFK.AFKMode.bottom.LogoTop = AFK.AFKMode:CreateTexture(nil, 'OVERLAY')
	AFK.AFKMode.bottom.LogoTop:Size(320, 150)
	AFK.AFKMode.bottom.LogoTop:Point('CENTER', AFK.AFKMode.bottom, 'CENTER', 0, 50)
	AFK.AFKMode.bottom.LogoTop:SetTexture(E.Media.Textures.LogoTop)

	AFK.AFKMode.bottom.LogoBottom = AFK.AFKMode:CreateTexture(nil, 'OVERLAY')
	AFK.AFKMode.bottom.LogoBottom:Size(320, 150)
	AFK.AFKMode.bottom.LogoBottom:Point('CENTER', AFK.AFKMode.bottom, 'CENTER', 0, 50)
	AFK.AFKMode.bottom.LogoBottom:SetTexture(E.Media.Textures.LogoBottom)

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = E.myfaction, 140, -20, -16, -10, -28
	if factionGroup == 'Neutral' then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = 'Panda', 90, 15, 10, 20, -5
	end

	AFK.AFKMode.bottom.faction = AFK.AFKMode.bottom:CreateTexture(nil, 'OVERLAY')
	AFK.AFKMode.bottom.faction:Point('BOTTOMLEFT', AFK.AFKMode.bottom, 'BOTTOMLEFT', offsetX, offsetY)
	AFK.AFKMode.bottom.faction:SetTexture(format([[Interface\Timer\%s-Logo]], factionGroup))
	AFK.AFKMode.bottom.faction:Size(size, size)

	local classColor = E:ClassColor(E.myclass)
	AFK.AFKMode.bottom.name = AFK.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.bottom.name:FontTemplate(nil, 20)
	AFK.AFKMode.bottom.name:SetFormattedText('%s-%s', E.myname, E.myrealm)
	AFK.AFKMode.bottom.name:Point('TOPLEFT', AFK.AFKMode.bottom.faction, 'TOPRIGHT', nameOffsetX, nameOffsetY)
	AFK.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	AFK.AFKMode.bottom.guild = AFK.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.bottom.guild:FontTemplate(nil, 20)
	AFK.AFKMode.bottom.guild:SetText(L["No Guild"])
	AFK.AFKMode.bottom.guild:Point('TOPLEFT', AFK.AFKMode.bottom.name, 'BOTTOMLEFT', 0, -6)
	AFK.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	AFK.AFKMode.bottom.time = AFK.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.bottom.time:FontTemplate(nil, 20)
	AFK.AFKMode.bottom.time:SetText('00:00')
	AFK.AFKMode.bottom.time:Point('TOPLEFT', AFK.AFKMode.bottom.guild, 'BOTTOMLEFT', 0, -6)
	AFK.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	--Use this frame to control position of the model
	AFK.AFKMode.bottom.modelHolder = CreateFrame('Frame', nil, AFK.AFKMode.bottom)
	AFK.AFKMode.bottom.modelHolder:Size(150, 150)
	AFK.AFKMode.bottom.modelHolder:Point('BOTTOMRIGHT', AFK.AFKMode.bottom, 'BOTTOMRIGHT', -200, 220)

	AFK.AFKMode.bottom.model = CreateFrame('PlayerModel', 'ElvUIAFKPlayerModel', AFK.AFKMode.bottom.modelHolder)
	AFK.AFKMode.bottom.model:Point('CENTER', AFK.AFKMode.bottom.modelHolder, 'CENTER')
	AFK.AFKMode.bottom.model:Size(GetScreenWidth() * 2, GetScreenHeight() * 2) --YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	AFK.AFKMode.bottom.model:SetCamDistanceScale(4.5) --Since the model frame is huge, we need to zoom out quite a bit.
	AFK.AFKMode.bottom.model:SetFacing(6)
	AFK.AFKMode.bottom.model:SetScript('OnUpdate', function(model)
		if not model.isIdle then
			local timePassed = GetTime() - model.startTime
			if timePassed > model.duration then
				model:SetAnimation(0)
				model.isIdle = true
				AFK.animTimer = AFK:ScheduleTimer('LoopAnimations', model.idleDuration)
			end
		end
	end)

	AFK:Toggle()
	AFK.isActive = false
end

E:RegisterModule(AFK:GetName())
