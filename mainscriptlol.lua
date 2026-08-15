local function missing(t, f, fallback)
	if type(f) == t then
		return f
	end
	return fallback
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

print("Script started")

while not player do
	task.wait()
	player = Players.LocalPlayer
end

print("Player found:", player.Name)

local queueteleport = missing(
	"function",
	queue_on_teleport
		or (syn and syn.queue_on_teleport)
		or (fluxus and fluxus.queue_on_teleport)
)

_G.hasFiredPlayAgain = nil

task.spawn(function()
	while not player do
		task.wait()
		player = Players.LocalPlayer
	end
	player.OnTeleport:Connect(function()
		if queueteleport then
			queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/LighthningSplash/flkdfksdr/refs/heads/main/mainscriptlol.lua'))()")
		end
	end)
end)

while not player do
	task.wait()
	player = Players.LocalPlayer
end

print("Waiting for StarterElevator...")
repeat task.wait() until workspace:FindFirstChild("StarterElevator", true)
print("StarterElevator found")

print("Waiting for Character...")
repeat task.wait() until player.Character
print("Character found")

print("Waiting for HumanoidRootPart...")
repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")
print("HumanoidRootPart found")

task.wait(2)

print("Getting PlayerGui...")
local playerGui = player:WaitForChild("PlayerGui", 10)
local mainUI = playerGui and playerGui:WaitForChild("MainUI", 10)
local itemShop = mainUI and mainUI:WaitForChild("ItemShop", 10)
local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder", 10)

if not remotesFolder then
	warn("RemotesFolder not found.")
	return
end

print("RemotesFolder found")

local crouchRemote = remotesFolder:FindFirstChild("Crouch")
if crouchRemote then
	crouchRemote:FireServer(false, true)
	print("Crouch fired")
end

local cewcew = true

task.spawn(function()
	while cewcew do
		local remotes = ReplicatedStorage:FindFirstChild("RemotesFolder")
		if remotes then
			local crouch = remotes:FindFirstChild("Crouch")
			if crouch then
				pcall(function()
					crouch:FireServer(true, true)
				end)
			end
		end
		task.wait()
	end
end)

local function getCharacter()
	local character = player.Character
	if not character or not character.Parent then
		character = player.CharacterAdded:Wait()
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		hrp = character:WaitForChild("HumanoidRootPart", 10)
	end
	return character, hrp
end

local function getCurrentHRP()
	local character = player.Character
	if not character or not character.Parent then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function tweenToPosition(hrp, targetPos, duration)
	if not hrp or not hrp.Parent or not targetPos then
		return false
	end
	local success = false
	local ok, err = pcall(function()
		local tweenInfo = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(targetPos) })
		tween:Play()
		tween.Completed:Wait()
		success = true
	end)
	if not ok then
		warn("Tween error:", err)
	end
	return success
end

local function aimCameraAtEyesLoop()
	task.spawn(function()
		while player and player.Character do
			local char = player.Character
			if not char then task.wait(0.5) break end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then task.wait(0.5) break end
			
			local eyes = workspace:FindFirstChild("Eyes", true)
			local motorRemote = ReplicatedStorage:FindFirstChild("RemotesFolder") 
				and ReplicatedStorage.RemotesFolder:FindFirstChild("MotorReplication")
			
			if eyes and hrp and motorRemote then
				local cam = workspace.CurrentCamera
				local eyesPos = eyes:GetPivot().Position
				
				local targetCharCF = CFrame.new(eyesPos + (eyes:GetPivot().LookVector * 6), eyesPos)
				hrp.CFrame = targetCharCF
				
				cam.CameraType = Enum.CameraType.Scriptable
				local targetCamPos = targetCharCF.Position + Vector3.new(0, 2, 0)
				local targetCamCF = CFrame.new(targetCamPos, eyesPos)
				
				local camTween = TweenService:Create(
					cam, 
					TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), 
					{CFrame = targetCamCF}
				)
				camTween:Play()
				
				local rx, ry, rz = targetCamCF:ToOrientation()
				local pitchInDegrees = math.deg(rx)
				local encodedMotorValue = math.round(pitchInDegrees * 10)
				
				motorRemote:FireServer(encodedMotorValue)
				print("Fired MotorReplication with encoded value: " .. tostring(encodedMotorValue))
				
				camTween.Completed:Connect(function()
					cam.CameraType = Enum.CameraType.Custom
				end)
			end
			task.wait(0.5)
		end
	end)
end

local function checkAlive()
	local character = player.Character
	if not character or not character.Parent then
		return false
	end
	local alive = character:FindFirstChild("Alive")
	if not alive then
		return false
	end
	return alive.Value == true
end

local function forceDeath()
	local replicateSignal = remotesFolder:FindFirstChild("ReplicateSignal")
	if replicateSignal then
		pcall(function()
			replicatesignal(game.Players.LocalPlayer.Kill)
		end)
		print("Force death triggered via ReplicateSignal")
	else
		warn("ReplicateSignal not found")
	end
end

local function waitForNewCharacter(oldCharacter, timeout)
	local start = tick()
	while tick() - start < timeout do
		local currentCharacter = player.Character
		if currentCharacter and currentCharacter.Parent and currentCharacter ~= oldCharacter then
			local hrp = currentCharacter:FindFirstChild("HumanoidRootPart")
			if hrp then
				return currentCharacter, hrp
			end
		end
		task.wait(0.1)
	end
	return nil, nil
end

print("Waiting for CurrentRooms...")
local currentRooms = workspace:WaitForChild("CurrentRooms", 10)
local currentRoom0 = currentRooms and currentRooms:WaitForChild("0", 10)

if currentRoom0 then
	print("Room 0 found")
	local assets = currentRoom0:WaitForChild("Assets", 10)
	local keyObtain = assets and assets:WaitForChild("KeyObtain", 10)
	local keyHitbox = keyObtain and keyObtain:WaitForChild("Hitbox", 10)
	local keyTimeout = tick()
	print("Looking for key...")
	repeat
		local character, hrp = getCharacter()
		local keyObject = currentRoom0:FindFirstChild("KeyObtain", true)
		local keyPrompt = keyObject and keyObject:FindFirstChild("ModulePrompt")
		if keyHitbox and keyHitbox.Parent and hrp then
			hrp.CFrame = CFrame.new(keyHitbox.Position + Vector3.new(0, 0, 5))
		end
		if keyPrompt and keyPrompt:IsDescendantOf(workspace) then
			pcall(function()
				fireproximityprompt(keyPrompt)
			end)
		end
		task.wait(0.05)
	until (player.Character and player.Character:FindFirstChild("Key")) or (tick() - keyTimeout > 15)

	if player.Character and player.Character:FindFirstChild("Key") then
		print("Key obtained!")
	else
		print("Key timeout")
	end

	print("Finding RoomExit...")
	local roomExit = currentRoom0:WaitForChild("RoomExit", 10)
	local doorLooping = true
	print("RoomExit found, starting door loop...")
	task.spawn(function()
		while doorLooping do
			local character, hrp = getCharacter()
			local doorPrompt = currentRoom0:FindFirstChild("UnlockPrompt", true)
			if roomExit and roomExit.Parent and hrp then
				hrp.CFrame = CFrame.new(roomExit.Position + Vector3.new(0, 0, 5))
			end
			if doorPrompt and doorPrompt:IsDescendantOf(workspace) then
				pcall(function()
					fireproximityprompt(doorPrompt)
				end)
			end
			task.wait(0.05)
		end
	end)

	cewcew = false
	print("Waiting 8 seconds...")
	task.wait(8)
	doorLooping = false
	print("Room 0 complete")

	-- Start aiming BEFORE revive (during Room 0 exit teleport)
	task.spawn(function()
		local deathTimer = tick()
		while tick() - deathTimer < 4 do
			if not checkAlive() then
				print("Death detected in Room 0")
				return
			end
			task.wait(0.1)
		end
		print("No death in 4s — teleporting to Eyes")
		local eyes = workspace:FindFirstChild("Eyes", true)
		if eyes then
			local hrp = getCurrentHRP()
			if hrp then
				hrp.CFrame = CFrame.new(eyes.Position + Vector3.new(0, 2, 0))
				-- Aim now before revive
				aimCameraAtEyesLoop()
				print("Camera aim loop started (pre-revive)")
			end
		end
	end)
end

local oldCharacter = player.Character

if oldCharacter and not checkAlive() then
	print("Character is dead, reviving...")
	local reviveRemote = remotesFolder:FindFirstChild("Revive")
	if reviveRemote then
		print("Reviving...")
		pcall(function()
			reviveRemote:FireServer()
		end)
		
		local newCharacter, newHRP = waitForNewCharacter(oldCharacter, 10)
		
		if newCharacter and newHRP then
			print("New character detected:", newCharacter:GetFullName())
			print("New HRP detected:", newHRP:GetFullName())

			task.wait(1)
			-- Aim again after revive (now with Alive check delay)
			aimCameraAtEyesLoop()
			print("Camera aim loop started (post-revive)")

			print("Looking for Room 1...")
			local room1 = nil
			local roomExitPart = nil
			local startTime = tick()
			repeat
				local rooms = workspace:FindFirstChild("CurrentRooms")
				if rooms then
					room1 = rooms:FindFirstChild("1")
					if room1 then
						roomExitPart = room1:FindFirstChild("RoomExit")
						if not roomExitPart then
							roomExitPart = room1:FindFirstChildWhichIsA("BasePart")
						end
					end
				end
				task.wait(0.1)
			until (room1 and roomExitPart) or (tick() - startTime > 15)

			if room1 and roomExitPart then
				print("RoomExit found in Room 1:", roomExitPart:GetFullName())
				
				local doorLooping2 = true
				task.spawn(function()
					while doorLooping2 do
						local liveCharacter = player.Character
						if liveCharacter and liveCharacter.Parent then
							local liveHRP = liveCharacter:FindFirstChild("HumanoidRootPart")
							if liveHRP and liveHRP.Parent then
								local liveRooms = workspace:FindFirstChild("CurrentRooms")
								local liveRoom1 = liveRooms and liveRooms:FindFirstChild("1")
								local liveExitPart = liveRoom1 and liveRoom1:FindFirstChild("RoomExit")
								if not liveExitPart then
									liveExitPart = liveRoom1 and liveRoom1:FindFirstChildWhichIsA("BasePart")
								end
								if liveExitPart then
									liveHRP.CFrame = CFrame.new(liveExitPart.Position)
								end
							end
						end
						task.wait(0.05)
					end
				end)

				task.wait(1)
				-- Wait 0.5s after revive before checking Alive
				task.wait(0.5)
				local isAlive = checkAlive()
				print("Alive status after revive (delayed):", isAlive)
				
				if isAlive then
					print("Alive in Room 1, waiting 7s then force death")
					task.wait(7)
					if checkAlive() then
						forceDeath()
					end
				end
				
				local playAgainRemote = remotesFolder:FindFirstChild("PlayAgain")
				if playAgainRemote then
					if not isAlive then
						print("Still dead, waiting 2 seconds then PlayAgain...")
						task.wait(2)
						pcall(function()
							playAgainRemote:FireServer()
						end)
						print("PlayAgain fired (early)")
					else
						print("Character is alive, proceeding normally")
						task.wait(8)
						pcall(function()
							playAgainRemote:FireServer()
						end)
						print("PlayAgain fired")
					end
				end
				
				task.wait(5)
				doorLooping2 = false
				print("Door loop stopped after 5 seconds")
			else
				warn("Could not find Room 1 / RoomExit after revive.")
			end
		else
			warn("Revive fired, but a new character/HRP was not detected.")
		end
	else
		warn("Revive remote was not found.")
	end
else
	print("Character is alive or missing, skipping revive")
end

local playAgainRemote = remotesFolder:WaitForChild("PlayAgain", 10)
if playAgainRemote and not _G.hasFiredPlayAgain then
	_G.hasFiredPlayAgain = true
	task.spawn(function()
		print("I am a loser")
		pcall(function()
			playAgainRemote:FireServer()
		end)
		while true do
			pcall(function()
				playAgainRemote:FireServer()
			end)
			task.wait(10)
		end
	end)
end

print("Script finished execution")
