-- Overrides for the lazyvim.plugins.extras.ai.avante extra.
return {
  "yetone/avante.nvim",
  opts = {
    provider = "gemini",
    providers = {
      gemini = {
        model = "gemini-2.5-flash",
      },
    },
  },
}
