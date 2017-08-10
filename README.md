# Leeroy Jenkins
Messing up your perfectly planned system.

### Description
Editing `iptables` to mimic network gray outs is scary. Wouldn't it be nice to
have a tool that does exactly what you want in an easy to write / read way
**and** provides you a reset button in case things don't work the way you
expect it to? Me too!

### Dependencies

- `Bundler`
- Ruby >= 2.2.1, may work on >= 2.0, but haven't tested it.
- Linux distributions with `iptables` and `at`
- `sudo` access

### How to use

1. `git clone`
2. `bundle`
2. `bin/leeroy` will display a prompt with available commands
3. `bin/leeroy <command> --help` will display options available to that command.

All commands require `--for_reals` flag to _actually_ run. Otherwise
`LeeroyJenkins` will output to the commands it will run.

### Available Commands (aka Disruptions)

#### Network
This command will ssh into a `target` server and create iptable rules aimed to
drop packets at random. This will create latency, as packets need to be resent
over the wire, or simulate half-open connections, where the target can
communicate to outside services but won't get a response back (because all
incoming packets will be dropped). This command also comes with a default
escape hatch which will trigger in 1 hour.

**Required arguments:**
- `-t`, `--target=TARGET` pass the url of the server which you'd like to cause
a network disruption on. For example if I want to randomly drop packets on
server `web-server`, `Leeroy Jenkins` will run `ssh 'whoami'@web-server` and
change `iptables` on that box.

#### Fire Drill

This command will run a process which will randomly `ssh` into your servers and
run disruptions. Leeroy will know about your services and their dependencies by
reading a yaml file. The format should be like:

```
nodes:
  web:
    url: web.example.com
    dependencies:
      - db
      - api
  api:
    url: api.example.com
    dependencies:
      - facebook.com
  db:
    url: db.examplc.com
```

Dependencies can be the name of other services you've described in your yaml
file, or the url of a vendor.


Network is currently the only available disruption, more to come in the future!


### Running Tests

`bundle exec rspec`
