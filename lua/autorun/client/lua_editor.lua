local PANEL = {}

PANEL.URL = "http://duckyc.github.io/lua_editor/"
PANEL.THEMES = {
	"ambiance", "chaos", "chrome", "clouds", "clouds_midnight", "cobalt", "crimson_editor", "dawn", "dreamweaver", "eclipse", "github", "idle_fingers", "katzenmilch", "kr_theme", "kuroir", "merbivore", "merbivore_soft", "mono_industrial", "monokai", "pastel_on_dark", "solarized_dark", "solarized_light", "terminal", "textmate", "tomorrow", "tomorrow_night", "tomorrow_night_blue", "tomorrow_night_bright", "tomorrow_night_eighties", "twilight", "vibrant_ink", "xcode"
}
PANEL.MODES = {
	"abap", "actionscript", "ada", "apache_conf", "asciidoc", "assembly_x86", "autohotkey", "batchfile", "c9search", "c_cpp", "clojure", "cobol", "coffee", "coldfusion", "csharp", "css", "curly", "d", "dart", "diff", "django", "dot", "ejs", "erlang", "forth", "ftl", "glsl", "golang", "groovy", "haml", "handlebars", "haskell", "haxe", "html", "html_completions", "html_ruby", "ini", "jack", "jade", "java", "javascript", "json", "jsoniq", "jsp", "jsx", "julia", "latex", "less", "liquid", "lisp", "livescript", "logiql", "lsl", "lua", "luapage", "lucene", "makefile", "markdown", "matlab", "mel", "mushcode", "mushcode_high_rules", "mysql", "nix", "objectivec", "ocaml", "pascal", "perl", "pgsql", "php", "plain_text", "powershell", "prolog", "properties", "protobuf", "python", "r", "rdoc", "rhtml", "ruby", "rust", "sass", "scad", "scala", "scheme", "scss", "sh", "snippets", "soy_template", "space", "sql", "stylus", "svg", "tcl", "tex", "text", "textile", "tmsnippet", "toml", "twig", "typescript", "vbscript", "velocity", "verilog", "vhdl", "xml", "xquery", "yaml"
}

local javascript_escape_replacements = {
	["\\"] = "\\\\",
	["\0"] = "\\0" ,
	["\b"] = "\\b" ,
	["\t"] = "\\t" ,
	["\n"] = "\\n" ,
	["\v"] = "\\v" ,
	["\f"] = "\\f" ,
	["\r"] = "\\r" ,
	["\""] = "\\\"",
	["\'"] = "\\\'",
}

function PANEL:Init()
	
	self.SelectedTheme = "monokai"
	self.SelectedMode = "lua"
	self.CompileAs = "LAU"
	self.Code = ""

	self.CodeSetBeforeReady = false
	self.NextValidate = false
	self.ErrorLine = false
	self.Ready = false

	local Panel = vgui.Create("DPanel", self)
	Panel:Dock(BOTTOM)
	Panel:DockMargin(6,3,3,3)
	Panel.OnMousePressed = function() print(self.ErrorLine) self:GotoErrorLine() end
	Panel.Paint = function() end

	self.ErrorLabel = vgui.Create("DLabel", Panel)
	self.ErrorLabel:SetTextColor( Color( 237,67,55 ) )
	self.ErrorLabel:SetText("")
	self.ErrorLabel:Dock(FILL)

	self:SetupHTML()
end

function PANEL:Think() 	if self.NextValidate and self.NextValidate < CurTime() then self:ValidateCode() end end
function PANEL:Paint() end

function PANEL:SetupHTML()

	self.HTML = vgui.Create("DHTML", self)
	self.HTML:Dock(FILL)

	self:AddJavascriptCallback("OnReady")
	self:AddJavascriptCallback("OnCode")
	self:AddJavascriptCallback("OnLog")
	self.HTML:OpenURL(self.URL)

end

function PANEL:JavascriptSafe( str )
	str = str:gsub( ".", javascript_escape_replacements )
	-- U+2028 and U+2029 are treated as line separators in JavaScript, handle separately as they aren't single-byte
	str = str:gsub( "\226\128\168", "\\\226\128\168" )
	str = str:gsub( "\226\128\169", "\\\226\128\169" )
	return str
end

function PANEL:CallJS(JS)
	if not self.Ready then return end
	self.HTML:Call(JS)
end

function PANEL:AddJavascriptCallback(name)
	local func = self[name]
	if not func or not IsValid(self.HTML) then return end
	self.HTML:AddFunction("gmodinterface", name, function(...)
		func(self,HTML,...)
	end)
end

function PANEL:OnReady() 
	self.Ready = true
	if self.CodeSetBeforeReady then
		self:SetCode(self:JavascriptSafe(self.Code))
	end
end

function PANEL:OnCode(_, code)
	self.NextValidate = CurTime() + 0.2
	self.Code = code
	self:OnCodeChanged(code)
end

function PANEL:OnLog(_, ...) Msg("Editor: ") print(...) end


function PANEL:SetTheme( name )
	if not table.HasValue(self.THEMES, name) then return end
	self.SelectedTheme = name
	self:CallJS("SetTheme('" .. name .. "'")
end

function PANEL:SetMode(name) 
	if not table.HasValue(self.MODES, name) then return end
	self.SelectedMode = name
	self:CallJS("SetMode('" .. name .. "'")
end

function PANEL:SetCode(code)
	if not content then return end
	if not self.Ready then self.CodeSetBeforeReady = true end
	self.Code = code
	self.HTML:CallJS('SetContent("' .. code .. '");')
end

function PANEL:GetCode() return self.Code end

function PANEL:SetGutterError(errline, errstr) self:CallJS("SetErr('"..errline.."', '"..self:JavascriptSafe(errstr).."')") end
function PANEL:GotoLine(num) self:CallJS("GotoLine('"..num.."')") end
function PANEL:ClearGutter() self.HTML:Call("ClearErr()") end
function PANEL:ShowMenu() self.HTML:Call("ShowMenu()") end
function PANEL:ShowBinds() self.HTML:Call("ShowBinds()") end
function PANEL:SetFontSize(size) self:CallJS("SetFontSize('"..size.."')") end

function PANEL:OnCodeChanged(code) end
function PANEL:OnLoaded() end

function PANEL:GotoErrorLine() self:GotoLine(self.ErrorLine or 1) end

function PANEL:SetError(err)
	if err then
		local line, err = string.match(err, self.CompileAs..":(%d*):(.+)")

		self.ErrorLabel:SetText( (line and err) and ("Line "..line..": "..err) or err or "" )
		self.ErrorLabel:SizeToContents()
		self.ErrorLabel:InvalidateLayout()
		
		self.ErrorLine = tonumber(string.match(err, " at line (%d)%)") or line) or 1
		self:SetGutterError(self.ErrorLine,err)
	else
		self.ErrorLabel:SetText("")
		self.ErrorLabel:SetWide(0)
		self.ErrorLabel:InvalidateLayout()

		self:ClearGutter()
	end
end
function PANEL:ValidateCode() 
	local time = SysTime()
	local code = self:GetCode()
	self.NextValidate = false
	if not code or code == "" then self:SetError() return end

	local errormsg = CompileString(code, self.CompileAs, false)
	time = SysTime() - time

	if type(errormsg) == "string" then
		self:SetError(errormsg)
	elseif time > 0.25 then
		self:SetError("Compiling took too long. ("..math.Round(time*1000)..")")
	else
		self:SetError()
	end
end

derma.DefineControl( "lua_editor", "Ingame Lua editor", PANEL, "EditablePanel" )