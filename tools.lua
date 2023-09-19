function addblipGC()
	gcblip = AddBlipForCoord(Config.Blip)
	SetBlipAsFriendly(gcblip, true)
	SetBlipSprite(gcblip, 109)
	if isGolfOpen then		
		SetBlipColour(gcblip, 2)
	else
		SetBlipColour(gcblip, 3)
	end
	SetBlipAsShortRange(gcblip,true)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("Los Santos Golf Club"))
	EndTextCommandSetBlipName(gcblip)
end

function endGame()

	isGameRunning = false
	golfHole = 1
	DeleteObject(mygolfball)
	mygolfball = nil
	golfclub = 1
	clubname = "None"
	power = 0.1
	isBallInHole = false
	isBallMoving = false
	isPlaying = false
	doingdrop = false
	golfstrokes = 0
	totalgolfstrokes = 0
	TriggerEvent('destroyProp')

	_removeStartEndCurrentHole()
	_removeBallBlip()
	N_0xa356990e161c9e65(false)
	lib.hideTextUI(GolfText)
	Wait(5)
	lib.hideTextUI()
end

function displayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 0, -1)
end

function blipsStartEndCurrentHole()
	if startblip ~= nil then
		RemoveBlip(startblip)
		RemoveBlip(endblip)
	end
	startblip = AddBlipForCoord(holes[golfHole]["x"],holes[golfHole]["y"],holes[golfHole]["z"])
	SetBlipAsFriendly(startblip, true)
	SetBlipSprite(startblip, 379)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("Start of Hole"))
	EndTextCommandSetBlipName(startblip)
	endblip = AddBlipForCoord(holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"])
	SetBlipAsFriendly(endblip, true)
	SetBlipSprite(endblip, 358)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("End of Hole"))
	EndTextCommandSetBlipName(endblip)
end

function _removeStartEndCurrentHole()
	if startblip ~= nil then
		RemoveBlip(startblip)
		RemoveBlip(endblip)
	end
end

function _removeBallBlip()
	if ballBlip ~= nil then
		RemoveBlip(ballBlip)
	end
end

function createBall(x,y,z)
	
	if ballBlip ~= nil then
		RemoveBlip(ballBlip)
	end

	DeleteObject(mygolfball)
	mygolfball = CreateObject(GetHashKey("prop_golf_ball"), x, y, z, true, true, false)

	SetEntityRecordsCollisions(mygolfball,true)
	SetEntityCollision(mygolfball, true, true)
	SetEntityHasGravity(mygolfball, true)
	FreezeEntityPosition(mygolfball, true)
	local curHeading = GetEntityHeading(GetPlayerPed(-1))
	SetEntityHeading(mygolfball, curHeading)
	
	addBallBlip()
end

function addBallBlip()
	ballBlip = AddBlipForEntity(mygolfball)
	SetBlipAsFriendly(ballBlip, true)
	SetBlipSprite(ballBlip, 1)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("Golf ball position"))
	EndTextCommandSetBlipName(ballBlip)
end

function idleShot()
	power = 0.1
	local parr = "PAR: " .. holes[golfHole]["par"]
	local holenum = "Hole: " .. golfHole
	local distance = GetDistanceBetweenCoords(GetEntityCoords(mygolfball), holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], true)
	local dst = math.ceil(distance) .. "m"
	if distance >= 200.0 then
		golfclub = 3 -- wood 200m-250m
	elseif distance >= 150.0 and distance < 200.0 then
		golfclub = 1 -- iron 1 140m-180m
	elseif distance >= 120.0 and distance < 250.0 then
		golfclub = 4 -- iron 3 -- 120m-150m
	elseif distance >= 90.0 and distance < 120.0 then
		golfclub = 5 -- -- iron 5 -- 70m-120m
	elseif distance >= 50.0 and distance < 90.0 then
		golfclub = 6 -- iron 7 -- 50m-100m
	elseif distance >= 20.0 and distance < 50.0 then
		golfclub = 2 --  wedge 50m-80m
	else
		golfclub = 0 -- else putter
	end

	_attachClub()
	RequestScriptAudioBank("GOLF_I", 0)

	while isPlaying do
		local ballcoords = GetEntityCoords(mygolfball)
		local ballheading = GetEntityHeading(mygolfball)
		local bfov = GetObjectOffsetFromCoords(ballcoords.x, ballcoords.y, ballcoords.z, ballheading, -2.5, 0.0, 15.0)
	
		local _, grass = GetGroundZAndNormalFor_3dCoord(bfov.x, bfov.y, bfov.z)
		grass = grass + 0.2

		Citizen.Wait(0)

		if (IsControlPressed(1, 38)) then
			addition = 0.5

			if power > 25 then
				addition = addition + 0.1
			end
			if power > 50 then
				addition = addition + 0.2
			end
			if power > 75 then
				addition = addition + 0.3
			end
			power = power + addition
			if power > 100.0 then
				power = 1.0
			end
		end


		Citizen.CreateThread(
      		function()
        		
				Scaleform = RequestScaleformMovie('golf')
        		while not HasScaleformMovieLoaded(Scaleform) do
          			Citizen.Wait(0)
        		end

            	if isPlaying == true then
              	 BeginScaleformMovieMethod(Scaleform, 'SWING_METER_TRANSITION_IN')
              	 EndScaleformMovieMethod()

    	         BeginScaleformMovieMethod(Scaleform, 'SWING_METER_POSITION')
              	 ScaleformMovieMethodAddParamFloat(0.70)
              	 ScaleformMovieMethodAddParamFloat(0.65)
            	 EndScaleformMovieMethod()

              	 BeginScaleformMovieMethod(Scaleform, 'SWING_METER_SET_FILL')
              	 ScaleformMovieMethodAddParamBool(true)
              	 EndScaleformMovieMethod()

              	 BeginScaleformMovieMethod(Scaleform, 'SWING_METER_SET_MARKER')
              	 ScaleformMovieMethodAddParamBool(true)
              	 ScaleformMovieMethodAddParamFloat((power * 2) / 200)
            	 ScaleformMovieMethodAddParamBool(false)
              	 EndScaleformMovieMethod()

				 BeginScaleformMovieMethod(Scaleform, 'SET_DISPLAY')
				 ScaleformMovieMethodAddParamBool(true)
              	 EndScaleformMovieMethod()
				 
				 BeginScaleformMovieMethod(Scaleform, 'SET_HOLE_DISPLAY')
				 PushScaleformMovieMethodParameterString(holenum)
				 PushScaleformMovieMethodParameterString(parr)
				 PushScaleformMovieMethodParameterString(dst)
				 EndScaleformMovieMethod()


            	else
              	 BeginScaleformMovieMethod(Scaleform, 'SWING_METER_TRANSITION_OUT')
              	 EndScaleformMovieMethod()
            	end
              	DrawScaleformMovieFullscreen(Scaleform, 255, 255, 255, 255)
      		end
     	)

		local offsetball = GetOffsetFromEntityInWorldCoords(mygolfball, (power) - (power*2), 0.0, 0.0)

		DrawLine(GetEntityCoords(mygolfball), holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], 222, 111, 111, 0.2)

		DrawMarker(27,holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], 0, 0, 0, 0, 0, 0, 0.5, 0.5, 10.3, 212, 189, 0, 105, 0, 0, 2, 0, 0, 0, 0)

		DrawMarker(3, bfov.x, bfov.y, grass, 0, 0, 0, 0.0, 180.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 155, false, true, 2, false, GolfPutting, PuttingMarker, false)


		if (IsControlJustPressed(1, 246)) then
			local newclub = golfclub+1
			if newclub > 6 then
				newclub = 0
			end
			golfclub = newclub
			_attachClub()
		end

		if (IsControlPressed(1, 34)) then
			_rotateShot(true)
		end
		if (IsControlPressed(1, 9)) then
			_rotateShot(false)
		end

		if golfclub == 0 then
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.14, -0.62, 0.99, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		elseif golfclub == 3 then
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.3, -0.92, 0.99, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		elseif golfclub == 2 then
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.38, -0.79, 0.94, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		else
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.4, -0.83, 0.94, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		end
		if (IsControlJustReleased(1, 38)) then
			if golfclub == 0 then
				playAnim = puttSwing["puttswinglow"]
			else
				playAnim = ironSwing["ironswinghigh"]
				playGolfAnim(playAnim)
				playAnim = ironSwing["ironswinglow"]
				playGolfAnim(playAnim)
				playAnim = ironSwing["ironswinglow"]
			end

			isPlaying = false
			inLoop = false
			DetachEntity(GetPlayerPed(-1), true, false)
		else
			if not inLoop then
				TriggerEvent("loopStart")
			end
		end
	end

	PlaySoundFromEntity(-1, "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER", GetPlayerPed(-1), 0, 0, 0)

	playGolfAnim(playAnim)
	swing()

	Citizen.Wait(3380)
	endShot()

	if isBallInGolf == false or isBallInEtang1 == true or isBallInEtang2 == true or isBallInEtang3 == true then

		lib.notify({
			title = 'Los Santos Golf Club',
			description = 'Your ball is off-limit or in water redropping from here with 1 penality.',
			type = 'inform'
		})

		x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
		createBall(x,y,z-1)
		golfstrokes = golfstrokes + 1
	end
end

function swing()
	
	if golfclub ~= 0 then
		ballCam()
	end
	if not HasNamedPtfxAssetLoaded("scr_minigamegolf") then
		RequestNamedPtfxAsset("scr_minigamegolf")
		while not HasNamedPtfxAssetLoaded("scr_minigamegolf") do
			Wait(0)
		end
	end
	SetPtfxAssetNextCall("scr_minigamegolf")
	StartParticleFxLoopedOnEntity("scr_golf_ball_trail", mygolfball, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

	local enabledroll = false

	dir = GetEntityHeading(mygolfball)
	local x,y = quickmafs(dir)
	FreezeEntityPosition(mygolfball, false)
	local rollpower = power / 3

	if golfclub == 0 then -- putter
		power = power / 3
		local check = 5.0
		while check < power do
			SetEntityVelocity(mygolfball, x*check,y*check,-0.1)
			Citizen.Wait(20)
			check = check + 0.3
		end

		power = power
		while power > 0 do
			SetEntityVelocity(mygolfball, x*power,y*power,-0.1)
			Citizen.Wait(20)
			power = power - 0.3
		end

	elseif golfclub == 1 then -- iron 1 140m-180m
		power = power * 1.85
		airpower = power / 2.6
		enabledroll = true
		rollpower = rollpower / 4
	elseif golfclub == 3 then -- Driver 200m-250m
		power = power * 2.0
		airpower = power / 2.6
		enabledroll = true
		rollpower = rollpower / 2
	elseif golfclub == 2 then -- wedge -- 50m-80m
		power = power * 1.5
		airpower = power / 2.1
		enabledroll = true
		rollpower = rollpower / 4.5
	elseif golfclub == 4 then -- iron 3 -- 110m-150m
		power = power * 1.8
		airpower = power / 2.55
		enabledroll = true
		rollpower = rollpower / 5
	elseif golfclub == 5 then -- iron 5 -- 70m-120m
		power = power * 1.75
		airpower = power / 2.5
		enabledroll = true
		rollpower = rollpower / 5.5
	elseif golfclub == 6 then -- iron 7 -- 50m-100m
		power = power * 1.7
		airpower = power / 2.45
		enabledroll = true
		rollpower = rollpower / 6.0
	end

	while power > 0 do
		SetEntityVelocity(mygolfball, x*power,y*power,airpower)
		Citizen.Wait(0)
		power = power - 1
		airpower = airpower - 1
	end

	if enabledroll then
		while rollpower > 0 do
			SetEntityVelocity(mygolfball, x*rollpower,y*rollpower,0.0)
			Citizen.Wait(5)
			rollpower = rollpower - 1
		end
	end

	Citizen.Wait(2000)

	SetEntityVelocity(mygolfball,0.0,0.0,0.0)

	if golfclub ~= 0 then
		ballCamOff()
	end

	FreezeEntityPosition(mygolfball, true)
	local x,y,z = table.unpack(GetEntityCoords(mygolfball))
	createBall(x,y,z)

	-- CHECKBALL POSITION
	local mygolfballCoord = GetEntityCoords(mygolfball)

	isBallInGolf = golfArea:isPointInside(mygolfballCoord)
	isBallInEtang1 = etang1:isPointInside(mygolfballCoord)
	isBallInEtang2 = etang2:isPointInside(mygolfballCoord)
	isBallInEtang3 = etang3:isPointInside(mygolfballCoord)
	if isBallInGolf and isBallInEtang1 == false and isBallInEtang2 == false and isBallInEtang3 == false then
		lib.notify({
			title = 'Los Santos Golf Club',
			description = 'Ball still in golf area and not in water',
			type = 'success'
		})
	else
		lib.notify({
			title = 'Los Santos Golf Club',
			description = 'Ball Out of Bounds',
			type = 'error'
		})
	end

end

function endShot()
	TriggerEvent("attachItem","golfbag01")
	inTask = false
	golfstrokes = golfstrokes + 1
	local ballLoc = GetEntityCoords(mygolfball)
	local distance = GetDistanceBetweenCoords(ballLoc.x,ballLoc.y,ballLoc.z, holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], true)
	if distance < 0.5 then
		TriggerEvent("customNotification","You got the ball with in range!")
		if golfstrokes == holes[golfHole]["par"] then
			Citizen.CreateThread(function()
				function Initialize(parscaleform)
					local parscaleform = RequestScaleformMovie(parscaleform)
			
					while not HasScaleformMovieLoaded(parscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(parscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("Par")
					PopScaleformMovieFunctionVoid()
					
					PushScaleformMovieFunction(parscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return parscaleform

				end
				parscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(parscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == (holes[golfHole]["par"] - 1) then
			Citizen.CreateThread(function()
				function Initialize(birscaleform)
					local birscaleform = RequestScaleformMovie(birscaleform)
			
					while not HasScaleformMovieLoaded(birscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(birscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("Birdie")
					PopScaleformMovieFunctionVoid()

					PushScaleformMovieFunction(birscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return birscaleform
				end
				birscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(birscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == (holes[golfHole]["par"] - 2) then
			Citizen.CreateThread(function()
				function Initialize(eagscaleform)
					local eagscaleform = RequestScaleformMovie(eagscaleform)
			
					while not HasScaleformMovieLoaded(eagscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(eagscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("EAGLE")
					PopScaleformMovieFunctionVoid()
					
					PushScaleformMovieFunction(eagscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return eagscaleform

				end
				eagscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(eagscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == (holes[golfHole]["par"] - 3) then
			Citizen.CreateThread(function()
				function Initialize(eagscaleform)
					local deagscaleform = RequestScaleformMovie(deagscaleform)
			
					while not HasScaleformMovieLoaded(deagscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(deagscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("DOUBLE EAGLE")
					PopScaleformMovieFunctionVoid()
					
					PushScaleformMovieFunction(deagscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return deagscaleform

				end
				deagscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(deagscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == (holes[golfHole]["par"] + 1) then
			Citizen.CreateThread(function()
				function Initialize(bogscaleform)
					local bogscaleform = RequestScaleformMovie(bogscaleform)
		
					while not HasScaleformMovieLoaded(bogscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(bogscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("Bogey")
					PopScaleformMovieFunctionVoid()

					PushScaleformMovieFunction(bogscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return bogscaleform
				end
				bogscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(bogscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == (holes[golfHole]["par"] + 2) then
			Citizen.CreateThread(function()
				function Initialize(dbogscaleform)
					local dbogscaleform = RequestScaleformMovie(dbogscaleform)
		
					while not HasScaleformMovieLoaded(dbogscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(dbogscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("Double Bogey")
					PopScaleformMovieFunctionVoid()

					PushScaleformMovieFunction(dbogscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return dbogscaleform
				end
				dbogscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(dbogscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == (holes[golfHole]["par"] + 3) then
			Citizen.CreateThread(function()
				function Initialize(tbogscaleform)
					local tbogscaleform = RequestScaleformMovie(tbogscaleform)
		
					while not HasScaleformMovieLoaded(tbogscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(tbogscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("Triple Bogey")
					PopScaleformMovieFunctionVoid()

					PushScaleformMovieFunction(tbogscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return tbogscaleform
				end
				tbogscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(tbogscaleform, 255, 255, 255, 255, 0)
				end
			end)
		elseif golfstrokes == 1 then
			Citizen.CreateThread(function()
				function Initialize(hioscaleform)
					local hioscaleform = RequestScaleformMovie(hioscaleform)
		
					while not HasScaleformMovieLoaded(hioscaleform) do
						Citizen.Wait(0)
					end
					PushScaleformMovieFunction(hioscaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					PushScaleformMovieFunctionParameterString("HOLE IN ONE")
					PopScaleformMovieFunctionVoid()

					PushScaleformMovieFunction(hioscaleform, "TRANSITION_OUT")
					PushScaleformMovieMethodParameterInt(5)
					PopScaleformMovieFunctionVoid()

					return hioscaleform
				end
				hioscaleform = Initialize("mp_big_message_freemode")
				while true do
					Citizen.Wait(0)
					DrawScaleformMovieFullscreen(hioscaleform, 255, 255, 255, 255, 0)
				end
			end)
		end
		totalgolfstrokes = golfstrokes + totalgolfstrokes
		golfstrokes = 0
		isBallInHole = true
	end
end

function dropShot()
	doingdrop = true
	while doingdrop do

		Citizen.Wait(0)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(mygolfball), GetEntityCoords(GetPlayerPed(-1)), true)
		local distanceHole = GetDistanceBetweenCoords(holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], GetEntityCoords(GetPlayerPed(-1)), true)
		if distance < 50.0 and distanceHole > 50.0 then
			DisplayHelpText("Press ~g~E~s~ to drop here.")
			if ( IsControlJustReleased(1, 38) ) then
				doingdrop = false
				x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
				createBall(x,y,z-1)
				golfstrokes = golfstrokes + 1
			end
		else
			DisplayHelpText("Press ~g~E~s~ to drop - ~r~ too far from ball or to close to hole.")
		end
	end
end


function quickmafs(dir)
	local x = 0.0
	local y = 0.0
	local dir = dir
	if dir >= 0.0 and dir <= 90.0 then
		local factor = (dir/9.2) / 10
		x = -1.0 + factor
		y = 0.0 - factor
	end

	if dir > 90.0 and dir <= 180.0 then
		dirp = dir - 90.0
		local factor = (dirp/9.2) / 10
		x = 0.0 + factor
		y = -1.0 + factor
	end

	if dir > 180.0 and dir <= 270.0 then
		dirp = dir - 180.0
		local factor = (dirp/9.2) / 10
		x = 1.0 - factor
		y = 0.0 + factor
	end

	if dir > 270.0 and dir <= 360.0 then
		dirp = dir - 270.0
		local factor = (dirp/9.2) / 10
		x = 0.0 - factor
		y = 1.0 - factor
	end
	return x,y
end

function _attachClub()

	if golfclub == 3 then
		TriggerEvent("attachItem","golfdriver01")
		clubname = "Driver"
	elseif golfclub == 2 then
		TriggerEvent("attachItem","golfwedge01")
		clubname = "Wedge"
	elseif golfclub == 1 then
		TriggerEvent("attachItem","golfiron01")
		clubname = "1 Iron"
	elseif golfclub == 4 then
		TriggerEvent("attachItem","golfiron03")
		clubname = "3 Iron"
	elseif golfclub == 5 then
		TriggerEvent("attachItem","golfiron05")
		clubname = "5 Iron"
	elseif golfclub == 6 then
		TriggerEvent("attachItem","golfiron07")
		clubname = "7 Iron"
	else
		TriggerEvent("attachItem","golfputter01")
		clubname = "Putter"
	end
end

function _rotateShot(moveType)
	local curHeading = GetEntityHeading(mygolfball)
	if curHeading >= 360.0 then
		curHeading = 0.0
	end
	if moveType then
		SetEntityHeading(mygolfball, curHeading-0.7)
	else
		SetEntityHeading(mygolfball, curHeading+0.7)
	end
end

RegisterNetEvent('customNotification')
AddEventHandler('customNotification', function(response)
	lib.notify({
		title = 'Los Santos Golf Club',
		description = response,
		type = 'inform'
	})
	print('GOOD JOB')
end)

RegisterNetEvent('destroyProp')
AddEventHandler('destroyProp', function()
	removeAttachedProp()
end)

RegisterNetEvent('attachProp')
AddEventHandler('attachProp', function(attachModelSent,boneNumberSent,x,y,z,xR,yR,zR)
	removeAttachedProp()
	attachModel = GetHashKey(attachModelSent)
	boneNumber = boneNumberSent
	SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263)
	local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumberSent)
	--local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Citizen.Wait(100)
	end
	attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(attachedProp, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end)

attachPropList = {

	["golfbag01"] = {
		["model"] = "prop_golf_bag_01", ["bone"] = 24816, ["x"] = 0.12,["y"] = -0.3,["z"] = 0.0,["xR"] = -75.0,["yR"] = 190.0, ["zR"] = 92.0
	},

	["golfputter01"] = {
		["model"] = "prop_golf_putter_01", ["bone"] = 57005, ["x"] = 0.0,["y"] = -0.05,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},

	["golfiron01"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.125,["y"] = 0.04,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfiron03"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.126,["y"] = 0.041,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfiron05"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.127,["y"] = 0.042,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfiron07"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.128,["y"] = 0.043,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfwedge01"] = {
		["model"] = "prop_golf_pitcher_01", ["bone"] = 57005, ["x"] = 0.17,["y"] = 0.04,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},

	["golfdriver01"] = {
		["model"] = "prop_golf_driver", ["bone"] = 57005, ["x"] = 0.14,["y"] = 0.00,["z"] = 0.0,["xR"] = 160.0,["yR"] = -60.0, ["zR"] = 10.0
	}

}

RegisterNetEvent('attachItem')
AddEventHandler('attachItem', function(item)
	TriggerEvent("attachProp",attachPropList[item]["model"], attachPropList[item]["bone"], attachPropList[item]["x"], attachPropList[item]["y"], attachPropList[item]["z"], attachPropList[item]["xR"], attachPropList[item]["yR"], attachPropList[item]["zR"])
end)

function playGolfAnim(anim)
	loadAnimDict( "mini@golf" )
	if IsEntityPlayingAnim(lPed, "mini@golf", anim, 3) then

	else
		length = GetAnimDuration("mini@golf", anim)
		TaskPlayAnim( GetPlayerPed(-1), "mini@golf", anim, 1.0, -1.0, length, 0, 1, 0, 0, 0)
		Citizen.Wait(length)
	end
end

function playAudio(num)
	RequestScriptAudioBank("GOLF_I", 0)
	PlaySoundFromEntity(-1, sounds[num], GetPlayerPed(-1), 0, 0, 0)
end

sounds = {
	[1] = "GOLF_SWING_GRASS_LIGHT_MASTER",
	[2] = "GOLF_SWING_GRASS_PERFECT_MASTER",
	[3] = "GOLF_SWING_GRASS_MASTER",
	[4] = "GOLF_SWING_TEE_LIGHT_MASTER",
	[5] = "GOLF_SWING_TEE_PERFECT_MASTER",
	[6] = "GOLF_SWING_TEE_MASTER",
	[7] = "GOLF_SWING_TEE_IRON_LIGHT_MASTER",
	[8] = "GOLF_SWING_TEE_IRON_PERFECT_MASTER",
	[9] = "GOLF_SWING_TEE_IRON_MASTER",
	[10] = "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER",
	[11] = "GOLF_SWING_FAIRWAY_IRON_PERFECT_MASTER",
	[12] = "GOLF_SWING_FAIRWAY_IRON_MASTER",
	[13] = "GOLF_SWING_ROUGH_IRON_LIGHT_MASTER",
	[14] = "GOLF_SWING_ROUGH_IRON_PERFECT_MASTER",
	[15] = "GOLF_SWING_ROUGH_IRON_MASTER",
	[16] = "GOLF_SWING_SAND_IRON_LIGHT_MASTER",
	[17] = "GOLF_SWING_SAND_IRON_PERFECT_MASTER",
	[18] = "GOLF_SWING_SAND_IRON_MASTER",
	[19] = "GOLF_SWING_CHIP_LIGHT_MASTER",
	[20] = "GOLF_SWING_CHIP_PERFECT_MASTER",
	[21] = "GOLF_SWING_CHIP_MASTER",
	[22] = "GOLF_SWING_CHIP_GRASS_LIGHT_MASTER",
	[23] = "GOLF_SWING_CHIP_GRASS_MASTER",
	[24] = "GOLF_SWING_CHIP_SAND_LIGHT_MASTER",
	[25] = "GOLF_SWING_CHIP_SAND_PERFECT_MASTER",
	[26] = "GOLF_SWING_CHIP_SAND_MASTER",
	[27] = "GOLF_SWING_PUTT_MASTER",
	[28] = "GOLF_FORWARD_SWING_HARD_MASTER",
	[29] = "GOLF_BACK_SWING_HARD_MASTER"
}

function lookingForBall()
	Citizen.Wait(0)
	if GetVehiclePedIsIn(GetPlayerPed(-1), false) == 0 then
		local ballLoc = GetEntityCoords(mygolfball)
		local playerLoc = GetEntityCoords(GetPlayerPed(-1))
		local distance = GetDistanceBetweenCoords(ballLoc.x,ballLoc.y,ballLoc.z, playerLoc.x,playerLoc.y,playerLoc.z, true)
		-- if distance < 50.0 then
		-- 	DisplayHelpText("Move to your ball, press ~g~E~s~ to ball drop if you are stuck.")
		-- 	if ( IsControlJustReleased(1, 38) ) then
		-- 		dropShot()
		-- 	end
		-- end

		if (distance < 5.0) and not doingdrop then
			isPlaying = true
		end
	end
end

function removeAttachedProp()
	DeleteEntity(attachedProp)
	attachedProp = 0
	ClearPedTasks(PlayerPedId())
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

function ballCam()
	ballcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	--AttachCamToEntity(ballcam, mygolfball, -2.0,0.0,-2.0, false)
	SetCamFov(ballcam, 90.0)
	RenderScriptCams(true, true, 3, 1, 0)

	TriggerEvent("camFollowBall")
end

function ballCamOff()
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(ballcam, false)
end

RegisterNetEvent('camFollowBall')
AddEventHandler('camFollowBall', function()
	local timer = 20000
	while timer > 0 do
		Citizen.Wait(5)
		x,y,z = table.unpack(GetEntityCoords(mygolfball))
		SetCamCoord(ballcam, x,y-10,z+9)
		PointCamAtEntity(ballcam, mygolfball, 0.0, 0.0, 0.0, true)
		timer = timer - 1
	end
end)

ironSwing = {
	["ironshufflehigh"] = "iron_shuffle_high",
	["ironshufflelow"] = "iron_shuffle_low",
	["ironshuffle"] = "iron_shuffle",
	["ironswinghigh"] = "iron_swing_action_high",
	["ironswinglow"] = "iron_swing_action_low",
	["ironidlehigh"] = "iron_swing_idle_high",
	["ironidlelow"] = "iron_swing_idle_low",
	["ironidle"] = "iron_shuffle",
	["ironswingintro"] = "iron_swing_intro_high"
}


puttSwing = {
	["puttshufflelow"] = "iron_shuffle_low",
	["puttshuffle"] = "iron_shuffle",
	["puttswinglow"] = "putt_action_low",
	["puttidle"] = "putt_idle_low",
	["puttintro"] = "putt_intro_low",
	["puttintro"] = "putt_outro"
}


RegisterNetEvent('loopStart')
AddEventHandler('loopStart', function()
	inLoop = true
	while inLoop do
		Citizen.Wait(0)
		idleLoop()
	end
end)

function idleLoop()
	if golfclub == 0 then
		playAnim = puttSwing["puttidle"]
	else
		if (IsControlPressed(1, 38)) then
			playAnim = ironSwing["ironidlehigh"]
		else
			playAnim = ironSwing["ironidle"]
		end
	end
	playGolfAnim(playAnim)
	Citizen.Wait(1200)
end

--- OX LIB ---
lib.registerContext({
	id = 'LSGC',
	title = 'Los Santos Golf Club',
	options = {
	  {
		title = 'Golf Club Membership',
		description = 'Example button description',
		icon = 'fa-id-card',
		onSelect = function()
		  TriggerServerEvent('RRGolf:buyMembership')
		end,
		metadata = {
		  {label = 'Price', value = Config.MemberPrice},
		},
	  },
	}
})

lib.registerContext({
	id = 'LSGC Golf',
	title = 'Los Santos Golf Club',
	options = {
	  {
		title = 'Golf',
		description = 'Play a 9 Hole Round of Golf',
		icon = '',
		menu = 'solo_group',
	  },
	  {
		title = 'End Game',
		description = 'End the round of Golf early',
		icon = '',
		onSelect = function()
			if isGameRunning == true then
				TriggerEvent('RRGolf:Ending')
			elseif isGameRunning == false then
				lib.notify({
					title = 'Los Santos Golf Club',
					description = 'You\'re not in a match',
					type = 'error'
				})
			end
		end,
	  },
	}
})

lib.registerContext({
	id = 'solo_group',
	title = 'Solo or Group',
	menu = 'LSGC Golf',
	onBack = function()
	  print('Went back!')
	end,
	options = {
		{
			title = 'Solo Play',
			description = 'Play by Yourself',
			icon = 'user',
			onSelect = function()
				if isGameRunning == true then
					lib.notify({
						title = 'Los Santos Golf Club',
						description = 'You\'re already in a match',
						type = 'error'
					})
				elseif isGameRunning == false then	
					TriggerServerEvent('RRP-Golf:Solos')
				end
			end,
		},
		{
			title = 'Group Play',
			description = 'Play with up to 4 People',
			icon = 'users',
			menu = 'group',
		}
	}
})

lib.registerContext({
	id = 'group',
	title = 'Group Menu',
	menu = 'solo_group',
	onBack = function()
	  print('Went back!')
	end,
	options = {
		{
			title = 'Start Group',
			description = 'Join in the group',
			icon = '',
			onSelect = function()
				if isGameRunning == true then
					lib.notify({
						title = 'Los Santos Golf Club',
						description = 'You\'re already in a match',
						type = 'error'
					})
				elseif isGameRunning == false then
					lib.notify({
						title = 'Los Santos Golf Club',
						description = 'Coming Soon',
						type = 'error'
					})
				end
			end,
		},
		{
			title = 'Join Group',
			description = 'Join in the group',
			icon = '',
			onSelect = function()
				if isGameRunning == true then
					lib.notify({
						title = 'Los Santos Golf Club',
						description = 'You\'re already in a match',
						type = 'error'
					})
				elseif isGameRunning == false then
					lib.notify({
						title = 'Los Santos Golf Club',
						description = 'Coming Soon',
						type = 'error'
					})
				end
			end,
		},
		{
			title = 'Start Match',
			description = 'Start the Round of Golf',
			icon = 'users',
			onSelect = function()
			  print("Coming Soon")
			  lib.notify({
				title = 'Los Santos Golf Club',
				description = 'Coming Soon',
				type = 'error'
			})
			end,
		}
	}
})

--- OX Target ---
if Config.Target == "ox_target" then
	exports[Config.Target]:addBoxZone({
    coords = Config.GolfStartLoc,
    size = vec3(3, 3, 3),
    rotation = 45,
    debug = drawZones,
	drawSprite = true,
		options = {
        	{
          		label = 'Golf',
		  		event = 'RRGolf:verify',
          		icon = 'fa-solid fa-flag',
        	}
    	}
	})

	exports[Config.Target]:addBoxZone({
	coords = Config.PayLoc,
	size = vec3(3, 3, 3),
	rotation = 45,
	debug = drawZones,
	drawSprite = true,
		options = {
      		{
        		label = 'Los Santos Golf Club',
        		event ='RRGolf:Membership',
        		icon = 'fa-solid fa-flag',
      		}
  		}
	})

elseif Config.Target == "qb-target" then
	-- QB-Target --
	exports[Config.Target]:AddBoxZone("Golfing", Config.GolfStartLoc, 0.45, 0.35,{
		name="Golfing",
		heading=11.0,
		debugPoly=false,
		minZ=54.0834,
		maxZ=54.87834,
		}, {
			options = {
				{
					event = "RRGolf:verify",
					icon = "fa-solid fa-flag",
					label = "Golf",
					distance = 2
				},
			}
	})

	exports[Config.Target]:AddBoxZone("Buying", Config.PayLoc, 0.45, 0.35, {
		name="Buying",
		heading=11.0,
		debugPoly=false,
		minZ=54.0834,
		maxZ=54.87834,
		}, {
		options = {
			{
				event = "RRGolf:Membership",
				icon = "fa-solid fa-flag",
				label = "Los Santos Golf Club",
				distance = 2		
			},
		},
	})

elseif Config.Target == "qtarget" then
	-- QTarget --
	exports[Config.Target]:AddBoxZone("Golfing", Config.GolfStartLoc, 0.45, 0.35, {
		name="Golfing",
		heading=11.0,
		debugPoly=false,
		minZ=54.0834,
		maxZ=54.87834,
		}, {
			options = {
				{
					event = "RRGolf:verify",
					icon = "fa-solid fa-flag",
					label = "Golf",
				},
			},
		distance = 2
	})

	exports[Config.Target]:AddBoxZone("Buying", Config.PayLoc, 0.45, 0.35, {
		name="Buying",
		heading=11.0,
		debugPoly=false,
		minZ=54.0834,
		maxZ=54.87834,
		}, {
			options = {
				{
					event = "RRGolf:Membership",
					icon = "fa-solid fa-flag",
					label = "Los Santos Golf Club",
				},
			},
		distance = 2
	})
end