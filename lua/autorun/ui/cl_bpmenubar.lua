if SERVER then AddCSLuaFile() return end

module("bpuimenubar", package.seeall, bpcommon.rescope(bpmodule, bpgraph))

local PANEL = {}

function PANEL:Init()

	self:SetBackgroundColor( Color(60,60,60) )
	self.items = {}

end

function PANEL:RunCommand( func )

	func()

end

function PANEL:Add( name, func, color, icon )

	color = color or Color(80,80,80)
	local textColor = Color(240,240,240)
	local opt = vgui.Create("DButton", self)
	local text = name
	if icon then text = "    " .. text end
	opt:SetFont("DermaDefaultBold")
	opt:SetText(text)
	opt:SizeToContentsX()
	opt:SetWide( opt:GetWide() + 10 )
	if icon then opt:SetIcon(icon) opt:SetWide( opt:GetWide() + 24 ) end
	opt:SetTall( 25 )
	opt:SetTextColor(textColor)
	opt.Paint = function(btn, w, h)
		local col = color

		if btn.Hovered then col = Color(200,100,50) end
		if btn:IsDown() then col = Color(50,170,200) end

		local bgColor = Color(col.r + 20, col.g + 20, col.b + 20)
		draw.RoundedBox( 2, 0, 0, w, h, bgColor )
		draw.RoundedBox( 2, 1, 1, w-2, h-2, col )
	end
	opt.DoClick = function(btn)
		self:RunCommand( func )
	end

	table.insert(self.items, opt)

end

function PANEL:PerformLayout()

	local x = 2
	local h = 25
	for _, item in ipairs(self.items) do
		item:SetPos(x, 2)
		x = x + item:GetWide() + 2
		h = math.max(h, item:GetTall())
	end

	self:SetTall(h + 4)

end

vgui.Register( "BPMenuBar", PANEL, "DPanel" )

function AddTo( panel )

	local menu = vgui.Create("BPMenuBar", panel)
	menu:Dock( TOP )

	return menu

end