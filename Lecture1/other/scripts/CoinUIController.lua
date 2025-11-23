local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoinCounterGUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 70)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 15, 0.5, -20)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10197992760"
icon.Parent = frame

local coinText = Instance.new("TextLabel")
coinText.Size = UDim2.new(0, 150, 0, 40)
coinText.Position = UDim2.new(0, 65, 0.5, -20)
coinText.BackgroundTransparency = 1
coinText.Text = "0"
coinText.TextColor3 = Color3.new(1, 0.84, 0)
coinText.TextSize = 28
coinText.Font = Enum.Font.GothamBold
coinText.TextXAlignment = Enum.TextXAlignment.Left
coinText.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 20)
label.Position = UDim2.new(0, 0, 1, -20)
label.BackgroundTransparency = 1
label.Text = "МОНЕТЫ"
label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
label.TextSize = 12
label.Font = Enum.Font.Gotham
label.Parent = frame

-- Получаем RemoteEvent
local CoinCollected = ReplicatedStorage:WaitForChild("CoinCollected")

-- Текущее количество монет
local currentCoins = 0

-- Функция обновления текста
local function updateCoinText(newCount)
	print("🎉 UI ОБНОВЛЕНИЕ: " .. currentCoins .. " → " .. newCount)
	currentCoins = newCount
	coinText.Text = tostring(newCount)

	-- Анимация
	coinText.TextSize = 32
	coinText.TextColor3 = Color3.new(1, 1, 1)

	wait(0.3)

	coinText.TextSize = 28
	coinText.TextColor3 = Color3.new(1, 0.84, 0)
end

-- Обработчик событий
CoinCollected.OnClientEvent:Connect(function(coinCount)
	print("📡 UI получил событие CoinCollected: " .. coinCount)
	updateCoinText(coinCount)
end)

print("✅ UI загружен! Ожидаем события...")