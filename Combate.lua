local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")

-- CONFIGURAÇÕES
local VELOCIDADE_PROJETIL = 150         -- Velocidade estimada do foguete
local FATOR_PREDICAO_CURTO = 0.1        -- Quanto prever movimento para distância curta
local FATOR_PREDICAO_LONGO = 0.3        -- Quanto prever movimento para distância longa
local COOLDOWN_TIRO = 1.5               -- Tempo entre tiros (segundos)
local PROBABILIDADE_ESQUIVA = 0.6       -- Chance de esquivar após atirar (60%)
local FATOR_ESQUIVA = 0.5                -- Quanto mover lateralmente ao esquivar

local ultimoTiro = 0                     -- Guarda o tempo do último tiro

local Combate = {}

-- Função para mirar suavemente no alvo com previsão de movimento
function Combate.mirarSuave(posAlvo, alvoHumanoid, distancia)
    local camera = workspace.CurrentCamera

    local predictedPos = posAlvo
    if alvoHumanoid and alvoHumanoid.Parent then
        local alvoVelocidade = alvoHumanoid.Parent.HumanoidRootPart.AssemblyLinearVelocity
        local fatorPredicao = FATOR_PREDICAO_CURTO
        if distancia > 20 then
            fatorPredicao = FATOR_PREDICAO_LONGO
        end

        local tempoImpacto = distancia / VELOCIDADE_PROJETIL
        predictedPos = posAlvo + alvoVelocidade * tempoImpacto * fatorPredicao
    end

    local screenPos, visivel = camera:WorldToViewportPoint(predictedPos + Vector3.new(0, 1.5, 0)) -- Mira na cabeça
    if not visivel then
        return false
    end

    local mouseX, mouseY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
    local step = 0.6
    if distancia < 10 then
        step = 0.8
    elseif distancia > 40 then
        step = 0.4
    end

    local newX = mouseX + (screenPos.X - mouseX) * step
    local newY = mouseY + (screenPos.Y - mouseY) * step

    VirtualInputManager:SendMouseMoveEvent(newX, newY, game, 1)
    return true
end

-- Função para disparar o foguete (clique do mouse)
function Combate.atirar()
    local camera = workspace.CurrentCamera
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2

    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
end

-- Função para tentar esquivar lateralmente após o tiro
function Combate.tentarEsquivar(humanoid)
    if math.random() < PROBABILIDADE_ESQUIVA then
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            humanoid:Move(Vector3.new(math.random(-1, 1) * FATOR_ESQUIVA, 0, 0))
        else
            local root = humanoid.RootPart or humanoid.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                local direcaoLateral = root.CFrame.RightVector * math.random(-1, 1) * FATOR_ESQUIVA
                humanoid:MoveTo(root.Position + direcaoLateral * 3)
            end
        end
    end
end

-- Retorna o cooldown padrão para ser usado no script principal
function Combate.getCooldownTiro()
    return COOLDOWN_TIRO
end

return Combate
