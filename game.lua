local love = love
local lg = love.graphics

local flux = require "flux"
local dist = require "dist"

local keyRows = {
  { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=' },
  { 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']' },
  { nil, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'" },
  { nil, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
}

local keySize = 40
local keyMargin = 5
local oddRowOffset = keySize / 2

local maxJumpDistance = keySize * 1.5

local totalWidth = #keyRows[1] * (keySize + keyMargin) - keyMargin
local totalHeight = #keyRows * (keySize + keyMargin) - keyMargin

-- returns world position of the key based on its row and column
local function getKeyPosition(column, row)
  return
      (column - 1) * (keySize + keyMargin) + ((row - 1) % 2 == 1 and oddRowOffset or 0),
      (row - 1) * (keySize + keyMargin)
end

local keyPositions = {}

for r, row in ipairs(keyRows) do
  for k = 1, 12 do
    local key = row[k]
    if key then
      local x, y = getKeyPosition(k, r)
      keyPositions[key] = { x = x, y = y }
    end
  end
end

local keyFont = lg.newFont(18)

local playerImage = lg.newImage('assets/player.png')

-- converts world key position to centered sprite position
local function posToSprite(x, y)
  return x + keySize / 2, y + keySize / 2
end

local game = {}

function game:enter()
  self.playerPos = {
    x = keyPositions['g'].x,
    y = keyPositions['g'].y,
  }
  self.playerSprite = {
    angle = 0,
    squish = 1,
  }
  self.playerSprite.x, self.playerSprite.y = posToSprite(self.playerPos.x, self.playerPos.y)

  self.keyTransforms = {}
  for key, _ in pairs(keyPositions) do
    self.keyTransforms[key] = {
      shake = 0
    }
  end

  self.tweens = flux.group()
end

function game:isPosInReach(x, y)
  return dist(self.playerPos.x, self.playerPos.y, x, y) <= maxJumpDistance
end

function game:keypressed(_, key)
  if keyPositions[key] then
    local newPos = keyPositions[key]
    if (self.playerPos.x ~= newPos.x or self.playerPos.y ~= newPos.y) and
        self:isPosInReach(newPos.x, newPos.y) then
      self.playerPos.x, self.playerPos.y = newPos.x, newPos.y
      local newSpriteX, newSpriteY = posToSprite(self.playerPos.x, self.playerPos.y)
      self.playerSprite.squish = 2
      self.playerSprite.angle = math.atan2(newSpriteY - self.playerSprite.y, newSpriteX - self.playerSprite.x)
      self.tweens:to(self.playerSprite, 0.2, {
        x = newSpriteX,
        y = newSpriteY,
        squish = 1
      })
          :ease("cubicout")
          :oncomplete(function()
            self.playerSprite.x, self.playerSprite.y = posToSprite(self.playerPos.x, self.playerPos.y)
          end)
    else
      -- shake the key
      local t = self.keyTransforms[key]
      t.shake = 1
      self.tweens:to(t, 0.3, { shake = 0 })
    end
  end
end

function game:update(dt)
  self.tweens:update(dt)
end

function game:draw()
  lg.push()
  lg.translate(math.floor(lg.getWidth() / 2 - totalWidth / 2), math.floor(lg.getHeight() / 2 - totalHeight / 2))

  for r, row in ipairs(keyRows) do
    for k = 1, 12 do
      local key = row[k]
      if key then
        lg.push()
        local keyX, keyY = getKeyPosition(k, r)
        lg.translate(keyX, keyY)

        local transform = self.keyTransforms[key]
        lg.translate(math.sin(love.timer.getTime() * 80) * 5 * transform.shake, 0)

        if self:isPosInReach(keyX, keyY) then
          lg.setColor(1, 1, 1)
        else
          lg.setColor(0.6, 0.6, 0.6)
        end
        lg.rectangle("fill", 0, 0, keySize, keySize)

        lg.setColor(0, 0, 0, 0.6)
        lg.setFont(keyFont)
        lg.printf(love.keyboard.getKeyFromScancode(key), 0, keySize / 2 - keyFont:getHeight() / 2, keySize, "center")
        lg.pop()
      end
    end
  end

  lg.setColor(1, 1, 1)
  lg.push()
  lg.translate(self.playerSprite.x, self.playerSprite.y)
  lg.rotate(self.playerSprite.angle)
  lg.scale(self.playerSprite.squish, 1 / self.playerSprite.squish)
  lg.draw(playerImage, 0, 0, -self.playerSprite.angle, 1, 1, playerImage:getWidth() / 2, playerImage:getHeight() / 2)
  lg.pop()

  lg.pop()
end

return game
