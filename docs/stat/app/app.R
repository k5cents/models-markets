library(shiny)
library(tidyverse)

hits <- read_csv("https://kiernann.github.io/predictr/data/hits.csv")

ui <- fluidPage(

    titlePanel("Predicting Elections"),

    # Create a new Row in the UI for selectInputs
    fluidRow(
        column(4, selectInput(inputId = "state",
                              label = "state",
                              choices = sort(unique(hits$state)),
                              selected = "IL")
        ),
        column(4, selectInput(inputId = "race",
                              label = "race",
                              choices = sort(unique(hits$race)),
                              selected = "06")
        )
    ), plotOutput("prop_plot", width = "100%")
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

        sub <- hits %>%
            filter(state == input$state) %>%
            filter(race == input$race)

        winner <- sub %>% pull(winner) %>% unique()

        sub %>%
            ggplot(aes(x = date, y = prob)) +
            geom_hline(yintercept = 0.50, lty = 2) +
            geom_line(mapping = aes(color = method), size = 2) +
            scale_y_continuous(labels = scales::percent) +
            scale_x_date() +
            scale_color_manual(values = c("#07A0BB", "#ED713A")) +
            labs(title = "Democratic Probability History",
                 subtitle = paste0("Race: ", input$state, "-", input$race,
                                   ", Democratic Winner: ", winner),
                 y = "Probability",
                 x = "Date") +
            theme(plot.title = element_text(size = 20),
                  plot.subtitle = element_text(size = 14),
                  legend.text = element_text(size = 14),
                  legend.title = element_blank(),
                  axis.title = element_text(size = 14),
                  axis.text = element_text(size = 12))

    })
}

# Run the application
shinyApp(ui = ui, server = server)

