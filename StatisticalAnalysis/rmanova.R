setwd("~/CrossSubjectAmputee/rebuttalScripts")

library('readxl')
library(tidyverse)
library(ggpubr)
library(rstatix)
my_data <- read_excel("Accuracies_for_RMANOVA.xlsx")



data_long <- my_data %>%
  gather(key = "repetition", value = "accuracy", S1:A5) %>%
  convert_as_factor(id,repetition)


data_long$Population <- as.factor(ifelse(substring(data_long$repetition,1,1) == "S",0,1))
# summary statistics
data_long %>% group_by(Pipeline,Population) %>% get_summary_stats(accuracy, type="mean_sd")

bxp <- ggboxplot(
  data_long, x = "Pipeline", y = "accuracy",
  color = "Population", palette = "jco"
)
bxp


# assumptions
data_long %>%
  group_by(Pipeline,Population) %>%
  shapiro_test(accuracy)


ggqqplot(data_long, "accuracy", ggtheme = theme_bw()) +
  facet_grid(Pipeline ~ Population, labeller = "label_both")




#### ALL PIPELINES TWO WAY RMANOVA
    data_long$rep_id= substring(data_long$repetition, 2, 4)
    # ANOVA test
    res.aov <- anova_test(
      data = data_long, dv = accuracy, wid = rep_id,
      within = c(Pipeline, Population)
    )
    get_anova_table(res.aov)
    write_xlsx(res.aov, "allpipelines_2way_RMANOVA.xslx")
    
    
    #### ONE WAY RMANOVA -- Pipeline
    # ANOVA test
    one.way <- data_long %>%
      group_by(Population) %>%
      anova_test(dv = accuracy, wid = rep_id,
      within = Pipeline
    )
    one.way
    write_xlsx(one.way, "allpipelines_1way_RMANOVA_pipeline.xslx")
    
    pwc <- data_long %>%
      group_by(Population) %>%
      pairwise_t_test(
        accuracy ~ Pipeline, paired = TRUE,
        p.adjust.method = "bonferroni"
      )
    pwc
    
    library(writexl)
    write_xlsx(pwc,"allpipelines_1way_posthoc_pipeline.xlsx")
    
    #### ONE WAY RMANOVA -- Population
    # ANOVA test
    one.way <- data_long %>%
      group_by(Pipeline) %>%
      anova_test(dv=accuracy, wid=rep_id,
                 within=Population) %>%
      get_anova_table() %>%
      adjust_pvalue(method="bonferroni")
    one.way
    write_xlsx(one.way,"allpipelines_1way_RMANOVA_population.xlsx")
    
    pwc2 <- data_long %>%
      group_by(Pipeline) %>%
      pairwise_t_test(
        accuracy ~ Population, paired=FALSE,
        p.adjust.method = "bonferroni"
      )
    pwc2
    write_xlsx(pwc2,"allpipelines_1way_posthoc_population.xlsx")

    
#### ONLY WITHIN SUBJECT -- 2 way RMANOVA
    within_data <-
      data_long %>%
      filter(substr(Pipeline, nchar(Pipeline), nchar(Pipeline)) == 1)
    
    
    # ANOVA test
    res.aov <- anova_test(
      data = within_data, dv = accuracy, wid = rep_id,
      within = c(Pipeline, Population)
    )
    get_anova_table(res.aov)
    write_xlsx(res.aov, "within_2way_RMANOVA.xslx")
    
    ## Not significant different interaction
    
    pwc <- within_data %>%
      pairwise_t_test(
        accuracy ~ Pipeline, paired = TRUE, 
        p.adjust.method = "bonferroni"
      )
    pwc
    write_xlsx(pwc, "within_1way_posthoc_pipeline.xslx")
    
    
    
    pwc <- within_data %>%
      pairwise_t_test(
        accuracy ~ Population, paired = FALSE, 
        p.adjust.method = "bonferroni"
      )
    pwc
    write_xlsx(pwc2,"within_1way_posthoc_population.xlsx")
    
    
    
    
    
    
#### ONLY SINGLE REPETITION -- 2 way RMANOVA
    sr_data <-
      data_long %>%
      filter(substr(Pipeline, nchar(Pipeline), nchar(Pipeline)) == 2)
    
    # ANOVA test
    res.aov <- anova_test(
      data = sr_data, dv = accuracy, wid = rep_id,
      within = c(Pipeline, Population)
    )
    get_anova_table(res.aov)
    write_xlsx(res.aov, "sr_2way_RMANOVA.xslx")
    
    ## Not significant different interaction
    
    pwc <- sr_data %>%
      pairwise_t_test(
        accuracy ~ Pipeline, paired = TRUE, 
        p.adjust.method = "bonferroni"
      )
    pwc
    write_xlsx(pwc, "sr_1way_posthoc_pipeline.xslx")
    
    
    
    pwc <- sr_data %>%
      pairwise_t_test(
        accuracy ~ Population, paired = FALSE, 
        p.adjust.method = "bonferroni"
      )
    pwc
    write_xlsx(pwc2,"sr_1way_posthoc_population.xlsx")
    
    
    
    
    
    
    
    
#### ONLY between subject  -- 2 way RMANOVA
    bs_data <-
      data_long %>%
      filter(substr(Pipeline, nchar(Pipeline), nchar(Pipeline)) == 3)
    
    # ANOVA test
    res.aov <- anova_test(
      data = bs_data, dv = accuracy, wid = rep_id,
      within = c(Pipeline, Population)
    )
    get_anova_table(res.aov)
    write_xlsx(res.aov, "bs_2way_RMANOVA.xslx")
    
    #### ONE WAY RMANOVA -- Pipeline
    # ANOVA test
    one.way <- bs_data %>%
      group_by(Population) %>%
      anova_test(dv = accuracy, wid = rep_id,
                 within = Pipeline
      )
    one.way
    write_xlsx(one.way, "bs_1way_RMANOVA_pipeline.xslx")
    
    pwc <- bs_data %>%
      group_by(Population) %>%
      pairwise_t_test(
        accuracy ~ Pipeline, paired = TRUE,
        p.adjust.method = "bonferroni"
      )
    pwc
    
    library(writexl)
    write_xlsx(pwc,"bs_1way_posthoc_pipeline.xlsx")
    
    #### ONE WAY RMANOVA -- Population
    # ANOVA test
    one.way <- bs_data %>%
      group_by(Pipeline) %>%
      anova_test(dv=accuracy, wid=rep_id,
                 within=Population) %>%
      get_anova_table() %>%
      adjust_pvalue(method="bonferroni")
    one.way
    write_xlsx(one.way,"bs_1way_RMANOVA_population.xlsx")
    
    pwc2 <- bs_data %>%
      group_by(Pipeline) %>%
      pairwise_t_test(
        accuracy ~ Population, paired=FALSE,
        p.adjust.method = "bonferroni"
      )
    pwc2
    write_xlsx(pwc2,"bs_1way_posthoc_population.xlsx")
    