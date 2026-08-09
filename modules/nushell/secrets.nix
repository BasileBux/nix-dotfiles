{ osConfig, ... }:
''
  $env.ANTHROPIC_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/anthropic.age".path
  } | str trim)
  $env.OPENAI_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/openai.age".path
  } | str trim)
  $env.GEMINI_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/gemini.age".path
  } | str trim)
  $env.GOOGLE_GENERATIVE_AI_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/google-generative-ai.age".path
  } | str trim)
  $env.MOONSHOT_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/moonshot.age".path
  } | str trim)
  $env.TAVILY_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/tavily.age".path
  } | str trim)
  $env.XAI_API_KEY = (open ${osConfig.age.secrets."modules/zsh/api-keys/xai.age".path} | str trim)
  $env.GITHUB_TOKEN = (open ${osConfig.age.secrets."modules/zsh/github-token.age".path} | str trim)
  $env.NVIDIA_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/nvidia.age".path
  } | str trim)
  $env.DEEPSEEK_API_KEY = (open ${
    osConfig.age.secrets."modules/zsh/api-keys/deepseek.age".path
  } | str trim)
  $env.RAD_PASSPHRASE = (open ${
    osConfig.age.secrets."modules/zsh/rad-passphrase.age".path
  } | str trim)
''
