--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

SetDifficulty = function()
  --[[  if Difficulty == "easy" then
        StartingCash = 7000

        USSRStartingCash = 75000
        BadGuyStartingCash = 30000


    elseif Difficulty == "normal" then
        StartingCash = 6000

        USSRStartingCash = 100000
        BadGuyStartingCash = 40000

	
	elseif Difficulty == "hard" then
		StartingCash = 5000

        USSRStartingCash = 100000
        BadGuyStartingCash = 40000
	end]]
end

--------------------------------------------------------------------
-----------------	    DATA BLOCK - START	------------------------
--------------------------------------------------------------------


Blk1Units = 
{
	hard = { "3tnk", "3tnk", "3tnk" },
	normal = { "3tnk", "3tnk" },
	easy = { "3tnk" }
}

Blk2Units = 
{
	hard = { "4tnk", "4tnk", "v2rl", "v2rl" },
	normal = { "4tnk", "v2rl", "v2rl" },
	easy = { "4tnk", "v2rl" }
}

Blk3Units = 
{
	hard = { "4tnk", "4tnk", "v2rl", "v2rl" },
	normal = { "4tnk", "v2rl", "v2rl" },
	easy = { "4tnk", "v2rl" }
}

Blk4Units = 
{
	hard = { "4tnk", "4tnk", "v2rl", "v2rl" },
	normal = { "4tnk", "v2rl", "v2rl" },
	easy = { "4tnk", "v2rl" }
}

Blk5Units = 
{
	hard = { "e4", "e4", "e4", "e4", "e4", "e4" },
	normal = { "e4", "e4", "e4", "e4", "e4" },
	easy = { "e4", "e4", "e4", "e4" }
}

Periodic1Units = 
{
	hard = { "4tnk", "4tnk" },
	normal = { "4tnk" },
	easy = { "3tnk" }
}

Periodic2Units = 
{
	hard = { "e4", "e4", "e4", "e4", "e1", "e1", "e1", "e2", "e2"  },
	normal = { "e4", "e4", "e4", "e1", "e1", "e2", "e2" },
	easy = { "e4", "e4", "e1", "e1", "e2" }
}

Periodic3Units = 
{
	hard = { "4tnk", "4tnk", "v2rl", "v2rl" },
	normal = { "4tnk", "v2rl", "v2rl" },
	easy = { "4tnk", "v2rl" }
}

Periodic4Units = 
{
	hard = { "v2rl", "v2rl", "v2rl" },
	normal = { "v2rl", "v2rl" },
	easy = { "v2rl" }
}

BadguyPeriodic1Units = 
{
	hard = { "e2", "e2", "e2", "e4", "e4", "e4" },
	normal = { "e2", "e2", "e2", "e4", "e4" },
	easy = { "e2", "e2", "e2", "e4" }
}

BadguyPeriodic2Units = 
{
	hard = { "e1", "e1", "e2", "e2", "e2", "e2" },
	normal = { "e1", "e1", "e2", "e2", "e2" },
	easy = { "e1", "e1", "e2", "e2" }
}

BadguyPeriodic3Units = 
{
	hard = { "3tnk","3tnk", "v2rl", "v2rl" },
	normal = { "3tnk", "v2rl", "v2rl" },
	easy = { "3tnk", "v2rl" }
}

BadguyPeriodic4Units = 
{
	hard = { "3tnk", "3tnk", "3tnk", "3tnk" },
	normal = { "3tnk", "3tnk", "3tnk" },
	easy = { "3tnk", "3tnk" }
}

ProductionInterval =
{
	easy = DateTime.Seconds(60),
	normal = DateTime.Seconds(40),
	hard = DateTime.Seconds(20)
}

Blk1UnitsGroup = { }
Blk2UnitsGroup = { }
Blk3UnitsGroup = { }
Blk4UnitsGroup = { }
Blk5UnitsGroup = { }
Periodic1UnitsGroup = { }
Periodic2UnitsGroup = { }
Periodic3UnitsGroup = { }
Periodic4UnitsGroup = { }
BadguyPeriodic1UnitsGroup = { }
BadguyPeriodic2UnitsGroup = { }
BadguyPeriodic3UnitsGroup = { }
BadguyPeriodic4UnitsGroup = { }

AirGroup1 = { "yak" }
AirGroup2 = { "yak", "yak" }
AirGroup3 = { "mig", "mig" }
AirGroup4 = { "mig", "mig", "yak" }
AirGroup5 = { "mig", "mig", "mig", "yak", "yak", "yak", "yak" }

AirGroup1Route = { WP96.Location }
AirGroup2Route = { WP96.Location }
AirGroup3Route = { WP83.Location }
AirGroup4Route = { WP83.Location }
AirGroup5Route = { WP84.Location }

USSRBaseBlueprints = {
	{ type = "apwr", actor = USSRBasePower1, cost = 500, shape = { 3, 3 }, location = CPos.New(21, 24) },
	{ type = "apwr", actor = USSRBasePower2, cost = 500, shape = { 3, 3 }, location = CPos.New(113, 39) },
	{ type = "apwr", actor = USSRBasePower3, cost = 500, shape = { 3, 3 }, location = CPos.New(113, 39) },
	{ type = "apwr", actor = USSRBasePower4, cost = 500, shape = { 3, 3 }, location = CPos.New(113, 39) },

	{ type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(25, 24) },

	{ type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(30, 27) },
	{ type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(35, 27) },
	{ type = "kenn", actor = USSRKenn, cost = 200, shape = { 1, 1 }, location = CPos.New(41, 27) },
	{ type = "spen", actor = USSRSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(46, 30) },

	{ type = "dome", actor = USSRDome, cost = 1400, shape = { 2, 3 }, location = CPos.New(21, 21) },
	{ type = "stek", actor = USSRStek, cost = 1500, shape = { 3, 3 }, location = CPos.New(32, 24) },

	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(22, 32) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(30, 22) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(33, 22) },
	{ type = "afld", actor = USSRAfld4, cost = 500, shape = { 3, 2 }, location = CPos.New(39, 32) },

	{ type = "ftur", actor = USSRFtur, cost = 600, shape = { 1, 1 }, location = CPos.New(28, 35) },
	{ type = "ftur", actor = USSRFtur, cost = 600, shape = { 1, 1 }, location = CPos.New(34, 35) },
    { type = "tsla", actor = USSRTesla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(27, 33 ) },
    { type = "tsla", actor = USSRTesla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(35, 33) }

	--[[ I think these should be added to counter allies aircraft on normal/hard
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(46, 23) },
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(46, 23) },
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(46, 23) },
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(46, 23) },
	]]
}

BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGBasePower1, cost = 300, shape = { 3, 3 }, location = CPos.New(82, 29) },
	{ type = "apwr", actor = BGBasePower2, cost = 500, shape = { 3, 3 }, location = CPos.New(74, 33) },
	{ type = "apwr", actor = BGBasePower3, cost = 500, shape = { 3, 3 }, location = CPos.New(87, 30) },
	{ type = "apwr", actor = BGBasePower4, cost = 500, shape = { 3, 3 }, location = CPos.New(87, 34) },
	{ type = "apwr", actor = BGBasePower4, cost = 500, shape = { 3, 3 }, location = CPos.New(87, 37) },

	{ type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(84, 37) },

	{ type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(79, 32) },
	{ type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(76, 37) },
	--[[
	{ type = "dome", actor = USSRDome, cost = 1400, shape = { 2, 3 }, location = CPos.New(21, 21) },
	{ type = "stek", actor = USSRStek, cost = 1500, shape = { 3, 3 }, location = CPos.New(32, 24) },
	]]
	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(72, 36) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(72, 38) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(33, 22) },

	{ type = "ftur", actor = USSRFtur, cost = 600, shape = { 1, 1 }, location = CPos.New(80, 42) },
	{ type = "ftur", actor = USSRFtur, cost = 600, shape = { 1, 1 }, location = CPos.New(84, 42) },
    { type = "tsla", actor = USSRTesla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(82, 40) },
    { type = "tsla", actor = USSRTesla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(81, 32) },

	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(87, 29) },
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(72, 33) },
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(72, 41) },
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 41) }
}

--------------------------------------------------------------------
-----------------	    DATA BLOCK - END	------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	UTILS BLOCK - START	----------------------------
--------------------------------------------------------------------

PlayerMoney = function(owner)
	return owner.Cash + owner.Resources
end

GrantCash = function(player, amount)
    player.Cash = player.Cash + amount
end

--------------------------------------------------------------------
-----------------	UTILS BLOCK - END	----------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------

BuildBase = function()
	if BGFact.IsDead or BGFact.Owner ~= BadGuy then
		return
	end
	for i,v in ipairs(BaseBuildings) do
		if not v.exists then
			BuildBuilding(v)
			return
		end
	end
	Trigger.AfterDelay(DateTime.Seconds(5), BuildBase)
end

BuildBuilding = function(building)
	Trigger.AfterDelay(Actor.BuildTime(building.type), function()
		if BGFact.IsDead or BGFact.Owner ~= BadGuy then
			return
		end
		local actor = Actor.Create(building.type, true, { Owner = BadGuy, Location = BGFact.Location + building.pos })
		BadGuy.Cash = BadGuy.Cash - building.cost

		building.exists = true
		if building.type == "barr" then
			Trigger.AfterDelay(DateTime.Seconds(40), ProduceBadGuyPeriodic1Units)
		elseif building.type == "weap" then
			Trigger.AfterDelay(DateTime.Seconds(120), ProduceBadGuyPeriodic3Units)
		end
		Trigger.OnKilled(actor, function() 
			building.exists = false 			
		end)
		Trigger.OnDamaged(actor, function(building)
			if building.Owner == BadGuy and building.Health < building.MaxHealth * 3/4 then
				building.StartBuildingRepairs()
			end
		end)
		Trigger.AfterDelay(DateTime.Seconds(5), BuildBase)
	end)
end



SendBlk1AttackGroup = function()
	if #Blk1UnitsGroup < #Blk1Units then
		return
	end
	for i = 1, #Blk1UnitsGroup do
		if not Blk1UnitsGroup[i].IsDead then
			Blk1UnitsGroup[i].AttackMove(MammothPatrolWP1.Location)
		end
	end
end

SendBlk2AttackGroup = function()
	if #Blk2UnitsGroup < #Blk2Units then
		return
	end
	for i = 1, #Blk2UnitsGroup do
		if not Blk2UnitsGroup[i].IsDead then
			Blk2UnitsGroup[i].AttackMove(MammothPatrolWP2.Location)
		end
	end
end

SendBlk3AttackGroup = function()
	if #Blk3UnitsGroup < #Blk3Units then
		return
	end
	for i = 1, #Blk3UnitsGroup do
		if not Blk3UnitsGroup[i].IsDead then
			Blk3UnitsGroup[i].AttackMove(MammothPatrolWP3.Location)
		end
	end
end

SendBlk4AttackGroup = function()
	if #Blk4UnitsGroup < #Blk4Units then
		return
	end
	for i = 1, #Blk4UnitsGroup do
		if not Blk4UnitsGroup[i].IsDead then
			Blk4UnitsGroup[i].AttackMove(MammothPatrolWP4.Location)
		end
	end
end

SendBlk5AttackGroup = function()
	if #Blk5UnitsGroup < #Blk5Units then
		return
	end
	Utils.Do(Blk5UnitsGroup, IdleHunt)
end

SendPeriodic1UnitsAttackGroup = function()
	if #Periodic1UnitsGroup < #Periodic1Units then
		return
	end
	Utils.Do(Periodic1UnitsGroup, IdleHunt)
	Periodic1UnitsGroup = { }
end

SendPeriodic2UnitsAttackGroup = function()
	if #Periodic2UnitsGroup < #Periodic2Units then
		return
	end
	Utils.Do(Periodic2UnitsGroup, IdleHunt)
	Periodic2UnitsGroup = { }
end

SendPeriodic3UnitsAttackGroup = function()
	if #Periodic3UnitsGroup < #Periodic3Units then
		return
	end
	Utils.Do(Periodic3UnitsGroup, IdleHunt)
	Periodic3UnitsGroup = { }
end

SendPeriodic4UnitsAttackGroup = function()
	if #Periodic4UnitsGroup < #Periodic4Units then
		return
	end
	Utils.Do(Periodic4UnitsGroup, IdleHunt)
	Periodic4UnitsGroup = { }
end

SendBadGuyPeriodic1UnitsAttackGroup = function()
	if #BadguyPeriodic1UnitsGroup < #BadguyPeriodic1Units then
		return
	end
	Utils.Do(BadguyPeriodic1UnitsGroup, IdleHunt)
	BadguyPeriodic1UnitsGroup = { }
end

SendBadGuyPeriodic2UnitsAttackGroup = function()
	if #BadguyPeriodic2UnitsGroup < #BadguyPeriodic2Units then
		return
	end
	Utils.Do(BadguyPeriodic2UnitsGroup, IdleHunt)
	BadguyPeriodic2UnitsGroup = { }
end

SendBadGuyPeriodic3UnitsAttackGroup = function()
	if #BadguyPeriodic3UnitsGroup < #BadguyPeriodic3Units then
		return
	end
	Utils.Do(BadguyPeriodic3UnitsGroup, IdleHunt)
	BadguyPeriodic3UnitsGroup = { }
end

SendBadGuyPeriodic4UnitsAttackGroup = function()
	if #BadguyPeriodic4UnitsGroup < #BadguyPeriodic4Units then
		return
	end
	Utils.Do(BadguyPeriodic4UnitsGroup, IdleHunt)
	BadguyPeriodic4UnitsGroup = { }
end

ProduceSovietBlk1Vehicle = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		return
	end
	USSR.Build({ Blk1Units[#Blk1UnitsGroup+1] }, function(units)
		table.insert(Blk1UnitsGroup, units[1])
		SendBlk1AttackGroup()
		if #Blk1UnitsGroup < #Blk1Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk1Vehicle)
		else
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk2Vehicle)
		end
	end)
end

ProduceSovietBlk2Vehicle = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		return
	end
	USSR.Build({ Blk2Units[#Blk2UnitsGroup+1] }, function(units)
		table.insert(Blk2UnitsGroup, units[1])
		SendBlk2AttackGroup()
		if #Blk2UnitsGroup < #Blk2Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk2Vehicle)
		else
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk3Vehicle)
		end
	end)
end

ProduceSovietBlk3Vehicle = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		return
	end
	USSR.Build({ Blk3Units[#Blk3UnitsGroup+1] }, function(units)
		table.insert(Blk3UnitsGroup, units[1])
		SendBlk3AttackGroup()
		if #Blk3UnitsGroup < #Blk3Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk3Vehicle)
		else
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk4Vehicle)
		end
	end)
end

ProduceSovietBlk4Vehicle = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		return
	end
	USSR.Build({ Blk2Units[#Blk4UnitsGroup+1] }, function(units)
		table.insert(Blk4UnitsGroup, units[1])
		SendBlk4AttackGroup()
		if #Blk4UnitsGroup < #Blk2Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk4Vehicle)
		else
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk5Infantry)
		end
	end)
end

-----------------------
--- Inf Attacks     ---
-----------------------

ProduceSovietBlk5Infantry = function()
	if USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Blk5Units[#Blk5UnitsGroup+1] }, function(units)
		table.insert(Blk5UnitsGroup, units[1])
		SendBlk5AttackGroup()
		if #Blk5UnitsGroup < #Blk5Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietBlk5Infantry)
		else
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic1Units)
		end
	end)
end

-----------------------
--- ??? Attacks     ---
-----------------------

ProduceSovietPeriodic1Units = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		ProduceSovietPeriodic2Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic1Units[#Periodic1UnitsGroup+1] }, function(units)
		table.insert(Periodic1UnitsGroup, units[1])
		if #Periodic1UnitsGroup < #Periodic1Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic1Units)
		else
			SendPeriodic1UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic2Units)
		end
	end)
end

ProduceSovietPeriodic2Units = function()
	if USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		ProduceSovietPeriodic3Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic2Units[#Periodic2UnitsGroup+1] }, function(units)
		table.insert(Periodic2UnitsGroup, units[1])
		if #Periodic2UnitsGroup < #Periodic2Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic2Units)
		else
			SendPeriodic2UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic3Units)
		end
	end)
end

ProduceSovietPeriodic3Units = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		ProduceSovietPeriodic2Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic3Units[#Periodic3UnitsGroup+1] }, function(units)
		table.insert(Periodic3UnitsGroup, units[1])
		if #Periodic3UnitsGroup < #Periodic3Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic3Units)
		else
			SendPeriodic3UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic4Units)
		end
	end)
end

ProduceSovietPeriodic4Units = function()
	if USSRWeap.IsDead or USSRWeap.Owner ~= USSR then
		ProduceSovietPeriodic2Units()
	elseif USSRWeap.IsDead or USSRWeap.Owner ~= USSR and USSRBarr.IsDead or USSRBarr.Owner ~= USSR then
		return
	end
	USSR.Build({ Periodic4Units[#Periodic4UnitsGroup+1] }, function(units)
		table.insert(Periodic4UnitsGroup, units[1])
		if #Periodic4UnitsGroup < #Periodic4Units then
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic4Units)
		else
			SendPeriodic4UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceSovietPeriodic1Units)
		end
	end)
end

ProduceBadGuyPeriodic1Units = function()
	BadGuy.Build({ BadguyPeriodic1Units[#BadguyPeriodic1UnitsGroup+1] }, function(units)
		table.insert(BadguyPeriodic1UnitsGroup, units[1])
		if #BadguyPeriodic1UnitsGroup < #BadguyPeriodic1Units then
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic1Units)
		else
			SendBadGuyPeriodic1UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic2Units)
		end
	end)
end

ProduceBadGuyPeriodic2Units = function()
	BadGuy.Build({ BadguyPeriodic2Units[#BadguyPeriodic2UnitsGroup+1] }, function(units)
		table.insert(BadguyPeriodic2UnitsGroup, units[1])
		if #BadguyPeriodic2UnitsGroup < #BadguyPeriodic2Units then
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic2Units)
		else
			SendBadGuyPeriodic2UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic1Units)
		end
	end)
end

ProduceBadGuyPeriodic3Units = function()
	BadGuy.Build({ BadguyPeriodic3Units[#BadguyPeriodic3UnitsGroup+1] }, function(units)
		table.insert(BadguyPeriodic3UnitsGroup, units[1])
		if #BadguyPeriodic3UnitsGroup < #BadguyPeriodic3Units then
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic3Units)
		else
			SendBadGuyPeriodic3UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic4Units)
		end
	end)
end

ProduceBadGuyPeriodic4Units = function()
	BadGuy.Build({ BadguyPeriodic4Units[#BadguyPeriodic4UnitsGroup+1] }, function(units)
		table.insert(BadguyPeriodic4UnitsGroup, units[1])
		if #BadguyPeriodic4UnitsGroup < #BadguyPeriodic4Units then
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic4Units)
		else
			SendBadGuyPeriodic4UnitsAttackGroup()
			Trigger.AfterDelay(ProductionInterval, ProduceBadGuyPeriodic3Units)
		end
	end)
end

-----------------------
--- Inf Attacks     --- 
-----------------------

ProduceInfantry = function(producer, owner)
	if not BarrAvailableCheck(producer, owner) then
		--Media.Debug("Out of ProduceInfantry")
		return
	elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing() then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(InfantryUnits) }

	owner.Build(toBuild, function(units)
		table.insert(InfantryAttackGroup, units[1])

		if #InfantryAttackGroup >= InfantryAttackGroupSize then
			SendUnits(InfantryAttackGroup, LandAtkPaths)
			InfantryAttackGroup = { }
			Trigger.AfterDelay(AttackProductionInterval, function()
				ProduceInfantry(producer, owner)
			end)
		else
			Trigger.AfterDelay(delay, function()
				ProduceInfantry(producer, owner)
			end)
		end
	end)
end

-----------------------
--- Air Attacks     ---
-----------------------
local function __AIR_ATTACKS__() end
--[[
BasePlanes = {}
TotalAflds = 1

AfldAvailableCheck = function(producer, owner)
	if not producer.IsDead or producer.Owner == owner then
		return true
	else
		return false
	end
	TotalAflds = USSR.GetActorsByType("afld")
end

ProduceAircraft = function(producer, owner)
    if not AfldAvailableCheck(producer, owner) then
        return
    end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(AircraftTypes) }

    USSR.Build(toBuild, function(units)
        local plane = units[1]
		table.insert(BasePlanes, plane)
        PlanesAttackGroup[#PlanesAttackGroup + 1] = plane

        Trigger.OnKilled(plane, function()
			table.remove(BasePlanes)
			Trigger.AfterDelay(delay, function()
				ProduceAircraft(producer, owner)
			end)
		end)
        InitializeAttackAircraft(plane, Greece)
    end)
end

--Out of map attacks
SendParabombs = function()
	if BaseAfld.IsDead or BaseAfld.Owner ~= USSR then
		return
	end

	local airfield = BaseAfld
	local targets = Utils.Where(Greece.GetActors(), function(actor)
		return
			actor.HasProperty("Sell") and
			actor.Type ~= "brik" and
			actor.Type ~= "sbag" or
			actor.Type == "pdox" or
			actor.Type == "atek"
	end)
	if #targets > 0 then
		airfield.TargetAirstrike(Utils.Random(targets).CenterPosition, Angle.NorthEast)
	end

	Trigger.AfterDelay(ParabombDelay, SendParabombs)
end

-- Maybe only leave this for hard difficulty
SendParadrop = function()
	if BaseAfld.IsDead or BaseAfld.Owner ~= USSR then
		return
	end

	local aircraft = ParadropProxy.TargetParatroopers(KosyginExtractPoint.CenterPosition)

	Utils.Do(aircraft, function(a)
		Trigger.OnPassengerExited(a, function(t, p)
			IdleHunt(p)
		end)
	end)
	Trigger.AfterDelay(ParadropDelay, SendParadrop)
end

CurrentAirWave = 1

PrepareAircraftReinforcements = function()
	local delay = DateTime.Seconds(10)--FirstAirDelays[Difficulty] or FirstAirDelays["normal"]

	Trigger.AfterDelay(delay, function()
		ScheduleAirWave(1)
	end)
	--Media.Debug("Prepare Air Attack")
end


HasAirfield = function(player)
	return player.HasPrerequisites({ "afld" })
end

---@param wave integer
ScheduleAirWave = function(wave)
	local team = SovietAirTeams[wave]
	if not team then
		team = SovietAirTeams[#SovietAirTeams]
		--return
	end
	Trigger.AfterDelay(team.interval, function()
		-- The last team was defeated before its scheduled repeat.
		if CurrentAirWave > wave then
			return
		end

		local units = Reinforcements.Reinforce(team.owner or USSR, team.types, team.path)
		ScheduleAirWave(wave)

		Utils.Do(units, function(unit)
			InitializeAttackAircraft(unit, Greece)

			Trigger.OnIdle(unit, function()
				--if unit.AmmoCount() > 0 or HasAirfield(unit.Owner) then -- #BasePlanes < TotalAflds
					--Media.Debug("On Idle - return")
					table.insert(BasePlanes, unit)
					return
				elseif HasAirfield(unit.Owner) and #BasePlanes < TotalAflds then
					return
				end
				OnAircraftStranded(unit, team.path[1])

			end)
		end)

		Trigger.OnAllRemovedFromWorld(units, function()
			if AreSovietPlanesActive() then
				--Media.Debug("Does it enters here?")
				return
			end


			if team.onWaveDefeated then
				team.onWaveDefeated()
			end

			CurrentAirWave = CurrentAirWave + 1
			ScheduleAirWave(CurrentAirWave)
		end)
	end)
end
]]
OnAircraftStranded = function(aircraft, exit)
	--Media.Debug("Stranded check")
	local oldOwner = aircraft.Owner
	
	--if oldOwner == USSR and HasAirfield(BadGuy) then
	--	aircraft.Owner = BadGuy
	--elseif oldOwner == BadGuy and HasAirfield(USSR) then
	--	aircraft.Owner = USSR
	--end
	
	if oldOwner == aircraft.Owner then
		--Media.Debug("Send aircraft to elimination")
		aircraft.Stop()
		aircraft.Move(exit)
		--aircraft.Move(exit)
		aircraft.Destroy()
	end
end
--[[
AreSovietPlanesActive = function()
	local planes = { "mig", "yak" }
	return #USSR.GetActorsByTypes(planes) > 0
end

---@type { interval: number, types: string[], path: cpos[], owner: player, onWaveDefeated: fun() }[]
SovietAirTeams =
{
	{ types = { "yak", "yak" }, interval = DateTime.Seconds(120), path = { USSRAircraftOrigin1.Location }},
	{ types = { "yak", "yak" }, interval = DateTime.Seconds(110), path = { USSRAircraftOrigin1.Location }},
	{ types = { "yak", "mig" }, interval = DateTime.Seconds(110), path = { USSRAircraftOrigin1.Location, USSRAircraftOrigin1.Location + CVec.New(-1, 0) }	},
	{ types = { "yak", "yak", "yak" }, interval = DateTime.Seconds(219),  path = { USSRAircraftOrigin1.Location, USSRAircraftOrigin1.Location + CVec.New(-1, 0) } },
	-- Original includes 2x Hind. Replaced with Yaks.
	{ types = { "yak", "yak", "mig" }, interval = DateTime.Seconds(210), path = { USSRAircraftOrigin1.Location, USSRAircraftOrigin1.Location + CVec.New(-1, 0) } }
}

]]
-----------------------
--- Naval Attacks   ---
-----------------------
local function __NAVAL_ATTACKS__() end



--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - END	--------------------
--------------------------------------------------------------------

SetupAIActivities = function()
	local difficulty = Map.LobbyOption("difficulty")
	ProductionInterval = ProductionInterval[difficulty]
	Blk1Units = Blk1Units[difficulty]
	Blk2Units = Blk2Units[difficulty]
	Blk3Units = Blk3Units[difficulty]
	Blk4Units = Blk4Units[difficulty]
	Blk5Units = Blk5Units[difficulty]
	Periodic1Units = Periodic1Units[difficulty]
	Periodic2Units = Periodic2Units[difficulty]
	Periodic3Units = Periodic3Units[difficulty]
	Periodic4Units = Periodic4Units[difficulty]
	BadguyPeriodic1Units = BadguyPeriodic1Units[difficulty]
	BadguyPeriodic2Units = BadguyPeriodic2Units[difficulty]
	BadguyPeriodic3Units = BadguyPeriodic3Units[difficulty]
	BadguyPeriodic4Units = BadguyPeriodic4Units[difficulty]
	local buildings = Utils.Where(Map.ActorsInWorld, function(self) return self.Owner == USSR and self.HasProperty("StartBuildingRepairs") end)
	Utils.Do(buildings, function(actor)
		Trigger.OnDamaged(actor, function(building)
			if building.Owner == USSR and building.Health < building.MaxHealth * 3/4 then
				building.StartBuildingRepairs()
			end
		end)
	end)
	Trigger.AfterDelay(DateTime.Minutes(5), ProduceSovietBlk1Vehicle)
	Trigger.AfterDelay(DateTime.Seconds(126), function()
		SendRenAirstrike(AirGroup1, AirGroup1Route)
	end)
	Trigger.AfterDelay(DateTime.Seconds(172), function()
		SendRenAirstrike(AirGroup2, AirGroup2Route)
	end)
	Trigger.AfterDelay(DateTime.Seconds(260), function()
		SendRenAirstrike(AirGroup3, AirGroup3Route)
	end)
	Trigger.AfterDelay(DateTime.Seconds(316), function()
		SendRenAirstrike(AirGroup4, AirGroup4Route)
	end)
	Trigger.AfterDelay(DateTime.Seconds(432), function()
		SendRenAirstrike(AirGroup5, AirGroup5Route)
	end)
	Trigger.AfterDelay(DateTime.Seconds(432), SendAirstrike)
	Trigger.AfterDelay(DateTime.Minutes(27), BuildBase)
end
