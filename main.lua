local roomy = require "roomy"
local game  = require "game"

Manager = roomy.new()

function love.load()
  Manager:hook()
  Manager:enter(game)
end