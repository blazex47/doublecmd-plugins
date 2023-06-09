-- signoff.lua (cross-platform)
-- 2023.04.14

require('read_write_csvfile_to_dict')

local fields = {
  "Signoff By",
  "Reviewed By",
  "Approved By"
}

local status = {
    "In progress",
    "Ready for review",
    "Inital review completed",
    "Final review completed",
    "On hold - wait for information",
    "On hold - other"
}

local params = {...}
local CSVDict = {}
local lu = {}


function PromptForPassword() --zhixiong
  result, password = Dialogs.InputQuery('signoff.lua', 'Enter password to proceed', true, '')
  if result == false then return end
  if password ~= '1' then
    Dialogs.MessageBox('Invalid password', 'signoff.lua', 0x0030)
    return PromptForPassword()
  end
  end
  
function WriteLog(hiddenDir, logEntry, action ,content)--zhixiong
  local logName = hiddenDir .. "change_log.csv"
  local pcName = os.getenv("COMPUTERNAME")
  local log = io.open(logName, 'a')
  if log == nil then
    Dialogs.MessageBox('Error writing log', 'signoff.lua', 0x0030)
    return
  end
  log:write(logEntry .. "," .. action .. "," .. content .. "," .. pcName .. "," .. os.date("%d/%m/%Y %H:%M:%S") .. "\n")
  log:close()
end



if #params == 0 then
  Dialogs.MessageBox('Check parameters!', 'signoff.lua', 0x0030)
  return
end

local sn = debug.getinfo(1).source
if string.sub(sn, 1, 1) == '@' then sn = string.sub(sn, 2, -1) end
fname = string.lower(fields[tonumber(params[2])])
fname = string.gsub(fname, " ", "_")
hiddenDir = createHiddenFolderIfNotExist(trimQuotes(params[4]),'dblcmd_hidden')
dbName = hiddenDir .. fname .. '.csv'
dbNameKey = removeNonAlphanumeric(dbName)
if CSVDict[fields[tonumber(params[2])] .. dbNameKey] == nil then
  CSVDict[fields[tonumber(params[2])] .. dbNameKey] = ReadCSVFileToDict(dbName)
end

h, err = io.open(params[3], 'r')
if h == nil then
  Dialogs.MessageBox('Error 2: ' .. err, 'signoff.lua', 0x0030)
  return
end
c = 1
for l in h:lines() do
  lu[c] = l
  c = c + 1
end
h:close()
if #lu == 0 then
  Dialogs.MessageBox('Error 3', 'signoff.lua', 0x0030)
  return
end

if params[1] == '--update' then
  namelistfile ,err = io.open(SysUtils.ExtractFilePath(sn) .. 'namelist.txt', 'r')
  if namelistfile == nil then
    Dialogs.MessageBox('Error 4: ' .. err, 'signoff.lua', 0x0030)
    return
  end
  count = 1
  namelist = {}
  for line in namelistfile:lines() do
    namelist[count] = line
    count = count + 1
  end
  namelistfile:close()  
  username = Dialogs.InputListBox('signoff.lua', fields[tonumber(params[2])], namelist, 1)
  if username == 'New Name' then
    result, userinput = Dialogs.InputQuery('signoff.lua', fields[tonumber(params[2])], false, '')
    if result == false then return end
    username = userinput
    namelist[#namelist + 1] = username
    namelistfile ,err = io.open(SysUtils.ExtractFilePath(sn) .. 'namelist.txt', 'w')
    if namelistfile == nil then
      Dialogs.MessageBox('Error 5: ' .. err, 'signoff.lua', 0x0030)
      return
    end
    namelistfile:write(table.concat(namelist, '\n') .. '\n')
    namelistfile:close()
  end
  state = Dialogs.InputListBox('signoff.lua', fields[tonumber(params[2])], status, 1)
  result, finalmsg = Dialogs.InputQuery('signoff.lua', fields[tonumber(params[2])], false, state .. ' (' .. username .. ', '.. os.date("%d/%m/%Y") .. ')')
  if result == false then return end
  for i = 1, #lu do
    CSVDict[fields[tonumber(params[2])] .. dbNameKey][lu[i]] = finalmsg
    -- Write log entry
    WriteLog(hiddenDir,lu[i],'update',finalmsg) 
  end
  
  
elseif params[1] == '--remove' then --zhixiong
  PromptForPassword()
  for i = 1, #lu do
    local content = CSVDict[fields[tonumber(params[2])] .. dbNameKey][lu[i]]
    CSVDict[fields[tonumber(params[2])] .. dbNameKey][lu[i]] = ""
    -- Write log entry--zhixiong
    WriteLog(hiddenDir,lu[i],'remove',content)  
  end
end

if CSVDict[fields[tonumber(params[2])] .. dbNameKey] ~= nil then
  WriteCSDictToFile(CSVDict[fields[tonumber(params[2])] .. dbNameKey],dbName)
end

os.setenv('SignOffDB' .. dbNameKey, 'Read')

if params[5] == '--auto' then
  DC.ExecuteCommand('cm_Refresh')
end