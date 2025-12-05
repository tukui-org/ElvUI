local E, L, V, P, G = unpack(ElvUI)
local AFK = E:GetModule('AFK')
local CH = E:GetModule('Chat')

local _G = _G
local floor = floor
local tostring, pcall = tostring, pcall
local unpack, strupper = unpack, strupper
local format, strsub, gsub = format, strsub, gsub
local issecretvalue = issecretvalue

local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetGuildInfo = GetGuildInfo
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local UIParent = UIParent
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK

local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle

local CAMERA_SPEED = 0.035
local DEFAULT_ANIMATION = 'dance'

local animations = {
	wave = { name = L["Wave"], id = 67, facing = 6, wait = 40, offsetX = -200, offsetY = 220, duration = 2.3 }, -- start animation
	lean = { name = L["Lean"], id = 1260, facing = 5.8, wait = 10, offsetX = -100, offsetY = 220, duration = 600 },
	dance = { name = L["Dance"], id = 69, facing = 6, wait = 30, offsetX = -200, offsetY = 220, duration = 300 },
	salute = { name = L["Salute"], id = 113, facing = 6, wait = 30, offsetX = -200, offsetY = 220, duration = 5 },
	talk = { name = L["Talk"], id = 60, facing = 6.2, wait = 15, offsetX = -200, offsetY = 220, duration = 10 },
	shy = { name = L["Shy"], id = 83, facing = 6.2, wait = 30, offsetX = -200, offsetY = 220, duration = 10 },
	roar = { name = L["Roar"], id = 74, facing = 6, wait = 30, offsetX = -200, offsetY = 220, duration = 5 }
}

local ignoreKeys = { LALT = true, LSHIFT = true, RSHIFT = true }
local printKeys = { PRINTSCREEN = true }

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

-- create these early and set the chat as moveable so the drag sticks
local afk = CreateFrame('Frame', 'ElvUIAFKFrame')
local chat = CreateFrame('ScrollingMessageFrame', 'ElvUIAFKChat', afk)
local bottom = CreateFrame('Frame', nil, afk)
chat:UnregisterAllEvents()
chat:SetMovable(true)

AFK.AFKMode = afk
afk.chat = chat
afk.bottom = bottom

function AFK:UpdateTimer()
	local time = GetTime() - AFK.startTime
	bottom.time:SetFormattedText('%02d:%02d', floor(time/60), time % 60)
end

function AFK:CameraSpin(status)
	if status and E.db.general.afkSpin then
		MoveViewLeftStart(CAMERA_SPEED)
	else
		MoveViewLeftStop()
	end
end

function AFK:GetAnimation(key)
	if not key then key = E.db.general.afkAnimation end -- check selected animation
	if key == 'lean' and not E.Retail then key = nil end -- lean dont exist outside of retail

	local animation = key or DEFAULT_ANIMATION
	return animations[animation], animation
end

function AFK:SetAnimation(key)
	local options = AFK:GetAnimation(key)

	local model = bottom.model
	model.curAnimation = key
	model.duration = options.duration
	model.idleDuration = options.wait
	model.startTime = GetTime()
	model.isIdle = nil

	model:SetFacing(options.facing)
	model:SetAnimation(options.id)

	if bottom.modelHolder then
		bottom.modelHolder:ClearAllPoints()
		bottom.modelHolder:Point('BOTTOMRIGHT', bottom, options.offsetX, options.offsetY)
	end
end

function AFK:SetAFK(status)
	if status then
		AFK:CameraSpin(status)

		CloseAllWindows()

		afk:Show()
		UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo('player')
			bottom.guild:SetFormattedText('%s-%s', guildName, guildRankName)
		else
			bottom.guild:SetText(L["No Guild"])
		end

		AFK:SetAnimation('wave')

		AFK.startTime = GetTime()
		AFK.timer = AFK:ScheduleRepeatingTimer('UpdateTimer', 1)

		bottom.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))
		chat:RegisterEvent('CHAT_MSG_WHISPER')
		chat:RegisterEvent('CHAT_MSG_BN_WHISPER')
		chat:RegisterEvent('CHAT_MSG_GUILD')

		AFK.isAFK = true
	elseif AFK.isAFK then
		UIParent:Show()
		afk:Hide()

		AFK:CameraSpin()
		AFK:CancelTimer(AFK.timer)
		AFK:CancelTimer(AFK.animTimer)

		bottom.time:SetText('00:00')
		chat:UnregisterAllEvents()
		chat:Clear()

		if E.Retail and _G.PVEFrame:IsShown() then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		AFK.isAFK = false
	end
end

function AFK:OnEvent(event, arg1)
	if event == 'PLAYER_REGEN_ENABLED' then
		AFK:UnregisterEvent(event)
	elseif event == 'UPDATE_BATTLEFIELD_STATUS' or event == 'PLAYER_REGEN_DISABLED' or event == 'LFG_PROPOSAL_SHOW' then
		if event ~= 'UPDATE_BATTLEFIELD_STATUS' or (GetBattlefieldStatus(arg1) == 'confirm') then
			AFK:SetAFK(false)
		end

		if event == 'PLAYER_REGEN_DISABLED' then
			AFK:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnEvent')
		end

		return
	elseif (not E.db.general.afk) or (event == 'PLAYER_FLAGS_CHANGED' and arg1 ~= 'player') or (InCombatLockdown() or _G.CinematicFrame:IsShown() or _G.MovieFrame:IsShown()) then
		return
	elseif UnitCastingInfo('player') then
		AFK:ScheduleTimer('OnEvent', 30)
		return -- Don't activate afk if player is crafting stuff, check back in 30 seconds
	end

	AFK:SetAFK(UnitIsAFK('player') and not ((E.Retail or E.Mists) and C_PetBattles_IsInBattle()))
end

function AFK:Chat_OnMouseWheel(delta)
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

function AFK:HandleShortChannels(msg)
	msg = gsub(msg, '|Hchannel:(.-)|h%[(.-)%]|h', CH.ShortChannel)
	msg = gsub(msg, '^(.-|h) '..L["whispers"], '%1')
	msg = gsub(msg, '<'.._G.AFK..'>', '[|cffFF9900'..L["AFK"]..'|r] ')
	msg = gsub(msg, '<'.._G.DND..'>', '[|cffFF3333'..L["DND"]..'|r] ')
	msg = gsub(msg, '^%['.._G.RAID_WARNING..'%]', '['..L["RW"]..']')
	msg = gsub(msg, '%[BN_CONVERSATION:', '%[')

	return msg
end

function AFK:Chat_OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local infoType = strsub(event, 10)
	local info = _G.ChatTypeInfo[infoType]

	local GetChatCategory = _G.ChatFrameUtil and _G.ChatFrameUtil.GetChatCategory or _G.Chat_GetChatCategory

	local chatTarget
	local chatGroup = GetChatCategory(infoType)
	if chatGroup == 'BN_CONVERSATION' then
		chatTarget = tostring(arg8)
	elseif chatGroup == 'WHISPER' or chatGroup == 'BN_WHISPER' then
		chatTarget = (not issecretvalue or not issecretvalue(arg2)) and strsub(arg2, 1, 2) ~= '|K' and strupper(arg2) or arg2
	end

	local playerLink
	local linkTarget = chatTarget and (':'..chatTarget) or ''
	if infoType ~= 'BN_WHISPER' and infoType ~= 'BN_CONVERSATION' then
		playerLink = format('|Hplayer:%s:%s:%s%s|h', arg2, arg11, chatGroup, linkTarget)
	else
		playerLink = format('|HBNplayer:%s:%s:%s:%s%s|h', arg2, arg13, arg11, chatGroup, linkTarget)
	end

	local isProtected = CH:MessageIsProtected(arg1)
	if not isProtected then
		arg1 = gsub(arg1, '%%', '%%%%') -- Escape any % characters, as it may otherwise cause an 'invalid option in format' error
		arg1 = RemoveExtraSpaces(arg1) -- Remove groups of many spaces
	end

	local isMobile = arg14 and _G.ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)
	local message = format('%s%s', isMobile or '', arg1)

	local coloredName = (infoType == 'BN_WHISPER' and CH:GetBNFriendColor(arg2, arg13)) or CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local senderLink = format('%s[%s]|h', playerLink, coloredName)
	local success, msg = pcall(format, _G['CHAT_'..infoType..'_GET']..'%s', senderLink, message)
	if not success then return end

	if not isProtected and CH.db.shortChannels then
		msg = AFK:HandleShortChannels(msg)
	end

	local accessID = CH:GetAccessID(chatGroup, chatTarget)
	local typeID = CH:GetAccessID(infoType, chatTarget, arg12 or arg13)
	self:AddMessage(msg, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

function AFK:Toggle()
	if E.db.general.afk then
		AFK:RegisterEvent('PLAYER_FLAGS_CHANGED', 'OnEvent')
		AFK:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEvent')
		AFK:RegisterEvent('LFG_PROPOSAL_SHOW', 'OnEvent')
		AFK:RegisterEvent('UPDATE_BATTLEFIELD_STATUS', 'OnEvent')

		E:SetCVar('autoClearAFK', 1)
	else
		AFK:UnregisterEvent('PLAYER_FLAGS_CHANGED')
		AFK:UnregisterEvent('PLAYER_REGEN_DISABLED')
		AFK:UnregisterEvent('LFG_PROPOSAL_SHOW')
		AFK:UnregisterEvent('UPDATE_BATTLEFIELD_STATUS')
	end

	if E.db.general.afkChat then
		chat:SetScript('OnEvent', AFK.Chat_OnEvent)
	else
		chat:SetScript('OnEvent', nil)
		chat:Clear()
	end
end

function AFK:ResetChatPosition(force)
	if force then
		chat:SetUserPlaced(false)
	end

	if not chat:IsUserPlaced() then
		chat:ClearAllPoints()
		chat:Point('TOPLEFT', afk, 4, -4)
	end
end

function AFK:OnKeyDown(key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	elseif AFK.isAFK then
		AFK:SetAFK(false)
		AFK:ScheduleTimer('OnEvent', 60)
	end
end

function AFK:Model_OnUpdate()
	if self.isIdle then return end

	local timePassed = GetTime() - self.startTime
	if timePassed >= self.duration then
		self:SetAnimation(0)
		self.isIdle = true

		AFK.animTimer = AFK:ScheduleTimer('SetAnimation', self.idleDuration)
	end
end

function AFK:Initialize()
	AFK.Initialized = true

	afk:SetFrameLevel(1)
	afk:SetScale(E.uiscale)
	afk:SetAllPoints(UIParent)
	afk:EnableKeyboard(true)
	afk:SetScript('OnKeyDown', AFK.OnKeyDown)
	afk:Hide()

	chat:Size(500, 200)
	chat:FontTemplate()
	chat:SetJustifyH('LEFT')
	chat:SetMaxLines(500)
	chat:EnableMouseWheel(true)
	chat:SetFading(false)
	chat:EnableMouse(true)
	chat:RegisterForDrag('LeftButton')
	chat:SetScript('OnDragStart', chat.StartMoving)
	chat:SetScript('OnDragStop', chat.StopMovingOrSizing)
	chat:SetScript('OnMouseWheel', AFK.Chat_OnMouseWheel)
	AFK:ResetChatPosition()

	bottom:SetFrameLevel(0)
	bottom:SetTemplate('Transparent')
	bottom:Point('BOTTOM', afk, 0, -E.Border)
	bottom:Width(E.screenWidth + (E.Border*2))
	bottom:Height(E.screenHeight * 0.10)

	local logoTop = afk:CreateTexture(nil, 'OVERLAY')
	logoTop:Size(320, 150)
	logoTop:Point('CENTER', bottom, 0, 50)
	logoTop:SetTexture(E.Media.Textures.LogoTop)
	bottom.LogoTop = logoTop

	local logoBottom = afk:CreateTexture(nil, 'OVERLAY')
	logoBottom:Size(320, 150)
	logoBottom:Point('CENTER', bottom, 0, 50)
	logoBottom:SetTexture(E.Media.Textures.LogoBottom)
	bottom.LogoBottom = logoBottom

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = E.myfaction, 140, -20, -16, -10, -28
	if factionGroup == 'Neutral' then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = 'Panda', 90, 15, 10, 20, -5
	end

	local faction = bottom:CreateTexture(nil, 'OVERLAY')
	faction:Point('BOTTOMLEFT', bottom, offsetX, offsetY)
	faction:SetTexture(format([[Interface\Timer\%s-Logo]], factionGroup))
	faction:Size(size, size)
	bottom.faction = faction

	local classColor = E.myClassColor
	local name = bottom:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, 20)
	name:SetFormattedText('%s-%s', E.myname, E.myrealm)
	name:Point('TOPLEFT', bottom.faction, 'TOPRIGHT', nameOffsetX, nameOffsetY)
	name:SetTextColor(classColor.r, classColor.g, classColor.b)
	bottom.name = name

	local guild = bottom:CreateFontString(nil, 'OVERLAY')
	guild:FontTemplate(nil, 20)
	guild:SetText(L["No Guild"])
	guild:Point('TOPLEFT', bottom.name, 'BOTTOMLEFT', 0, -6)
	guild:SetTextColor(0.7, 0.7, 0.7)
	bottom.guild = guild

	local afkTime = bottom:CreateFontString(nil, 'OVERLAY')
	afkTime:FontTemplate(nil, 20)
	afkTime:SetText('00:00')
	afkTime:Point('TOPLEFT', bottom.guild, 'BOTTOMLEFT', 0, -6)
	afkTime:SetTextColor(0.7, 0.7, 0.7)
	bottom.time = afkTime

	--Use this frame to control position of the model
	local holder = CreateFrame('Frame', nil, bottom)
	holder:Size(150)

	local model = CreateFrame('PlayerModel', 'ElvUIAFKPlayerModel', holder)
	model:Point('CENTER', holder)
	model:Size(E.screenWidth * 2, E.screenHeight * 2) --YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	model:SetCamDistanceScale(4.5) --Since the model frame is huge, we need to zoom out quite a bit.
	model:SetUnit('player')
	model:SetScript('OnUpdate', AFK.Model_OnUpdate)
	bottom.model = model
	bottom.modelHolder = holder

	AFK:Toggle()

	AFK.isActive = false
end

E:RegisterModule(AFK:GetName())
