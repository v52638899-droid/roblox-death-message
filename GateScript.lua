-- Script do Portão Universal com Sons Personalizados (VERSÃO CORRIGIDA)

local TweenService = game:GetService("TweenService")
local gateModel = script.Parent

print("[GateScript] Iniciando script do portão em: " .. gateModel.Name)

--------------------------------------------------------------------
-- 1. PROCURA AUTOMATICAMENTE A PARTE DO PORTÃO
--------------------------------------------------------------------
local mainGatePart = nil

for _, child in ipairs(gateModel:GetChildren()) do
	if child:IsA("BasePart") and child.Name:lower():find("gate") then
		mainGatePart = child
		print("[GateScript] Part encontrada: " .. child.Name)
		break
	end
end

if not mainGatePart then
	warn("[GateScript] ERRO: Nenhuma Part com nome contendo 'Gate' foi encontrada em: " .. gateModel.Name)
	warn("[GateScript] Procure por uma parte nomeada 'Gate', 'Gate1', 'Gate2', etc.")
	return
end

--------------------------------------------------------------------
-- 2. SOLDAGEM AUTOMÁTICA DAS DECORAÇÕES E MAÇANETAS
--------------------------------------------------------------------
mainGatePart.Anchored = true

for _, part in ipairs(gateModel:GetDescendants()) do
	if part:IsA("BasePart") and part ~= mainGatePart then
		part.Anchored = false

		local existingWeld = part:FindFirstChildOfClass("WeldConstraint")
		if not existingWeld then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = mainGatePart
			weld.Part1 = part
			weld.Parent = part
		end
	end
end

print("[GateScript] Soldagem concluída!")

--------------------------------------------------------------------
-- 3. PROXIMITY PROMPT ("Press E to...")
--------------------------------------------------------------------
local prompt = mainGatePart:FindFirstChildOfClass("ProximityPrompt")
if not prompt then
	prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Open"
	prompt.ObjectText = "Gate"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 15
	prompt.RequiresLineOfSight = false
	prompt.Parent = mainGatePart
	print("[GateScript] ProximityPrompt criado!")
end

--------------------------------------------------------------------
-- 4. CONFIGURAÇÃO DOS SONS SOLICITADOS
--------------------------------------------------------------------

-- Som de Abrir
local soundOpen = mainGatePart:FindFirstChild("GateOpenSound")
if not soundOpen then
	soundOpen = Instance.new("Sound")
	soundOpen.Name = "GateOpenSound"
	soundOpen.SoundId = "rbxassetid://5122149230"
	soundOpen.Volume = 0.8
	soundOpen.Parent = mainGatePart
	print("[GateScript] Som de abertura criado!")
end

-- Som de Fechar (COM O ID QUE VOCÊ PEDIU)
local soundClose = mainGatePart:FindFirstChild("GateCloseSound")
if not soundClose then
	soundClose = Instance.new("Sound")
	soundClose.Name = "GateCloseSound"
	soundClose.SoundId = "rbxassetid://130044785338025" -- SEU SOM DE FECHAR
	soundClose.Volume = 0.8
	soundClose.Parent = mainGatePart
	print("[GateScript] Som de fechamento criado!")
else
	-- Garante que o som certo está configurado
	soundClose.SoundId = "rbxassetid://130044785338025"
end

print("[GateScript] Sons configurados!")

--------------------------------------------------------------------
-- 5. LÓGICA DE ABRIR E FECHAR (TWEENSERVICE)
--------------------------------------------------------------------
local isOpen = false
local isBusy = false

-- Grava a posição fechada original
local closedCFrame = mainGatePart.CFrame

-- Define o ângulo de abertura em 90 graus (pode ajustar conforme necessário)
local openCFrame = closedCFrame * CFrame.Angles(0, math.rad(90), 0)

-- Configuração do Tween
local tweenInfo = TweenInfo.new(
	1.2,  -- Duração em segundos
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

print("[GateScript] Sistema pronto! Pressione 'E' para abrir/fechar o portão.")

prompt.Triggered:Connect(function(player)
	print("[GateScript] Portão acionado por: " .. player.Name)
	
	if isBusy then 
		print("[GateScript] Portão está ocupado, aguarde...")
		return 
	end
	
	isBusy = true
	prompt.Enabled = false

	if not isOpen then
		-- ========== ABRIR ==========
		print("[GateScript] Abrindo portão...")
		soundOpen:Play()
		
		local tween = TweenService:Create(mainGatePart, tweenInfo, {CFrame = openCFrame})
		tween:Play()
		tween.Completed:Wait()

		isOpen = true
		prompt.ActionText = "Close"
		print("[GateScript] Portão aberto!")
		
	else
		-- ========== FECHAR ==========
		print("[GateScript] Fechando portão...")
		soundClose:Play()
		
		local tween = TweenService:Create(mainGatePart, tweenInfo, {CFrame = closedCFrame})
		tween:Play()
		tween.Completed:Wait()

		isOpen = false
		prompt.ActionText = "Open"
		print("[GateScript] Portão fechado!")
	end

	prompt.Enabled = true
	isBusy = false
end)

print("[GateScript] Script carregado com sucesso!")