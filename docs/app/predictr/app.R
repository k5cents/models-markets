library(shiny)
library(tidyverse)
library(wayback)
library(magrittr)

hits <- read_csv("https://kiernann.github.io/predictr/data/hits.csv")

ui <- fluidPage(

    titlePanel("Predicting Elections"),

    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "state",
                        label = "state",
                        choices = sort(unique(hits$state)),
                        selected = "WV"),
            selectInput(inputId = "race",
                        label = "race",
                        choices = sort(unique(hits$race)),
                        selected = "03")
        ),

                mainPanel(
            plotOutput("prop_plot", width = "100%")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(session, input, output) {

    observe({
        y <- hits %>%
            filter(state == input$state) %>%
            pull(race) %>%
            unique() %>%
            sort()
        updateSelectInput(session,
                          inputId = "race",
                          label = "race",
                          choices = y)
    })

    output$prop_plot <- renderPlot({
        hits %>%
            filter(state == input$state) %>%
            filter(race == input$race) %>%
            ggplot(aes(x = date, y = prob)) +
            geom_hline(yintercept = 0.50, lty = 2) +
            geom_line(mapping = aes(color = method), size = 2) +
            scale_y_continuous(labels = scales::percent) +
            scale_x_date() +
            scale_color_manual(values = c("#07A0BB", "#ED713A")) +
            labs(title = "Democratic Probability History",
                 subtitle = paste0("Race: ", input$state, "-", input$race),
                 color = "Method",
                 y = "Probability",
                 x = "Date")
    })
}

# Run the application
shinyApp(ui = ui, server = server)

