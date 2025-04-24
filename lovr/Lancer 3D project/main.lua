function lovr.load()
  -- Load a 3D model
  hex = lovr.graphics.newModel('Hex.obj')

  -- Use a dark grey background
  lovr.graphics.setBackgroundColor(.2, .2, .2)
end

function lovr.draw(hexpass)
  -- Draw the model
  hexpass:setColor(0.5, 0.5, 0.5)
  hexpass:draw(hex, -.5, 1, -3)
end
