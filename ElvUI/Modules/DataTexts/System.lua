local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local select, collectgarbage = select, collectgarbage
local sort, wipe, floor, format = sort, wipe, floor, format
local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetAvailableBandwidth = GetAvailableBandwidth
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

local function formatMem(memory)
	local mult = 10^1
	if memory > 999 then
		return format(megaByteString, ((memory/1024) * mult) / mult)
	else
		return format(kiloByteString, (memory * mult) / mult)
	end
end

local function sortByMemoryOrCPU(a, b)
	if a and b then
		return (a[3] == b[3] and a[2] < b[2]) or a[3] > b[3]
	end
end

local cpuTable = {}
local memoryTable = {}
local function RebuildAddonList()
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) then return end

	-- Number of loaded addons changed, create new memoryTable for all addons
	wipe(memoryTable)
	wipe(cpuTable)

	for i = 1, addOnCount do
		memoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
		cpuTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
	end
end

local function UpdateMemory()
	-- Update the memory usages of the addons
	UpdateAddOnMemoryUsage()

	-- Load memory usage in table
	local totalMemory = 0
	for _, data in ipairs(memoryTable) do
		data[3] = GetAddOnMemoryUsage(data[1])
		totalMemory = totalMemory + data[3]
	end

	-- Sort the table to put the largest addon on top
	sort(memoryTable, sortByMemoryOrCPU)

	return totalMemory
end

local function UpdateCPU()
	--Update the CPU usages of the addons
	UpdateAddOnCPUUsage()

	-- Load cpu usage in table
	local totalCPU = 0
	for _, data in ipairs(cpuTable) do
		local addonCPU = GetAddOnCPUUsage(data[1])
		data[3] = addonCPU
		totalCPU = totalCPU + addonCPU
	end

	-- Sort the table to put the largest addon on top
	sort(cpuTable, sortByMemoryOrCPU)

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
	DT:SetupTooltip(self)
	enteredFrame = true

	local _, _, homePing, worldPing = GetNetStats()
	DT.tooltip:AddDoubleLine(L["Home Latency:"], format(homeLatencyString, homePing), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	DT.tooltip:AddDoubleLine(L["World Latency:"], format(homeLatencyString, worldPing), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		DT.tooltip:AddDoubleLine(L["Home Protocol:"], ipTypes[ipTypeHome or 0] or UNKNOWN, 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		DT.tooltip:AddDoubleLine(L["World Protocol:"], ipTypes[ipTypeWorld or 0] or UNKNOWN, 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	end

	local bandwidth = GetAvailableBandwidth()
	if bandwidth ~= 0 then
		DT.tooltip:AddDoubleLine(L["Bandwidth"] , format(bandwidthString, bandwidth),0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		DT.tooltip:AddDoubleLine(L["Download"] , format(percentageString, GetDownloadedPercentage() * 100),0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
		DT.tooltip:AddLine(" ")
	end

	local totalCPU
	local totalMemory = UpdateMemory()
	local cpuProfiling = GetCVar("scriptProfile") == "1"
	DT.tooltip:AddDoubleLine(L["Total Memory:"], formatMem(totalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	if cpuProfiling then
		totalCPU = UpdateCPU()
		DT.tooltip:AddDoubleLine(L["Total CPU:"], format(homeLatencyString, totalCPU), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	end

	DT.tooltip:AddLine(" ")
	if IsShiftKeyDown() or not cpuProfiling then
		for _, data in ipairs(memoryTable) do
			if IsAddOnLoaded(data[1]) then
				local red = data[3] / totalMemory
				local green = (1 - red) + .5
				DT.tooltip:AddDoubleLine(data[2], formatMem(data[3]), 1, 1, 1, red, green, 0)
			end
		end
	else
		for _, data in ipairs(cpuTable) do
			if IsAddOnLoaded(data[1]) then
				local red = data[3] / totalCPU
				local green = (1 - red) + .5
				DT.tooltip:AddDoubleLine(data[2], format(homeLatencyString, data[3]), 1, 1, 1, red, green, 0)
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

DT:RegisterDatatext('System', nil, { 'ADDON_LOADED' }, RebuildAddonList, Update, Click, OnEnter, OnLeave, L["System"])
