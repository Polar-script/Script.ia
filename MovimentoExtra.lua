local Estados = require(script.Parent:WaitForChild("Estados"))
local falar = require(script.Parent:WaitForChild("Chat"))
local Movimento = require(script.Parent:WaitForChild("Movimento")) -- ✅ IMPORTANTE

local TEMPO_VERIFICAR_PRESO = 3
local DISTANCIA_MIN_MOVIMENTO = 2
local MAX_ATOLAMENTO = 3

local ultimaVerificacao = tick()
local contadorAtolado = 0
local ultimaPosicao = nil

local indicePatrulha = 1

local pontosPatrulha = {
	Vector3.new(0, 5, 0),
	Vector3.new(50, 5, 50),
	Vector3.new(-50, 5, 50),
	Vector3.new(0, 5, -50)
}

local function atualizarEstado(personagem, estado)
	local status = personagem:FindFirstChild("EstadoAtual")
	if not status then
		status = Instance.new("StringValue")
		status.Name = "EstadoAtual"
		status.Parent = personagem
	end
	status.Value = estado
end

local function checarAtolado(personagem)
	local raiz = personagem:FindFirstChild("HumanoidRootPart")
	if not raiz then return false end

	if not ultimaPosicao then
		ultimaPosicao = raiz.Position
		return false
	end

	if tick() - ultimaVerificacao >= TEMPO_VERIFICAR_PRESO then
		local dist = (raiz.Position - ultimaPosicao).Magnitude
		if dist < DISTANCIA_MIN_MOVIMENTO then
			contadorAtolado += 1
			if contadorAtolado >= MAX_ATOLAMENTO then
				raiz.CFrame = CFrame.new(raiz.Position + Vector3.new(math.random(-10, 10), 8, math.random(-10, 10)))
				falar("Atolado! Reposicionando...", personagem)
				contadorAtolado = 0
				return true
			end
		else
			contadorAtolado = 0
		end
		ultimaVerificacao = tick()
		ultimaPosicao = raiz.Position
	end
	return false
end

local function patrulhar(personagem, humanoid)
	atualizarEstado(personagem, Estados.Patrulhando)
	local destino = pontosPatrulha[indicePatrulha]
	Movimento.moverPara(destino, personagem, humanoid) -- ✅ usa o mover com pathfinding

	if (personagem.HumanoidRootPart.Position - destino).Magnitude < 10 then
		indicePatrulha = (indicePatrulha % #pontosPatrulha) + 1
	end
end

return {
	ChecarAtolado = checarAtolado,
	Patrulhar = patrulhar,
	AtualizarEstado = atualizarEstado
}