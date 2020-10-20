## Top ###########################################
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# rsconnect::deployApp('./shiny_resource/', forceUpdate = TRUE, appName = 'shiny_resource')
# rsconnect::deployApp('./', forceUpdate = TRUE, appName = 'shiny_resource')
# rsconnect::deployApp('./', forceUpdate = TRUE, appName = 'shiny_resource_test')


library(shiny)
library(shinythemes)


# navbarPage(title=strong("Water Detection in Serengeti National Park"),
navbarPage(title=img(src = "images/logo/Original-transparent_novertborder.png", height=40, alt="Re:source"), 
           tags$style(HTML('.navbar-nav > li > a {line-height:38px}, .navbar-brand {
                   padding-top:15px !important;
                   padding-bottom:4px !important;
                 }
                 .navbar {min-height:55px !important;}')),
           id="nav", 
           selected = 'interactive_map',
           collapsible = TRUE,
           theme = shinytheme("flatly"),

           ## Interactive map ###########################################
           tabPanel(strong("Interactive map"),
                    value="interactive_map",
                    
                    div(class = "outer",
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),
                        
                        shinyjs::useShinyjs(), # https://gist.github.com/PaulC91/2424f2714ca8c2f68024b119c93163de
                        fluidRow(
                          column(width = 12, align = "center",
                                 # br(),
                                 # getwd(),
                                 p()
                          )
                        ),

                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default",
                                      draggable = FALSE, top = "15%", left = "auto", right = 20, bottom = "auto",
                                      width = "auto", height = "auto",
                                      style="border-color: #4db6acff",
                                      p(),
                                      div(id = "inputs",
                                          p(),
                                          div(id = "logo", align = 'center',
                                              img(src = "images/logo/Original-transparent_novertborder.png", width=228, height="auto",
                                                  alt="Re:source")
                                          ),
                                          br(),
                                          # HTML("<center>A tool to identify water</center><br>"),
                                          htmlOutput("api_post"),
                                          # br(),
                                          br(),
                                          
                                          
                                          actionButton("hide_controls", HTML("&nbsp;Hide Controls"), icon = icon("minus-square"),
                                                       style="color: #fff; background-color: #4db6acff; border-color: #4db6acff"),
                                          br(),
                                          # br(),                                          
                                          
                                          
                                          
                                          radioButtons("waypoint",
                                                       # label = HTML('<font color="#ef6c00"><h1>Choose Waypoints to display</h1></font>'),
                                                       label = HTML('<font color="#ef6c00"><h2>Key Water Sources</h2></font>'),
                                                       # choiceNames = serengeti_wpts_deduped$Location_Unique,
                                                       # choiceNames = map(test$choice, HTML),
                                                       choiceNames = serengeti_wpts_deduped$choice,
                                                       choiceValues = serengeti_wpts_deduped$Location_Unique,
                                                       selected = initial_selection
                                          ),
                                          
                                          
                                      ),
                                      # div(id = "inputs2",
                                      #     HTML('<font color="#ef6c00"><h4>&nbsp;Legend: </h4></font>',
                                      #          paste(legend$legend, collapse = '<br>'))
                                      # ),
                                      
                                      
                                      shinyjs::hidden(
                                        actionButton("show_controls", HTML("&nbsp;Show Controls"), icon = icon("plus-square"),
                                                     style="color: #fff; background-color: #4db6acff; border-color: #4db6acff")
                                      ),
                                      # br(),
                                      # div(id = "inputs2",
                                      #     HTML('<font color="#ef6c00"><h4>Legend: </h4></font>', 
                                      #          paste(legend$legend, collapse = '<br>'))
                                      # )
                        ),
                        
                        absolutePanel(id = "legend_panel",
                                      class = "panel panel-default",
                                      fixed = TRUE,
                                      draggable = FALSE, top = "auto", left = 20, right = "auto", bottom = 20,
                                      width = "auto", height = "auto",
                                      style="border-color: #4db6acff",

                                      div(id = "legend",
                                          HTML('<font color="#ef6c00"><h4>&nbsp;Legend: </h4></font>',
                                               paste(legend$legend, collapse = '<br>'))
                                      )
                        ),
                        
                        # absolutePanel(id = "waypoint_prediction",
                        #               class = "panel panel-default",
                        #               fixed = FALSE,
                        #               draggable = TRUE, top = "20%", left = 20, right = "auto", bottom = "auto",
                        #               width = 250, height = "auto",
                        #               style="border-color: #4db6acff",
                        #               
                        #               img(src = "images/logo/Original-transparent.png", width="100%", height="100%",
                        #                   alt="Re:source"),
                        #               # HTML("<center>A tool to identify water</center><br>"),
                        #               htmlOutput("api_post")
                        # ),
                    )
           ),
           
           ## Test Page ###########################################
           tabPanel(strong("About"),
                    
                    div(class = "outer",
                        tags$head(
                          # Include our custom CSS
                          #includeCSS("ty_css1.css"),
                        )
                    ),
                    
                    fluidPage(
                      HTML(readChar("ty_html_test.html",nchars=1e6)),
                      #includeCSS("ty_css1.css"),
                      #includeCSS("ty_css2.scss")
                    )
           ),
           
           
           ## About ###########################################
           
           # tabPanel(strong("About"),
           #          fluidPage(
           #            
           #            # fluidRow(
           #            #   column(width = 12, align = "left",
           #            #          br(),
           #            #          div(id = "logo", align = 'left',
           #            #              img(src = "images/logo/Original-transparent.png", width=228, height="auto",
           #            #                  alt="Re:source")
           #            #          ),
           #            #          
           #            #   ),
           #            # ),
           #            
           #            fluidRow(
           #              column(width = 12, align = "left",
           #                     br(),
           #                     HTML('<a href="https://serengetiwatch.org/water/"><font color="#ef6c00"><h1>"Water is an existential issue for the Serengeti"</h1></font></a>'),
           #                     HTML('<a href="https://serengetiwatch.org/water/"><div style="text-align:right"><font color="#ef6c00"><h3> -- Serengeti Watch</h3></font></div></a>'),
           #                     
           #              ),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 4, align = "center",
           #                     
           #                     h4("Water shortages are caused by"),
           #                     p("↑ Increasing human population diverts water"),
           #                     p("↓ Climate change has reduced annual rainfall"),
           #                     
           #              ),
           #              column(width = 4, align = "center",
           #                     h4("Environmental Impacts:"),
           #                     p("↑ Increasingly alkaline surface water (pH > 10)"),
           #                     p("↑ Increased salinity of surface water (5-17%)"),
           #                     p("↑ Increasing Waterborne Illnesses"),
           #                     
           #              ),
           #              column(width = 4, align = "center",
           #                     h4("Results:"),
           #                     p("↑ Increased illness"),
           #                     p("↓ Reduced herd sizes"),
           #                     p("- Changes in wildlife migratory patterns"),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     
           #              ),
           #            ),
           #            
           #            
           #            fluidRow(
           #              column(width = 12, align = "left",
           #                     br(),
           #                     HTML('<font color="#ef6c00"><h1>Serengeti-Mara Ecosystem</h1></font>'),
           #                     p("Largest & Most Protected Ecosystem on Earth 40,000 Sq Km")
           #              ),
           #            ),
           #            fluidRow(
           #              column(width = 12, align = "center",
           #                     HTML('<img src="https://serengetiwatch.org/wp-content/uploads/2019/08/Mara-River-Basin-1.jpg" alt title="Mara-River-Basin-1" max-width=100% width="auto" height="auto"/>'),
           #                     HTML('<br>Serengeti-Mara Ecosystem | Source: WWF | <a href="https://serengetiwatch.org/water/">Serengeti Watch</a>'),
           #              ),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 2, align = "left"),
           #              column(width = 8,
           #                     br(),
           #                     HTML('<font color="#ef6c00"><h1>Serengeti-Mara Ecosystem</h1></font>'),
           #                     p("Largest & Most Protected Ecosystem on Earth 40,000 Sq Km")
           #              ),
           #              column(width = 2, align = "left"),
           #              
           #            ),
           #            leafletOutput("tiny_map", width='100%', height=525),
           #            
           #            
           #            fluidRow(
           #              column(width = 12, align = "left",
           #                     
           #                     h3('Home to:'),
           #              ),
           #            ),
           #            fluidRow(
           #              column(width = 6, align = "center",
           #                     
           #                     br(),
           #                     br(),
           #                     br(),
           #                     HTML('<font color="#ef6c00"><h2>Serengeti National Park</h2></font>'),
           #                     p("UNESCO World Heritage Site"),
           #                     p("Flagship of Tanzania’s tourism industry"),
           #                     
           #                     
           #              ),
           #              column(width = 6, align = "center",
           #                     
           #                     
           #                     HTML('<a title="Daniel Rosengren / CC BY (https://creativecommons.org/licenses/by/4.0)" href="https://commons.wikimedia.org/wiki/File:Wildebeest_Migration_in_Serengeti_National_Park,_Tanzania.jpg"><img max-width=100% width=100% height="auto" alt="Wildebeest Migration in Serengeti National Park, Tanzania" src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Wildebeest_Migration_in_Serengeti_National_Park%2C_Tanzania.jpg/512px-Wildebeest_Migration_in_Serengeti_National_Park%2C_Tanzania.jpg"></a>'),
           #                     HTML('<br>Wildebeast migration in the Serengeti | <a href="https://commons.wikimedia.org/wiki/File:Masai_Mara_River_aerial.jpg" title="via Wikimedia Commons">ryan harvey from Portland, OR</a> | <a href="https://creativecommons.org/licenses/by-sa/2.0">CC BY-SA</a>'),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     
           #                     
           #              ),
           #            ),
           #            fluidRow(
           #              column(width = 6, align = "center",
           #                     HTML('<a title="ryan harvey from Portland, OR / CC BY-SA (https://creativecommons.org/licenses/by-sa/2.0)" href="https://commons.wikimedia.org/wiki/File:Masai_Mara_River_aerial.jpg"><img  max-width=100% width=100% height="auto" alt="Masai Mara River aerial" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Masai_Mara_River_aerial.jpg/512px-Masai_Mara_River_aerial.jpg"></a>'),
           #                     HTML('<br>Masai Mara River | <a href="https://commons.wikimedia.org/wiki/File:Masai_Mara_River_aerial.jpg" title="via Wikimedia Commons">ryan harvey from Portland, OR</a> | <a href="https://creativecommons.org/licenses/by-sa/2.0">CC BY-SA</a>'),
           #                     
           #                     br(),
           #                     br(),
           #                     br(),
           #              ),
           #              column(width = 6, align = "center",
           #                     br(),
           #                     br(),
           #                     br(),
           #                     HTML('<font color="#ef6c00"><h2>Maasai Mara National Reserve</h2></font>'),
           #                     p("Home to the Maasai People"),
           #                     p("World-renowned for diverse population"),
           #                     p("290,000 Tourists per year"),
           #                     
           #              ),
           #            ),
           #            
           #            
           #            
           #            
           #            fluidRow(
           #              column(width = 12, align = "left",
           #                     HTML('<font color="#ef6c00"><h1>Threat to Inhabitants, Wildlife & Tourism</h1></font>'),
           #                     
           #                     br(),
           #                     br(),
           #              ),
           #            ),
           #            
           #            
           #            fluidRow(
           #              column(width = 8, align = "center",
           #                     HTML('<a title="Olais Wilson Lucumay / CC BY-SA (https://creativecommons.org/licenses/by-sa/4.0)" href="https://commons.wikimedia.org/wiki/File:Mama_Yeyoo_(maasai_Women)_02.jpg"><img width="512" alt="Mama Yeyoo (maasai Women) 02" src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Mama_Yeyoo_%28maasai_Women%29_02.jpg/512px-Mama_Yeyoo_%28maasai_Women%29_02.jpg"></a>'),
           #                     # HTML('<br>Mama Yeyoo (maasai Women) 02 | <a href="https://commons.wikimedia.org/wiki/File:Mama_Yeyoo_(maasai_Women)_02.jpg" title="via Wikimedia Commons">Olais Wilson Lucumay</a> | <a href="https://creativecommons.org/licenses/by-sa/4.0">CC BY-SA</a>'),
           #                     # HTML('<br>Maasai Women matching to the cultural heritage center in Arusha Tanzania | <a href="https://commons.wikimedia.org/wiki/File:Mama_Yeyoo_(maasai_Women)_02.jpg" title="via Wikimedia Commons">Olais Wilson Lucumay</a> | <a href="https://creativecommons.org/licenses/by-sa/4.0">CC BY-SA</a>'),
           #                     HTML('<br>Maasai Women matching to the cultural heritage center in Arusha Tanzania'),
           #                     HTML('<br><a href="https://commons.wikimedia.org/wiki/File:Mama_Yeyoo_(maasai_Women)_02.jpg" title="via Wikimedia Commons">Olais Wilson Lucumay</a> | <a href="https://creativecommons.org/licenses/by-sa/4.0">CC BY-SA</a>'),
           #              ),
           #              column(width = 4),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 8, align = "left",
           #                     h3("Human Population"),
           #              ),
           #              column(width = 4),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 8, align = "center",
           #                     HTML('<font color="#ef6c00"><h2>400% increase in the previous 40 years</h2></font>'),
           #              ),
           #              column(width = 4),
           #            ),
           #            fluidRow(
           #              column(width = 8, align = "right",
           #                     HTML(' - Source: <a href="https://phys.org/news/2019-03-serengeti-mara-squeezeone-world-iconic-ecosystems.html">University of York</a>'),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     br(),
           #              ),
           #              column(width = 4),
           #            ),
           #            
           #            
           #            fluidRow(
           #              column(width = 2),
           #              column(width = 8, align = "center",
           #                     
           #                     HTML('<a title="Leo Li from Hong Kong / CC BY (https://creativecommons.org/licenses/by/2.0)" href="https://commons.wikimedia.org/wiki/File:%22Calm%22_@_Masai_Mara_(21373245543).jpg"><img width="512" alt="&quot;Calm&quot; @ Masai Mara (21373245543)" src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/%22Calm%22_%40_Masai_Mara_%2821373245543%29.jpg/512px-%22Calm%22_%40_Masai_Mara_%2821373245543%29.jpg"></a>'),                               
           #                     HTML('<br>&quot;Calm&quot; @ Masai Mara | <a href="https://commons.wikimedia.org/wiki/File:%22Calm%22_@_Masai_Mara_(21373245543).jpg" title="via Wikimedia Commons">Leo Li from Hong Kong</a> | <a href="https://creativecommons.org/licenses/by/2.0">CC BY</a>'),
           #              ),
           #              column(width = 2),
           #            ),
           #            
           #            
           #            fluidRow(
           #              column(width = 2),
           #              column(width = 8, align = "left",
           #                     h3("Large Animal Population"),
           #              ),
           #              column(width = 2),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 2),
           #              column(width = 8, align = "center",
           #                     HTML('<font color="#ef6c00"><h2>75% decrease in the last 40 years</h2></font>'),
           #              ),
           #              column(width = 2),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 2),
           #              column(width = 8, align = "right",
           #                     HTML(' - Source: <a href="https://phys.org/news/2019-03-serengeti-mara-squeezeone-world-iconic-ecosystems.html">University of York</a>'),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     br(),
           #              ),
           #              column(width = 2),
           #            ),
           #            
           #            
           #            fluidRow(
           #              column(width = 4),
           #              column(width = 8, align = "center",
           #                     
           #                     HTML("<iframe src='https://tradingeconomics.com/embed/?s=tza.st.int.arvl%3aworldbank&lbl=0&h=300&w=600&ref=/tanzania/international-tourism-number-of-arrivals-wb-data.html' height='300' width='600'  frameborder='0' scrolling='no'></iframe><br />source: <a href='https://tradingeconomics.com/tanzania/international-tourism-number-of-arrivals-wb-data.html'>tradingeconomics.com</a>"),
           #              ),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 4),
           #              column(width = 8, align = "left",
           #                     h3("Tourism contributed"),
           #              ),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 4),
           #              column(width = 8, align = "center",
           #                     HTML('<font color="#ef6c00"><h2>$2.43 billion to the Tanzania GDP in 2018</h2></font>'),
           #              ),
           #            ),
           #            
           #            fluidRow(
           #              column(width = 4),
           #              column(width = 8, align = "right",
           #                     HTML(' - Source: <a href="https://www.busiweek.com/tanzania-earns-us2-43-billion-from-tourism-in-2018/">Business Week</a>'),
           #                     br(),
           #                     br(),
           #                     br(),
           #                     br(),                        
           #              ),
           #            ),
           #            
           #            
           #            
           #            
           #            
           #            fluidRow(
           #              column(width = 12, align = "left",
           #                     HTML('<font color="#ef6c00"><h1>The Current Solution</h1></font>'),
           #                     # br(),
           #                     # br(),
           #                     # br(),
           #                     # br(),
           #                     # br(),
           #              ),
           #            ),
           #            #                       
           #            fluidRow(
           #              column(width = 6,
           #                     br(),
           #                     h4(
           #                       
           #                       tags$ul(
           #                         HTML('<li>Individual <strong>environmentalists</strong> running water trucks to refill watering holes</li>'),
           #                         br(),
           #                         HTML('<li><strong>Researchers</strong> bring visibility to the impact drought is having on Mara/Serengeti Ecosystem</li>'),
           #                         br(),
           #                         HTML('<li><strong>Park Rangers</strong> bore wells to provide wildlife access to underground water sources</li>'),
           #                         br(),
           #                         HTML('<li><strong>All</strong> are lacking real-time information that is accessible and easy to understand.</li>'),
           #                       )
           #                     )
           #              ),
           #              column(width = 6, align = "center",
           #                     HTML('<a href="https://www.thedodo.com/water-man-kenya-animals-2263728686.html#"><img alt="water-man-kenya-animals-2263728686" src="https://assets3.thrillist.com/v1/image/2541961/size/tmg-article_tall.jpg" width="438"></a>'),
           #                     HTML('<br>Patrick Kilonzo Mwalua | <a href="https://www.thedodo.com/water-man-kenya-animals-2263728686.html">the dodo</a>'),
           #                     h4('“There is completely no water, so the animals are depending on humans.  If we don’t help them, they will die.”'),
           #                     HTML('<div align="right">Patrick Kilonzo Mwalua - The Water Man</div>'),
           #              )
           #            ),
           #            
           #            fluidRow(
           #              column(width = 12, align = "center",
           #                     br(),
           #                     br(),
           #                     br(),
           #                     
           #                     HTML('<font color="#ef6c00"><h1>Our Solution - Re:Source</h1></font>'),
           #                     br(),                    
           #                     br(),
           #                     
           #              )
           #            ))
           #          
           #          
           # ),
           
           
           ## Our Approach ###########################################
           
           tabPanel(strong("Our Approach"),
                    
                    br(),
                    
                    # div(id = "logo", align = 'left',
                    #     img(src = "images/logo/Original-transparent.png", width=228, height="auto",
                    #         alt="Re:source")
                    # ),
                             
                    HTML('<font color="#ef6c00"><h1>Our Approach</h1></font>'),
                    
                    includeMarkdown('approach.md')
                    
                    # # HTML('<font color="#ef6c00"><h3>Infrastructure:</h3></font>'),
                    # h3('Infrastructure'),
                    # p("We leverage AWS suite of tools for the development of this project. Primarily, we rely heavily on GPU-enabled EC2 instances as well as S3 storage buckets. The former served as our main VM for developing models, hosting services, and running automated scripts. The latter is where we stored and retrieved our data for development."),
                    # 
                    # # HTML('<font color="#ef6c00"><h3>API Framework:</h3></font>'),
                    # h3('API Framework'),
                    # p("We use a RESTful framework to access model predictions. Particularly, a Python-Flask service was built around the final model which was then containerized and hosted in a docker container on an EC2 instance."),
                    # 
                    # # HTML('<font color="#ef6c00"><h3>Web Application:</h3></font>'),
                    # h3('Web Application'),
                    # p("The user interface (UI) was built using an RShiny framework which uses Shinyjs, an R-based javascript wrapper around javascript, to call and present the data in a dynamic and easy to use manner. The UI was also hosted via a docker container on an EC2 instance, which was assigned a fixed DNS hostname using AWS Route53 to allow for ease of access. "),
                    # 
                    # # HTML('<font color="#ef6c00"><h3>Dataset:</h3></font>'),
                    # h3('Dataset'),
                    # p("All datasets were sourced from either Planet or Kaggle. The former required the development of an automated API call script which we deployed on an EC2 instance and set a cron job to run daily. We also bulk pulled satellite images and manually annotated them using the Figure 8 platform. "),
                    # 
                    # # HTML('<font color="#ef6c00"><h3>Modeling:</h3></font>'),
                    # h3('Modeling'),
                    # p("We developed our models using PyTorch for the training and the Weights and Biases plugin to track our progress. In terms of models, we leveraged Mixnet, a novel algorithm published by google in Dec 2019. The advantages of Mixnet over prior algorithms is that it can deliver comparative performance with fewer parameters. One of its main features that allows it to do this is that it uses variable kernel sizes which allow the capture of both macroscopic and microscopic details. "),
                    
                    # h1('--------------------------------------'),
                    # 
                    # br(),
                    # 
                    # HTML('<font color="#ef6c00"><h1>Our Technical Approach</h1></font>'),
                    # 
                    # HTML('<font color="#ef6c00"><h3>Infrastructure:</h3></font>'),
                    # # h3('Infrastructure'),
                    # p("We leverage AWS suite of tools for the development of this project. Primarily, we rely heavily on GPU-enabled EC2 instances as well as S3 storage buckets. The former served as our main VM for developing models, hosting services, and running automated scripts. The latter is where we stored and retrieved our data for development."),
                    # 
                    # HTML('<font color="#ef6c00"><h3>API Framework:</h3></font>'),
                    # # h3('API Framework'),
                    # p("We use a RESTful framework to access model predictions. Particularly, a Python-Flask service was built around the final model which was then containerized and hosted in a docker container on an EC2 instance."),
                    # 
                    # HTML('<font color="#ef6c00"><h3>Web Application:</h3></font>'),
                    # # h3('Web Application'),
                    # p("The user interface (UI) was built using an RShiny framework which uses Shinyjs, an R-based javascript wrapper around javascript, to call and present the data in a dynamic and easy to use manner. The UI was also hosted via a docker container on an EC2 instance, which was assigned a fixed DNS hostname using AWS Route53 to allow for ease of access. "),
                    # 
                    # HTML('<font color="#ef6c00"><h3>Dataset:</h3></font>'),
                    # # h3('Dataset'),
                    # p("All datasets were sourced from either Planet or Kaggle. The former required the development of an automated API call script which we deployed on an EC2 instance and set a cron job to run daily. We also bulk pulled satellite images and manually annotated them using the Figure 8 platform. "),
                    # 
                    # HTML('<font color="#ef6c00"><h3>Modeling:</h3></font>'),
                    # # h3('Modeling'),
                    # p("We developed our models using PyTorch for the training and the Weights and Biases plugin to track our progress. In terms of models, we leveraged Mixnet, a novel algorithm published by google in Dec 2019. The advantages of Mixnet over prior algorithms is that it can deliver comparative performance with fewer parameters. One of its main features that allows it to do this is that it uses variable kernel sizes which allow the capture of both macroscopic and microscopic details. "),
                    
           ),
           
           
           
           ## Team ###########################################
           
           tabPanel(strong("Team"),
                    fluidPage(
                      
                      fluidRow(
                        column(width = 12, align = "center",
                               HTML('<font color="#ef6c00"><h1>Our Team</h1></font>'),
                               p("We are a team of graduate students at the UC Berkeley School of Information. For our capstone project in the Master of Information and Data Science (MIDS) program, we developed this tool to identify water availability at targeted locations based on satellite imagery. And we had a lot of fun doing it."),
                               br()
                        ),
                        
                        fluidRow(
                          column(width = 6, align = "center",
                                 HTML('<img class="img-circle" src="images/pierce_headshot.jpeg" width="225" height="225"/>'),
                                 h1('Pierce Coggins'),
                                 h4("Data Scientist @ Appen"),
                                 h4("San Francisco, CA"),
                                 HTML('<h4><a href="https://www.linkedin.com/in/pierce-coggins/">LinkedIn</a> | <a href="https://www.github.com/PierceCoggins">Github</a></h4>'),
                                 br(),
                                 p()
                          ),
                          
                          column(width = 6, align = "center",
                                 HTML('<img class="img-circle" src="images/jason_headshot.jpeg" width="225" height="225"/>'),
                                 h1('Jason Baker'),
                                 h4("Analytic Methodologist"),
                                 h4("St. Louis, MO"),
                                 HTML('<h4><a href="https://www.linkedin.com/in/jason-baker-8b640b3/">LinkedIn</a> | <a href="https://www.github.com/bakerjas">Github</a></h4>'),
                                 br(),
                                 p()
                          )
                        ),
                        
                        fluidRow(
                          column(width = 6, align = "center",
                                 HTML('<img class="img-circle" src="images/conor_headshot.jpeg" width="225" height="225"/>'),
                                 h1('Conor Healy'),
                                 h4("Data Science Consultant"),
                                 h4("San Ramon, CA"),
                                 HTML('<h4><a href="https://www.linkedin.com/in/chealy/">LinkedIn</a> | <a href="https://www.github.com/revgizmo">Github</a></h4>')
                          ),
                          
                          column(width = 6, align = "center",
                                 HTML('<img class="img-circle" src="images/tennison_headshot.jpeg" width="225" height="225"/>'),
                                 h1('Tennison Yu'),
                                 h4("Data Scientist"),
                                 h4("San Francisco, CA"),
                                 HTML('<h4><a href="https://www.linkedin.com/in/tennisonyu/">LinkedIn</a> | <a href="https://www.github.com/tyu0912">Github</a></h4>')
                          )
                        )
                      )
                    ),
                    fluidRow(
                      column(width = 12,
                             HTML('<center><font color="#ef6c00"><h1>Huge Thanks</h1></font></center>'),
                             tags$ol(
                               tags$li("Our fellow students who made this an incredible learning experience, and the instructors who brought us along.  Especially the Capstone course instructors David Stier and Joyce Chen."), 
                               tags$li("Yuri Shendryka, Yannik Rista, Catherine Ticehurstb, and Peter Thorburna, the authors of the paper and dataset we used to guide many of our developments.  More info on their work and the data can be found at: ",
                                       tags$ul(
                                         tags$li('Paper: Shendryk, Y., Rist, Y., Ticehurst, C., & Thorburn, P. (2019). Deep learning for multi-modal classification of cloud, shadow and land cover scenes in PlanetScope and Sentinel-2 imagery. ISPRS Journal of Photogrammetry and Remote Sensing, 157, 124–136. ', 
                                                 tags$a(href="https://doi.org/10.1016/J.ISPRSJPRS.2019.08.018", 
                                                        "doi.org/10.1016/J.ISPRSJPRS.2019.08.018")
                                         ),
                                         tags$li("Dataset: Shendryk, Iurii (2019), “Data for: Application of deep learning models to provide a generalizable approach for cloud, shadow and land cover classification in PlanetScope and Sentinel-2 imagery”, Mendeley Data, v1", 
                                                 tags$a(href="http://dx.doi.org/10.17632/6gdybpjnwh.1", "dx.doi.org/10.17632/6gdybpjnwh.1"), 
                                                 "which was released under a ", tags$a(href="https://creativecommons.org/licenses/by/4.0/", "Creative Commons license")
                                         )
                                       )
                               ),
                               tags$li("The amazing folks who build free and open-source software and tools like R, Python, Pandas, Pytorch, Shiny, and dozens of others."),
                               tags$li("Amazon and Planet Labs for their generous student credits"),
                               tags$li("And most importantly, the friends and family who supported us through this 27 units of amazing learning!")
                             ),
                             br()
                      )
                      
                    )
           )
           
)


# ## -/-/-Commented Code \-\- ###########################################
# ## About ###########################################
# 
# tabPanel(strong("About"),
#          
#          br(),
#          HTML('<font color="#ef6c00"><h3>What is Re:source?</h3></font>'),
#          p("Re:source provides near-daily water availability in ponds, lakes, streams and rivers within Serengeti National Park, enabling park rangers, land managers, and researchers to re-allocate resources necessary to identify and respond to potential drought conditions."),
#          
#          HTML('<font color="#ef6c00"><h3>Mission</h3></font>'),
#          HTML('<font color="red"><strong>Including would be the impact and potential level of impact that your project can deliver now and in the future if you continued?</strong></font>'),
#          
#          HTML('<font color="#ef6c00"><h3>"Water is an existential issue for the Serengeti"</h3></font>'),
#          HTML('<div style="text-align:right"><font color="#ef6c00"><h3>-- Serengeti Watch</h3></font></div>'),
#          tags$ol(
#            tags$li(tags$strong("Causes of water shortages:")),
#            tags$ol(
#              tags$li("Increasing human population diverts water"),
#              tags$li("Climate change has reduced annual rainfall")
#            ),
#            
#            tags$li(tags$strong("Water shortages cause:")),
#            tags$ol(
#              tags$li("Increasingly alkaline surface water (pH > 10)"),
#              tags$li("Increased salinity of surface water (5-17%)"),
#              tags$li("Stagnant or brackish water (eutrophication)")
#            ),
#            
#            tags$li(tags$strong("Result of water shortages:")),
#            tags$ol(
#              tags$li("Changes in wildlife migratory patterns"),
#              tags$li("Increased likelihood of illness and reduction in herd sizes")
#            )
#          ),
#          
#          HTML('<font color="#ef6c00"><h3>Problem Overview</h3></font>'),
#          tags$ol(
#            tags$li(tags$strong("Users:")),
#            tags$ol(
#              tags$li("Serengeti National Park Rangers"),
#              tags$li("Serengeti Ecosystem Researchers")
#            ),
#            
#            tags$li(tags$strong("Problem Importance:")),
#            tags$ol(
#              tags$li("Drought is posing significant threat to wildlife and tourism economy")
#            ),
#            
#            tags$li(tags$strong("Impact:")),
#            tags$ol(
#              tags$li("Help Serengeti National Park rangers, Researchers and governmental organizations preserve the Serengeti ecosystem.")
#            ),
#            
#            tags$li(tags$strong("Market Opportunity:")),
#            tags$ol(
#              tags$li("Tanzania tourism increases 2x from 2000 - 2010"),
#              tags$li("Tourism contributes ~$1.5 billion USD to Kenya/Tanzania GDP")
#            )
#          ),
#          
#          
#          HTML('<font color="#ef6c00"><h3>Impact</h3></font>'),
#          p("Our Impact goes here"), 
#          
#          HTML('<font color="#ef6c00"><h3>Differentiation</h3></font>'),
#          p("Discussion of our differentiation goes here,"),
#          br(),
#          br(),
#          br()
#          
#          # )
# ),


# ## Our Approach: Remote Sensing ###########################################
# 
# tabPanel(strong("Our Approach: Remote Sensing"),
#          
#          br(),
#          h1("This is the PlanetScope Satellite Imagery page."),
#          p("A short white paper on our process for pulling PlanetScope images, with examples and link to code.")
#          # )
# ),


# ## What is Re:Source? ###########################################
# 
# tabPanel(strong("What is Re:Source?"),
#          
#          br(),
#          h1("This is the Model page."),
#          p("Format in terms of a walkthrought like this: [fancy link](https://towardsdatascience.com/land-use-and-deforestation-in-the-brazilian-amazon-5467e88933b)"),                
#          p("notebooks folder: pytorch_transfer_learning-Serengeti-Final")
#          # )
# ),

# ## The Future ###########################################
# 
# tabPanel(strong("The Future"),
#          
#          br(),
#          h1("This is the Support page."),
#          
#          h3("How to Help"),
#          p("How to Help go here")
#          
# ),
# ## Evaluation ###########################################
# 
# tabPanel(strong("Evaluation"),
#          
#          br(),
#          h1("This is the Support page."),
#          
#          h3("How to Help"),
#          p("How to Help go here")
#          
# ),
# 
# 
# 

