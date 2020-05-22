local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local tinsert, collectgarbage = tinsert, collectgarbage
local ipairs, sort, wipe, floor, format = ipairs, sort, wipe, floor, format
local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetAvailableBandwidth = GetAvailableBandwidth
local GetFileStreamingStatus = GetFileStreamingStatus
local GetBackgroundLoadingStatus = GetBackgroundLoadingStatus
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetDownloadedPercentage = GetDownloadedPercentage
local GetFramerate = GetFramerate
local GetNetIpTypes = GetNetIpTypes
local GetNetStats = GetNetStats
local GetNumAddOns = GetNumAddOns
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local IsModifierKeyDown = IsModifierKeyDown
local ResetCPUUsage = ResetCPUUsage
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local InCombatLockdown = InCombatLockdown
local UNKNOWN = UNKNOWN

local statusColors = {
	"|cff0CD809",
	"|cffE8DA0F",
	"|cffFF9000",
	"|cffD80909"
}

local enteredFrame = false
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local homeLatencyString = "%d ms"
local kiloByteString = "%d kb"
local megaByteString = "%.2f mb"
local profilingString = '%s%s|r |cffffffff/|r %s%s|r'
local totalAddOnMemory, totalCPU = 0, 0
local cpuProfiling = GetCVar("scriptProfile") == "1"

local function formatMem(memory)
	local mult = 10^1
	if memory >= 1024 then
		return format(megaByteString, ((memory/1024) * mult) / mult)
	else
		return format(kiloByteString, (memory * mult) / mult)
	end
end

local function sortByMemory(a, b)
	if a and b then
		return (a[3] == b[3] and a[2] < b[2]) or a[3] > b[3]
	end
end

local function sortByCPU(a, b)
	if a and b then
		return (a[4] == b[4] and a[2] < b[2]) or a[4] > b[4]
	end
end

local infoTable = {}

local function BuildAddonList()
	local addOnCount = GetNumAddOns()
	if (addOnCount == #infoTable) then return end

	wipe(infoTable)

	for i = 1, addOnCount do
		local _, title, _, loadable = GetAddOnInfo(i)
		if loadable then
			tinsert(infoTable, {i, title, 0, 0})
		end
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()

	totalAddOnMemory = 0

	for _, data in ipairs(infoTable) do
		if IsAddOnLoaded(data[1]) then
			local mem = GetAddOnMemoryUsage(data[1])
			data[3] = mem
			totalAddOnMemory = totalAddOnMemory + mem
		end
	end

	sort(infoTable, sortByMemory)

	return totalAddOnMemory
end

local function UpdateCPU()
	UpdateAddOnCPUUsage()

	totalCPU = 0

	for _, data in ipairs(infoTable) do
		if IsAddOnLoaded(data[1]) then
			local addonCPU = GetAddOnCPUUsage(data[1])
			data[4] = addonCPU
			totalCPU = totalCPU + addonCPU
		end
	end

	if not IsShiftKeyDown() then
		sort(infoTable, sortByCPU)
	end

	return totalCPU
end

local function Click()
	if IsModifierKeyDown() then
		collectgarbage("collect")
		ResetCPUUsage()
	end
end

local ipTypes = {"IPv4", "IPv6"}
local function OnEnter(self)
	if InCombatLockdown() then return end

	DT:SetupTooltip(self)
	enteredFrame = true
	UpdateMemory()

	local _, _, homePing, worldPing = GetNetStats()
	DT.tooltip:AddDoubleLine(L["Home Latency:"], format(homeLatencyString, homePing), .69, .31, .31, .84, .75, .65)
	DT.tooltip:AddDoubleLine(L["World Latency:"], format(homeLatencyString, worldPing), .69, .31, .31, .84, .75, .65)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		DT.tooltip:AddDoubleLine(L["Home Protocol:"], ipTypes[ipTypeHome or 0] or UNKNOWN, .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["World Protocol:"], ipTypes[ipTypeWorld or 0] or UNKNOWN, .69, .31, .31, .84, .75, .65)
	end

	local Downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if Downloading then
		DT.tooltip:AddDoubleLine(L["Bandwidth"] , format(bandwidthString, GetAvailableBandwidth()), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["Download"] , format(percentageString, GetDownloadedPercentage() * 100), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddLine(" ")
	end

	DT.tooltip:AddDoubleLine(L["AddOn Memory:"], formatMem(totalAddOnMemory), .69, .31, .31, .84, .75, .65)

	if cpuProfiling then
		totalCPU = UpdateCPU()
		DT.tooltip:AddDoubleLine(L["Total CPU:"], format(homeLatencyString, totalCPU), .69, .31, .31, .84, .75, .65)
	end

	DT.tooltip:AddLine(" ")

	if IsShiftKeyDown() or not cpuProfiling then
		for _, data in ipairs(infoTable) do
			if IsAddOnLoaded(data[1]) then
				local red = data[3] / totalAddOnMemory
				local green = (1 - red) + .5
				DT.tooltip:AddDoubleLine(data[2], formatMem(data[3]), 1, 1, 1, red, green, 0)
			end
		end
		DT.tooltip:AddLine(" ")
	else
		for _, data in ipairs(infoTable) do
			if IsAddOnLoaded(data[1]) then
				local mem, cpu = data[3], data[4]
				local memRed, cpuRed = mem / totalAddOnMemory, cpu / totalCPU
				local memGreen, cpuGreen = (1 - memRed) + .5, (1 - cpuRed) + .5
				DT.tooltip:AddDoubleLine(data[2], format(profilingString, E:RGBToHex(memRed, memGreen, 0), formatMem(mem), E:RGBToHex(cpuRed, cpuGreen, 0), format(homeLatencyString, data[4])), 1, 1, 1)
			end
		end

		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(L["(Hold Shift) Memory Usage"])
	end

	DT.tooltip:AddLine(L["(Modifer Click) Collect Garbage"])
	DT.tooltip:Show()
end

local function OnLeave()
	enteredFrame = false
	DT.tooltip:Hide()
end

local wait = 6 -- initial delay for update (let the ui load)
local function Update(self, elapsed)
	wait = wait - elapsed

	if wait < 0 then
		wait = 1

		local framerate = floor(GetFramerate())
		local _, _, _, latency = GetNetStats()

		local fps = framerate >= 30 and 1 or (framerate >= 20 and framerate < 30) and 2 or (framerate >= 10 and framerate < 20) and 3 or 4
		local ping = latency < 150 and 1 or (latency >= 150 and latency < 300) and 2 or (latency >= 300 and latency < 500) and 3 or 4
		self.text:SetFormattedText("FPS: %s%d|r MS: %s%d|r", statusColors[fps], framerate, statusColors[ping], latency)

		if enteredFrame then
			OnEnter(self)
		end
	end
end

DT:RegisterDatatext('System', nil, nil, BuildAddonList, Update, Click, OnEnter, OnLeave, L["System"])
