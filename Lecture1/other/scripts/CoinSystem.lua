local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Создаем RemoteEvent для связи
local CoinCollected = Instance.new("RemoteEvent")
CoinCollected.Name = "CoinCollected"
CoinCollected.Parent = ReplicatedStorage

-- DataStore для сохранения данных
local coinsDataStore
if not RunService:IsStudio() then
	coinsDataStore = DataStoreService:GetDataStore("PlayerCoins")
	print("💾 DataStore включен для реальной игры")
else
	print("🎮 Режим Studio: DataStore отключен, используем временные данные")
end

-- Таблица для хранения счетов игроков
local playerCoins = {}
local playerDataMutex = {}

-- Глобальная ссылка на систему для доступа из других скриптов
_G.CoinSystem = {}

-- Генерация ключа для игрока
local function getPlayerKey(player)
	return "player_" .. player.UserId
end

-- Сохранение данных игрока
local function savePlayerData(player)
	if RunService:IsStudio() then
		-- В Studio просто логируем, но не сохраняем
		print("📝 [Studio] Данные игрока " .. player.Name .. ": " .. (playerCoins[player] or 0) .. " монет (не сохранено)")
		return true
	end

	if not coinsDataStore then
		warn("❌ DataStore не доступен для сохранения")
		return false
	end

	local playerKey = getPlayerKey(player)
	playerDataMutex[playerKey] = true

	local success, errorMessage = pcall(function()
		coinsDataStore:SetAsync(playerKey, playerCoins[player] or 0)
	end)

	if success then
		print("💾 Данные сохранены для " .. player.Name .. ": " .. (playerCoins[player] or 0) .. " монет")
	else
		warn("❌ Ошибка сохранения для " .. player.Name .. ": " .. tostring(errorMessage))
	end

	playerDataMutex[playerKey] = false
	return success
end

-- Загрузка данных игрока
local function loadPlayerData(player)
	if RunService:IsStudio() then
		-- В Studio используем временные данные
		local testCoins = 0
		print("📥 [Studio] Загружены тестовые данные для " .. player.Name .. ": " .. testCoins .. " монет")
		return testCoins
	end

	if not coinsDataStore then
		warn("❌ DataStore не доступен для загрузки")
		return 0
	end

	local playerKey = getPlayerKey(player)

	-- Ждем, если данные уже загружаются
	while playerDataMutex[playerKey] do
		wait(0.1)
	end

	playerDataMutex[playerKey] = true

	local coins = 0
	local success, data = pcall(function()
		return coinsDataStore:GetAsync(playerKey)
	end)

	if success and data then
		coins = data or 0
		print("📥 Загружены данные для " .. player.Name .. ": " .. coins .. " монет")
	else
		print("🆕 Новый игрок " .. player.Name .. ", установлено 0 монет")
		coins = 0
	end

	playerDataMutex[playerKey] = false
	return coins
end

-- Функция при подключении игрока
local function onPlayerAdded(player)
	-- Загружаем данные игрока
	local coins = loadPlayerData(player)
	playerCoins[player] = coins

	-- Немедленно обновляем UI
	CoinCollected:FireClient(player, coins)

	print("✅ Игрок " .. player.Name .. " подключен. Монеты: " .. coins)

	-- Обработчик респавна персонажа
	player.CharacterAdded:Connect(function(character)
		wait(0.5)
		if playerCoins[player] then
			CoinCollected:FireClient(player, playerCoins[player])
			print("🔄 UI обновлен при респавне: " .. playerCoins[player] .. " монет")
		end
	end)
end

-- Функция при отключении игрока
local function onPlayerRemoving(player)
	savePlayerData(player)
	print("👋 Игрок " .. player.Name .. " отключен. Монеты: " .. (playerCoins[player] or 0))
	playerCoins[player] = nil
end

-- Функция при сборе монетки (из RemoteEvent)
local function onCoinCollected(player)
	if not player or not player.Parent then 
		print("❌ Неверный игрок в onCoinCollected")
		return 
	end

	if not playerCoins[player] then
		playerCoins[player] = 0
	end

	-- Увеличиваем счет
	local oldCoins = playerCoins[player]
	playerCoins[player] = playerCoins[player] + 1

	-- Обновляем UI у клиента
	CoinCollected:FireClient(player, playerCoins[player])

	-- Сохраняем данные
	spawn(function()
		savePlayerData(player)
	end)

	print("💰 Игрок " .. player.Name .. " собрал монету через RemoteEvent! " .. oldCoins .. " → " .. playerCoins[player])
end

-- Функция для добавления монет из других скриптов
local function addCoin(player, amount)
	if not player or not player.Parent then 
		warn("❌ Неверный игрок для добавления монет")
		return false 
	end

	if not playerCoins[player] then
		playerCoins[player] = 0
	end

	local oldCoins = playerCoins[player]
	playerCoins[player] = playerCoins[player] + (amount or 1)

	-- Обновляем UI
	CoinCollected:FireClient(player, playerCoins[player])

	-- Сохраняем данные
	spawn(function()
		savePlayerData(player)
	end)

	print("🎯 Монета добавлена через addCoin: " .. player.Name .. " " .. oldCoins .. " → " .. playerCoins[player])
	return true
end

-- Автосохранение каждые 5 минут (только в реальной игре)
if not RunService:IsStudio() then
	spawn(function()
		while true do
			wait(300) -- 5 минут
			for player, coins in pairs(playerCoins) do
				if player and player.Parent then
					savePlayerData(player)
				end
			end
			print("💾 Автосохранение завершено")
		end
	end)
else
	print("🎮 Режим Studio: автосохранение отключено")
end

-- Подключаем обработчики
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
CoinCollected.OnServerEvent:Connect(onCoinCollected)

-- Экспортируем функции в глобальную область
_G.CoinSystem.addCoin = addCoin
_G.CoinSystem.getCoins = function(player) 
	return playerCoins[player] or 0 
end
_G.CoinSystem.setCoins = function(player, amount)
	if playerCoins[player] then
		local oldCoins = playerCoins[player]
		playerCoins[player] = amount
		CoinCollected:FireClient(player, amount)

		-- Сохраняем данные
		spawn(function()
			savePlayerData(player)
		end)

		print("⚙️ Установлены монеты для " .. player.Name .. ": " .. oldCoins .. " → " .. amount)
		return true
	end
	return false
end
_G.CoinSystem.debugInfo = function()
	print("=== DEBUG INFO ===")
	for player, coins in pairs(playerCoins) do
		print("  " .. player.Name .. ": " .. coins .. " монет")
	end
	print("Игроков в памяти: " .. tostring(#Players:GetPlayers()))
	print("Режим Studio: " .. tostring(RunService:IsStudio()))
	print("=================")
end
_G.CoinSystem.forceSave = function(player)
	if player then
		return savePlayerData(player)
	else
		-- Сохранить всех игроков
		for p, coins in pairs(playerCoins) do
			if p and p.Parent then
				savePlayerData(p)
			end
		end
		return true
	end
end

print("🎮 CoinSystem загружен! Готов к работе.")
print("💡 Доступ через _G.CoinSystem.addCoin(player, amount)")