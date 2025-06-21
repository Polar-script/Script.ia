-- Script que controla o comportamento do NPC-bot
-- Deve ser executado pela conta bot (ex: loveyoubaby466)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local playerBot = Players.LocalPlayer
local nomeAlvo = "soupoeta2" -- nome do player que o bot vai perseguir

local Estados = require("Estados")
local GerenciadorEstados = require("GerenciadorEstados")
local Movimento = require("Movimento")
local MovimentoExtra = require("MovimentoExtra")
local Chat = require("Chat")
local Combate = require("Combate")

local humanoid, rootPart

local function onCharacterAdded(character)
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
end

if playerBot.Character then
	onCharacterAdded(playerBot.Character)
end
playerBot.CharacterAdded:Connect(onCharacterAdded)

local function getAlvo()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name == nomeAlvo and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			return p.Character.HumanoidRootPart
		end
	end
	return nil
end

local function controlarIA()
	if not humanoid or not rootPart then return end

	if MovimentoExtra.ChecarAtolado(rootPart.Parent) then
		GerenciadorEstados:setEstado(rootPart.Parent, Estados.Atolado)
		Chat("Atolado! Reposicionando...", rootPart.Parent)
		return
	end

	local alvoHRP = getAlvo()
	if alvoHRP then
		local distancia = (rootPart.Position - alvoHRP.Position).Magnitude
		if distancia < 40 then
			GerenciadorEstados:setEstado(rootPart.Parent, Estados.Perseguindo)
			Movimento.moverPara(alvoHRP.Position, rootPart.Parent, humanoid)
			return
		end
	end

	GerenciadorEstados:setEstado(rootPart.Parent, Estados.Patrulhando)
	MovimentoExtra.Patrulhar(rootPart.Parent, humanoid)
end

while true do
	task.wait(1)
	controlarIA()
end