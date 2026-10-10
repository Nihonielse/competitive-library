-- =========================================================
-- Competitive Programming Neovim Configuration
--
-- competitive/
-- ├── .nvim.lua
-- ├── input.txt
-- ├── output.txt
-- ├── codes/
-- │   ├── a.cpp
-- │   └── ...
-- └── build/
--     ├── a.cpp-bin
--     └── ...
-- =========================================================


-- =========================================================
-- Project root
-- =========================================================

-- .nvim.lua 自身が存在するディレクトリをプロジェクトルートにする
--
-- cwd に依存しないので、
--
--   cd competitive && nvim codes/a.cpp
--
-- でも
--
--   nvim competitive/codes/a.cpp
--
-- でも同じ competitive/ を使える。
local function project_root()
  local source = debug.getinfo(1, "S").source

  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end

  return vim.fn.fnamemodify(source, ":p:h")
end


-- =========================================================
-- Paths
-- =========================================================

local function source_file()
  return vim.fn.expand("%:p")
end

local function source_name()
  return vim.fn.expand("%:t")
end

local function build_file()
  return project_root() .. "/build/" .. source_name() .. "-bin"
end

local function input_file()
  return project_root() .. "/input.txt"
end

local function output_file()
  return project_root() .. "/output.txt"
end


-- =========================================================
-- Save
-- =========================================================

local function save_current_file()
  if vim.bo.modified then
    vim.cmd("update")
  end
end


local function save_buffer_by_path(path)
  local bufnr = vim.fn.bufnr(path)

  if bufnr == -1 or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("write")
    end)
  end
end


local function save_input()
  save_buffer_by_path(input_file())
end


-- =========================================================
-- Build
-- =========================================================

local function ensure_build_dir()
  local dir = project_root() .. "/build"

  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end


local function needs_build(source, output)
  if vim.fn.filereadable(output) == 0 then
    return true
  end

  return vim.fn.getftime(source) > vim.fn.getftime(output)
end


local function build(callback)
  local source = source_file()
  local output = build_file()

  if not source:match("%.cpp$") then
    vim.notify("Current file is not C++", vim.log.levels.WARN)
    if callback then
      callback(false)
    end
    return
  end

  ensure_build_dir()

  if not needs_build(source, output) then
    if callback then
      callback(true)
    end
    return
  end

  vim.notify("Building " .. source_name() .. "...")

  vim.system({
    "g++",
	"-I",
	".",
    "-std=c++23",
    "-O0",
    "-g",
    "-Wall",
    "-Wextra",
    source,
    "-o",
    output,
  }, {
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Build succeeded")

        if callback then
          callback(true)
        end
      else
        vim.notify(
          result.stderr ~= "" and result.stderr or "Build failed",
          vim.log.levels.ERROR
        )

        if callback then
          callback(false)
        end
      end
    end)
  end)
end


-- =========================================================
-- Bundle
-- =========================================================

local function bundle()
  -- 現在開いているソースコードだけ保存
  save_current_file()

  local source = source_file()

  if not source:match("%.cpp$") then
    vim.notify("Current file is not C++", vim.log.levels.WARN)
    return
  end

  vim.notify("Running oj-bundle...")

  vim.system({
    "oj-bundle",
    source,
  }, {
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          result.stderr ~= "" and result.stderr or "oj-bundle failed",
          vim.log.levels.ERROR
        )
        return
      end

      -- + レジスタ = システムクリップボード
      vim.fn.setreg("+", result.stdout)

      vim.notify("Bundled source copied to clipboard")
    end)
  end)
end


-- =========================================================
-- Clipboard -> input.txt
-- =========================================================

local function paste_input()
  local input = input_file()
  local bufnr = vim.fn.bufnr(input)

  -- input.txt がまだバッファとして開かれていなければ開く
  if bufnr == -1 then
    bufnr = vim.fn.bufadd(input)
    vim.fn.bufload(bufnr)
  end

  local clipboard = vim.fn.getreg("+")

  -- 末尾の改行を整理
  clipboard = clipboard:gsub("\n$", "")

  local lines = {}

  if clipboard == "" then
    lines = {}
  else
    lines = vim.split(clipboard, "\n", {
      plain = true,
    })
  end

  vim.api.nvim_buf_set_lines(
    bufnr,
    0,
    -1,
    false,
    lines
  )

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("write")
  end)

  vim.notify("Clipboard pasted to input.txt")
end


-- =========================================================
-- Debug
-- =========================================================

local function debug_program()
  -- ソースコードを保存
  save_current_file()

  -- input.txt も保存
  save_input()

  -- 必要ならビルドしてからDAP開始
  build(function(success)
    if not success then
      return
    end

    -- dap はプラグインロード後に取得
    local dap = require("dap")

    dap.continue()
  end)
end


-- =========================================================
-- DAP configuration
-- =========================================================

local function setup_dap()
  local dap = require("dap")

  dap.configurations.cpp = {
    {
      name = "Competitive Programming",
      type = "codelldb",
      request = "launch",

      program = function()
        return build_file()
      end,

      cwd = function()
        return project_root()
      end,

      stopOnEntry = false,

      args = {},

      stdio = {
        input_file(),
        output_file(),
      },
    },
  }
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(setup_dap)
  end,
})

-- =========================================================
-- Layout
-- =========================================================

local function setup_layout()
  local current = vim.api.nvim_get_current_buf()
  local current_name = vim.api.nvim_buf_get_name(current)

  -- すでに input/output が開かれている場合は何もしない
  local input = input_file()
  local output = output_file()

  -- 現在のバッファが source であることを前提にする
  if current_name == input or current_name == output then
    return
  end

  -- 左: source
  -- 右: input
  -- 右下: output

  vim.cmd("vsplit " .. vim.fn.fnameescape(input))

  vim.cmd("split " .. vim.fn.fnameescape(output))

  -- source 側へ戻る
  vim.cmd("wincmd h")
end


vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      setup_layout()
    end)
  end,
})


-- =========================================================
-- Disable format on save
-- =========================================================

vim.g.autoformat = false

-- =========================================================
-- Commands
-- =========================================================

vim.api.nvim_create_user_command("CPBuild", function()
  save_current_file()
  build()
end, {
  desc = "CP: Build",
})


vim.api.nvim_create_user_command("CPBundle", bundle, {
  desc = "CP: Bundle + Clipboard",
})


vim.api.nvim_create_user_command("CPPasteInput", paste_input, {
  desc = "CP: Paste clipboard into input.txt",
})


vim.api.nvim_create_user_command("CPDebug", debug_program, {
  desc = "CP: Build if needed and Debug",
})


-- =========================================================
-- Keymaps
-- =========================================================

vim.keymap.set("n", "<leader>cb", function()
  save_current_file()
  build()
end, {
  desc = "CP: Build",
})


vim.keymap.set("n", "<leader>co", bundle, {
  desc = "CP: Bundle + Clipboard",
})


vim.keymap.set("n", "<leader>ci", paste_input, {
  desc = "CP: Clipboard -> input.txt",
})


vim.keymap.set("n", "<leader>dd", debug_program, {
  desc = "CP: Build if needed and Debug",
})
