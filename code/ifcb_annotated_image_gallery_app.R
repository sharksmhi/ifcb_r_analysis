# Load required libraries
library(shiny)
library(base64enc)

# Define UI
ui <- fluidPage(
  titlePanel("IFCB annotated image gallery"),
  sidebarLayout(
    sidebarPanel(
      tags$label("Enter the path to the folder:"),
      textInput("path", "Folder Path", placeholder = "e.g., C:/path/to/annotated/images"),
      actionButton("go", "Go"),
      downloadButton("download", "Summary of selected images")
    ),
    mainPanel(
      uiOutput("gallery"),
      actionButton("prev", "Previous"),
      actionButton("next_button", "Next"),
      selectInput("imagesPerPage", "Images per page:",
                  choices = c(20, 50, 100),
                  selected = 20),
      tags$div(id = "log_info")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  images <- reactiveVal(NULL)
  current_page <- reactiveVal(1)
  images_per_page <- reactiveVal(20)
  clicked_images <- reactiveVal(character(0)) # Store clicked images
  class_folder <- reactiveVal(NULL) # Store the last folder in the path
  
  observeEvent(input$go, {
    # Validate path input
    if (is.null(input$path) || input$path == "") {
      return()
    }
    
    # Reset clicked_images
    clicked_images(NULL)
    
    # Replace backslashes with forward slashes
    path <- gsub("\\\\", "/", input$path)
    
    # Get last folder in the path
    folders <- unlist(strsplit(path, "/"))
    class_folder(folders[length(folders)])
    
    # Get list of files in the directory
    files <- list.files(path, full.names = TRUE)
    
    # Filter only images
    images(files[grep("\\.png$", files, ignore.case = TRUE)])
    current_page(1)
  })
  
  output$gallery <- renderUI({
    if (is.null(images()) || length(images()) == 0) {
      return(tags$p("No images found in the specified directory."))
    }
    
    start_index <- (current_page() - 1) * as.numeric(images_per_page()) + 1
    end_index <- min(current_page() * as.numeric(images_per_page()), length(images()))
    
    tags$div(
      lapply(images()[start_index:end_index], function(image) {
        encoded_image <- base64enc::dataURI(file = image, mime = "image/png")
        filename <- basename(image)
        style <- ifelse(filename %in% clicked_images(), "color: red;", "color: black;")
        tags$div(
          tags$img(src = encoded_image, 
                   style = "margin: 10px; cursor: pointer;",
                   onclick = paste0("Shiny.setInputValue('clicked_image', '", filename, "')")),
          tags$p(filename, id = filename, 
                 style = paste("margin: 5px 10px; font-weight: bold;", style))
        )
      })
    )
  })
  
  observeEvent(input$prev, {
    if (current_page() > 1) {
      current_page(current_page() - 1)
    }
  })
  
  observeEvent(input$next_button, {
    if (current_page() < ceiling(length(images()) / as.numeric(images_per_page()))) {
      current_page(current_page() + 1)
    }
  })
  
  observeEvent(input$imagesPerPage, {
    images_per_page(input$imagesPerPage)
  })
  
  observeEvent(input$clicked_image, {
    if (!input$clicked_image %in% clicked_images()) {
      clicked_images(c(clicked_images(), input$clicked_image))
    } else {
      clicked_images(clicked_images()[!clicked_images() %in% input$clicked_image])
    }
  })
  
  output$log_info <- renderText({
    paste("Clicked Images:", paste(clicked_images(), collapse = ", "))
  })
  
  # Generate and download text file with selected images summary
  output$download <- downloadHandler(
    filename = function() {
      paste(class_folder(), "_selected_images.txt", sep = "")
    },
    content = function(file) {
      selected_images <- data.frame(class_folder = class_folder(), image_filename = clicked_images())
      write.table(selected_images, file, sep = "\t", quote = FALSE, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
