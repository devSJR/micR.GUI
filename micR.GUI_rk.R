# RKWard plugin for the analysis of image data
# Convention: The naming convention is to use period.separated
# (Baåth, R. (2012), The R Journal 4(2)) if possible.
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
  dependencies.info <- rk.XML.dependencies(dependencies = list(rkward.min = "0.6.3", R.min = "3.2"), 
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
  
  # Definition for warning settings
  # Default is to show no warnings
  warn.chk  <- rk.XML.cbox("Show warnings", value = "0", un.value = "-1")
  
  # File browser for XLS data.
  # Convntion: The names of the dyes will not be used for the initial variale 
  # assignment. Instead, by convention all dyes will have a name consisting of the
  # expression dye, followed by a running number (e.g., dye.one).
  
  dye.one <- rk.XML.browser("DAPI:", url = TRUE, required = TRUE, filter = c("*.bmp", "*.png", "*.tiff", "*.tif"))
  dye.two <- rk.XML.browser("FITC:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png", "*.tiff", "*.tif"))
  dye.three <- rk.XML.browser("Cy3:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png", "*.tiff", "*.tif"))
  dye.four <- rk.XML.browser("APC:", url = TRUE, required = FALSE, filter = c("*.bmp", "*.png", "*.tiff", "*.tif"))

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
				    rk.XML.row(
				      preview.chk,
				      do.full.analysis),
				    rk.XML.stretch()
				)
		    )
		    
  advanced.settings <- rk.XML.row(warn.chk)

  ## Image processing (img.processor)

  gblur.sigma <- rk.XML.spinbox("Sigma of gblur", min = 0, max = 10, initial = 2, max.precision = 4)
  thresh.w  <- rk.XML.spinbox("Width of the moving rectangular window", min = 0, initial = 20, max.precision = 2)
  thresh.h  <- rk.XML.spinbox("Hight of the moving rectangular window", min = 0, initial = 20, max.precision = 2)
  thresh.offset  <- rk.XML.spinbox("Thresholding offset from the averaged value", min = , max = , initial = 0.02, max.precision = 4)
  watershed.ext  <- rk.XML.spinbox("Radius of the neighborhood in pixels", min = 0, initial = 1, max.precision = 4)
  
  ## spott function
  spott.quantile <- rk.XML.spinbox("quantile", min = 0.001, max = 0.999, initial = 0.03, max.precision = 3)

  ## Image visualization

  image.display <- rk.XML.checkbox("Image Display", value = "raster", un.value = "browser", chk = TRUE)



  ## Image processing GUI elements

  image.processing <- rk.XML.row(
				rk.XML.col(
				    gblur.sigma,
				    thresh.w,
				    thresh.h,
				    thresh.offset,
				    watershed.ext,
				    spott.quantile,
				    rk.XML.stretch()
				)
			)

  image.visualization <- rk.XML.row(
				  rk.XML.col(
				      image.display,
				      rk.XML.stretch()
				      )
		      )
  
  ## Full diaglog structure
  
  full.dialog <- rk.XML.dialog(
    label = "Image Analysis",
    rk.XML.tabbook(tabs = list("Basic settings" = list(basic.settings),
			       "Image processing" = list(image.processing),
			       "Visualization" = list(image.visualization),
			       "Advanced settings" = list(advanced.settings)
      )
    )
  )
  
  JS.calc <- rk.paste.JS(
  echo("# Read images with img.dim
	img.DAPI <- try(img.dim(\"", dye.one,"\", width = ", img.dim.width,", hight = ", img.dim.width,"), silent = TRUE)
	img.FITC <- try(img.dim(\"", dye.two,"\", width = ", img.dim.width,", hight = ", img.dim.width,"), silent = TRUE)
	img.Cy3 <- try(img.dim(\"", dye.three,"\", width = ", img.dim.width,", hight = ", img.dim.width,"), silent = TRUE)
	img.APC <- try(img.dim(\"", dye.four,"\", width = ", img.dim.width,", hight = ", img.dim.width,"), silent = TRUE)
  \n"),
    
    echo("# Create a list of the images
	  list.data <- list(DAPI = img.DAPI, Cy3 = img.Cy3, APC = img.APC, FITC = img.FITC)\n"),
    
    echo("# Process a subfram of the nucleus image
	 img.pp.reduced <- img.processor(img.raw = img.DAPI[[\"img.reduced\"]], gblur.sigma = ", gblur.sigma,",
					 thresh.w = ", thresh.w,", thresh.h = ", thresh.h,",
					 thresh.offset = ", thresh.offset,", watershed.ext = ", watershed.ext,")
    \n"),
    js(
    if(do.full.analysis) { 
      echo("# Do full analysis of images by parallel processing
	    options(warn = ", warn.chk,");
	    numWorkers <- detectCores();
	    cl <- makeCluster(numWorkers, type = \"PSOCK\");
	    registerDoParallel(cl);
	    
	   # Process a subfram of the nucleus image
	    img.pp <- img.processor(img.raw = img.DAPI[[\"img.raw\"]], gblur.sigma = ", gblur.sigma,",
				    thresh.w = ", thresh.w,", thresh.h = ", thresh.h,",
				    thresh.offset = ", thresh.offset,", watershed.ext = ", watershed.ext,");
				    
	    img.moment <- computeFeatures.moment(img.pp);

	    res.out <- foreach(i = 1L:length(list.data), .packages = \"micR\") %dopar% if(class(list.data[[i]]) != \"try-error\") 
	    spott(img.raw = list.data[[i]][[\"img.raw\"]], img.pp = img.pp, img.moment  = img.moment, quantile = ", spott.quantile,")\n
	    names(res.out) <- names(list.data)
	    cell.numbers <- lapply(1L:length(list.data), function(i) {length(na.omit(res.out[[i]]))})
	    names(cell.numbers) <- names(list.data)
	    ")
	  }
      )
    )

  
  JS.print <- rk.paste.JS(
  echo("rk.sessionInfo()\n"),
  echo("layout(matrix(c(1,2,0,3,4,5), 2, 3, byrow = FALSE))
	try(display(img.DAPI[[\"img.reduced\"]], method = \"",  image.display,"\", title = \"", experiment.name,"\"))
	try(display(img.DAPI[[\"img.reduced\"]] - img.pp.reduced, method = \"",  image.display,"\"))
	try(display(rgbImage(blue = img.DAPI[[\"img.raw\"]], green = img.FITC[[\"img.raw\"]]), method = \"",  image.display,"\"))
	try(display(rgbImage(blue = img.DAPI[[\"img.raw\"]], green = img.Cy3[[\"img.raw\"]]), method = \"",  image.display,"\"))
	try(display(rgbImage(blue = img.DAPI[[\"img.raw\"]], red = img.APC[[\"img.raw\"]]), method = \"",  image.display,"\"))
  \n"),
  ite("full", rk.paste.JS(
      echo("rk.print.literal (\"Image Analysis:\")"),
      echo("\n# rk.print(res.out)\n"),
      echo("\nrk.print(cell.numbers)\n"),
      level = 3)
    )
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
