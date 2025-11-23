local coin = script.Parent
local debounce = false

local coinPart = coin:FindFirstChildWhichIsA("BasePart")
if not coinPart then
	warn("❌ Не найдена основная часть монетки!")
	return
end

-- Настройки
coinPart.CanCollide = true
coinPart.Anchored = true

-- Анимация вращения
spawn(function()
	while coin and coin.Parent do
		coinPart.CFrame = coinPart.CFrame * CFrame.Angles(0, math.rad(3), 0)
		wait()
	end
end)

-- Функция при касании
local function onTouched(hit)
	if debounce then return end

	-- Проверяем игрока
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if not humanoid then return end

	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then 
		print("❌ Игрок не найден для монетки")
		return 
	end

	debounce = true

	print("🎯 Монетка касание: " .. player.Name)

	-- Отключаем коллизию
	coinPart.CanCollide = false

	-- Анимация исчезновения
	for i = 1, 3 do
		if coinPart then
			coinPart.Transparency = i * 0.3
			wait(0.1)
		end
	end

	-- ✅ СПОСОБ 1: Через глобальную переменную _G
	if _G.CoinSystem and _G.CoinSystem.addCoin then
		local success, errorMsg = pcall(function()
			_G.CoinSystem.addCoin(player, 1)
		end)

		if success then
			print("✅ Монета добавлена через _G.CoinSystem")
		else
			print("❌ Ошибка _G.CoinSystem: " .. tostring(errorMsg))
		end
	else
		print("❌ _G.CoinSystem не доступен")
	end

	-- ✅ СПОСОБ 2: Через RemoteEvent (резервный)
	local success2 = pcall(function()
		game.ReplicatedStorage.CoinCollected:FireServer()
		print("✅ Запрос отправлен через RemoteEvent")
	end)

	if not success2 then
		print("❌ RemoteEvent также не сработал")
	end

	-- Звук
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://607665037"
	sound.Volume = 0.5
	sound.Parent = workspace
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 3)

	-- Удаляем монетку
	wait(0.2)
	if coin and coin.Parent then
		coin:Destroy()
		print("✅ Монетка уничтожена")
	end
end

coinPart.Touched:Connect(onTouched)

print("✅ Монетка создана: " .. tostring(coinPart.Position))