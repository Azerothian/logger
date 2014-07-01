path = require "path"
CSON = require "cson"

class Config
  @scope: "singleton"
  constructor: () ->
    @rootdir = process.cwd()
    configPath = path.join @rootdir, "/config.cson"
    config = CSON.parseFileSync configPath
    for i of config #alternative to using extends. dont know if this is faster?
      @[i] = config[i]
  getPath: (target) =>
    return path.join @rootdir, target
module.exports = Config
