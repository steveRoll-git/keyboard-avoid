local love = love
local lg = love.graphics

local keyRows = {
  { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' },
  { 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p' },
  { nil, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l' },
  { nil, 'z', 'x', 'c', 'v', 'b', 'n', 'm' },
}

local keySize = 32
local keyMargin = 5
local oddRowOffset = keySize / 2

local totalWidth = #keyRows[1] * (keySize + keyMargin) - keyMargin
local totalHeight = #keyRows * (keySize + keyMargin) - keyMargin

local game = {}

function game:enter()

end

function game:draw()
  lg.push()
  lg.translate(lg.getWidth() / 2 - totalWidth / 2, lg.getHeight() / 2 - totalHeight / 2)
  for r, row in ipairs(keyRows) do
    lg.push()
    lg.translate((r - 1) % 2 == 1 and oddRowOffset or 0, (r - 1) * (keySize + keyMargin))
    for k = 1, 10 do
      local key = row[k]
      if key then
        lg.rectangle("fill", (k - 1) * (keySize + keyMargin), 0, keySize, keySize)
      end
    end
    lg.pop()
  end
  lg.pop()
end

return game
