require("./environment")

_        = require("lodash")
cp       = require("child_process")
path     = require("path")
argsUtil = require("./util/args")
Project  = require("./project")
api      = require("./api")
errors   = require("./electron/handlers/errors")

module.exports = {
  isCurrentlyRunningElectron: ->
    process.versions and process.versions.electron

  runGui: (options) ->
    ## if we have the electron property on versions
    ## that means we're already running in electron
    ## like in production and we shouldn't spawn a new
    ## process
    if @isCurrentlyRunningElectron()
      ## just run the gui code directly here
      ## and pass our options directly to main
      require("./electron/main")(options)
    else
      ## sanity check to ensure we're running
      ## the local dev server. dont crash just
      ## log a warning
      api.ping().catch (err) ->
        console.log(err.message)
        errors.warning("DEV_NO_SERVER")

      ## we are in dev mode and can just run electron
      ## in our electron folder which kicks things off
      cp.spawn("electron", [path.join(__dirname, "electron")], {
        ## we are going to pass the options as CYPRESS_ARGS
        ## for our electron process to avoid doing this again
        env: _.extend({}, process.env, {CYPRESS_ARGS: JSON.stringify(options)})
        stdio: "inherit"
      })

  runProject: (options) ->
    ## this code actually starts a project
    ## and is spawned from nodemon
    Project(options.project).open()

  runServer: (options) ->
    switch options.env
      when "development"
        args = {}

        _.defaults options, { autoOpen: true }

        if not options.project
          throw new Error("Missing path to project:\n\nPlease pass 'npm run server -- --project path/to/project'\n\n")

        if options.debug
          args.debug = "--debug"

        ## just spawn our own index.js file again
        ## but put ourselves in project mode so
        ## we actually boot a project!
        _.extend(args, {
          script:  "index.js"
          watch:  ["--watch", "lib"]
          ignore: ["--ignore", "lib/public"]
          verbose: "--verbose"
          exts:   ["-e", "coffee,js"]
          args:   ["--", "--mode", "project", "--project", options.project]
        })

        args = _.chain(args).values().flatten().value()

        cp.spawn("nodemon", args, {stdio: "inherit"})

        ## auto open in dev mode directly to our
        ## default cypress web app client
        if options.autoOpen
          _.delay ->
            require("open")("http://localhost:2020/__")
          , 2000

        if options.debug
          cp.spawn("node-inspector", [], {stdio: "inherit"})

          require("open")("http://127.0.0.1:8080/debug?ws=127.0.0.1:8080&port=5858")

      when "production"
        console.log "production"

      else
        throw new Error("Missing 'options.env'. This value is required to run Cypress server!")

  start: (argv) ->
    options = argsUtil.toObject(argv)

    ## if we are in smokeTest mode
    ## then just output the pong's value
    ## and exit
    if options.smokeTest
      process.stdout.write(options.pong + "\n")
      return process.exit()

    ## if we are in returnPackage mode
    ## then just output our package's value
    ## and exist
    if options.returnPkg
      manifest = require("../package.json")
      process.stdout.write(JSON.stringify(manifest) + "\n")
      return process.exit()

    ## to ensure we stay backwards compatible with older versions
    ## of the CLI Tool, we need to automatically set mode to be
    ## headless when any of these CLI arguments are present
    ##
    ## in the future we should be able to remove this code and instead
    ## automatically blow up if the cli version is too old
    if options.runProject or options.getKey or options.generateKey
      options.mode = "headless"

    switch options.mode
      when "gui"
        ## run the gui headed
        @runGui(options)

      when "headless"
        ## run the gui headlessly
        options.headless = true
        @runGui(options)

      when "server"
        ## run the server without gui
        @runServer(options)

      when "project"
        ## start the project
        @runProject(options)

      else
        throw new Error("Missing 'options.mode'. This value is required to run Cypress.")
}
