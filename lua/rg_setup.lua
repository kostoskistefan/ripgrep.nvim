local M = {}

function M.install_rg()
  -- Define supported targets for each OS and architecture
  local supported_os_architecture_targets = {
    Windows_NT = {
      i686      = 'i686-pc-windows-msvc',
      x86_64    = 'x86_64-pc-windows-msvc',
    },
    Darwin = {
      x86_64    = 'x86_64-apple-darwin',
      aarch64   = 'aarch64-apple-darwin',
    },
    Linux = {
      i686      = 'i686-unknown-linux-gnu',
      s390x     = 's390x-unknown-linux-gnu',
      x86_64    = 'x86_64-unknown-linux-musl',
      aarch64   = 'aarch64-unknown-linux-gnu',
      powerpc64 = 'powerpc64-unknown-linux-gnu',
      armv7     = 'armv7-unknown-linux-musleabi',
      armv7l    = 'armv7-unknown-linux-musleabi',
      armv7h    = 'armv7-unknown-linux-musleabihf',
    },
    OpenBSD = {
      i686      = 'i686-unknown-linux-gnu',
      s390x     = 's390x-unknown-linux-gnu',
      x86_64    = 'x86_64-unknown-linux-musl',
      aarch64   = 'aarch64-unknown-linux-gnu',
      powerpc64 = 'powerpc64-unknown-linux-gnu',
      armv7     = 'armv7-unknown-linux-musleabi',
      armv7l    = 'armv7-unknown-linux-musleabi',
      armv7h    = 'armv7-unknown-linux-musleabihf',
    },
  }

  -- Get the current OS, architecture and corresponding target
  local os = vim.loop.os_uname().sysname
  local architecture = vim.loop.os_uname().machine
  local target = supported_os_architecture_targets[os][architecture]

  if not target then
    error(string.format('Unsupported architecture for %s: %s', os, architecture))
  end

  -- Find the latest ripgrep version from the rg_version file
  -- which is updated through GitHub actions to the latest version
  local ripgrep_version = vim.fn.readfile(debug.getinfo(1).source:match("@?(.*/).-/") .. 'rg_version')[1]

  if not ripgrep_version then
    error('Failed to read the latest ripgrep version.')
  end

  -- Create a ripgrep.nvim directory inside the nvim-data directory to store the ripgrep executable
  local data_path = vim.fn.stdpath('data') .. '/ripgrep.nvim'

  if vim.fn.isdirectory(data_path) == 0 then
    vim.fn.mkdir(data_path, 'p')
  end

  local ripgrep_filename = string.format('ripgrep-%s-%s', ripgrep_version, target)
  local base_url = 'https://github.com/BurntSushi/ripgrep/releases/download/' .. ripgrep_version .. '/'

  local archive_extension = (os == 'Windows_NT' and 'zip' or 'tar.gz')
  local archive_path = string.format('%s/rg.%s', data_path, archive_extension)
  local url = string.format('%s/%s.%s', base_url, ripgrep_filename, archive_extension)

  local commands

  -- Set the commands to download and install ripgrep
  if os == 'Windows_NT' then
    commands = {
      string.format('powershell.exe -command "Invoke-WebRequest %s -OutFile %s"', url, archive_path),
      string.format('powershell.exe -command "Expand-Archive -Path %s -DestinationPath %s"', archive_path, data_path),
      string.format('powershell.exe -command "mv %s/%s/rg.exe %s/rg.exe"', data_path, ripgrep_filename, data_path),
      string.format('powershell.exe -command "rm %s"', archive_path),
      string.format('powershell.exe -command "rm %s/%s -Recurse -Force"', data_path, ripgrep_filename),
    }
  else
    commands = {
      string.format('curl -L %s -o %s', url, archive_path),
      string.format('tar -xzf %s -C %s', archive_path, data_path),
      string.format('mv %s/%s/rg %s/rg', data_path, ripgrep_filename, data_path),
      string.format('rm %s', archive_path),
      string.format('rm %s/%s', data_path, ripgrep_filename),
    }
  end

  -- Execute the commands sequentially
  for _, command in ipairs(commands) do
    vim.fn.system(command)
  end
end

return M
