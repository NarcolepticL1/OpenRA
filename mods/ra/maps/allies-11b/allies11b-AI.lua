----------------------------------
--- Definitions Start    ---------
----------------------------------

------------------------------
--- Definitions End	----------
------------------------------

------------------------------
--- Data Start	--------------
------------------------------
local function __DATA__() end

---@type blueprint[]
local USSRBaseBlueprints = {}
USSRBaseBlueprints =
{
	{ type = "apwr", actor = USSRPower1, cost = 500, shape = { 3, 3 }, location = CPos.New(38, 38) },
	{ type = "apwr", actor = USSRPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(49, 39) },
	{ type = "apwr", actor = USSRPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(34, 43) },
	{ type = "apwr", actor = USSRPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(30, 44) },

    { type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(38, 32) },
    { type = "silo", actor = USSRSilo1, cost = 1400, shape = { 1, 1 }, location = CPos.New(47, 36) },
    { type = "silo", actor = USSRSilo2, cost = 1400, shape = { 1, 1 }, location = CPos.New(48, 35) },
	{ type = "silo", actor = USSRSilo2, cost = 1400, shape = { 1, 1 }, location = CPos.New(49, 36) },

    { type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(39, 42), owner = USSR, producer = true },
    { type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(45, 42), owner = USSR, producer = true },
    { type = "spen", actor = USSRSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(52, 30), owner = USSR, producer = true },

	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(50, 36) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(53, 41) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(51, 43) },
	{ type = "afld", actor = USSRAfld4, cost = 500, shape = { 3, 2 }, location = CPos.New(31, 48) },

    { type = "fix", actor = USSRFix, cost = 1000, shape = { 3, 3 }, location = CPos.New(41, 30) },
    { type = "dome", actor = USSRDome, cost = 1500, shape = { 2, 3 }, location = CPos.New(52, 38) },
    --[[{ type = "stek", actor = BadGuyStek, cost = 1500, shape = { 3, 3 }, location = CPos.New(107, 41) },]]

    { type = "ftur", actor = USSRFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(40, 49) },
    { type = "ftur", actor = USSRFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(45, 49) },
    { type = "tsla", actor = USSRTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(39, 48) },
    { type = "tsla", actor = USSRTsla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(46, 48) },

    { type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(40, 36) },
    { type = "sam", actor = USSRSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(48, 38) },
    { type = "sam", actor = USSRSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(37, 46) },
	{ type = "sam", actor = USSRSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(47, 47) }
}

---@type blueprint[]
BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGPower1, cost = 500, shape = { 2, 3 }, location = CPos.New(102, 34) },
	{ type = "apwr", actor = BGPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(91, 30) }
}

---@type blueprint[]
--BadGuyToBeBuilt = {}
BadGuyToBeBuilt =
{
    { type = "apwr", actor = BGPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(99, 33) },
	{ type = "apwr", actor = BGPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(91, 33) },

    { type = "proc", actor = BGProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(100, 36) },

    { type = "barr", actor = BGBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(97, 36) },
    { type = "weap", actor = BGWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(91, 37) },
    { type = "spen", actor = BGSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(80, 32) },

	{ type = "afld", actor = BGAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 30) },
	{ type = "afld", actor = BGAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 32) },
	{ type = "afld", actor = BGAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 34) },

    { type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(95, 41) },
    { type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(99, 41) },
    { type = "tsla", actor = BGTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(95, 37) }
}

InfantryTypes = {"e1", "e2", "e4"}
InfantryUSSRAttackGroup = { }
InfantryBadGuyAttackGroup = { }

InfantryAttackGroupSize = 8


VehicleTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "v2rl" }
VehicleUSSRAttackGroup = { }
VehicleBadGuyAttackGroup = { }

USSRAttackPaths =
{
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP6.Location, Waypoint34.Location},
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP4.Location, Waypoint32.Location, Waypoint33.Location}
}

BadGuyAttackPaths = { {BGAttackRallyWP.Location}}

local function __UTILS__() end
------------------------------
--- Utils Start	--------------
------------------------------

local PlayerMoney = function(owner)
	return owner.Cash + owner.Resources
end

local GrantCash = function(player, amount)
    player.Cash = player.Cash + amount
end

local IsHarvesterMissing = function(owner)
	return #owner.GetActorsByType("harv") == 0
end

------------------------------
--- Utils End	--------------
------------------------------

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function __BASE_MANAGEMENT__() end

---@param blueprints blueprint[]
---@param cyard any
---@param owner player
local BuildBase = function(blueprints, cyard, owner)
    for _, b in ipairs(blueprints) do
        if not b.actor then
            Media.Debug(b.type)
            BuildBlueprint(b, cyard, owner, blueprints)
			return
		end
	end
    if owner == BadGuy then Media.Debug("Entering?") end

	Trigger.AfterDelay(DateTime.Seconds(1), function() --CHANGE: Change to 1 second
        BuildBase(blueprints, cyard, owner)
    end)
end

local BuildBlueprint = function(blueprint, cyard, owner, blueprints)
    Trigger.AfterDelay(1 --[[Actor.BuildTime(blueprint.type)]], function()   --CHANGE: Change to actual actor buildTime
		if cyard.IsDead or cyard.Owner ~= owner then
			Media.Debug("RETURN - ENTER 1")
            return
		elseif PlayerMoney(owner) <= 299 --[[and IsHarvesterMissing(owner)]] then
            Media.Debug("RETURN - ENTER 2")
            return
		end
		if IsBuildAreaBlocked(owner, blueprint) then
			Media.Debug("Check if build")
            Trigger.AfterDelay(DateTime.Seconds(5), function()

				BuildBlueprint(blueprint, cyard, owner, blueprints)
			end)
			return
		end
		local actor = Actor.Create(blueprint.type, true, { Owner = owner, Location = blueprint.location })
		OnBlueprintBuilt(actor, blueprint, owner)

		Trigger.AfterDelay(DateTime.Seconds(1), function()
            BuildBase(blueprints, cyard, owner)
        end)
	end)
end

local OnBlueprintBuilt = function(actor, blueprint, owner)
    owner.Cash = owner.Cash - blueprint.cost
	blueprint.actor = actor
	MaintainBuilding(actor, blueprint, 0.75)
	if blueprint.onBuilt then
		-- Build() will not work properly on producers if immediately called.
		Trigger.AfterDelay(DateTime.Seconds(1), function()
            blueprint.onBuilt(actor)
		end)
	end
end

local IsBuildAreaBlocked = function(player, blueprint)
    local nw, se = blueprint.northwestEdge, blueprint.southeastEdge
    local blockers = Map.ActorsInBox(nw, se, function(actor)
		-- Neutral check is for ignoring trees near the refinery.
		return actor.Owner ~= Neutral and actor.CenterPosition.Z == 0 and actor.HasProperty("Health") and actor.Type ~= "stek"
	end)
	if #blockers == 0 then
		return false
	end
	ScatterBlockers(player, blockers)
	return true
end

local ScatterBlockers = function(player, actors)
	Utils.Do(actors, function(actor)
		if actor.IsIdle and actor.Owner == player and actor.HasProperty("Scatter") then
			actor.Scatter()
		end
	end)
end

local BeginBaseMaintenance = function(blueprints, owner)
    Utils.Do(blueprints, function(blueprint)
		MaintainBuilding(blueprint.actor, blueprint)
	end)
	Utils.Do(owner.GetActors(), function(actor)
		if actor.HasProperty("StartBuildingRepairs") then
			MaintainBuilding(actor, nil, 0.75)
		end
	end)
end

local MaintainBuilding = function(actor, blueprint, repairThreshold)
    if blueprint then
        Trigger.OnKilled(actor, function() blueprint.actor = nil end)
        Trigger.OnSold(actor, function() blueprint.actor = nil end)
		if not blueprint.northwestEdge then
            PrepareBlueprintEdges(blueprint)
		end
    end

	if repairThreshold then
		local original = actor.Owner

		Trigger.OnDamaged(actor, function()
			if actor.Owner ~= original or actor.Health > actor.MaxHealth * repairThreshold then
				return
			end
			actor.StartBuildingRepairs()
		end)
	end
end

local PrepareBlueprintEdges = function(blueprint)
	local shapeX, shapeY = blueprint.shape[1], blueprint.shape[2]
	local northwestEdge = Map.CenterOfCell(blueprint.location) + WVec.New(-512, -512, 0)
    local southeastEdge = northwestEdge + WVec.New(shapeX * 1024, shapeY * 1024, 0)
	blueprint.northwestEdge = northwestEdge
    blueprint.southeastEdge = southeastEdge
end

local InsertBlueprints = function()
    local t = BadGuyBaseBlueprints
    local build = BadGuyToBeBuilt
    local index = #BadGuyBaseBlueprints + 1

    Utils.Do(BadGuyToBeBuilt, function(b)
        table.insert(t, index, b)
        PrepareBlueprintEdges(b)
    end)
end

local ProduceHarvester = function(owner, factory, delay)
	if PlayerMoney(owner) < Actor.Cost("harv") then
		return
	end

	local toBuild = { "harv" }
	owner.Build(toBuild, function()
		Trigger.AfterDelay(delay, function()
			ProduceArmor(factory)
		end)
	end)
end

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - END 	----------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------	AI ATTACKING BLOCK - START	--------------------
--------------------------------------------------------------------
local function __AI_ATTACKS__() end

SendUnits = function(units, path)
	Utils.Do(units, function(unit)
		if unit.IsDead then
			return
		end

		unit.Patrol(path, false)
		IdleHunt(unit)
	end)
end

-----------------------
--- Inf Attacks     ---
-----------------------

---@param barrack any
---@param owner player
ProduceInfantry = function(barrack, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(2), DateTime.Seconds(4))

	if barrack.IsDead or barrack.Owner ~= owner then
		return
	elseif PlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
		return
	end

    local toBuild = { Utils.Random(InfantryTypes) }
    local allPaths = {}
    if barrack.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
	owner.Build(toBuild, function(units)
        if barrack.Owner == USSR then
            table.insert(InfantryUSSRAttackGroup, units[1])
            if #InfantryUSSRAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryUSSRAttackGroup, path)
                InfantryUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceInfantry(barrack, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(barrack, owner)
			    end) 
            end
        else
            table.insert(InfantryBadGuyAttackGroup, units[1])
            if #InfantryBadGuyAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryBadGuyAttackGroup, path)
                InfantryBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceInfantry(barrack, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(barrack, owner)
			    end) 
            end
        end
	end)
end

-----------------------
--- Tank Attacks    ---
-----------------------

ProduceArmor = function(factory, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if factory.IsDead or factory.Owner ~= owner then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(owner, factory, delay)
        else
            return
        end
    end

	local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if factory.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
	owner.Build(toBuild, function(units)
        if factory.Owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        elseif factory.Owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        end
    end)
end

-----------------------
--- Air Attacks    ----
-----------------------
--[[
ProduceAircraft = function()
    if (USSRAfld1.IsDead or USSRAfld1.Owner ~= USSR) and (USSRAfld2.IsDead or USSRAfld2.Owner ~= USSR) then
        return
    end

    USSR.Build(SovietAircraftType, function(units)
        local plane = units[1]
        PlanesAttackGroup[#PlanesAttackGroup + 1] = plane

        Trigger.OnKilled(plane, ProduceAircraft)

        local alive = Utils.Where(PlanesAttackGroup, function(p) return not p.IsDead end)
        if #alive < 2 then
            Trigger.AfterDelay(ProductionIntervalAir, ProduceAircraft)
        end

        InitializeAttackAircraft(plane, Greece)
    end)
end

PlanesAttack = function()
    local entry = Utils.Random({ IronTankEntry.Location, SovWaterEntry.Location, BadgerEntry.Location })
    local planeType = Utils.Random({SovietAircraftType})
    Media.Debug("Check till here 1")
    for p = 1, #planeType do
        Trigger.AfterDelay(DateTime.Seconds(0.25*p), function()
            local a = Actor.Create(planeType[p], true, { Owner = USSR, Location = entry })
            InitializeAttackAircraft(a, Greece)
        end)
    end
end

CheckPlaneAmmo = function(plane, dir)
    if not plane.IsDead and plane.AmmoCount() >= 1 then
        Trigger.AfterDelay(DateTime.Seconds(3), function()
            CheckPlaneAmmo(plane, dir)
        end)
    elseif not plane.IsDead then
            Trigger.ClearAll(plane)
            plane.Move(dir)
            plane.Destroy()
            return
    end
end
]]
-----------------------
--- Naval Attacks  ----
-----------------------

ProduceSubmarines = function(shipyard, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

    if shipyard.IsDead or shipyard.Owner ~= owner then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(owner, factory, delay)
        else
            return
        end
    end

    local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if shipyard.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
    owner.Build(toBuild, function(units)
        if shipyard.Owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceSubmarines(shipyard, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceSubmarines(shipyard, owner)
                end)
            end
        elseif shipyard.Owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceSubmarines(shipyard, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceSubmarines(shipyard, owner)
                end)
            end
        end
    end)
end

ProduceArmor = function(factory, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if factory.IsDead or factory.Owner ~= owner then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(owner, factory, delay)
        else
            return
        end
    end

	local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if factory.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
	owner.Build(toBuild, function(units)
        if factory.Owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        elseif factory.Owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        end
    end)
end

EnemySubsReinforcements = function()
    local northLeftEdge = WPos.New( (CPos.New(62,18)).X * 1024,  (CPos.New(70,18)).Y * 1024, 0)
    local southRightEdge = WPos.New( (CPos.New(94,54)).X * 1024, (CPos.New(94,54)).Y * 1024, 0)

    local actors = Map.ActorsInBox( northLeftEdge, southRightEdge, function(actor)
		return actor.Owner == Greece and ( actor.Type == "pt" or actor.Type == "dd" or actor.Type == "ca" or actor.Type == "ss" or actor.Type == "spen" or actor.Type == "syrd" or actor.Type == "lst" )
	end)

    if #actors > 0 then
        local subs = Reinforcements.Reinforce(USSR, {"ss", "ss", "ss"}, { SovWaterEntry.Location, SovWaterEntry.Location + CVec.New(0, 2) })
        Utils.Do(subs, function(u)
            if not u.IsDead then
                u.AttackMove(SovWaterWaypoint.Location)
                IdleHunt(u)
            end
        end)
    end

    Trigger.AfterDelay(DateTime.Minutes(2), function()
        EnemySubsReinforcements()
    end)
end

--------------------------------------------------------------------
----------------	AI ATTACKING BLOCK - END        ----------------
--------------------------------------------------------------------
local function __AI_SETUP__() end

AISetup = function()
    BeginBaseMaintenance(USSRBaseBlueprints, USSR)
    BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

    BuildBase(USSRBaseBlueprints, USSRFact, USSR)

    Trigger.AfterDelay(DateTime.Seconds(10), function()
        InsertBlueprints()
    end)

    ProduceInfantry(USSRBarr, USSR)
    ProduceArmor(USSRWeap, USSR)
end