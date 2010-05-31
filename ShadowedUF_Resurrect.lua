--[[ 
	Shadowed Unit Frames (Resurrect), Shadow of Mal'Ganis (US) PvP
]]

local Resurrect = select(2, ...)
local L, SL = Resurrect.L, ShadowUF.L
local ResComm = LibStub("LibResComm-1.0")
local frames, resTarget = {}, {}
ShadowUF.activeRes = {}

-- Setup our custom tag, using the general tags system so if this addon is removed the tags will no longer show up as their name instead of silently breaking
ShadowUF.Tags.defaultTags["res:name"] = [[
	function(unit, unitOwner, fontString)
		local name, server = UnitName(unit)
		if( server and server ~= "" ) then
			name = string.format("%s-%s", name, server)
		end
		
		return ShadowUF.activeRes[name] and "Resurrect" or ShadowUF.tagFunc.name(unit, unitOwner, fontString)
	end
]]

ShadowUF.Tags.defaultTags["res:color"] = [[
	function(unit, unitOwner, fontString)
		local name, server = UnitName(unit)
		if( server and server ~= "" ) then
			name = string.format("%s-%s", name, server)
		end
		
		return ShadowUF.activeRes[name] and "|cffffce00" or nil
	end
]]

ShadowUF.Tags.defaultCategories["res:name"] = "raid"
ShadowUF.Tags.defaultEvents["res:name"] = "RES_STATUS"
ShadowUF.Tags.defaultNames["res:name"] = L["Name/Resurect"]
ShadowUF.Tags.defaultHelp["res:name"] = L["Returns the [name] tag if the player is not being resurrected (uses LibResCom-1.0)."]

ShadowUF.Tags.defaultCategories["res:color"] = "raid"
ShadowUF.Tags.defaultEvents["res:color"] = "RES_STATUS"
ShadowUF.Tags.defaultNames["res:color"] = L["Resurrect (Color)"]
ShadowUF.Tags.defaultHelp["res:color"] = L["Returns |cffffd0ffgold|r tag text when a player is being resurrected (uses LibResCom-1.0)."]

function Resurrect:UpdateAll()
	for frame in pairs(frames) do
		if( frame:IsVisible() ) then
			for _, fontString in pairs(frame.fontStrings) do
				fontString:UpdateTags()
			end
		end
	end
end

function Resurrect:ResStart(event, caster, endTime, target)
	if( target ) then
		ShadowUF.activeRes[target] = true
		self:UpdateAll()
		
		resTarget[caster] = target
	end
end

-- I'm not entirely sure why target can sometimes be nil, but I'll assume that it's possible for target to be nil and base it off the caster if it has to
function Resurrect:ResEnd(event, caster, target)
	if( target ) then
		ShadowUF.activeRes[target] = nil
		self:UpdateAll()
		
		resTarget[caster] = nil
	elseif( resTarget[caster] ) then
		ShadowUF.activeRes[resTarget[caster]] = nil
		resTarget[caster] = nil
		self:UpdateAll()
	end
end

-- Maintain the general list of tags that care about pvp trinkets
ShadowUF.Tags.customEvents["RES_STATUS"] = Resurrect
function Resurrect:EnableTag(frame)
	frames[frame] = true
	ResComm.RegisterCallback(self, "ResComm_ResStart", "ResStart")
	ResComm.RegisterCallback(self, "ResComm_ResEnd", "ResEnd")
end

function Resurrect:DisableTag(frame)
	frames[frame] = nil
	
	local active
	for frame in pairs(frames) do
		active = true
		break
	end

	if( not active ) then
		ResComm:UnregisterAllCallbacks(Resurrect)
	end
end
