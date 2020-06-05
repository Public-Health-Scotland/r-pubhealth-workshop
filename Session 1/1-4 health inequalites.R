# Public Health Tools in R
# Calculating SII/RII
# Mirjam Allik
# May 2020


# Packages
library(ggplot2)
require(dplyr)
require(tidyr)
require(SocEpi)
require(PHEindicatormethods)

# if data not loaded
# d <- health_data

# SocEpi
# ===========================================================================
# https://github.com/m-allik/SocEpi
# Very much work in progress

?rii # how to use the function

# RII using quintiles for "all"
rii(data = d, health = bad, population = pop, ses = quintile, 
    age = age, groups = ethnicity == "all", W = T)

# SII using quintiles for "all"
rii(data = d, health = bad, population = pop, ses = quintile, 
    age = age, groups = ethnicity == "all", RII = F, W = T) 


# RII for all ethnic groups simultaneously
my_RII <- d %>% group_by(ethnicity) %>%
  group_modify(~ rii(.x, bad, pop, quintile, age, W = T))

head(my_RII)

my_RII %>% filter(age == "all")



# PHEindicatormethods
# ===============================================================================
# Need for some aggregation
# May need to supply your own standard population

# define ESP 2013
esp13 <- c(5000, 5500, 5500, 5500, 6000, 6000, 6500, 7000, 7000, 
           7000, 7000, 6500, 6000, 5500, 5000, 4000, 2500, 2500)


# First, aggregate data and then calculate rates
q_rates <- d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>% # groupings for aggregation
  summarise_all(sum) %>% # aggregation
  group_by(quintile, ethnicity) %>%
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000) # rate calculation

head(q_rates)


# RII & SII for "all"
phe_rii <- q_rates %>% group_by(ethnicity) %>%
  phe_sii(quintile, total_pop, value, lower_cl = lowercl, upper_cl = uppercl, rii = T) # SII/RII calculation

phe_rii

# SII only 
q_rates %>% group_by(ethnicity) %>%
  phe_sii(quintile, total_pop, value, lower_cl = lowercl, upper_cl = uppercl) 



# Compare RII values
# ====================================================================
my_RII_all <- my_RII %>% filter(age == "all") # select all age groups 
rii_data <- merge(my_RII_all, phe_rii, by = "ethnicity") # merge SocEpi RII with PHE RII

rii_data

# Comparison of RII values
plot(rii_data$rii.x, rii_data$rii.y, xlab = "SocEpi RII", ylab = "PHE RII", 
     xlim = c(0.75, 1.8), ylim = c(1.5, 6), bty = "n", col = "red")
text(rii_data$rii.x, rii_data$rii.y, rii_data$ethnicity, pos = 4, cex = 0.7)


# With error bars
ggplot(rii_data, aes(x = rii.x, y  = rii.y)) +
  geom_point(shape = 1) + xlab("SocEpi RII") + ylab("PHE RII") +   
  geom_errorbarh(aes(xmin = ci_low,
                     xmax = ci_high)) +
  geom_errorbar(aes(ymin = rii_lower95_0cl,
                    ymax = rii_upper95_0cl))


# With error bars for the biggest 6 ethnic groups
rii_data %>% filter(!(ethnicity %in% c("afr", "other", "mix", "caribb"))) %>%
  ggplot(aes(x = rii.x, y  = rii.y)) + xlab("SocEpi RII") + ylab("PHE RII") +
    geom_point(shape = 1) +    
    geom_errorbarh(aes(xmin = ci_low, xmax = ci_high)) +
    geom_errorbar(aes(ymin = rii_lower95_0cl,
                    ymax = rii_upper95_0cl)) +
    geom_text(aes(label = ethnicity))