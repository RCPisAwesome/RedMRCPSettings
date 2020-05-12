local menucrosshairtext = false
local menucrosshairtextpermanent = false
local menucrosshairtextpermanenttoggle = 0

RegisterCommand('rcpuifix', function() 
	SendNUIMessage({showmenu = false})
	SetNuiFocus(false)
end, false)

RegisterCommand('rcpsettings', function() 
	SendNUIMessage({showmenu = true})
	SetNuiFocus(true, true)
	menucrosshairtext = true
end, false)

RegisterCommand('rcpcrosshair', function()
	if menucrosshairtextpermanenttoggle == 0 then
		menucrosshairtextpermanent = true
		menucrosshairtextpermanenttoggle = 1
	elseif menucrosshairtextpermanenttoggle == 1 then
		menucrosshairtextpermanent = false
		menucrosshairtext = false
		menucrosshairtextpermanenttoggle = 0
	end
end, false)

RegisterNUICallback('close', function()
	SendNUIMessage({showmenu = false})
	SetNuiFocus(false)
	if not menucrosshairtextpermanent then
		menucrosshairtext = false
	end
end)

function DrawText(text)
	SetTextScale(0.35,0.35)
	SetTextColor(255,255,255,255)--r,g,b,a
	SetTextCentre(true)--true,false
	SetTextDropshadow(1,0,0,0,200)--distance,r,g,b,a
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), 0.5, 0.75)--text,x,y
end

function DrawCrosshairText(text)
	SetTextScale(0.35,0.35)
	SetTextColor(255,0,0,255)--r,g,b,a
	SetTextCentre(true)--true,false
	SetTextDropshadow(1,0,0,0,200)--distance,r,g,b,a
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), 0.5, 0.5)--text,x,y
end

function GetEntityInView()
	local RotateX,RotateY,RotateZ = table.unpack(GetGameplayCamRot())
	local CoordX,CoordY,CoordZ = table.unpack(GetGameplayCamCoord())

	local MathRotateX = -math.sin((math.pi / 180) * RotateZ) * math.abs(math.cos((math.pi / 180) * RotateX))
	local MathRotateY = math.cos((math.pi / 180) * RotateZ) * math.abs(math.cos((math.pi / 180) * RotateX))
	local MathRotateZ = math.sin((math.pi / 180) * RotateX)
	
	local EndCoordX = CoordX + MathRotateX * 10000.0
	local EndCoordY = CoordY + MathRotateY * 10000.0
	local EndCoordZ = CoordZ + MathRotateZ * 10000.0
	
	local retval,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(StartShapeTestRay(CoordX,CoordY,CoordZ,EndCoordX,EndCoordY,EndCoordZ, -1, -1, 1))
	if entityHit > 0 then
		return entityHit
	else
		return nil
	end
end

function DrawTextWait()
	menutext = not menutext
	Wait(2000)
	menutext = not menutext
end

CreateThread( function()
	while true do 
		Wait(0)
		if menutext then
			DrawText(tostring(datatext))
		end
	end
end)

CreateThread( function()
	while true do 
		Wait(0)
		if menucrosshairtext then
			DrawCrosshairText(tostring("X"))
		end
		if menucrosshairtextpermanent then
			DrawCrosshairText(tostring("X"))
		end
	end
end)

local restorestamina = false
local restoreentitystamina = false
local superjump = false
CreateThread(function()
	while true do
		Wait(0)
		if restorestamina then
			RestorePlayerStamina(PlayerId(),1.0)
		end
		if restoreentitystamina then
			RestorePedStamina(entityhit,100.0)
		end
		if superjump then
			SetSuperJumpThisFrame(PlayerId())
		end
	end
end)

RegisterNUICallback('cleartask', function(data)
	CreateThread(function()
		ClearPedTasks(PlayerPedId(),false,false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('cleartask2', function(data)
	CreateThread(function()
		ClearPedSecondaryTask(PlayerPedId())
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('cleartaskimmediately', function(data)
	CreateThread(function()
		ClearPedTasksImmediately(PlayerPedId(),false,false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('superjumpon', function(data)
	CreateThread(function()
		superjump = true
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('superjumpoff', function(data)
	CreateThread(function()
		superjump = false
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('healthcore', function(data)
	CreateThread(function()
		--SetAttributeCoreValue
		N_0xc6258f41d86676e0(PlayerPedId(),0,tonumber(data.health))
		datatext = tostring(data.text..", Max: "..GetAttributeCoreValue(PlayerPedId(),0))
		DrawTextWait()
	end)
end)

RegisterNUICallback('healthset', function(data)
	CreateThread(function()
		SetEntityHealth(PlayerPedId(),tonumber(data.health),0)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('healthsetmax', function(data)
	CreateThread(function()
		SetEntityMaxHealth(PlayerPedId(),tonumber(data.health))
		datatext = tostring(data.text..", Max: "..GetEntityMaxHealth(PlayerPedId(),true))
		DrawTextWait()
	end)
end)

--Seem to do nothing, at least without missions somehow set as completed
--[[RegisterNUICallback('healthbase', function(data)
	CreateThread(function()
		SetAttributeBaseRank(PlayerPedId(),0,tonumber(data.health))
		datatext = tostring(data.text.." Max: "..GetDefaultMaxAttributeRank(PlayerPedId(),0))
		DrawTextWait()
	end)
end)

RegisterNUICallback('healthbonus', function(data)
	CreateThread(function()
		SetAttributeBonusRank(PlayerPedId(),0,tonumber(data.health))
		datatext = tostring(data.text.." Max: "..GetMaxAttributeRank(PlayerPedId(),0))
		DrawTextWait()
	end)
end)

RegisterNUICallback('healthpoints', function(data)
	CreateThread(function()
		SetAttributePoints(PlayerPedId(),0,tonumber(data.health))
		datatext = tostring(data.text.." Max: "..GetMaxAttributePoints(PlayerPedId(),0))
		DrawTextWait()
	end)
end)--]]

RegisterNUICallback('stamina', function(data)
	CreateThread(function()
		N_0xc6258f41d86676e0(PlayerPedId(),1,tonumber(data.stamina))
		datatext = data.text
		DrawTextWait()
	end)

end)

RegisterNUICallback('deadeye', function(data)
	CreateThread(function()
		N_0xc6258f41d86676e0(PlayerPedId(),2,tonumber(data.deadeye))
		datatext = data.text
		DrawTextWait()
	end)
end)

function TeleportToWaypoint()
	if IsWaypointActive() then
		local ped = PlayerPedId()
		FreezeEntityPosition(ped,true)
		local waypointx,waypointy,waypointz = table.unpack(GetWaypointCoords())
		SetEntityCoords(ped,waypointx,waypointy,1000.0,0,0,0,0)
		x,y,z = table.unpack(GetEntityCoords(ped))
		local groundz = GetHeightmapBottomZForPosition(x,y)
		SetEntityInvincible(ped,true)
		SetEntityCoords(ped,x,y,groundz+10.0,0,0,0,0)
		FreezeEntityPosition(ped,false)
		Wait(3000)
		SetEntityInvincible(ped,false)
	end
end

RegisterNUICallback('teleporttowaypoint', function(data)
	CreateThread(function()
		TeleportToWaypoint()
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('alpha', function(data)
	CreateThread(function()
		SetEntityAlpha(PlayerPedId(),tonumber(data.alpha),tonumber(data.skin))
		datatext = data.text.." Alpha Level: "..data.alpha.." Exclude Skin: "..data.skin
		DrawTextWait()
	end)
end)

RegisterNUICallback('alphareset', function(data)
	CreateThread(function()
		ResetEntityAlpha(PlayerPedId())
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('velocity', function(data)
	CreateThread(function()
		SetEntityVelocity(PlayerPedId(), tonumber(data.x), tonumber(data.y), tonumber(data.z))
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('clothes', function(data)
	CreateThread(function()
		SetPedRandomComponentVariation(PlayerPedId(),0)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('invincibleon', function(data)
	CreateThread(function()
		SetEntityInvincible(PlayerPedId(),true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('invincibleoff', function(data)
	CreateThread(function()
		SetEntityInvincible(PlayerPedId(),false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('infinitestaminaon', function(data)
	CreateThread(function()
		restorestamina = true
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('infinitestaminaoff', function(data)
	CreateThread(function()
		restorestamina = false
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('ragdollon', function(data)
	CreateThread(function()
		SetPedCanRagdoll(PlayerPedId(),true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('ragdolloff', function(data)
	CreateThread(function()
		SetPedCanRagdoll(PlayerPedId(),false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('killself', function(data)
	CreateThread(function()
		ApplyDamageToPed(PlayerPedId(),500000,false,true,true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('reviveself', function(data)
	CreateThread(function()
		ResurrectPed(PlayerPedId())
		ClearPedBloodDamage(PlayerPedId())
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('friendlyfireon', function(data)
	CreateThread(function()
		NetworkSetFriendlyFireOption(true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('friendlyfireoff', function(data)
	CreateThread(function()
		NetworkSetFriendlyFireOption(false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('mapcloudon', function(data)
	CreateThread(function()
		SetMinimapHideFow(false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('mapcloudoff', function(data)
	CreateThread(function()
		SetMinimapHideFow(true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('minimapon', function(data)
	CreateThread(function()
		DisplayHud(true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('minimapoff', function(data)
	CreateThread(function()
		DisplayHud(false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('youcantbeshoton', function(data)
	CreateThread(function()
		SetEveryoneIgnorePlayer(PlayerId(),true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('youcantbeshotoff', function(data)
	CreateThread(function()
		SetEveryoneIgnorePlayer(PlayerId(),false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('scale', function(data)
	CreateThread(function()
		SetPedScale(PlayerPedId(),tonumber(data.scale))
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('scalereset', function(data)
	CreateThread(function()
		SetPedScale(PlayerPedId(),1.0)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('visibleon', function(data)
	CreateThread(function()
		SetEntityVisible(PlayerPedId(),true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('visibleoff', function(data)
	CreateThread(function()
		SetEntityVisible(PlayerPedId(),false)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('armour', function(data)
	CreateThread(function()
		AddArmourToPed(PlayerPedId(),100)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityarmour', function(data)
	CreateThread(function()
		entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			AddArmourToPed(PlayerPedId(),100)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityignoreon', function(data)
	CreateThread(function()
		entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetBlockingOfNonTemporaryEvents(entityhit, true)
			SetPedFleeAttributes(entityhit, 0, 0)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityignoreoff', function(data)
	CreateThread(function()
		entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetBlockingOfNonTemporaryEvents(entityhit, false)
			SetPedFleeAttributes(entityhit, 0, true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityinvincibleon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityInvincible(entityhit, true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityinvincibleoff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityInvincible(entityhit, false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityinfinitestaminaon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			restoreentitystamina = true
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityinfinitestaminaoff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			restoreentitystamina = false
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityragdollon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetPedCanRagdoll(entityhit,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityragdolloff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetPedCanRagdoll(entityhit,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitykill', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ApplyDamageToPed(entityhit,500000,false,true,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityrevive', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ResurrectPed(entityhit)
			ReviveInjuredPed(entityhit)
			SetEntityHealth(entityhit,20,0)
			ClearPedBloodDamage(entityhit)
			ClearPedTasksImmediately(entityhit,false,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityscale', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetPedScale(entityhit,tonumber(data.scale))
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityscalereset', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetPedScale(entityhit,1.0)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityhealth', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			N_0xc6258f41d86676e0(entityhit,0,tonumber(data.health))
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityhealthset', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityHealth(PlayerPedId(),tonumber(data.health),0)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityhealthsetmax', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityMaxHealth(PlayerPedId(),tonumber(data.health))
			datatext = tostring(data.text..", Max: "..GetEntityMaxHealth(PlayerPedId(),true))
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitystamina', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			N_0xc6258f41d86676e0(entityhit,1,tonumber(data.stamina))
			datatext = data.text
		end
		DrawTextWait()
	end)

end)

RegisterNUICallback('entitydeadeye', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			N_0xc6258f41d86676e0(entityhit,2,tonumber(data.deadeye))
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityvisibleon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityVisible(entityhit,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityvisibleoff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityVisible(entityhit,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitydespawnon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityAsMissionEntity(entityhit,true,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitydespawnoff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityAsMissionEntity(entityhit,true,true)
			SetEntityAsNoLongerNeeded(entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitycleartask', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClearPedTasks(entityhit,false,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitycleartask2', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClearPedSecondaryTask(entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitycleartaskimmediately', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClearPedTasksImmediately(entityhit,false,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityfreezeon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			FreezeEntityPosition(entityhit,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityfreezeoff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			FreezeEntityPosition(entityhit,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitygravityon', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityHasGravity(entityhit,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitygravityoff', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityHasGravity(entityhit,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityclothes', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetPedRandomComponentVariation(entityhit,0)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitydelete', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityAsMissionEntity(entityhit,true,true)
			DeleteEntity(entityhit)
			SetEntityAsNoLongerNeeded(entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityalpha', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityAlpha(entityhit,tonumber(data.alpha),tonumber(data.skin))
			datatext = data.text.." Alpha Level: "..data.alpha.." Exclude Skin: "..data.skin
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityalphareset', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ResetEntityAlpha(entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityvelocity', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			SetEntityVelocity(entityhit, tonumber(data.x), tonumber(data.y), tonumber(data.z))
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitychangeintotarget', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClonePedToTarget(entityhit,PlayerPedId())
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitychangetarget', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClonePedToTarget(PlayerPedId(),entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entityclone', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClonePed(entityhit,0.0,true,true)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('clone', function(data)
	CreateThread(function()
		ClonePed(PlayerPedId(),0.0,true,true)
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitynetwork', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			if IsEntityAVehicle(entityhit) then
				networkid = VehToNet(entityhit)
			elseif IsEntityAPed(entityhit) then
				networkid = PedToNet(entityhit)
			else
				networkid = ObjToNet(entityhit)
			end
			SetNetworkIdExistsOnAllMachines(networkid, true)
			NetworkRegisterEntityAsNetworked(entityhit)
			NetworkSetEntityInvisibleToNetwork(entityhit,false)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitygun', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			local retval, hash = GetCurrentPedWeapon(PlayerPedId(),true--[[bool--]],0--[[int--]],true--[[bool--]])
			GiveWeaponToPed_2(entityhit,hash,100,true,true,1,false,0.5,1.0,false,0)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('cleandirt', function(data)
	CreateThread(function()
		ClearPedEnvDirt(PlayerPedId())
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('cleanwetness', function(data)
	CreateThread(function()
		ClearPedWetness(PlayerPedId())
		datatext = data.text
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitycleandirt', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClearPedEnvDirt(entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)

RegisterNUICallback('entitycleanwetness', function(data)
	CreateThread(function()
		local entityhit = GetEntityInView()
		if (entityhit == nil) then
			datatext = "You Need To Point At An Entity"
		else
			ClearPedWetness(entityhit)
			datatext = data.text
		end
		DrawTextWait()
	end)
end)