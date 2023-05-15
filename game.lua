local love = love
local lg = love.graphics

local keyRows = {
  { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=' },
  { 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']' },
  { nil, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'" },
  { nil, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
}

local keySize = 40
local keyMargin = 5
local oddRowOffset = keySize / 2

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

local game = {}

function game:enter()
  self.test = keyPositions['g']
end

function game:keypressed(_, key)
  if keyPositions[key] then
    self.test = keyPositions[key]
  end
end

function game:draw()
  lg.push()
  lg.translate(lg.getWidth() / 2 - totalWidth / 2, lg.getHeight() / 2 - totalHeight / 2)

  for r, row in ipairs(keyRows) do
    for k = 1, 12 do
      local key = row[k]
      if key then
        lg.push()
        lg.translate(getKeyPosition(k, r))

        lg.setColor(1, 1, 1)
        lg.rectangle("fill", 0, 0, keySize, keySize)

        lg.setColor(0, 0, 0, 0.6)
        lg.setFont(keyFont)
        lg.printf(love.keyboard.getKeyFromScancode(key), 0, keySize / 2 - keyFont:getHeight() / 2, keySize, "center")
        lg.pop()
      end
    end
  end

  lg.setColor(1, 0, 0)
  lg.circle("fill", self.test.x + keySize / 2, self.test.y + keySize / 2, keySize / 4)

  lg.pop()
end

return game
