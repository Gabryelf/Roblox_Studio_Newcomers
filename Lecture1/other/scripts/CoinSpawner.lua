local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- Модель монетки (должна быть в ServerStorage)
local coinTemplate = ServerStorage:FindFirstChild("CoinTemplate")

if not coinTemplate then
	warn("❌ CoinTemplate не найден в ServerStorage!")
	return
end

-- Находим основную часть в модели монетки
local coinPrimaryPart = coinTemplate:FindFirstChildWhichIsA("BasePart")
if not coinPrimaryPart then
	warn("❌ В CoinTemplate не найдена основная часть (BasePart)!")
	return
end

local spawnPoints = {
	Vector3.new(10, 5, 10),
	Vector3.new(-10, 5, 15),
	Vector3.new(20, 5, -5),
	Vector3.new(-15, 5, -10),
	Vector3.new(5, 5, 25),
	Vector3.new(15, 5, 20),
	Vector3.new(-20, 5, 5),
	Vector3.new(0, 5, -15)
}

local activeCoins = {}

local function spawnCoin(position)
	local newCoin = coinTemplate:Clone()

	-- Устанавливаем позицию для основной части модели
	local primaryPart = newCoin:FindFirstChildWhichIsA("BasePart")
	if primaryPart then
		primaryPart.Position = position
	else
		warn("❌ Не удалось найти основную часть в клоне монетки")
		return nil
	end

	newCoin.Parent = Workspace
	table.insert(activeCoins, newCoin)

	print("✅ Монетка создана на позиции: " .. tostring(position))

	-- Авто-удаление через 3 минуты
	delay(180, function()
		if newCoin and newCoin.Parent then
			newCoin:Destroy()
		end
	end)

	return newCoin
end

-- Функция для проверки активных монеток
local function cleanupCoins()
	local removed = 0
	for i = #activeCoins, 1, -1 do
		if not activeCoins[i] or not activeCoins[i].Parent then
			table.remove(activeCoins, i)
			removed = removed + 1
		end
	end
	return removed
end

-- Спавн начальных монеток
print("🔄 Начинаем спавн монеток...")
for i, position in ipairs(spawnPoints) do
	spawnCoin(position)
	wait(0.1) -- Небольшая задержка между созданием
end

print("✅ Создано " .. #spawnPoints .. " монеток")

-- Респавн каждые 50 секунд
while true do
	wait(50)

	-- Очищаем список от собранных монеток
	local removed = cleanupCoins()

	-- Респавним недостающие монетки
	local coinsToSpawn = #spawnPoints - #activeCoins
	if coinsToSpawn > 0 then
		print("🔄 Респавн " .. coinsToSpawn .. " монеток...")
		for i = 1, coinsToSpawn do
			local position = spawnPoints[math.random(1, #spawnPoints)]
			spawnCoin(position)
			wait(0.1)
		end
		print("✅ Респавнено " .. coinsToSpawn .. " монеток")
	end
end