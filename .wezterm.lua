-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Thin", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Thin Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Thin", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Thin Italic Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="ExtraLight", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono ExtraLight Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="ExtraLight", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono ExtraLight Italic Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Light", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Light Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Light", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Light Italic Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Regular Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Regular", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Italic Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Medium", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Medium Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Medium", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Medium Italic Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Bold", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Bold Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="Bold", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono Bold Italic Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="ExtraBold", stretch="Normal", style="Normal"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono ExtraBold Nerd Font Complete Mono.ttf, FontConfig
-- wezterm.font("JetBrainsMono Nerd Font Mono", {weight="ExtraBold", stretch="Normal", style="Italic"}) -- $HOME/.local/share/fonts/NerdFonts/JetBrains Mono ExtraBold Italic Nerd Font Complete Mono.ttf, FontConfig
--JetBrains Mono NL")

--config.font = wezterm.font("Maple Mono NF")
--config.font = wezterm.font("MonoLisa Nerd Font Mono")
--config.font = wezterm.font("D2CodingLigature Nerd Font")
--config.font = wezterm.font("Hack Nerd Font JBM Ligatured CCG")
--config.font = wezterm.font("BerkeleyMonoTrial Nerd Font Mono")
--config.font = wezterm.font("NotoMono Nerd Font Mono")
--config.font = wezterm.font("InconsolataLGC Nerd Font Mono")
--config.font = wezterm.font("JetBrainsMono Nerd Font")

config.font_size = 10

config.command_palette_font_size = 11
-- config.command_pallete_font = wezterm.font("JetBrainsMono Nerd Font Mono")

-- and finally, return the configuration to wezterm
return config
