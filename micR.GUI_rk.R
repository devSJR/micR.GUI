# RKWard plugin for the analysis of image data

require(rkwarddev)
local({
  
  # Author names and contact information
  about.info <- rk.XML.about(
    name = "Image Analysis",
    author = c(
      person(given = "Stefan", family = "Roediger",
             email = "stefan.roediger@b-tu.de", 
             role = c("aut","cre"))),
    about = list(desc = "GUI interface to analyze image data",
                 version = "0.0.1", url = "")
  )
  
  ## help page
  plugin.summary <- rk.rkh.summary(
    "GUI interface to analyze image data"
  )
  
  plugin.usage <- rk.rkh.usage(
    "Chose all images to analyze."
  )
  
  # Define dependencies
  dependencies.info <- rk.XML.dependencies(dependencies = list(rkward.min = "0.6.3"), 
                                           package = list(c(name = "micR", min = "0.0.1")))
  ## General settings
  
  preview.chk <- rk.XML.preview(label = "Preview")
  
  basic.settings <- rk.XML.row(
    rk.XML.col(
     		 preview.chk,
      rk.XML.stretch()
    ))
  
  
  full.dialog <- rk.XML.dialog(
    label = "Image Analysis",
    rk.XML.tabbook(tabs = list("Basic settings" = list(basic.settings)			  
      )
    )
  )
  
  JS.calc <- rk.paste.JS(
			  echo("img.APC  <- readImage(system.file('images/Well_Slide2_9_APC.png', package='micR'))\n"),
			  echo("img.pp   <- img.processor(img.raw = img.DAPI)\n"),
			  echo("img.xy	 <- computeFeatures(img.pp, img.DAPI, xname = \"nucleus\")\n"),
			  echo("img.moment <- computeFeatures.moment(img.pp)\n"),
			    echo("par(mfrow = c(1,2))\n"),
  echo("display(img.DAPI, method = \"raster\")\n"),
  echo("display(img.pp, method = \"raster\")\n")
  )
  
  JS.print <- rk.paste.JS(
  echo("par(mfrow = c(1,2))\n"),
  echo("display(img.DAPI, method = \"raster\")\n"),
  echo("display(img.pp, method = \"raster\")\n")
  
  )
  
  qIAanalysis <<-  rk.plugin.skeleton(
    about = about.info,
    dependencies = dependencies.info,
    xml = list(dialog = full.dialog),
    js = list(require = "micR",
              calculate = JS.calc,
              doPrintout = JS.print,
              results.header = FALSE), # results.header = FALSE is used for backward compatibility (RKWard v. < 0.6.2). Shoudl be removed for RKWard 0.6.3 or later
    rkh = list(plugin.summary, plugin.usage),
    pluginmap = list(
      name = "Image Analysis",
      hierarchy = list("analysis", "Image Analysis")),
    create=c("pmap","xml","js","desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = TRUE
  )
})

rk.build.plugin(imgAnalysis)