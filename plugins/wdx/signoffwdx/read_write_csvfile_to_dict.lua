-- read_write_csvfile_to_dict.lua (cross-platform)
-- 2023.04.14

function ReadCSVFileToDict(CSVFilePath)
  local result = {}
  local CSVFile = io.open(CSVFilePath, 'r')
  if CSVFile ~= nil then
    for line in CSVFile:lines() do
      local tokens = split(line, ",")
      if #tokens > 0 then
        local filepathkey = table.remove(tokens, 1)
        if #tokens == 0 then
          result[filepathkey] = ""
        else
          result[filepathkey] = tokens[1] .. '(' .. tokens[2] .. ',' .. tokens[3] .. ')'
        end
      end
    end
    CSVFile:close()
  end
  return result
end

function WriteCSDictToFile(CSVDict,CSVFilePath)
  local CSVFile = io.open(CSVFilePath, 'w+')
  if CSVFile ~= nil then
    if getTableSize(CSVDict) == 0 then
      CSVFile:write('\n')
    else
      r = {}
      c = 1
      for k, v in pairs(CSVDict) do
        if v ~= "" then
          local tokens = split(v, ",()")
          r[c] = k .. "," .. table.concat(tokens, ",")
          c = c + 1
        end
      end
      CSVFile:write(table.concat(r, '\n') .. '\n')
    end
    CSVFile:close()
  end
end

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function getTableSize(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

function createHiddenFolderIfNotExist(baseDir, folderName)
  local path

  -- Detect the operating system
  if package.config:sub(1, 1) == "\\" then -- Windows
      path = baseDir .. "\\" .. folderName
      if not os.rename(path, path) then -- Check if folder exists
          os.execute("mkdir " .. path) -- Create folder
          os.execute("attrib +h " .. path) -- Set hidden attribute
      end
      path = path .. "\\"
  else -- Linux, macOS, and other Unix-based systems
      path = baseDir .. "/" .. "." .. folderName
      if not os.rename(path, path) then -- Check if folder exists
          os.execute("mkdir " .. path) -- Create hidden folder
      end
      path = path .. "/"
  end

  return path
end

function getDirectory(filePath)
  local directory = string.match(filePath, "(.-)[\\/][^\\/]-$")
  return directory
end

function removeNonAlphanumeric(filePath)
  local directory = string.gsub(filePath, "%W", "")
  return directory
end

function trimQuotes(str)
  if string.sub(str, 1, 1) == '"' and string.sub(str, -1) == '"' then
      return string.sub(str, 2, -2)
  end
  return str
end