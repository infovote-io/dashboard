rm(list=ls())
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(shinythemes)

# Retrieve RDI data from FRED API
api_key <- "b613f51921dab64aeae0bb2fe2894ea7"
series_id <- "A229RX0"
today <- format(Sys.Date(), "%Y-%m-%d")
url <- paste0("https://api.stlouisfed.org/fred/series/observations?series_id=", series_id, "&api_key=", api_key, "&file_type=json&observation_start=1960-01-01&observation_end=", today, "&frequency=a")

# Make GET request to the API
data <- fromJSON(content(GET(url), "text"))
odata <- read.csv("https://www.dropbox.com/s/r5qsxerj04jgu7y/RDI_40_09.csv?dl=1")

# Dict of Presidents
presidents <- jsonlite::fromJSON('{"1960": "Dwight D. Eisenhower", "1964": "Lyndon B. Johnson - 1st term", "1968": "Lyndon B. Johnson - 2nd term", "1972": "Richard Nixon", "1976": "Gerald Ford", "1980": "Jimmy Carter", "1984": "Ronald Reagan - 1st term", "1988": "Ronald Reagan - 2nd term", "1992": "George H.W. Bush", "1996": "Bill Clinton - 1st term", "2000": "Bill Clinton - 2nd term", "2004": "George W. Bush - 1st term", "2008": "George W. Bush - 2nd term", "2012": "Barack Obama - 1st term", "2016": "Barack Obama - 2nd term", "2020": "Donald Trump", "2024": "Joe Biden"}')
presidents_o <- jsonlite::fromJSON('{"1940": "Franklin D. Roosevelt - 3rd term", "1944": "Franklin D. Roosevelt - 4th term", "1945": "Harry S. Truman - 1st term", "1948": "Harry S. Truman - 2nd term", "1952": "Dwight D. Eisenhower - 1st term", "1956": "Dwight D. Eisenhower - 2nd term", "1960": "John F. Kennedy", "1964": "Lyndon B. Johnson - 1st term", "1968": "Lyndon B. Johnson - 2nd term", "1972": "Richard Nixon", "1976": "Gerald Ford", "1980": "Jimmy Carter", "1984": "Ronald Reagan - 1st term", "1988": "Ronald Reagan - 2nd term", "1992": "George H.W. Bush", "1996": "Bill Clinton - 1st term", "2000": "Bill Clinton - 2nd term", "2004": "George W. Bush - 1st term", "2008": "George W. Bush - 2nd term", "2012": "Barack Obama - 1st term"}')

# Original Data
df_o <- odata %>%
  as.data.frame() %>%
  mutate(date = seq(1940, length.out = nrow(.)),
         value = as.numeric(usvalue),
         usvalue = value,
         value = log(value / lag(value)) * 100) %>%
  filter(date >= 1940) %>%
  select(date, usvalue, value)

# Fred Data
df <- data$observations %>%
  as.data.frame() %>%
  mutate(date = format(as.Date(date), "%Y"),
         value = as.numeric(value),
         usvalue = value,
         value = log(value / lag(value)) * 100) %>%
  filter(date >= "1960") %>%
  select(date, usvalue, value)
write.csv(df, "df_data.csv", row.names = FALSE)

# Save df dataframe as CSV to your desired location
file_path <- "C:/Users/danbo/OneDrive - Fundacao Getulio Vargas - FGV/Info_Vote/R Code/df_data.csv"
# Save df dataframe as CSV at the specified location
write.csv(df, file = file_path, row.names = FALSE)

# Hypothetical data
set.seed(5)
value <- round(rnorm(120, mean = 2, sd = 2), 1)
usvalue <- round(rnorm(120, mean = 44551.62, sd = 100))

df_rand <- data.frame(
  date = format(seq(as.Date("1960-01-01"), by = "year", length.out = length(usvalue)), "%Y"),
  value = value,
  usvalue = ifelse(seq(1960, length.out = length(usvalue)) %% 4 == 0, usvalue, NA)
)

for (i in 1:(nrow(df_rand) - 1)) {
  df_rand$usvalue[i + 1] <- ifelse(is.na(df_rand$usvalue[i + 1]), df_rand$usvalue[i] * (1 + df_rand$value[i + 1] / 100), df_rand$usvalue[i + 1])
}

df_rand$usvalue <- round(df_rand$usvalue, -2)

# Generate years starting from 1964 with increments of 4 years
years <- seq(1964, 2024, by = 4)
years_o <- seq(1944, 2012, by = 4)

# Define UI for Shiny app
ui <- navbarPage(
  title = "RDI Growth",
  theme = shinytheme("flatly"),
  tabPanel(
    "Original Data",
    icon = icon("bars"),
    sidebarLayout(
      sidebarPanel(
        numericInput(
          "yearSelect_o",
          "Select General Election Year",
          value = max(years_o)-4,
          min = min(years_o),
          max = max(years_o),
          step = 4
        ),
        checkboxInput(
          "showPresident_o",
          "Display President's Name",
          value = FALSE
        ),
        checkboxInput(
          "showCumulative_o",
          "Display Cumulative Plot",
          value = FALSE
        ),
        checkboxInput(
          "showIncome_o",
          "Display Personal Income",
          value = FALSE
        )
      ),
      mainPanel(
        plotOutput("yearlyPlot_o"),
        conditionalPanel(
          condition = "input.showCumulative_o == true",
          plotOutput("cumulativePlot_o")
        ),
        conditionalPanel(
          condition = "input.showIncome_o == true",
          plotOutput("incomePlot_o")
        )
      )
    )
  ),
  tabPanel(
    "Fred Data",
    icon = icon("chart-line"),
    sidebarLayout(
      sidebarPanel(
        numericInput(
          "yearSelect",
          "Select General Election Year",
          value = max(years)-4,
          min = min(years),
          max = max(years),
          step = 4
        ),
        checkboxInput(
          "showPresident",
          "Display President's Name",
          value = FALSE
        ),
        checkboxInput(
          "showCumulative",
          "Display Cumulative Plot",
          value = FALSE
        ),
        checkboxInput(
          "showIncome",
          "Display Personal Income",
          value = FALSE
        )
      ),
      mainPanel(
        plotOutput("yearlyPlot"),
        conditionalPanel(
          condition = "input.showCumulative == true",
          plotOutput("cumulativePlot")
        ),
        conditionalPanel(
          condition = "input.showIncome == true",
          plotOutput("incomePlot")
        )
      )
    )
  ),
  tabPanel(
    "Hypothetical Economies",
    icon = icon("chart-line"),
    sidebarLayout(
      sidebarPanel(
        numericInput(
          "yearSelectHypothetical",
          "Select Year",
          value = max(years)-4,
          min = min(years),
          max = max(years),
          step = 4
        ),
        checkboxInput(
          "showCumulativeHypothetical",
          "Display Cumulative Plot",
          value = FALSE
        ),
        checkboxInput(
          "showIncomeHypothetical",
          "Display Personal Income",
          value = FALSE
        )
      ),
      mainPanel(
        plotOutput("yearlyPlotHypothetical"),
        conditionalPanel(
          condition = "input.showCumulativeHypothetical == true",
          plotOutput("cumulativePlotHypothetical")
        ),
        conditionalPanel(
          condition = "input.showIncomeHypothetical == true",
          plotOutput("showIncomeHypothetical")
        )
      )
    )
  )
)

# Define Server Function
server <- function(input, output) {
  # Original Data
  filteredData_o <- reactive({
    df_o %>%
      filter(date >= input$yearSelect_o - 3, date <= input$yearSelect_o) %>%
      select(date, value, usvalue)
  })
  
  output$yearlyPlot_o <- renderPlot({
    start_year_o <- input$yearSelect_o - 3
    end_year_o <- input$yearSelect_o
    president_o <- presidents_o[as.character(end_year_o)]
    president_label_o <- ifelse(input$showPresident_o, paste0(" (", president_o, ")"), "")
    
    ggplot(filteredData_o(), aes(x = date, y = value, group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = round(value, 2), vjust = -0.5), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "% Change in Personal Income", title = paste0("Yearly Personal Income Growth for ", start_year_o, "-", end_year_o, president_label_o)) +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::label_number(accuracy = 0.1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  output$cumulativePlot_o <- renderPlot({
    start_year_o <- input$yearSelect_o - 3
    end_year_o <- input$yearSelect_o
    president_o <- presidents_o[as.character(end_year_o)]
    president_label_o <- ifelse(input$showPresident_o, paste0(" (", president_o, ")"), "")
    
    ggplot(filteredData_o(), aes(x = date, y = cumsum(value), group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = round(cumsum(value), 2), vjust = -0.5), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "% Change in Personal Income",
           title = paste0("Cumulative Personal Income Growth for ", start_year_o, "-", end_year_o, president_label_o),
           subtitle = "Each year adds the growth of all previous years, so the 4th Year shows the total growth from Years 1st-4th") +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::label_number(accuracy = 0.1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            plot.subtitle = element_text(hjust = 0, margin = margin(b = 20), size = 14, vjust = 0),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  output$incomePlot_o <- renderPlot({
    start_year_o <- input$yearSelect_o - 3
    end_year_o <- input$yearSelect_o
    president_o <- presidents_o[as.character(end_year_o)]
    president_label_o <- ifelse(input$showPresident_o, paste0(" (", president_o, ")"), "")
    
    ggplot(filteredData_o(), aes(x = date, y = usvalue, group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = scales::comma(round(usvalue, -2)), vjust = -2), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "Personal Income (in US$)", title = paste0("Yearly Personal Income for ", start_year_o, "-", end_year_o, president_label_o)) +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::comma) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  observeEvent(c(input$showCumulative_o, input$showIncome_o), {
    if (input$showCumulative_o) {
      outputOptions(output, "cumulativePlot_o", suspendWhenHidden = FALSE)
    } else {
      outputOptions(output, "cumulativePlot_o", suspendWhenHidden = TRUE)
    }
    
    if (input$showIncome_o) {
      outputOptions(output, "incomePlot_o", suspendWhenHidden = FALSE)
    } else {
      outputOptions(output, "incomePlot_o", suspendWhenHidden = TRUE)
    }
  })
  
  #Fred Data
  filteredData <- reactive({
    df %>%
      filter(date >= input$yearSelect - 3, date <= input$yearSelect) %>%
      select(date, value, usvalue)
  })
  
  output$yearlyPlot <- renderPlot({
    start_year <- input$yearSelect - 3
    end_year <- input$yearSelect
    president <- presidents[as.character(end_year)]
    president_label <- ifelse(input$showPresident, paste0(" (", president, ")"), "")
    
    ggplot(filteredData(), aes(x = date, y = value, group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = round(value, 2), vjust = -0.5), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "% Change in Personal Income", title = paste0("Yearly Personal Income Growth for ", start_year, "-", end_year, president_label)) +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::label_number(accuracy = 0.1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  output$cumulativePlot <- renderPlot({
    start_year <- input$yearSelect - 3
    end_year <- input$yearSelect
    president <- presidents[as.character(end_year)]
    president_label <- ifelse(input$showPresident, paste0(" (", president, ")"), "")
    
    ggplot(filteredData(), aes(x = date, y = cumsum(value), group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = round(cumsum(value), 2), vjust = -0.5), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "% Change in Personal Income",
           title = paste0("Cumulative Personal Income Growth for ", start_year, "-", end_year, president_label),
           subtitle = "Each year adds the growth of all previous years, so the 4th Year shows the total growth from Years 1st-4th") +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::label_number(accuracy = 0.1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            plot.subtitle = element_text(hjust = 0, margin = margin(b = 20), size = 14, vjust = 0),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  output$incomePlot <- renderPlot({
    start_year <- input$yearSelect - 3
    end_year <- input$yearSelect
    president <- presidents[as.character(end_year)]
    president_label <- ifelse(input$showPresident, paste0(" (", president, ")"), "")
    
    ggplot(filteredData(), aes(x = date, y = usvalue, group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = scales::comma(round(usvalue, -2)), vjust = -2), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "Personal Income (in US$)", title = paste0("Yearly Personal Income for ", start_year, "-", end_year, president_label)) +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::comma) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  observeEvent(c(input$showCumulative, input$showIncome), {
    if (input$showCumulative) {
      outputOptions(output, "cumulativePlot", suspendWhenHidden = FALSE)
    } else {
      outputOptions(output, "cumulativePlot", suspendWhenHidden = TRUE)
    }
    
    if (input$showIncome) {
      outputOptions(output, "incomePlot", suspendWhenHidden = FALSE)
    } else {
      outputOptions(output, "incomePlot", suspendWhenHidden = TRUE)
    }
  })
  
  # Hypothetical  
  filteredDataHypothetical <- reactive({
    yearHypothetical <- input$yearSelectHypothetical
    df_rand[df_rand$date >= yearHypothetical - 3 & df_rand$date <= yearHypothetical, ]
  })
  
  output$yearlyPlotHypothetical <- renderPlot({
    start_yearHypothetical <- input$yearSelectHypothetical - 3
    end_yearHypothetical <- input$yearSelectHypothetical
    
    ggplot(filteredDataHypothetical(), aes(x = date, y = value, group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = round(value, 2), vjust = -0.5), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "% Change in Personal Income", title = paste0("Yearly Personal Income Growth for ", start_yearHypothetical, "-", end_yearHypothetical)) +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::label_number(accuracy = 0.1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  output$cumulativePlotHypothetical <- renderPlot({
    start_yearHypothetical <- input$yearSelectHypothetical - 3
    end_yearHypothetical <- input$yearSelectHypothetical
    
    ggplot(filteredDataHypothetical(), aes(x = date, y = cumsum(value), group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = round(cumsum(value), 2), vjust = -0.5), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "% Change in Personal Income",
           title = paste0("Cumulative Personal Income Growth for ", start_yearHypothetical, "-", end_yearHypothetical),
           subtitle = "Each year adds the growth of all previous years, so Year 4 shows the total growth from Years 1-4") +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::label_number(accuracy = 0.1)) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            plot.subtitle = element_text(hjust = 0, margin = margin(b = 20), size = 14, vjust = 0),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })
  
  output$showIncomeHypothetical <- renderPlot({
    start_yearHypothetical <- input$yearSelectHypothetical - 3
    end_yearHypothetical <- input$yearSelectHypothetical

    ggplot(filteredDataHypothetical(), aes(x = date, y = usvalue, group = 1)) +
      geom_line(color = "steelblue", size = 1.5) +
      geom_point(color = "steelblue", size = 3) +
      geom_text(aes(label = scales::comma(round(usvalue, -2)), vjust = -2), size = 5, nudge_y = 0.5) +
      labs(x = "Year", y = "Personal Income (in US$)", title = paste0("Yearly Personal Income for ", start_yearHypothetical, "-", end_yearHypothetical)) +
      scale_y_continuous(expand = c(0.2, 0.2), labels = scales::comma) +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0, margin = margin(b = 20), size = 20),
            axis.title = element_text(size = 18),
            axis.text = element_text(size = 18))
  })  
  
  observeEvent(input$showCumulativeHypothetical, {
    if (input$showCumulativeHypothetical) {
      outputOptions(output, "cumulativePlotHypothetical", suspendWhenHidden = FALSE)
    } else {
      outputOptions(output, "cumulativePlotHypothetical", suspendWhenHidden = TRUE)
    }
    if (input$showIncomeHypothetical) {
      outputOptions(output, "showIncomeHypothetical", suspendWhenHidden = FALSE)
    } else {
      outputOptions(output, "showIncomeHypothetical", suspendWhenHidden = TRUE)
    }
  })
}

# Run the Shiny app
shinyApp(ui, server)