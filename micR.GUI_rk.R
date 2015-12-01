# RKWard plugin for the analysis of image data

require(rkwarddev)
rkwarddev.required("0.7.3")

local({
  
  # Author names and contact information
  about.info <- rk.XML.about(
    name = "Image Analysis",
    author = c(
      person(given = "Stefan", family = "Roediger",
             email = "stefan.roediger@b-tu.de", 
             role = c("aut","cre"))),
    about = list(desc = "GUI interface to analyze image data",
                 version = "0.0.1", url = "https://github.com/devSJR/micR.GUI")
  )
  
  ## help page
  plugin.summary <- rk.rkh.summary(
    "GUI interface to analyze image data"
  )
  
  plugin.usage <- rk.rkh.usage(
    "Chose all images to analyze."
  )
  
  # Define dependencies
  dependencies.info <- rk.XML.dependencies(dependencies = list(rkward.min = "0.6.4"), 
					   package = list(c(name = "doParallel", min = "1.0.10"),
							  c(name = "EBImage", min = "4.12.0"),
							  c(name = "foreach", min = "1.4.3"),
							  c(name = "micR", min = "0.0.1")
							 ))
  ## General settings
  # File browser for XLS data.
  dye.DAPI <- rk.XML.browser("DAPI:", url = TRUE, required = TRUE, filter = c("*.bmp", "*.png"))
  dye.FITC <- rk.XML.browser("FITC:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png"))
  dye.Cy3 <- rk.XML.browser("Cy3:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png"))
  dye.APC <- rk.XML.browser("APC:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png"))
  
  preview.chk <- rk.XML.preview(label = "Preview")
  
  basic.settings <- rk.XML.row(
				rk.XML.col(
				    dye.DAPI,
				    dye.FITC,
				    dye.Cy3,
				    dye.APC,
				    preview.chk,
				    rk.XML.stretch()
				)
		    )
  
  
  full.dialog <- rk.XML.dialog(
    label = "Image Analysis",
    rk.XML.tabbook(tabs = list("Basic settings" = list(basic.settings)			  
      )
    )
  )
  
  JS.calc <- rk.paste.JS(
			  echo("img.DAPI  <- try(imgtoEBImage(\"", dye.DAPI,"\"))\n"),
			  echo("img.FITC  <- try(imgtoEBImage(\"", dye.FITC,"\"))\n"),
			  echo("img.Cy3  <- try(imgtoEBImage(\"", dye.Cy3,"\"))\n"),
			  echo("img.APC  <- try(imgtoEBImage(\"", dye.APC,"\"))\n"),
			  echo("img.pp   <- img.processor(img.raw = img.DAPI)\n"),
			  echo("img.xy	 <- computeFeatures(img.pp, img.DAPI, xname = \"nucleus\")\n"),
			  echo("img.moment <- computeFeatures.moment(img.pp)\n"),
			  echo("numWorkers <- detectCores()\n"),
			  echo("cl <- makeCluster(numWorkers, type = \"PSOCK\")\n"),
			  echo("registerDoParallel(cl)\n"),
			  echo("list.data <- list(DAPI = img.DAPI, Cy3 = img.Cy3, APC = img.APC, FITC = img.FITC)\n"),
			  echo("res.out <- foreach(i = 1L:length(list.data), .packages = \"micR\") %dopar% if(class(list.data[[i]]) != \"try-error\") spott(img.raw = list.data[[i]], img.pp = img.pp, img.moment  = img.moment, quantile = 0.03)\n")
			)
  
  JS.print <- rk.paste.JS(
  echo("par(mfrow = c(1,2))\n"),
  echo("display(img.DAPI, method = \"raster\")\n"),
  echo("display(img.pp, method = \"raster\")\n")
  
  )
  
  imgAnalysis <<-  rk.plugin.skeleton(
    about = about.info,
    dependencies = dependencies.info,
    xml = list(dialog = full.dialog),
    js = list(require = c("doParallel", "EBImage", "foreach", "micR"),
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
