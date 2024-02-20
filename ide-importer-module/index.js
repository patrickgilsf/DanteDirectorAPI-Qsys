import fs from 'fs';
import net from 'net';
const timeoutPromise = (timeout) => new Promise((resolve) => setTimeout(resolve, timeout))


class Core {
  constructor({ip="",username="",pw="", comp=""} = {}) {
    this.ip = ip;
    this.username = username;
    this.pw = pw;
    this.comp = comp;
  }

  nt = "\u0000";

  ip = (ip) => {
    this.ip = ip
  };

  username = (un) => {
    this.username = un
  };

  pw = (pw) => {
    this.pw = pw
  };

  comp = (comp) => {
    this.comp = comp
  };

  add = (input, attribute) => {
    this[input] = attribute
  }
  
  login = () => {
    return this.username && this.pw
    ?
    JSON.stringify({
      "jsonrpc": "2.0",
      "method": "Logon",
      "params": {
        "User": this.username,
        "Password": this.pw
      }
    })
    :
    false;
  };

  addCode = (comp, code, id) => {
    id ? id = id : id = 1234;
    return JSON.stringify({
      "jsonrpc": "2.0",
      "id": id,
      "method": "Component.Set",
      "params": {
        "Name": comp,
        "Controls": [
          {
            "Name": "code",
            "Value": code
          }
        ]
      }
    })
  };

  update = (file) => {
    console.log(this.login());
    let client = new net.Socket();
    client.connect(1710, this.ip, async () => {
      let login = this.login();
      this.login() ? client.write(login + this.nt) : null;

      fs.readFile(file, 'utf-8', (err, data) => {
        if (err) {
          throw err
        } else {
          client.write(this.addCode(this.comp, data) + this.nt);
        }
      });

      client.on('data', (d) => {
        console.log(`received data from QRC API: ${d}`);
      });

      client.on('close', () => {
        console.log('server closed connection');
        client.end();
      });

      await timeoutPromise(3000);
      client.end();
    })
    
  }

}

export {
  Core
}
