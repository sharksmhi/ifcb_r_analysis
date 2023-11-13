library(shiny)
library(shinyjs)
source("code/fun/get_class2use.R")

# Select classifier
classifier <- "Baltic"

# Select taxa
taxa <- "Dinophysis acuminata"

# Define your config data path
config_path <- ""

# Define filenames
class2use_file <- "class2use_Baltic.mat"

# Get class2use
class2use <- get_class2use(file.path(config_path, class2use_file))

# Remove current taxa from class2use
class2use <- class2use[!class2use == taxa]

# Set the paths to your image folders
source_folder <- file.path("", classifier, taxa)
destination_folder1 <- file.path("output/classifier/corrected", classifier, taxa)

# List all PNG files in the source folder
image_files <- list.files(source_folder, pattern = "\\.png$", full.names = TRUE)
sorted_image_files <- sort(image_files)  # Sort files alphabetically

# Check if there are images in destination_folder1
existing_files <- list.files(destination_folder1, pattern = "\\.png$", full.names = TRUE)

# Identify last file
last_file <- tail(existing_files, 1)

# Initialize Shiny app
ui <- fluidPage(
  useShinyjs(),  # Initialize shinyjs
  titlePanel(uiOutput("title")),
  mainPanel(
    fluidRow(
      column(12,
             actionButton("copy_to_folder1", taxa, style = "color: white; background-color: #007BFF"),
             actionButton("undo", "Previous image", style = "color: white; background-color: #6C757D")
      )
    ),
    fluidRow(
      column(8, imageOutput("image")),
      # Split dynamic buttons into three columns
      uiOutput("dynamic_buttons")
    )
  ),
  # Add custom CSS to adjust button size
  tags$head(
    tags$style(
      HTML("
           .btn {
             padding: 4px 8px;
             font-size: 10px;
           }
        ")
    )
  ),
  # Add JavaScript for keyboard shortcuts
  tags$script("
    $(document).on('keydown', function(e) {
      if (e.key === 'c' || e.key === 'C') {
        $('#copy_to_folder1').click();
      } else if (e.key === 'n' || e.key === 'N') {
        $('#copy_to_unclassified').click();
      }
    });
  ")
)

server <- function(input, output, session) {
  # Initialize reactive values
  current_image_index <- reactiveVal(ifelse(length(existing_files) > 0, match(basename(last_file), basename(image_files)), 1))
  copied_files <- reactiveVal(character(0))
  rv <- reactiveValues(copy_to_folder1_count = 0, dynamic_counts = rep(0, length(class2use)))
  
  # Initialize named list for dynamic button counts
  dynamic_counts <- reactiveVal(setNames(rep(0, length(class2use)), paste0("copy_to_", gsub(" ", "_", class2use))))
  
  # Initialize reactive values for button press history
  button_history <- reactiveValues(history = character(0))
  
  # Function to log button presses to a text file
  logButtonPresses <- function() {
    print("Logging button presses...")
    print(paste("copy_to_folder1_count:", rv$copy_to_folder1_count))
    
    dynamic_counts_val <- dynamic_counts()
    print(paste("dynamic_counts:", dynamic_counts_val))
    
    log_data <- data.frame(
      button_id = c(taxa, sub("copy_to_", "", names(dynamic_counts_val))),
      count = c(rv$copy_to_folder1_count, unname(dynamic_counts_val))
    )
    print(log_data)
    
    write.table(log_data, paste0("output/classifier/corrected/", classifier, "/",  taxa, "_button_press_log_", Sys.Date(), ".txt"), sep = "\t", row.names = FALSE, col.names = !file.exists("button_press_log.txt"))
    print("Button presses logged.")
  }
  
  # Function to increment button count
  increment_button_count <- function(button_id) {
    rv[[paste0(button_id, "_count")]] <- rv[[paste0(button_id, "_count")]] + 1
    
    # Update dynamic_counts
    button_index <- which(class2use == substr(button_id, 11, nchar(button_id)))
    if (length(button_index) > 0) {
      rv$dynamic_counts[button_index] <- rv$dynamic_counts[button_index] + 1
    }
  }
  
  # Function to decrement button count
  decrement_button_count <- function(button_id) {
    count_key <- paste0(button_id, "_count")
    rv[[count_key]] <- max(0, rv[[count_key]] - 1)
  }
  
  # Function to update the history of button presses
  update_button_history <- function(button_id) {
    button_history$history <- c(button_history$history, button_id)
  }
  
  # Function to update the displayed image
  updateImage <- function() {
    img_path <- reactive({
      req(sorted_image_files[current_image_index()])
      sorted_image_files[current_image_index()]
    })
    
    output$image <- renderImage({
      list(src = img_path(), alt = "Image", width = "auto", height = "auto")
    }, deleteFile = FALSE)
  }
  
  # Initialize the first image
  updateImage()
  
  # Function to copy the current image to a destination folder
  copyImage <- function(destination_folder) {
    if (!file.exists(destination_folder)) {
      dir.create(destination_folder, recursive = TRUE)
    }
    source_file <- sorted_image_files[current_image_index()]
    destination_file <- file.path(destination_folder, basename(source_file))
    file.copy(source_file, destination_file, overwrite = TRUE)
    copied_files(c(copied_files(), destination_file))
  }
  
  # Function to remove the last copied file
  undoCopy <- function() {
    if (length(copied_files()) > 0) {
      # Get the last copied file
      last_copied_file <- tail(copied_files(), 1)
      
      # Get the corresponding button ID from the history
      last_button <- tail(button_history$history, 1)
      
      # Remove the last copied file
      file.remove(last_copied_file)
      copied_files(c(copied_files()[-length(copied_files())]))
      
      # Decrement count for the last button press
      decrement_button_count(last_button)
      
      # Update dynamic counts if the last button press was a dynamic button
      if (startsWith(last_button, "copy_to_")) {
        dynamic_button <- sub("^copy_to_", "", last_button)
        dynamic_counts_val <- dynamic_counts()
        dynamic_counts_val[last_button] <- max(0, dynamic_counts_val[last_button] - 1)
        dynamic_counts(dynamic_counts_val)
      }
      
      # Remove the last button from history
      button_history$history <- button_history$history[-length(button_history$history)]
      
      logButtonPresses()
    }
  }
  
  # Event handler for "Copy to Folder 1" button
  observeEvent(input$copy_to_folder1, {
    copyImage(destination_folder1)
    current_image_index(current_image_index() + 1)
    updateImage()
    increment_button_count("copy_to_folder1")
    update_button_history("copy_to_folder1")
    logButtonPresses()
  })
  
  # Event handler for "Go Back" button
  observeEvent(input$undo, {
    undoCopy()
    if (current_image_index() > 1) {
      current_image_index(current_image_index() - 1)
      updateImage()
    }
  })
  
  # Event handler for dynamic buttons
  observe({
    lapply(seq_along(class2use), function(i) {
      button_id <- paste0("copy_to_", gsub(" ", "_", class2use[i]))
      observeEvent(input[[button_id]], {
        destination_folder <- file.path("output/classifier/corrected", classifier, class2use[i])
        copyImage(destination_folder)
        current_image_index(current_image_index() + 1)
        updateImage()
        increment_button_count(button_id)
        update_button_history(button_id)
        dynamic_counts_val <- dynamic_counts()
        dynamic_counts_val[button_id] <- dynamic_counts_val[button_id] + 1
        dynamic_counts(dynamic_counts_val)
        logButtonPresses()
      })
    })
  })
  
  # Add JavaScript to disable buttons when there are no more images
  observe({
    if (current_image_index() == length(sorted_image_files)) {
      shinyjs::disable(c("copy_to_folder1", "undo", paste0("copy_to_", class2use)))
    } else {
      shinyjs::enable(c("copy_to_folder1", "undo", paste0("copy_to_", class2use)))
    }
  })
  
  # Dynamically render buttons into three columns
  output$dynamic_buttons <- renderUI({
    buttons <- lapply(seq_along(class2use), function(i) {
      button_id <- paste0("copy_to_", gsub(" ", "_", class2use[i]))
      if (i == 1) {
        actionButton(button_id, label = class2use[i], style = "color: white; background-color: #28A745;")
      } else {
        actionButton(button_id, label = class2use[i])
      }
    })
    
    n <- length(buttons)
    buttons_per_column <- ceiling(n / 3)
    
    columns <- lapply(seq(0, 2), function(col_index) {
      start_index <- col_index * buttons_per_column + 1
      end_index <- min((col_index + 1) * buttons_per_column, n)
      column(width = 4, buttons[start_index:end_index])
    })
    
    do.call(fluidRow, columns)
  })
  
  # Dynamic title update
  output$title <- renderUI({
    h3(basename(sorted_image_files[current_image_index()]))
  })
}

shinyApp(ui, server)
