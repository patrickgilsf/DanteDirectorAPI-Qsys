import {
  Core 
} from '../ide-importer-module/index.js';

import {
  UN, PIN, IP
} from './config.js';


let deployment = new Core({
  ip: IP,
  username: UN,
  pw: PIN,
  comp: "Dante"
})

export {
  deployment
}

