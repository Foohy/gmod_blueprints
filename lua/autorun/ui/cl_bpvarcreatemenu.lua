if SERVER then AddCSLuaFile() return end

module("bpuivarcreatemenu", package.seeall, bpcommon.rescope(bpschema))


local PANEL = {}

function PANEL:Init()

end

vgui.Register( "BPVarCreateMenu", PANEL, "EditablePanel" )

function RequestVarSpec( module, callback, parent )

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "Create Variable" )
	Window:SetDraggable( true )
	Window:ShowCloseButton( true )

	--Window:SetBackgroundBlur( true )
	--Window:SetDrawOnTop( true )

	local Combo = vgui.Create("DComboBox", Window )
	local TableOption = vgui.Create("DCheckBoxLabel", Window)
	local NameEntry = vgui.Create("DTextEntry", Window )

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetPaintBackground( true )

	local function DoClose()
		if IsValid(parent) then parent:MoveToFront() end
		Window:Close()
	end

	Window.OnFocusChanged = function(self, gained)
		timer.Simple(.1, function()
			if not (gained or vgui.FocusedHasParent(Window)) then
				if IsValid(Window) then DoClose() end
			end
		end)
	end

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( "OK" )
	Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function()

		local name = NameEntry:GetText()
		local text, data = Combo:GetSelected()
		local flags = 0
		local type = data[1]
		local ex = data[2]

		if TableOption:GetChecked() then flags = bit.bor( flags, PNF_Table ) end

		callback( name, type, flags, ex )

		DoClose()
	end

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( "Cancel" )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() DoClose() end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local blackList = {
		[PN_Exec] = true,
		[PN_Bool] = false,
		[PN_Vector] = false,
		[PN_Number] = false,
		[PN_Any] = true,
		[PN_String] = false,
		[PN_Color] = false,
		[PN_Angles] = false,
		[PN_Enum] = true,
		[PN_Ref] = true,
		[PN_Struct] = true,
		[PN_Func] = true,
	}

	for i=0, PN_Max do
		if blackList[i] then continue end
		Combo:AddChoice( PinTypeNames[i], {i}, i == 1 )
		--Combo:AddChoice( "Another Choice", "myData" )
		--Combo:AddChoice( "Default Choice", "myData2", true )
		--Combo:AddChoice( "Icon Choice", "myData3", false, "icon16/star.png" )
	end

	for _, v in pairs(bpdefs.Get():GetClasses()) do
		if v:GetParam("pinTypeOverride") then continue end
		Combo:AddChoice( v.name, {PN_Ref, v.name} )
	end

	for _, v in pairs(bpdefs.Get():GetStructs()) do
		if v:GetPinTypeOverride() then continue end
		Combo:AddChoice( v.name, {PN_Struct, v.name} )
	end

	for id, struct in module:Structs() do
		Combo:AddChoice( struct:GetName(), {PN_Struct, struct:GetName()} )
	end

	Combo:SetWide( 150 )

	TableOption:SetText("As Table")


	Window:SetSize( 300, 200 )
	Window:Center()
	Window:SetParent(parent)

	NameEntry:SetWide(150)
	NameEntry:CenterHorizontal()
	NameEntry:AlignTop(40)

	Combo:CenterHorizontal()
	Combo:AlignTop(60)

	TableOption:CenterHorizontal()
	TableOption:AlignTop(100)

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	return Window
	--Window:DoModal()

end