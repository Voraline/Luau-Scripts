--!optimize 2
--!native

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer
local DefaultGravity = workspace.Gravity
local IsRunning = true
local Speed = 300
local CurrentTween = nil
local IsFarming = false

local Destinations = {
	CFrame.new(-43.6134491, 62.1137619, 672.744934, -0.999842644, -0.00183729955, 0.017645346, 0, 0.994622767, 0.103564225, -0.0177407414, 0.103547923, -0.994466245),
	CFrame.new(-60.1504707, 97.4659729, 8767.91406, -0.99889338, 0.000705028593, 0.0470264405, 0, 0.999887645, -0.0149902813, -0.047031723, -0.0149736926, -0.998781145),
	CFrame.new(-54.331871, -345.398346, 9488.60645, -0.98221302, 0, 0.187770084, 0, 1, 0, -0.187770084, 0, -0.98221302),
}
local DestCount = #Destinations

local function GetRoot()
	local Char = Player.Character
	return Char and Char:FindFirstChild("HumanoidRootPart")
end

local function MoveTo(TargetCFrame, ResetGravity)
	local Root = GetRoot()
	if not Root then return end
	local Duration = (Root.Position - TargetCFrame.Position).Magnitude / Speed
	workspace.Gravity = ResetGravity and DefaultGravity or 0
	if CurrentTween then CurrentTween:Cancel() end
	CurrentTween = TweenService:Create(Root, TweenInfo.new(Duration, Enum.EasingStyle.Linear), { CFrame = TargetCFrame })
	CurrentTween:Play()
	local Done = false
	CurrentTween.Completed:Once(function() Done = true end)
	while not Done and IsRunning do
		if not GetRoot() then CurrentTween:Cancel() break end
		RunService.Heartbeat:Wait()
	end
end

local function AutoFarmLoop()
	if IsFarming then return end
	IsFarming = true
	while IsRunning do
		if not GetRoot() then IsFarming = false return end
		for i = 1, DestCount do
			if not IsRunning then IsFarming = false return end
			if not GetRoot() then break end
			MoveTo(Destinations[i], i == DestCount)
		end
		workspace.Gravity = DefaultGravity
		IsFarming = false
		Player.CharacterAdded:Wait()
		task.wait(1.5)
		IsFarming = true
	end
	IsFarming = false
end

task.spawn(function()
	while true do
		task.wait(10)
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.K, false, game)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.K, false, game)
	end
end)

Player.CharacterAdded:Connect(function()
	if not IsRunning or IsFarming then return end
	task.wait(1.5)
	task.spawn(AutoFarmLoop)
end)

task.spawn(AutoFarmLoop)
