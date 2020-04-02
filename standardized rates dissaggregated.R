# Public Health Tools in R
# Calculating standardised rates
# Disaggregated data
# Mirjam Allik
# May 2020


# PHEindicatormethods, can be used on aggregated and some level of disaggregated data
# ===============================================================================

# Dissagregated small area data
d <- health_data
head(d)

# Need for some aggregation
# May need to supply your own standard population

# create standard population
stp <- c(5000, 5500, 5500, 5500, 6000, 6000, 6500, 7000, 7000, 7000, 7000, 6500, 6000, 5500, 5000, 4000, 2500, 2500)

d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  phe_dsr(bad, pop, stdpop = stp, stdpoptype = "vector", type = "standard") %>%
  filter(ethnicity == "all")


# makes the implicit (!) assumption that your data is ordered by age from youngest to oldest
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  mutate(jumble = sample(1:18, 18)) %>%
  arrange(jumble) %>%
  phe_dsr(bad, pop, stdpop = stp, stdpoptype = "vector", type = "standard") %>%
  filter(ethnicity == "all")



st_rate(d, bad, pop, quintile, age, ethnicity == "all",
        age_group = NULL, st_pop = "esp2013_18ag", CI = 95, total = 100000) %>% 
  filter(age == "all")

table(d$quintile)
table(d$ethnicity)




# popEpi, uses disaggregated data
# ===============================================================================
