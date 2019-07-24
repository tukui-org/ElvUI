--[[
	* Collection of functions that can be used in multiple places
]]
local E, L, V, P, G = unpack(select(2, ...))
local C_UIWidgetManager_GetStatusBarWidgetVisualizationInfo = _G.C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo
local strmatch = _G.strmatch

E.MaxNazjatarBodyguardRank = 30
function E:GetNazjatarBodyguardXP(widgetID)
	local widget = widgetID and C_UIWidgetManager_GetStatusBarWidgetVisualizationInfo(widgetID)
	if not widget then
		return
	end

	local rank = tonumber(strmatch(widget.overrideBarText, "%d+"))
	if not rank then return end
	local cur = widget.barValue - widget.barMin
	local next = widget.barMax - widget.barMin
	local total = widget.barValue
	local isMax = rank == E.MaxNazjatarBodyguardRank

	return rank, cur, next, total, isMax
end
