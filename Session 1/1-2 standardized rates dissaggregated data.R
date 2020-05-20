# Public Health Tools in R
# Calculating standardised rates
# Disaggregated data
# Mirjam Allik
# May 2020


# If you have these packages already istalled you can skip this stage
install.packages("popEpi")

# Load packages
library(popEpi)
library(SocEpi)
library(dplyr)
library(PHEindicatormethods)

# Dissagregated small area data
# We use postcode sector level self-rated health data from 2011 Scottish Census

d <- health_data # package SocEpi needs to be loaded for this
head(d)

?health_data # to look up data dictionary

# Run summaries to get a sense of the data
table(d$age)


# popEpi, uses disaggregated data
# ===============================================================================
# https://cran.r-project.org/web/packages/popEpi/index.html

# define ESP 2013
esp13 <- c(5000, 5500, 5500, 5500, 6000, 6000, 6500, 7000, 7000, 7000, 7000, 6500, 6000, 5500, 5000, 4000, 2500, 2500)
length(esp13)
sum(esp13)

?rate

# Rates for all ethnicities
rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, subset = ethnicity == "all")

# Note, you may get a waring about integer overflow
# This seems to be an R, rather than a package issue
# https://stackoverflow.com/questions/8804779/what-is-integer-overflow-in-r-and-how-can-it-happen#8804991

rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

# by quintile
rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, print = quintile, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

# by quintile and urban rural differences
rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, 
     print = list(quintile, ur2fold), subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)


# For age groups
# ages 0-64
esp13_g <- esp13[1:13] # select standard population for age grups

d %>% filter(age %in% 1:13) %>%
 rate(obs = bad, pyrs = pop, adjust = age, weights = esp13_g, 
      subset = ethnicity == "all") %>%
 mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)


# For multiple age groups simultaneously?



# SocEpi
# ===========================================================================
# https://github.com/m-allik/SocEpi
# Very much work in progress
# May need to provide your own st population, but many built-in options

?st_rate # how to use the function
?st_pop # what st populations are available?

# rates for all ethnicities by ses (quintiles)
# A lot of results at a single go! Can be good, can be bad!
st_rate(data = d, health = bad, population = pop, ses = quintile, age = age, groups = ethnicity == "all") 

# to get less results use filter()
st_rate(d, bad, pop, quintile, age, ethnicity == "all") %>% 
  filter(age == "all")

# or save calculations and then filter
my_rates <- st_rate(data = d, health = bad, population = pop, ses = quintile, age = age, groups = ethnicity == "all") 

# For all ages
my_rates %>% filter(age == "all")

# For different age groups, across SES
my_rates %>% filter(ses == "overall")
  

# For quintiles and urban-rural 
st_rate(d, bad, pop, quintile, age, groups = c(ethnicity == "all" & ur2fold == "Rural")) %>% 
  filter(age == "all")
st_rate(d, bad, pop, quintile, age, groups = c(ethnicity == "all" & ur2fold == "Urban")) %>% 
  filter(age == "all")

# or
d %>% group_by(ur2fold) %>%
  group_modify(~ st_rate(.x, bad, pop, quintile, age, ethnicity == "all")) %>%
  filter(age == "all")


# For different age groups
st_rate(d, bad, pop, quintile, age, age_group = c("15-44"), groups = ethnicity == "all") 

# For multiple different age groups
st_rate(d, bad, pop, quintile, age, age_group = c("15-44", "45-59"), groups = ethnicity == "all") 



# Using packages for aggregate data on individual or small-area data

# PHEindicatormethods
# ===============================================================================
# Need for some aggregation
# May need to supply your own standard population

# aggregation of data follows prior calculation
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>% # group data for aggregations
  summarise_all(sum) %>% # aggregate
  group_by(quintile, ethnicity) %>% # group data for rate calculations
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000) %>%
  filter(ethnicity == "all")


# Note!
# Makes the assumption that your data is ordered by age from youngest to oldest
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  mutate(jumble = sample(1:18, 18)) %>% # re-arrange the data set
  arrange(jumble) %>% # re-arrange the data set
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000) %>%
  filter(ethnicity == "all")


# Results are different

# When might this matter?
my_age_groups <- c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54")
my_age_groups
my_age_groups[order(my_age_groups)]

# So, whenever using PHEindicatormethods make sure your data is ordered by age!


# Example of jumble for SocEpi
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  mutate(jumble = sample(1:182160, 182160)) %>%
  arrange(jumble) %>% # re-arrange the data set
  st_rate(bad, pop, quintile, age, ethnicity == "all") %>% 
  filter(age == "all")

st_rate(d, bad, pop, quintile, age, ethnicity == "all") %>% 
  filter(age == "all") # results without jumble

# Results are the same!

# Example of jumble for popEpi
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  mutate(jumble = sample(1:182160, 182160)) %>%
  arrange(jumble) %>% # re-arrange the data set
  rate(obs = bad, pyrs = pop, adjust = age, weights = esp13, print = quintile, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, print = quintile, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000) # results without jumble

# Results are the same!
