solarShader = lovr.graphics.newShader([[
  vec4 lovrmain() {
    return DefaultPosition;
  }
]], [[
  	uniform vec3 lightDir;
	private vec3 normal;

  vec4 lovrmain(){
  	return DefaultColor;
  }
]])

