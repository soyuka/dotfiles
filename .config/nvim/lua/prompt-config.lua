local conf = {
  default_command_agent = 'MyCodeGemini',
  default_chat_agent = 'MyCodeGemini',
  -- repo_instructions_cb = function()
  --   local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
  --   local prompt_message = 'This is a list of files with a list of files in the repository. Each file is separated by <file_separator> and contains its relative path and content.'
  --   local cache_result = vectorcode_cacher.query_from_cache()
  --   for _, file in ipairs(cache_result) do
  --     prompt_message = prompt_message
  --         .. '<file_separator>'
  --         .. file.path
  --         .. '\n'
  --         .. file.document
  --   end
  --
  --   if prompt_message ~= '' then
  --     prompt_message = '<repo_context>\n' .. prompt_message .. '\n</repo_context>'
  --   end
  --
  --   return prompt_message
  -- end,
  providers = {
    openai = {
      disable = true,
    },
    googleai = {
      disable = false,
      endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
      secret = os.getenv("GEMINI_API_KEY")
    },

  },
  agents = {
    {
      provider = "googleai",
      name = "MyCodeGemini",
      chat = true,
      command = true,
      model = { model = "gemini-2.0-flash" },
      system_prompt =
      [[
Respond to user messages according to the following principles:
- Do not repeat the user's request and return only the response to the user's request.
- Unless otherwise specified, respond in the same language as used in the user's request.
- Be as accurate as possible.
- Be as truthful as possible.
- Be as comprehensive and informative as possible.
- Do not give any explanation unless explicitly asked for.
- In PHP use PHP 8 attributes and functionalities if possible (match, fn)
- Do not add comments explaining what you did I understand the code
- You can add doc-block comments on function arguments if needed
- Do not change the given code even if the logic looks wrong, in that case just add a comment
            ]]
    },
    {
      provider = "googleai",
      name = "ConventionalCommit",
      chat = true,
      command = true,
      model = { model = "gemini-2.0-flash" },
      system_prompt = [[
Create a conventional commit for the given git diff that should respect the following specification: 		

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

    Commits MUST be prefixed with a type, which consists of a noun, feat, fix, etc., followed by the OPTIONAL scope, OPTIONAL !, and REQUIRED terminal colon and space.
    The type feat MUST be used when a commit adds a new feature to your application or library.
    The type fix MUST be used when a commit represents a bug fix for your application.
    A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis, e.g., fix(parser):
    A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes, e.g., fix: array parsing issue when multiple spaces were contained in string.
    A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.
    A commit body is free-form and MAY consist of any number of newline separated paragraphs.
    One or more footers MAY be provided one blank line after the body. Each footer MUST consist of a word token, followed by either a :<space> or <space># separator, followed by a string value (this is inspired by the git trailer convention).
    A footer’s token MUST use - in place of whitespace characters, e.g., Acked-by (this helps differentiate the footer section from a multi-paragraph body). An exception is made for BREAKING CHANGE, which MAY also be used as a token.
    A footer’s value MAY contain spaces and newlines, and parsing MUST terminate when the next valid footer token/separator pair is observed.
    Breaking changes MUST be indicated in the type/scope prefix of a commit, or as an entry in the footer.
    If included as a footer, a breaking change MUST consist of the uppercase text BREAKING CHANGE, followed by a colon, space, and description, e.g., BREAKING CHANGE: environment variables now take precedence over config files.
    If included in the type/scope prefix, breaking changes MUST be indicated by a ! immediately before the :. If ! is used, BREAKING CHANGE: MAY be omitted from the footer section, and the commit description SHALL be used to describe the breaking change.
    Types other than feat and fix MAY be used in your commit messages, e.g., docs: update ref docs.
    The units of information that make up Conventional Commits MUST NOT be treated as case sensitive by implementors, with the exception of BREAKING CHANGE which MUST be uppercase.
    BREAKING-CHANGE MUST be synonymous with BREAKING CHANGE, when used as a token in a footer.
]]
    }
  },
  hooks = {
		-- GpImplement rewrites the provided selection/range based on comments in it
		Implement = function(gp, params)
			local template = "Having following from {{filename}}:\n\n"
				.. "```{{filetype}}\n{{selection}}\n```\n\n"
				.. "Please rewrite this according to the contained instructions."
				.. "\n\nRespond exclusively with the snippet that should replace the selection above."

			local agent = gp.get_command_agent()
			gp.logger.info("Implementing selection with agent: " .. agent.name)

			gp.Prompt(
				params,
				gp.Target.rewrite,
				agent,
				template,
				nil, -- command will run directly without any prompting for user input
				nil -- no predefined instructions (e.g. speech-to-text from Whisper)
			)
		end,

    CommitMessage = function(gp, params)
      local agent = gp.get_command_agent('ConventionalCommit')
      local function get_commitlintrc_content()
        local filename = ".commitlintrc"
        local file = io.open(filename, "r")
        if not file then
          return ""
        end
        local content = file:read("*a")
        file:close()
        return 'My commitlint configuration:\n' .. content .. '\n'
      end

      local buffer_to_string = function()
        local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return table.concat(content, "\n")
      end
      gp.Prompt(params, gp.Target.rewrite, agent, buffer_to_string() .. get_commitlintrc_content())
    end,
    -- CodeWithContext = function(gp, params)
    --   local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
    --   local prompt_message = ''
    --   local cache_result = vectorcode_cacher.query_from_cache()
    --   for _, file in ipairs(cache_result) do
    --     prompt_message = prompt_message
    --         .. '<file_separator>'
    --         .. file.path
    --         .. '\n'
    --         .. file.document
    --   end
    --
    --   if prompt_message ~= '' then
    --     prompt_message = '<repo_context>\n' .. prompt_message .. '\n</repo_context>'
    --   end
    --
    --   prompt_message = prompt_message .. "\nThis is my instruction from {{filename}}:\n\n"
    --       .. "```{{filetype}}\n{{selection}}\n```"
    --   local agent = gp.get_command_agent()
    --   gp.Prompt(params, gp.Target.rewrite, agent, prompt_message)
    -- end,
    -- ChatWithContext = function(gp, params)
    --   local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
    --   local prompt_message = ''
    --   local cache_result = vectorcode_cacher.query_from_cache()
    --   for _, file in ipairs(cache_result) do
    --     prompt_message = prompt_message
    --         .. '<file_separator>'
    --         .. file.path
    --         .. '\n'
    --         .. file.document
    --   end
    --
    --   if prompt_message ~= '' then
    --     prompt_message = '<repo_context>\n' .. prompt_message .. '\n</repo_context>'
    --   end
    --
    --   gp.cmd.ChatNew(params, prompt_message)
    -- end,
  }
}

return conf
