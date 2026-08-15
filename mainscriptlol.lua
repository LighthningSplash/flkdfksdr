local function aimCameraAtEyesLoop()
	task.spawn(function()
		while player and player.Character do
			local char = player.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local eyes = workspace:FindFirstChild("Eyes", true)
			local motorRemote = ReplicatedStorage:FindFirstChild("RemotesFolder") 
				and ReplicatedStorage.RemotesFolder:FindFirstChild("MotorReplication")
			if eyes and hrp and motorRemote then
				local eyesPos = eyes:GetPivot().Position
				local targetCharCF = CFrame.new(eyesPos + (eyes:GetPivot().LookVector * 6), eyesPos)
				hrp.CFrame = targetCharCF
				local cam = workspace.CurrentCamera
				cam.CameraType = Enum.CameraType.Scriptable
				local targetCamPos = targetCharCF.Position + Vector3.new(0, 2, 0)
				local targetCamCF = CFrame.new(targetCamPos, eyesPos)
				local camTween = TweenService:Create(cam, TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {CFrame = targetCamCF})
				camTween:Play()
				local rx, ry, rz = targetCamCF:ToOrientation()
				motorRemote:FireServer(math.round(math.deg(rx) * 10))
				camTween.Completed:Connect(function() cam.CameraType = Enum.CameraType.Custom end)
			end
			task.wait(0.5)
		end
	end)
end

-- Замена ReplicateSignal
local function forceDeath()
	local replicateSignal = remotesFolder:FindFirstChild("ReplicateSignal")
	if replicateSignal then
		pcall(function()
			replicatesignal(game.Players.LocalPlayer.Kill)
		end)
	end
end

-- Исправленный телепорт к RoomExit (бесконечный цикл)
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
