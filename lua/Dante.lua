--handle errors
this = Component.New("Dante")
Controls.FeedBack.String = ""
Controls.Log.String = ""
this["script.error.count"].EventHandler = function(c)
  if c.Value > 0 then 
    Controls.FeedBack.String = Controls.FeedBack.String.."\n"..this["log.history"].String
    Controls.Status.Value = 2
  end
end
this["log.history"].EventHandler = function(c)
  Controls.Log.String = Controls.Log.String.."\n"..c.String
end


--dependencies and variables
json = require('rapidjson')
pw = Controls.APIKey.String

--API Calls
function Calls(site)
  if not site then site = "" end
  return {
    ['Request Devices Status'] = 
    '{"query":"query Devices($domainId: ID!) {domain(id: $domainId) {devices {id name status { connectivity subscriptions}}}}","variables":{"domainId":"'..site..'"}}',
    ['Get Domains'] = 
    '{"query": "query Domains {domains {name id}}"}',
    ['List Accounts'] = 
    '{"query": "query Accounts {accounts {id name domains {name}}}"}',
    ['Request Domain Status'] = 
    '{"query":"query Domains {domains {name status {clocking connectivity latency subscriptions summary}}}","variables":{}}',
    ['List Unenrolled Devices'] = 
    '{"query": "query UnenrolledDevices {unenrolledDevices {name}}", "variables": {}}'
  }
end

--variables
local sites = {}
local siteIDs = {}
local data

--functions
--main api call handler
function MakeCall(call)
  HttpClient.Upload({
    Method = 'POST',
    Url = 'https://api.director.dante.cloud/graphql',
    Headers = {
      ['Content-Type'] = 'application/json',
      Authorization = pw
    },
    Data = call,
    EventHandler = function(t,c,d,e,h)
      if c == 200 then 
        Controls.Status.Value = 0 
      else 
        Controls.Status.Value = 2 
        print('error with code '..c)
        return false
      end
      if d then ProcessFeedback(json.decode(d)) end
      data = json.decode(d)
      return d
    end
  })
end

function DomainID()
  MakeCall('{"query": "query Domains {domains {name id}}"}')
  Timer.CallAfter(function()
    if data.errors then
      print('no data from API! errors:')
      print(json.encode(data.errors))
    else
      Timer.CallAfter(function() 
        for idx, site in pairs(data.data.domains) do
          sites[idx] = site.name
          siteIDs[idx] = site.id
          Controls.SiteId.Choices = sites
        end
      end, 05)
    end
  end, 1)
end

function ProcessFeedback(fb)
  for k,v in pairs(fb) do
    Controls.FeedBack.String = json.encode(v, {pretty=true})
  end
end

function PopulateCalls()
  local q = {}
  for name,_ in pairs(Calls("")) do
    table.insert(q, name)
  end
  Controls.Calls.Choices = q
  Controls.SiteId.IsInvisible = true
  Controls.Calls.String = "Choose an API Call..."
end

function HidePw()
  local cond 
  pw = Controls.APIKey.String
  if pw == '' then cond = false else cond = true end
  Controls.APIKey.IsInvisible = cond
end

function APIKeyHandler()
  Controls.ClearAPIKey.EventHandler = function()
    Controls.APIKey.String = ""
    print("API Key Cleared")
    HidePw()
  end
  Controls.APIKey.EventHandler = function(c)
    pw = Controls.APIKey.String
    Controls.FeedBack.String = ""
    HidePw()
    Init()
  end
  HidePw()
end

Controls.Calls.EventHandler = function(c)
  local data
  if c.String == "Request Devices Status" then
    Controls.SiteId.IsInvisible = false
    Controls.SiteId.String = "Choose a site..."
    Controls.FeedBack.String = ""
    Controls.SiteId.EventHandler = function(cs)
      local id
      for idx, site in pairs(sites) do
        if cs.String == site then id = siteIDs[idx] end
      end
      MakeCall(Calls(id)[c.String])
    end
  else
    Controls.SiteId.IsInvisible = true
    MakeCall(Calls("")[c.String])
  end
end

function PreInit()
  Controls.Status.Value = 5
  Controls.APIKey.IsInvisible = true
  Controls.FeedBack.String = ""
end



--initialize
function Init()
  PreInit()
  PopulateCalls()
  APIKeyHandler()
  Controls.Status.Value = 0
  DomainID()
end


Init()
