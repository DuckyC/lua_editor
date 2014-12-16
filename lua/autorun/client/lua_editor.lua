local PANEL = {}

PANEL.URL = "http://duckyc.github.io/lua_editor/"

PANEL.THEMES = {
	"ambiance", "chaos", "chrome", "clouds", "clouds_midnight", "cobalt", "crimson_editor", "dawn", "dreamweaver", "eclipse", "github", "idle_fingers", "katzenmilch", "kr_theme", "kuroir", "merbivore", "merbivore_soft", "mono_industrial", "monokai", "pastel_on_dark", "solarized_dark", "solarized_light", "terminal", "textmate", "tomorrow", "tomorrow_night", "tomorrow_night_blue", "tomorrow_night_bright", "tomorrow_night_eighties", "twilight", "vibrant_ink", "xcode"
}
PANEL.MODES = {
	"abap", "actionscript", "ada", "apache_conf", "asciidoc", "assembly_x86", "autohotkey", "batchfile", "c9search", "c_cpp", "clojure", "cobol", "coffee", "coldfusion", "csharp", "css", "curly", "d", "dart", "diff", "django", "dot", "ejs", "erlang", "forth", "ftl", "glsl", "golang", "groovy", "haml", "handlebars", "haskell", "haxe", "html", "html_completions", "html_ruby", "ini", "jack", "jade", "java", "javascript", "json", "jsoniq", "jsp", "jsx", "julia", "latex", "less", "liquid", "lisp", "livescript", "logiql", "lsl", "lua", "luapage", "lucene", "makefile", "markdown", "matlab", "mel", "mushcode", "mushcode_high_rules", "mysql", "nix", "objectivec", "ocaml", "pascal", "perl", "pgsql", "php", "plain_text", "powershell", "prolog", "properties", "protobuf", "python", "r", "rdoc", "rhtml", "ruby", "rust", "sass", "scad", "scala", "scheme", "scss", "sh", "snippets", "soy_template", "space", "sql", "stylus", "svg", "tcl", "tex", "text", "textile", "tmsnippet", "toml", "twig", "typescript", "vbscript", "velocity", "verilog", "vhdl", "xml", "xquery", "yaml"
}

function PANEL:Init()
	
	self.ErrorLabel = vgui.Create("DLabel", self)
	self.ErrorLabel.Dock(BOTTOM)
	self.ErrorLabel:SetText("")


	self:SetupHTML()
end

function PANEL:Think() end
function PANEL:Paint() end

function PANEL:SetupHTML()

	local HTML = vgui.Create("DHTML", self)
	HTML:Dock(FILL)

	AddJavascriptCallback("OnReady")
	AddJavascriptCallback("OnCode")
	AddJavascriptCallback("OnLog")

	self.HTML = HTML
end

function PANEL:AddJavascriptCallback(name)
	local func = self[name]
	if not func or IsValid(self.HTML) then return end
	self.HTML:AddFunction("gmodinterface", name, function(...)
		func(self,HTML,...)
	end)
end

function PANEL:OnReady() 

end

function PANEL:OnCode(_, code) 

end

function PANEL:OnLog(_, ...) Msg("Editor: ") print(...) end


function PANEL:SetTheme(name) end

function PANEL:SetFontSize(size) end

function PANEL:SetMode(name) end

function PANEL:GotoLine(num) end

function PANEL:SetContent(code) end

function PANEL:SetErr(errline, errstr) end

function PANEL:ClearErr() end

function PANEL:ShowMenu() self.HTML:Call("ShowMenu()") end

function PANEL:ShowBinds() self.HTML:Call("ShowBinds()") end




derma.DefineControl( "lua_editor", "Ingame Lua editor", PANEL, "EditablePanel" )