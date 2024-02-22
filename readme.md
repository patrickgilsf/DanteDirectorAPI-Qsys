#Steps

1. clone this repo
2. open Q-Sys file and drag in DanteAPI.quc
3. add your api key in the text box titled "APIKey", then press enter. 
  - Script will re-run and box will be hidden
  - cycle/remove API key by hitting button title "ClearAPIKey"
4. if you want to change the code, do the following:

  - create .env file at root of repo with following values
  - add the following items to .env:
  ```js
  UN="", --"User", set up in Q-Sys Administrator
  Pin="", --"Pin", set up in Q-Sys Adminitrator
  IP="", --IP address of Core
  ```

  - open terminal at root of repo, run:
    - `npm test` 
      - OR
    - `npm start`
  - write code and push updates
