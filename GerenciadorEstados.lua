local Estados = require(script.Parent:WaitForChild("Estados"))

local GerenciadorEstados = {}

-- Define o estado atual do personagem
function GerenciadorEstados:setEstado(personagem, estado)
	local status = personagem:FindFirstChild("EstadoAtual")
	if not status then
		status = Instance.new("StringValue")
		status.Name = "EstadoAtual"
		status.Parent = personagem
	end
	status.Value = estado
end

-- Retorna o estado atual do personagem
function GerenciadorEstados:getEstado(personagem)
	local status = personagem:FindFirstChild("EstadoAtual")
	if status then
		return status.Value
	end
	return nil
end

-- Reseta o estado para Idle
function GerenciadorEstados:resetEstado(personagem)
	self:setEstado(personagem, Estados.Idle)
end

return GerenciadorEstados