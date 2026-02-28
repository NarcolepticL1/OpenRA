--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

--[[
APPROACH
First of all I tried to stick to the original level spirit more than copying verbatim triggers/events.

ORIGINAL VS ORA VERSION
Again the redeployable MCV changes a few things. At the start of the level the player starts with 2 mcvs. I want to change this a bit (See BALANCE).

BALANCE
First of all the second MCV the player has would only be available on EASY. In Normal the MCV will arrive after X time. In HARD there will be no extra
MCV. If the player wants to secure the right side, he/she must migrate there with the only MCV. 
The closest soviet base doesn't have sams so aircrafts can do quick work of it. I think is better to give the AI (USSR) sams but these will be built after
X time. The X amount will depend on difficulty, so, if the player is quick enough, he/she can weaken the soviet enough so they become less of a threat.


MCV-Deploy
Aircrafts
Spy

As mentioned before, AI will send attacks occasionally but the bulk of the AI efforts will be in protecting the base and other behaviors that make it hard
for the VIP unit to leave the base. Among these changes

OTHER
No secondary objective yet


TL;DR
- Change dog locations, add a way for AI to rebuild them and add patrol
- 
]]

Mcv1Reinforcements =
{
	actors = { "mcv" },
	entryPath = { MCVEntry1.Location, MCVDst1.Location }
}

Mcv2Reinforcements =
{
	actors = { "mcv" },
	entryPath = { MCVEntry2.Location, MCVDst2.Location }
}

Sea1Reinforcements =
{
	actors = { "pt", "pt", "dd", "dd" },
	entryPath = { EnglandLeftEntry.Location }
}

Sea2Reinforcements =
{
	actors = { "pt", "pt", "dd", "dd" },
	entryPath = { EnglandRightEntry.Location }
}

Sea3Reinforcements =
{
	actors = { "ca" },
	entryPath = { EnglandLeftEntry.Location }
}

Sea4Reinforcements =
{
	actors = { "ca" },
	entryPath = { EnglandRightEntry.Location }
}

Sea3Sea4Units = {}

Sea1PatrolPath = { WP27.Location, WP52.Location, WP53.Location, WP54.Location, WP55.Location, WP56.Location, EnglandLeftDst.Location }
Sea2PatrolPath = { WP59.Location, WP60.Location, WP61.Location, WP62.Location, WP63.Location, WP64.Location, EnglandRightDst.Location }

MmthPatrolPath =
{
	MammothPatrolWP1.Location, MammothPatrolWP2.Location, MammothPatrolWP3.Location, MammothPatrolWP4.Location, MammothPatrolWP5.Location,
	MammothPatrolWP6.Location, MammothPatrolWP7.Location, MammothPatrolWP8.Location, MammothPatrolWP9.Location, MammothPatrolWP10.Location
}

SentNavy = false
SentCa = false

EdgeOfRiverTriggerActivator =
{
	CPos.New(50,1), CPos.New(51,1), CPos.New(52,1), CPos.New(53,1), CPos.New(54,1), CPos.New(55,1),
	CPos.New(56,1), CPos.New(57,1), CPos.New(58,1), CPos.New(59,1), CPos.New(60,1), CPos.New(61,1),
	CPos.New(62,1), CPos.New(63,1), CPos.New(64,1), CPos.New(65,1), CPos.New(66,1), CPos.New(67,1),
	CPos.New(68,1), CPos.New(69,1), CPos.New(70,1), CPos.New(71,1), CPos.New(72,1), CPos.New(73,1),
	CPos.New(74,1), CPos.New(75,1), CPos.New(76,1), CPos.New(77,1), CPos.New(78,1), CPos.New(79,1),
	CPos.New(80,1), CPos.New(81,1), CPos.New(82,1), CPos.New(83,1), CPos.New(84,1), CPos.New(85,1),
	CPos.New(50,2), CPos.New(51,2), CPos.New(52,2), CPos.New(53,2), CPos.New(54,2), CPos.New(55,2),
	CPos.New(56,2), CPos.New(57,2), CPos.New(58,2), CPos.New(59,2), CPos.New(60,2), CPos.New(61,2),
	CPos.New(62,2), CPos.New(63,2), CPos.New(64,2), CPos.New(65,2), CPos.New(66,2), CPos.New(67,2),
	CPos.New(68,2), CPos.New(69,2), CPos.New(70,2), CPos.New(71,2), CPos.New(72,2), CPos.New(73,2),
	CPos.New(74,2), CPos.New(75,2), CPos.New(76,2), CPos.New(77,2), CPos.New(78,2), CPos.New(79,2),
	CPos.New(80,2), CPos.New(81,2), CPos.New(82,2), CPos.New(83,2), CPos.New(84,2), CPos.New(85,2)
}


TimerTicks = DateTime.Minutes(72)

InitialSovietPatrols = function()
	mmth1.Patrol(MmthPatrolPath, true, DateTime.Seconds(12))
	mmth2.Patrol(MmthPatrolPath, true, DateTime.Seconds(12))
end

InitialAlliedReinforcements = function()
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Media.PlaySpeechNotification(Greece, "ReinforcementsArrived")
		Reinforcements.Reinforce(Greece, Mcv1Reinforcements.actors, Mcv1Reinforcements.entryPath)
	end)
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Reinforcements.Reinforce(Greece, Mcv2Reinforcements.actors, Mcv2Reinforcements.entryPath)
	end)
end

TimerExpiredSendNavy = function()
	if SentNavy then
		return
	end
	SentNavy = true
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Media.PlaySpeechNotification(Greece, "AlliedForcesApproaching")
		local sea1Units = Reinforcements.Reinforce(England, Sea1Reinforcements.actors, Sea1Reinforcements.entryPath)
		Utils.Do(sea1Units, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Patrol(Sea1PatrolPath, false, DateTime.Seconds(2))
			end)
			Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a)
				if a.Owner == England and a.Type == "dd" or a.Type == "pt" then
					a.Destroy()
				end
			end)
		end)
		local sea2Units = Reinforcements.Reinforce(England, Sea2Reinforcements.actors, Sea2Reinforcements.entryPath)
		Utils.Do(sea2Units, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Patrol(Sea2PatrolPath, false, DateTime.Seconds(2))
			end)
			Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a)
				if a.Owner == England and a.Type == "dd" or a.Type == "pt" then
					a.Destroy()
				end
			end)
		end)
	end)
	Trigger.AfterDelay(DateTime.Seconds(10), TimerExpiredSendCa)
end

TimerExpiredSendCa = function()
	if SentCa then
		return
	end
	SentCa = true
	Trigger.AfterDelay(DateTime.Seconds(30), function()
		local sea3Units = Reinforcements.Reinforce(England, Sea3Reinforcements.actors, Sea3Reinforcements.entryPath)
		Utils.Do(sea3Units, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Move(WP57.Location, 0)
			end)
			Trigger.OnKilled(a, function()
				USSR.MarkCompletedObjective(USSRObj)
			end)
		end)
		local sea4Units = Reinforcements.Reinforce(England, Sea4Reinforcements.actors, Sea4Reinforcements.entryPath)
		Utils.Do(sea4Units, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Move(WP65.Location, 0)
			end)
			Trigger.OnKilled(a, function()
				USSR.MarkCompletedObjective(USSRObj)
			end)
		end)
		count = 0
		Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a, id)
			if a.Owner == England and a.Type =="ca" then
				count = count + 1
				a.Destroy()
				if count == 2 then
					Greece.MarkCompletedObjective(ClearNavalChannel)
					Trigger.RemoveFootprintTrigger(id)
				end		
			end			
		end)
	end)
end

FinishTimer = function()
	for i = 0, 9, 1 do
		local c = TimerColor
		if i % 2 == 0 then
			c = HSLColor.White
		end
		Trigger.AfterDelay(DateTime.Seconds(i), function() UserInterface.SetMissionText("Naval vessels have arrived!", c) end)
	end
	Trigger.AfterDelay(DateTime.Seconds(10), function() UserInterface.SetMissionText("") end)
end

InitTriggers = function()
	Greece.Cash = 5000

	InitialAlliedReinforcements()
	InitialSovietPatrols()

	


end

PrepareObjectives = function()
	InitObjectives(Greece)

	ClearNavalChannel = Greece.AddObjective("Clear the naval channel.")

	USSRObj = USSR.AddObjective("Eliminate all Allied forces.")
end

Ticked = TimerTicks
Tick = function()
	USSR.Cash = 5000
	BadGuy.Cash = 10000
	if Greece.HasNoRequiredUnits() then
		USSR.MarkCompletedObjective(USSRObj)
	end
	if Ticked > 0 then
		UserInterface.SetMissionText("Naval vessels arrive in " .. Utils.FormatTime(Ticked), TimerColor)
		Ticked = Ticked - 1
		if USSR.HasNoRequiredUnits() and BadGuy.HasNoRequiredUnits() then
			Ticked = 0
		end
	elseif Ticked == 0 then
		FinishTimer()
		TimerExpiredSendNavy()
		Ticked = Ticked - 1
	end
end

WorldLoaded = function()
	Camera.Position = DefaultCameraPosition.CenterPosition

	Greece = Player.GetPlayer("Greece")
	USSR = Player.GetPlayer("USSR")
	BadGuy = Player.GetPlayer("BadGuy")
	England = Player.GetPlayer("England")
	Neutral = Player.GetPlayer("Neutral")

	SetDifficulty()
	InitTriggers()
	PrepareObjectives()

	--ToBeRemoved()

	Trigger.AfterDelay(DateTime.Seconds(30), function()
		SetupAIActivities()
	end)

	Trigger.OnPlayerLost(Greece, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(USSR, "MissionFailed")
		end)
	end)	
	Trigger.OnPlayerWon(Greece, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(USSR, "MissionAccomplished")
		end)
	end)

	TimerColor = Greece.Color
end
