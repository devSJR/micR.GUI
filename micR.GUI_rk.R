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
  dependencies.info <- rk.XML.dependencies(dependencies = list(rkward.min = "0.6.4", R.min = "3.2"), 
					   package = list(c(name = "doParallel", min = "1.0.10"),
							  c(name = "EBImage", min = "4.12.0"),
							  c(name = "foreach", min = "1.4.3"),
							  c(name = "micR", min = "0.0.1")
							 ))
  ## General settings

  # Name of experiment
  experiment.name <- rk.XML.input("Experiment name", initial = "Image analysis")

  # Do full analysis
  do.full.analysis <- rk.XML.checkbox("Start full analysis")
  
  # File browser for XLS data.
  dye.one <- rk.XML.browser("DAPI:", url = TRUE, required = TRUE, filter = c("*.bmp", "*.png"))
  dye.two <- rk.XML.browser("FITC:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png"))
  dye.three <- rk.XML.browser("Cy3:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png"))
  dye.four <- rk.XML.browser("APC:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png"))

  img.dim.width <- rk.XML.spinbox("Preview width", min = 0, max = 100, initial = 25, real = FALSE)
  
  preview.chk <- rk.XML.preview(label = "Preview")

  ## General settings GUI elements
    
  basic.settings <- rk.XML.row(
				rk.XML.col(
				    experiment.name,
				    dye.one,
				    dye.two,
				    dye.three,
				    dye.four,
				    img.dim.width,
				    preview.chk,
				    do.full.analysis,
				    rk.XML.stretch()
				)
		    )

  ## Image processing (img.processor)

  gblur.sigma <- rk.XML.spinbox("Sigma of gblur", min = 0, max = 10, initial = 2, max.precision = 4)
  thresh.w  <- rk.XML.spinbox("Width of the moving rectangular window", min = 0, initial = 20, max.precision = 2)
  thresh.h  <- rk.XML.spinbox("Hight of the moving rectangular window", min = 0, initial = 20, max.precision = 2)
  thresh.offset  <- rk.XML.spinbox("Thresholding offset from the averaged value", min = , max = , initial = 0.02, max.precision = 4)
  watershed.ext  <- rk.XML.spinbox("Radius of the neighborhood in pixels", min = 0, initial = 1, max.precision = 4)

  ## Image processing GUI elements

  image.processing <- rk.XML.row(
				rk.XML.col(
				    gblur.sigma,
				    thresh.w,
				    thresh.h,
				    thresh.offset,
				    watershed.ext,
				    rk.XML.stretch()
				)
		    )
  
  ## Full diaglog structure
  
  full.dialog <- rk.XML.dialog(
    label = "Image Analysis",
    rk.XML.tabbook(tabs = list("Basic settings" = list(basic.settings),
			       "Image processing" = list(image.processing)
      )
    )
  )
  
  JS.calc <- rk.paste.JS(
			  
    echo("img.DAPI <- try(img.dim(\"", dye.one,"\", width = ", img.dim.width,", hight = ", img.dim.width,"))\n"),
    echo("img.FITC <- try(img.dim(\"", dye.two,"\", width = ", img.dim.width,", hight = ", img.dim.width,"))\n"),
    echo("img.Cy3 <- try(img.dim(\"", dye.three,"\", width = ", img.dim.width,", hight = ", img.dim.width,"))\n"),
    echo("img.APC <- try(img.dim(\"", dye.four,"\", width = ", img.dim.width,", hight = ", img.dim.width,"))\n\n"),
    
    echo("img.pp <- img.processor(img.raw = img.DAPI$\"img.reduced\", gblur.sigma = ", gblur.sigma,",\n"),
    echo("\t\t\tthresh.w = ", thresh.w,", thresh.h = ", thresh.h,", thresh.offset = ", thresh.offset,",\n"),
    echo("\t\t\twatershed.ext = ", watershed.ext,")\n\n"),
    
    echo("img.xy <- computeFeatures(img.pp, img.DAPI$\"img.reduced\", xname = \"nucleus\")\n\n"),
    echo("img.moment <- computeFeatures.moment(img.pp)\n\n"),
    echo("numWorkers <- detectCores()\n"),

    echo("cl <- makeCluster(numWorkers, type = \"PSOCK\")\n"),
    echo("registerDoParallel(cl)\n\n"),
    echo("list.data <- list(DAPI = img.DAPI, Cy3 = img.Cy3, APC = img.APC, FITC = img.FITC)\n"),
    echo("res.out <- foreach(i = 1L:length(list.data), .packages = \"micR\") %dopar% if(class(list.data[[i]]) != \"try-error\") spott(img.raw = list.data[[i]]$\"img.raw\", img.pp = img.pp, img.moment  = img.moment, quantile = 0.03)\n")
  )
  
  JS.print <- rk.paste.JS(
  echo("par(mfrow = c(1,2))\n"),
  echo("try(display(img.DAPI$\"img.reduced\", method = \"raster\", title = \"", experiment.name,"\"))\n"),
  echo("try(display(img.DAPI$\"img.reduced\" - img.pp, method = \"raster\"))\n")
  )
  
  imgAnalysis <<-  rk.plugin.skeleton(
    about = about.info,
    dependencies = dependencies.info,
    xml = list(dialog = full.dialog),
    js = list(require = c("doParallel", "EBImage", "foreach", "micR"),
              calculate = JS.calc,
              doPrintout = JS.print),
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
