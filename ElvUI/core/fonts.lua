--------------------------------------------------------------------------
-- overwrite font for some language, because default font are incompatible
--------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import: E - functions, constants, variables; C - config; L - locales

if E.client == "ruRU" or E.client == "RUru" then
	DB["media"].uffont_ = DB["media"].ru_uffont
	DB["media"].font_ = DB["media"].ru_font
	DB["media"].dmgfont_ = DB["media"].ru_dmgfont
elseif E.client == "zhTW" then
	DB["media"].uffont_ = DB["media"].tw_uffont
	DB["media"].font_ = DB["media"].tw_font
	DB["media"].dmgfont_ = DB["media"].tw_dmgfont
elseif E.client == "koKR" then
	DB["media"].uffont_ = DB["media"].kr_uffont
	DB["media"].font_ = DB["media"].kr_font
	DB["media"].dmgfont_ = DB["media"].kr_dmgfont
elseif E.client == "frFR" then
	DB["media"].uffont_ = DB["media"].fr_uffont
	DB["media"].font_ = DB["media"].fr_font
	DB["media"].dmgfont_ = DB["media"].fr_dmgfont
elseif E.client == "deDE" then
	DB["media"].uffont_ = DB["media"].de_uffont
	DB["media"].font_ = DB["media"].de_font
	DB["media"].dmgfont_ = DB["media"].de_dmgfont
end