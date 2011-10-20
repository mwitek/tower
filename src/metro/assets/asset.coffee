class Asset extends (require("../support/path"))
  @digest_path: (path) ->
    @path_with_fingerprint(path, @digest(path))
    
  @path_fingerprint: (path) ->
    result = Metro.Support.Path.basename(path).match(/-([0-9a-f]{32})\.?/)
    if result? then result[1] else null
    
  @path_with_fingerprint: (path, digest) ->
    if old_digest = @path_fingerprint(path)
      path.replace(old_digest, digest)
    else
      path.replace(/\.(\w+)$/, "-#{digest}.\$1")
  
  constructor: (path) ->
    @path        = Metro.Support.Path.expand_path(path)
  
  # Return logical path with digest spliced in.
  # 
  #   "foo/bar-37b51d194a7513e45b56f6524f2d51f2.js"
  # 
  digest_path: ->
    @constructor.digest_path(@path)
  
  # Gets digest fingerprint.
  # 
  #     "foo-0aa2105d29558f3eb790d411d7d8fb66.js"
  #     # => "0aa2105d29558f3eb790d411d7d8fb66"
  # 
  path_fingerprint: ->
    @constructor.path_fingerprint(@path)
  
  # Injects digest fingerprint into path.
  # 
  # ``` coffeescript
  # "foo.js" #=> "foo-0aa2105d29558f3eb790d411d7d8fb66.js"
  # ```
  # 
  path_with_fingerprint: (digest) ->
    @constructor.path_with_fingerprint(@path, digest)
    
  write: (to, options) ->
    # Gzip contents if filename has '.gz'
    options.compress ?= Metro.Support.Path.extname(to) == '.gz'
    
    if options.compress
      # Open file and run it through `Zlib`
      fs.readFile @path, (data) ->
        fs.writeFile "#{to}+", data
    else
      # If no compression needs to be done, we can just copy it into place.
      Metro.Support.Path.copy(@path, "#{to}+")
    
    # Atomic write
    FileUtils.mv("#{filename}+", filename)
    
    # Set mtime correctly
    Metro.Support.Path.utime(mtime, mtime, filename)

    nil
    
  render: ->
    data        = Metro.Assets.processor_for(@extensions()[0][1..-1]).process_directives(@read())
    compilers   = @compilers()
    for compiler in compilers
      data = compiler.compile(data)
    data
    
  compilers: ->
    unless @_compilers
      extensions  = @extensions()
      result      = []
      
      for extension in extensions
        compiler = Metro.Compilers.find(extension[1..-1])
        result.push(compiler) if compiler
        
      @compilers = result
      
    @compilers
    
  body: ->
    @render()

module.exports = Asset
