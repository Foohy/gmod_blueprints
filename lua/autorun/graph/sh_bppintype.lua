AddCSLuaFile()

module("bppintype", package.seeall)

local meta = bpcommon.MetaTable("bppintype")
meta.__tostring = function(self)
	return self:ToString()
end

function meta:Init(type, flags, subtype)
	self.basetype = type
	self.flags = flags or bpschema.PNF_None
	self.subtype = subtype
	return self
end

function meta:AsTable()
	return New(self:GetBaseType(), bit.bor(self:GetFlags(), bpschema.PNF_Table), self:GetSubType())
end

function meta:AsSingle()
	return New(self:GetBaseType(), bit.band(self:GetFlags(), bit.bnot(bpschema.PNF_Table)), self:GetSubType())
end

function meta:WithFlags(flags)
	return New(self:GetBaseType(), flags, self:GetSubType())
end

function meta:GetBaseType() return self.basetype end
function meta:GetSubType() return self.subtype end
function meta:GetFlags(mask) return bit.band(self.flags, mask or bpschema.PNF_All) end
function meta:GetColor() return bpschema.NodePinColors[ self:GetBaseType() ] or Color(0,0,0,255) end
function meta:GetTypeName() return bpschema.PinTypeNames[ self:GetBaseType() ] or "UNKNOWN" end
function meta:GetLiteralType() return bpschema.NodeLiteralTypes[ self:GetBaseType() ] end
function meta:GetDefault()

	if self:GetBaseType() == bpschema.PN_Enum and bpdefs and bpdefs.Ready() then
		local enum = bpdefs.Get():GetEnum( self )
		if enum and enum.entries[1] then return enum.entries[1].key end
	end
	return bpschema.Defaults[ self:GetBaseType() ]

end

function meta:SetPinClass( class )

	self.pinClass = class

end

function meta:GetPinClass()

	local def = bpschema.PinTypeClasses[ self:GetBaseType() ]
	return self.pinClass or def

end

function meta:ToString()
	local str = self:GetTypeName()
	if self:GetSubType() ~= nil then str = str .. ", " .. self:GetSubType() end
	if self:HasFlag(bpschema.PNF_Table) then str = str .. " -table" end
	if self:HasFlag(bpschema.PNF_Nullable) then str = str .. " -null" end
	if self:HasFlag(bpschema.PNF_Bitfield) then str = str .. " -bitfield" end
	return str
end

function meta:IsType(base, sub)
	return self:GetBaseType() == base and (sub == nil and true or self:GetSubType() == sub)
end

function meta:HasFlag(fl)
	return bit.band(self:GetFlags(), fl) ~= 0
end

function meta:Equal(other, flagMask, ignoreSubType)
	flagMask = flagMask or bpschema.PNF_All
	if self:GetBaseType() ~= other:GetBaseType() then return false end
	if bit.band( self:GetFlags(), flagMask ) ~= bit.band( other:GetFlags(), flagMask ) then return false end
	if self:GetSubType() ~= other:GetSubType() and not ignoreSubType then return false end
	return true
end

meta.__eq = function(a, b)
	return a.basetype == b.basetype and a.flags == b.flags and a.subtype == b.subtype
end

meta.__lt = function(a, b)
	if a.basetype ~= b.basetype then return a.basetype < b.basetype end
	if a.subtype ~= b.subtype then return a.subtype < b.subtype end
	return false
end

meta.__le = function(a, b)
	if a.basetype ~= b.basetype then return a.basetype <= b.basetype end
	if a.subtype ~= b.subtype then return a.subtype <= b.subtype end
	return true
end

function meta:WriteToStream(stream)

	assert(stream:IsUsingStringTable())
	stream:WriteBits(self.basetype, 8)
	stream:WriteBits(self.flags, 8)
	stream:WriteStr(self.subtype)
	return self

end

function meta:ReadFromStream(stream)

	assert(stream:IsUsingStringTable())
	self.basetype = stream:ReadBits(8)
	self.flags = stream:ReadBits(8)
	self.subtype = stream:ReadStr()
	return self

end

function New(...) return bpcommon.MakeInstance(meta, ...) end