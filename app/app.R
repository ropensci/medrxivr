###########################################################################
# About -------------------------------------------------------------------
###########################################################################
#
# Title: medrxivr web application
# Author: Luke A McGuinness (luke.mcguinness@bristol.ac.uk)
# Description: This app was created to be a companion to the medrixvr R package
# (https://github.com/mcguinlu/medrxivr), which allows systematic reviewers to
# to use complex search queries to find relevant preprints in the medRxiv
# (https://www.medrxiv.org/) repository. The app also allows users to explore
# some simple visualisations of their search results and export their results in
# a useable format.
#
# Other notes: Submitted to the Shiny Contest 2020

###########################################################################
# External scripts --------------------------------------------------------
###########################################################################

# Library calls
source("R/library.R")

# Define function for main trend plot
source("R/plot_results.R")

# Define function for wordcloud plot
source("R/plot_word_cloud.R")

# Define misc variables and JS code
source("R/misc.R")

###########################################################################
# User interface ----------------------------------------------------------
###########################################################################

# Define UI
ui <- tagList(
  tags$head(includeHTML("www/google-analytics.html")),
  navbarPage(

        title = "medrxivr",
        id = "mytabsetpanel",
        theme = shinythemes::shinytheme("yeti"),

    # Tab with the welcome screen and basic search interface ----
    tabPanel(
      "Welcome",
      includeMarkdown("text/intro.md"),
      p("To get started, enter a search term (",
        actionLink("loadbasicsearch","click here to load an example"),
        ") into the box below or go to the \"Advanced search\" tab to design more complex searches. Your search results are presented as a table and are available for easy download as a comma seperated file (CSV). Summary graphics describing your search results are presented. Finally, as this app is designed as a companion to the ",
        code("medrxivr"),
        " R package, the code used to perform your search in R is provided, meaning it is readily reproducible.",        "To see more about the apps background and development, please click ",
        actionLink("gotomore", "here.")
      ),

      hr(),
      h1("Basic search", align = "center"),
      fluidRow(
        column(
          6,
          align = "center",
          offset = 3,
          p(snapshot_info),

          # Simulate button click with "Enter" key
          # Allows users to hit enter to start basic search
          tagAppendAttributes(
            textInput("basicsearchquery", NULL, value = ""),
            `data-proxy-click` = "basicsearchbutton"
          ),
          actionButton("basicsearchbutton", label = "Start basic search"),
          br(),
          actionLink("gotoadv", "Advanced search")

        )
      ),

      # Define initalising loading screen
      waiter_show_on_load(
        html = tagList(spin_folding_cube(),
                       br(),
                       h4("Initalising medrxivr")),
        color = "#333333"
      )
    ),

    # Tab with the advanced search interface ----
    tabPanel(
    "Advanced search",
    value = "advsearch",

    # Read text from file
    includeMarkdown("text/advsearch.md"),
    p(
      "Click ",
      actionLink("loadsearch", "here"),
      " to load an example search (tests for coronavirus) and",
      " see the ",
      actionLink("gotohelp", "\"Help\""),
      " tab for more information on using regular expressions in your search terms."
    ),


    # Search builder interface
    column(
      width = 5,
      fluidRow(
        h1("Search builder"),

      ),
      fluidRow(textAreaInput(
        inputId = "topic1",
        label = "Topic 1",
        value = ""
      )),
      fluidRow(textAreaInput(
        inputId = "topic2",
        label = "Topic 2",
        value = ""
      )),
      fluidRow(textAreaInput(
        inputId = "topic3",
        label = "Topic 3",
        value = ""
      )),
      tags$div(id = 'placeholder'),
      fluidRow(actionButton("addtopic", label = "Add topic"))

    ),

    # Options interface
    column(
      width = 6,
      offset = 1,
      fluidRow(h1("Options")),
      fluidRow(textAreaInput(
        inputId = "NOT",
        label = "NOT",
        value = ""
      )),
      fluidRow(textInput("from_date", "Earlist record date", value = 20190625)),
      fluidRow(uiOutput("dyn_input")),
      div(style = "margin-top:-3px"),

      fluidRow(
        checkboxInput("deduplicate",
                      "Remove older versions of the same record?",
                      value = TRUE)
      ),
      div(style = "margin-top:-2px"),
      fluidRow(
        actionButton("advsearchbutton", label = "Start advanced search")
      )
    )

    ),

    # Results tab ----
    # Has three sub-tabs - "Table", "Visualise", and "Reproducible code"
    tabPanel(
      "Results",
      value = "myresults",
      tabsetPanel(
        id = "results-subpanel",

        # Sub-tab with table of first 5 records returned by the search
        # Also allows for download of search hits as CSV
        tabPanel(
          "Overview",
          value = "mytable",
          fluidRow(
            column(
              width = 6,
              br(),
              strong(textOutput("results_no")),
              br(),
              p(snapshot_info),

            ),

            column(
              width = 3,
              offset = 3,
              align = "right",
              br(),
              downloadButton("downloadresults", "Download results", style = "width:65%;"),
            )
          ),
          fluidRow(
            column(
              width = 5,
              br(),
              br(),
              p(
                "A selection of your results are presented below. Use these to ensure your search worked as expected. Download the records matching your search as a CSV file using the button on the right."
              )
            ),

            column(
              width = 2,
              offset = 5,
              align = "left",
              br(),
              selectInput("nres",
                          "Number of results to display:",
                          choices = c("5", "25", "50", "100")
              )
            )),
          hr(),
          tableOutput("results"),
          waiter_hide_on_render("results")
        ),

        # Sub-tab with visualisations of the records returned by the search
        tabPanel(
          "Visualise",
          value = "myplots",
          br(),
          # Display trend plot
          fluidRow(
            column(
              width = 4,
              h3("Publication trends over time"),
              p(
                "The total number of publications in the medRxiv database (black) and the number matching your search (grey) are presented in the graph on the right. Click and drag to zoom in on an area of the plot. Hovering over a point will show you information about that preprint, and clicking on it will open the record in a new tab."
              ),
              br(),
              p(
                "Displaying the trend both for your search and all of medRxiv is important, as it allows you to see whether the increase in the number of papers on your topic is due to increased research interest, or simply due to the overall growth of the database."
              )
            ),
            column(
              width = 8,
              plotlyOutput("trendPlot", inline = TRUE)
            )
          ),
          hr(),

          # Display wordcloud plot
          fluidRow(column(
            12,
            align = "center",
            h3(
              "Most common words in the titles and abstracts of preprints matching your search"
            ),
            wordcloud2Output("wordcloudPlot")
          )),
          hr(),

          # Display histogram of number of papers per category
          fluidRow(column(width = 8,
                          plotlyOutput("histPlot")),
                   column(
                     width = 4,
                     h3("Preprints by category"),
                     p("Each medRxiv record is assigned to one of 51 topic categories. The category with the most preprints matching your search criteria was"),
                     br(),
                     strong(htmlOutput("histtext")),
                     br(),
                     p("Hover over the histogram on the left to explore the number of preprints matching your search that fall under each subject heading.")
                   ))
        ),

        # Sub-tab with reproducible code to run the search
        tabPanel(
          "Reproducible code",
          value = "mycode",
          br(),
          includeMarkdown("text/reproducible_code.md"),
          br(),
          p(strong("Use the code below to run the search from R:")),
          p(em(
            "devtools::install_github(\"mcguinlu/medrxivr\")"
          )),
          p(em("library(medrxivr)")),
          lapply(1:15, function(i) uiOutput(paste0("topic", i))),
          uiOutput("query"),

          br(),
          p(strong("Use the code below to run download the full-text PDFs of the records matching your search:")),
          p(em(
            "mx_download(mx_results, directory = \"pdf/\", create = TRUE)"
          )),
        )
      )
    ),

    # Help tab - reads content from the "help" markdown file
    tabPanel("Help",
             value = "help",
             includeMarkdown("text/help.md")),

    # About tab - reads content from the "about" markdown file
    tabPanel(
      "About",
      value = "about",
      includeMarkdown("text/about.md"),
      img(src = "nihr_logo.jpg", align = "center"),
      br(),
      br()
    )),

    # Add calls to dependencies for waiter and shinyjs
    use_waiter(),
    useShinyjs(),

    # Add JS scripts
    # jscode: simulates button click on "Enter key"
    # prevent_back: warns user when using browser back button
    tags$head(tags$script(HTML(jscode)),
              tags$script(HTML(prevent_back)))
)

###########################################################################
# Server ------------------------------------------------------------------
###########################################################################

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  # Load all preprint hosted in medRxiv
  # Good to do on initialisation as a bit slow
  df_total <- mx_search("*")
  waiter_hide()

# Navigation --------------------------------------------------------------

  # Hide tabs and "Hide help" button on start
  observe({
    hide(selector = "#mytabsetpanel li a[data-value=myresults]")
    hide(selector = "#mytabsetpanel li a[data-value=myplots]")
    hide("hidehelpbtn")
  })

  # On search, show results tab and move to it
  observeEvent(input$basicsearchbutton | input$advsearchbutton, {
    if(input$basicsearchbutton==0 && input$advsearchbutton==0){
      return()
    }
    show(selector = "#mytabsetpanel li a[data-value=myresults]")
    show(selector = "#mytabsetpanel li a[data-value=myplots]")

    # Navigate to nested subpanel
    updateTabsetPanel(session, inputId = 'mytabsetpanel', selected = 'myresults')
    updateTabsetPanel(session, "results-subpanel", selected = "mytable")

  })

  observeEvent(input$gotomore, {
    updateTabsetPanel(session, 'mytabsetpanel', selected = "about")
  })

  observeEvent(input$gotoadv,{
    updateTabsetPanel(session, inputId = 'mytabsetpanel', selected = 'advsearch')
  })

  observeEvent(input$gotohelp,{
    updateTabsetPanel(session, inputId = 'mytabsetpanel', selected = 'help')
  })


# Load example searches ---------------------------------------------------

  observeEvent(input$loadsearch, {
    updateTextInput(session,
                    inputId = "topic1",
                    value = "coronavirus\nCOVID\ncovid\n\\\\bncov\\\\b\n\\\\bNCOV\\\\b")
    updateTextInput(session,
                    inputId = "topic2",
                    value = "test\ndiagnosis\n")
  })

  observeEvent(input$loadbasicsearch, {
    updateTextInput(session,
                    inputId = "basicsearchquery",
                    value = "coronavirus")
  })

# Dynamically render help on advanced search screen -----------------------

  # Render the "to.date" option UI (advanced search tab)
  # Initalises with current date as value
  todays_date <- gsub("-","",Sys.Date())

  output$dyn_input <- renderUI({
    textInput("to_date", "Latest record date", value = todays_date)
  })


# Prevent cross contamination between basic and advanced search -----------

  # Used to prevent the value of the basic search accidentally being included
  # in the advanced search

  # Reset all advanced options to defaults ("") if basic search is performed
  observeEvent(input$basicsearchbutton, {
    btn <- input$addtopic + 3
    lapply(1:btn, function(i)
      updateTextAreaInput(session, paste0("topic", i), value = ""))
    updateTextInput(session, "from_date", value = 20190101)
    updateTextInput(session, "to_date", value = todays_date)
    updateTextInput(session, "NOT", value = "")
    updateCheckboxInput(session, "deduplicate", value = TRUE)
  })

  # Reset basic search to default if advanced search is performed
  observeEvent(input$advsearchbutton, {
    updateTextInput(session, "basicsearchquery", value = "")
  })

  inserted <- c()

  observeEvent(input$addtopic, {
    btn <- input$addtopic + 3
    id <- paste0('topic', btn)
    insertUI(
      selector = '#placeholder',
      ## wrap element in a div with id for ease of removal
      ui = tags$div(
        fluidRow(textAreaInput(paste0('topic', btn), paste('Topic', btn),value = "")),
        id = id
      )
    )
    inserted <<- c(id, inserted)
  })



# Perform search ----------------------------------------------------------

  # Define query, conditional on button click
  # Allows fo complex strategies to be built, without the code re-executing
  # on entry of each term

  query <-
    eventReactive(input$basicsearchbutton | input$advsearchbutton, {
      if (input$basicsearchbutton == 0 && input$advsearchbutton == 0) {
        return()
      }

      # Decide whether to build query from basic or advanced search inputs
      if (input$basicsearchquery != "") {
        input$basicsearchquery
      } else {

        lapply(1:2, function(i)
          unlist(strsplit(input[[paste0('topic', i)]], "\n")))
      }
    })

  # Define terms to exclude, which are passed to the search
  NOT <-
    eventReactive(input$basicsearchbutton | input$advsearchbutton, {
      if (input$basicsearchbutton == 0 && input$advsearchbutton == 0) {
        return()
      }
      if (input$basicsearchquery != "") {
        c("")
      } else {

        if (input$NOT == "") {
          c("")
        } else {
          unlist(strsplit(input$NOT, "\n"))
        }
      }
    })


  # Define results dataset
  mx_data <- reactive({
    mx_search(
      query(),
      to.date = input$to_date,
      from.date = input$from_date,
      NOT = NOT(),
      deduplicate = input$deduplicate
    )
  })


# Results table ----------------------------------------------------

  # Render results table, conditional on button click
  observeEvent(input$basicsearchbutton | input$advsearchbutton, {
    if(input$basicsearchbutton==0 && input$advsearchbutton==0){
      return()
    }

    # Define loading screen
    waiter_show(color = "#333333", html = tagList(
      spin_folding_cube(),
      br(),
      h4("Running search")
    ))

    # Render table
    output$results <- renderTable({
      mx_data <- mx_data()[, c(12, 1, 2, 7, 5, 6)]

      mx_data$date <-
        paste0(
          substring(mx_data$date, 1, 4),
          "-",
          substring(mx_data$date, 5, 6),
          "-",
          substring(mx_data$date, 7, 8)
        )

      mx_data$abstract <- gsub("Â","",mx_data$abstract)
      mx_data$abstract <- gsub("\\\\","",mx_data$abstract)

      # Renames columns for nice presentation
      colnames(mx_data)[1] <- "ID"
      colnames(mx_data)[2] <- "Title"
      colnames(mx_data)[3] <- "Abstract"
      colnames(mx_data)[4] <- "First author"
      colnames(mx_data)[5] <- "Publication date"
      colnames(mx_data)[6] <- "Subject area"

      # Show first X records, to make sure search worked properly

        head(mx_data, as.numeric(input$nres))

    }, striped = TRUE, width = "100%")

    # Show number of results for basic search
    output$results_no <- renderText({
      paste0("Number of results: ", dim(mx_data())[1])
    })
  })

  # Download results as CSV
  output$downloadresults <- downloadHandler(
    filename = function() {
      paste("search_results", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(mx_data(), file, row.names = FALSE)
    }
  )

# Visualisations ----------------------------------------------------------

  # Define loading screens for plots
  w <-
    Waiter$new(
      id = c("trendPlot", "wordcloudPlot", "histPlot"),
      color = "#333333",
      hide_on_render = TRUE,
      html = tagList(spin_folding_cube(),
                     br(),
                     h4("Drawing plots"),)
    )

  # Render trend plot
  output$trendPlot <- renderPlotly({

    w$show()

    # Enable hyperlinking of points to medRxiv record
    onRender(plot_results(df_total,mx_data()), "
    function(el, x) {
                el.on('plotly_click', function(d) {
                var url = d.points[0].customdata;
                //url
                window.open(url);
                });
                }"
    )

  })


  # Render wordcloud
  output$wordcloudPlot <- renderWordcloud2({
    if (input$basicsearchbutton == 0 && input$advsearchbutton == 0) {
      return()
    }

    word_cloud(mx_data())

  })

  # Render histogram
  output$histPlot <- renderPlotly({

    plot_histogram(mx_data())

  })

  common <- reactive({
  common <- mx_data()
  common$subject[is.na(common$subject)] <- "No category recorded"
  common$subject <- gsub("\\n","",common$subject)
  common_table <- as.data.frame(table(common$subject))
  common_table
  })

  output$most_common_count <- renderText({
  })

  output$common_text <- renderText({
    sub <- common()[which(common()$Freq == max(common()$Freq)), 1]
    count <- common()[which(common()$Freq == max(common()$Freq)), 2]

    paste(sub, " with ",count, " preprints")

  })


  output$histtext <- renderUI({
    p(textOutput("common_text"))
    })



# Reproducible code -------------------------------------------------------

  # Render the code used to define each topic for the advanced search
  # This looks awful, but allows the app to deal with varying numbers of topics

  observe({
    btn <-  input$addtopic + 3
    lapply(1:btn, function(i)
      output[[paste0("topic", i)]] <- renderUI({
        req(input[[paste0("topic", i)]])
        if (input[[paste0("topic", i)]] != "") {
          p(em(paste0(
            "topic",
            i,
            " <- c(\"",
            paste0(unlist(strsplit(input[[paste0("topic", i)]], "\n")),
                   collapse = "\", \""),
            "\")"
          )))
        }
      }))
  })


  # Render code used to define entire query

  output$query <- renderUI({
    if (input$basicsearchquery != "") {

      # If basic search is used, query is just this input
      tagList(p(em(paste0("query <- \"", query(), "\""))),
      p(em("mx_results <- mx_search(query)")))

    } else {

      # If advanced search is used, query is more complicated
      # Build query iteratively based on number of topics with input

        btn <-  input$addtopic + 3

        q <- "topic1"

        for (list in 2:btn) {
          if (input[[paste0("topic", list)]] != "") {
            q <- c(q, paste0("topic", list))
          }}


      NOT_char <- paste0(
        "c(\"",
        paste0(unlist(strsplit(input$NOT, "\n")),
               collapse = "\", \""),
        "\")"
      )


     search <- paste0("mx_results <- mx_search(query",
                       ", from.date =", input$from_date,
                       ", to.date =", input$to_date,
                       ", NOT = ", NOT_char,
                       ", deduplicate = ", input$deduplicate,
                       ")")

      # Output full query
     tagList(p(em(paste0(
       "query <- list(", paste0(q, collapse = ", "), ")"
     ))),

     p(em(search)))

      }
  })

}

###########################################################################
# Call to shiny app function ----------------------------------------------
###########################################################################

shinyApp(ui = ui, server = server)
