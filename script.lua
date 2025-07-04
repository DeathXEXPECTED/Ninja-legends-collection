--// CONFIGURATION
local tweenSpeed = 1.5
local waitBetweenChecks = 0.5

--// SERVICES
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

--// LOOP STATE
local loopActive = false

--// CHARACTER SETUP
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end
local hrp = getHRP()

--// Lock player in place
local function freezePlayer(freeze)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = freeze
	end
end

--// Fetch valid parts/models inside spawnedCoins > Valley
local function getValleyItems()
	local root = workspace:FindFirstChild("spawnedCoins")
	if not root then return {} end

	local valley = root:FindFirstChild("Valley")
	if not valley then return {} end

	local items = {}
	for _, obj in ipairs(valley:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(items, obj)
		elseif obj:IsA("Model") and obj.PrimaryPart then
			table.insert(items, obj)
		end
	end
	return items
end

--// Tween to the object
local function tweenToTarget(target)
	local targetCFrame = target:IsA("Model") and target:GetPrimaryPartCFrame() or target.CFrame
	local tween = TweenService:Create(hrp, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
	tween:Play()
	tween.Completed:Wait()
end

--// Wait until item disappears
local function waitForItemToBeCollected(item)
	while item and item.Parent do
		task.wait(0.1)
	end
end

--// MAIN LOOP
task.spawn(function()
	while true do
		if loopActive then
			freezePlayer(true)
			local targets = getValleyItems()

			if #targets == 0 then
				task.wait(waitBetweenChecks)
			else
				for _, target in ipairs(targets) do
					if not loopActive then break end
					if target and target.Parent then
						tweenToTarget(target)
						waitForItemToBeCollected(target)
						task.wait(0.1)
					end
				end
			end
		else
			freezePlayer(false)
			task.wait(0.2)
		end
	end
end)

--// GUI TOGGLE
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "TweenControl"

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 40)
button.Position = UDim2.new(0.05, 0, 0.9, 0)
button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 22
button.Font = Enum.Font.SourceSansBold
button.Text = "Start"
button.Parent = gui

button.MouseButton1Click:Connect(function()
	loopActive = not loopActive
	button.Text = loopActive and "Stop" or "Start"
	button.BackgroundColor3 = loopActive and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(60, 180, 75)
end)
