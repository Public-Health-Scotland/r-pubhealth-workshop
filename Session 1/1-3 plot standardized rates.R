# Public Health Tools in R
# Plotting standardised rates
# Disaggregated data
# Mirjam Allik
# May 2020


library(ggplot2)
library(gridExtra)
require(dplyr)
require(SocEpi)

# Read data, if not yet read into R
# package SocEpi needs to be loaded for this
d <- health_data 
head(d)


# rates for White Irish ethnicities by ses (quintiles)
irish_rate <- st_rate(data = d, health = bad, population = pop, ses = quintile, age = age, groups = ethnicity == "Irish") 

head(irish_rate)

p1 <- irish_rate %>% 
  filter(age == "0-64") %>% # select age group
  filter(ses %in% 1:5) %>% # select SES values
  mutate(ses = as.numeric(ses)) %>%
  ggplot(aes(x = ses, y = rate)) +
  geom_line() +
  geom_ribbon(aes(ymin = CI_low, ymax = CI_high), alpha = 0.3) +
  ggtitle("Poor self-rated health \nWhite Irish 0-64") + xlab("Deprivation quintile") + ylab("Rate per 1000") +
  ylim(0, 80)

x11() # open plotting window
p1 # draw plot

p2 <- irish_rate %>% 
  filter(age == "15-29") %>%
  filter(ses %in% 1:5) %>%
  mutate(ses = as.numeric(ses)) %>%
  ggplot(aes(x = ses, y = rate)) +
  geom_line() +
  geom_ribbon(aes(ymin = CI_low, ymax = CI_high), alpha = 0.3) +
  ggtitle("Poor self-rated health \nWhite Irish 15-29") + xlab("Deprivation quintile") + ylab("Rate per 1000") +
  ylim(0, 80)

x11()
grid.arrange(p1, p2, nrow = 1)
