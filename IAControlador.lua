-- IAControlador.lua
-- Controla o comportamento de um player-bot que age como NPC

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local playerBot = Players.LocalPlayer
local nomeAlvo = "soupoeta2"

local Estados = require(script.Parent:WaitForChild("Estados"))
local GerenciadorEstados = require(script.Parent:WaitForChild("GerenciadorEstados"))
local Movimento = require(script.Parent:WaitForChild("Movimento"))
local MovimentoExtra = require(script.Parent:WaitForChild("MovimentoExtra"))
local Chat = require(script.Parent:WaitForChild("Chat"))
local Combate = require(script.Parent:WaitForChild("Combate"))

local humanoid, rootPart

local function equiparArma(character)
	local mochila = playerBot:WaitForChild("Backpack")
	local ferramenta = mochila:FindFirstChild("RocketLauncher") or mochila:FindFirstChildOfClass("Tool")
	if ferramenta then
		humanoid:EquipTool(ferramenta)
		Chat("Arma equipada!", character)
	else
		Chat("Sem arma para equipar!", character)
	end
end

local function onCharacterAdded(character)
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	task.wait(1)
	equiparArma(character)
end

if playerBot.Character then
	onCharacterAdded(playerBot.Character)
end
playerBot.CharacterAdded:Connect(onCharacterAdded)

local function getAlvo()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name == nomeAlvo and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			return p.Character
		end
	end
	return nil
end

local tempoUltimoTiro = 0

local function controlarIA()
	if not humanoid or not rootPart then return end

	if MovimentoExtra.ChecarAtolado(rootPart.Parent) then
		GerenciadorEstados:setEstado(rootPart.Parent, Estados.Atolado)
		return
	end

	local alvoChar = getAlvo()
	if alvoChar then
		local alvoHRP = alvoChar:FindFirstChild("HumanoidRootPart")
		local alvoHumanoid = alvoChar:FindFirstChild("Humanoid")
		if alvoHRP and alvoHumanoid then
			local distancia = (rootPart.Position - alvoHRP.Position).Magnitude
			GerenciadorEstados:setEstado(rootPart.Parent, Estados.Perseguindo)
			Movimento.moverPara(alvoHRP.Position, rootPart.Parent, humanoid)

			if distancia <= 40 and tick() - tempoUltimoTiro >= Combate.getCooldownTiro() then
				local sucessoMira = Combate.mirarSuave(alvoHRP.Position, alvoHumanoid, distancia)
				if sucessoMira then
					Combate.atirar()
					Combate.tentarEsquivar(humanoid)
					tempoUltimoTiro = tick()
				end
			end
			return
		end
	end

	GerenciadorEstados:setEstado(rootPart.Parent, Estados.Patrulhando)
	MovimentoExtra.Patrulhar(rootPart.Parent, humanoid)
end

-- Loop principal da IA
while true do
	task.wait(1)
	pcall(controlarIA)
end