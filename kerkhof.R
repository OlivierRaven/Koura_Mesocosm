# RQ1 — Overall reef preference at L1
df2_L1     <- df2 %>% filter(stage == "L1", reef_type != "TankWall") %>%
  mutate(reef_type = droplevels(reef_type))
tab2_L1    <- table(df2_L1$reef_type)
tab2_L1_nz <- tab2_L1[tab2_L1 > 0]
reef_levels <- names(tab2_L1_nz)

xmulti2    <- XNomial::xmulti(
  obs  = as.numeric(tab2_L1_nz),
  expr = rep(sum(tab2_L1_nz) / length(tab2_L1_nz), length(tab2_L1_nz)))
p_xmulti2  <- xmulti2$pLLR

# Post-hoc pairwise G-tests
pgtest2           <- pairwise_gtest(tab2_L1_nz)
p_single_vs_flat2 <- pgtest2$p_adj[pgtest2$pair == "SingleStone vs FlatStone"]
p_single_vs_pile2 <- pgtest2$p_adj[pgtest2$pair == "SingleStone vs StonePile"]
p_single_vs_wood2 <- pgtest2$p_adj[pgtest2$pair == "SingleStone vs WoodLog"]
p_flat_vs_pile2   <- pgtest2$p_adj[pgtest2$pair == "FlatStone vs StonePile"]
p_flat_vs_wood2   <- pgtest2$p_adj[pgtest2$pair == "FlatStone vs WoodLog"]
p_pile_vs_wood2   <- pgtest2$p_adj[pgtest2$pair == "StonePile vs WoodLog"]

# CLD for combined panel
cld_combined2 <- data.frame(
  stage      = "L1",
  panel      = "Combined",
  reef_type  = names(gtest_to_cld(pgtest2)),
  cld_letter = unname(gtest_to_cld(pgtest2)))

# RQ2 — Within-size-class preference
xmulti_small  <- XNomial::xmulti(
  obs  = as.numeric(table(df2_L1$reef_type[df2_L1$size_class == "S"])),
  expr = rep(1/4, 4))
xmulti_medium <- XNomial::xmulti(
  obs  = as.numeric(table(df2_L1$reef_type[df2_L1$size_class == "M"])),
  expr = rep(1/4, 4))
xmulti_large  <- XNomial::xmulti(
  obs  = as.numeric(table(df2_L1$reef_type[df2_L1$size_class == "L"])),
  expr = rep(1/4, 4))

# Post-hoc G-tests and CLD only if within-size xmulti is significant
if (xmulti_small$pLLR < 0.05) {
  pgtest_small <- pairwise_gtest(table(df2_L1$reef_type[df2_L1$size_class == "S"]))
  cld_small    <- data.frame(stage = "L1", panel = "Small",
    reef_type  = names(gtest_to_cld(pgtest_small)),
    cld_letter = unname(gtest_to_cld(pgtest_small)))} else {
  cld_small <- data.frame(stage = "L1", panel = "Small",
    reef_type = reef_levels, cld_letter = "a")}

if (xmulti_medium$pLLR < 0.05) {
  pgtest_medium <- pairwise_gtest(table(df2_L1$reef_type[df2_L1$size_class == "M"]))
  cld_medium    <- data.frame(stage = "L1", panel = "Medium",
    reef_type  = names(gtest_to_cld(pgtest_medium)),
    cld_letter = unname(gtest_to_cld(pgtest_medium)))} else {
  cld_medium <- data.frame(stage = "L1", panel = "Medium",
    reef_type = reef_levels, cld_letter = "a")}

if (xmulti_large$pLLR < 0.05) {
  pgtest_large <- pairwise_gtest(table(df2_L1$reef_type[df2_L1$size_class == "L"]))
  cld_large    <- data.frame(stage = "L1", panel = "Large",
    reef_type  = names(gtest_to_cld(pgtest_large)),
    cld_letter = unname(gtest_to_cld(pgtest_large)))} else {
  cld_large <- data.frame(stage = "L1", panel = "Large",
    reef_type = reef_levels, cld_letter = "a")}

# Bind all CLD panels
cld_all2 <- bind_rows(cld_combined2, cld_small, cld_medium, cld_large)

# RQ3 — Do size classes differ from each other in reef choice?
tab2_size <- table(df2_L1$reef_type, df2_L1$size_class)
fisher2   <- fisher.test(tab2_size, simulate.p.value = TRUE, B = 9999)
p_fisher2 <- fisher2$p.value

# Join CLD letters (built in stats chunk)
exp2_reef_letters <- exp2_reef_all %>%
  relevel_reef() %>%
  filter(stage == "L1") %>%
  left_join(cld_all2, by = c("stage", "panel", "reef_type"))

Exp2_reef_p <- exp2_reef_all %>%
  relevel_reef() %>%
  ggplot(aes(reef_type, prop)) +
  geom_col(color = "black") +
  geom_text(aes(label = n), vjust = 1.3, colour = "white") +
  geom_text(data = exp2_reef_letters, aes(y = prop + 0.04, label = cld_letter), size = 3.5,fontface = "bold") +
  facet_grid(panel ~ stage, labeller = labeller(stage = lab_stage, panel = lab_panel2)) +
  labs(x = "Reef type", y = "Proportion")

ggsave(Exp2_reef_p, file = file.path(out_dir, "fig-exp2.png"),
       width = 7, height = 6, dpi = 300)

Exp2_reef_p

# L1 only — by size class
exp2_L1_size <- df_exp2_group_long %>%
  filter(stage == "L1") %>%
  count(reef_type, size_class, name = "n") %>%
  group_by(size_class) %>%
  mutate(N = sum(n), prop = n / N) %>%
  ungroup() %>%
  relevel_reef() %>%
  mutate(panel = as.character(size_class))

exp2_reef_all <- bind_rows(exp2_L1_combined, exp2_L1_size)



df3_L1     <- df3 %>% filter(stage == "L1")
tab3_L1    <- table(df3_L1$reef_type)
tab3_L1_nz <- tab3_L1[tab3_L1 > 0]

xmulti3    <- XNomial::xmulti(
  obs  = as.numeric(tab3_L1_nz),
  expr = rep(sum(tab3_L1_nz) / length(tab3_L1_nz), length(tab3_L1_nz)))
p_xmulti3  <- xmulti3$pLLR

pgtest3    <- pairwise_gtest(tab3_L1_nz)
p_flat_vs_wood3    <- pgtest3$p_adj[pgtest3$pair == "FlatStone vs WoodSplit"]
p_flat_vs_wall3    <- pgtest3$p_adj[pgtest3$pair == "FlatStone vs TankWall"]
p_wood_vs_wall3    <- pgtest3$p_adj[pgtest3$pair == "WoodSplit vs TankWall"]

cld_combined3 <- data.frame(
  stage      = "L1",
  panel      = "Combined",
  reef_type  = names(gtest_to_cld(pgtest3)),
  cld_letter = unname(gtest_to_cld(pgtest3)))

# RQ2 — Do size classes differ from each other?
tab3_size  <- table(df3_L1$reef_type, df3_L1$size_class)
fisher3    <- fisher.test(tab3_size, simulate.p.value = TRUE, B = 9999)
p_fisher3  <- fisher3$p.value

# RQ3 — Preference within each size class
reef_levels3 <- names(tab3_L1_nz)

xmulti3_small  <- XNomial::xmulti(
  obs  = as.numeric(table(df3_L1$reef_type[df3_L1$size_class == "S"])),
  expr = rep(1/3, 3))
xmulti3_medium <- XNomial::xmulti(
  obs  = as.numeric(table(df3_L1$reef_type[df3_L1$size_class == "M"])),
  expr = rep(1/3, 3))
xmulti3_large  <- XNomial::xmulti(
  obs  = as.numeric(table(df3_L1$reef_type[df3_L1$size_class == "L"])),
  expr = rep(1/3, 3))

if (xmulti3_small$pLLR < 0.05) {
  pgtest3_small <- pairwise_gtest(table(df3_L1$reef_type[df3_L1$size_class == "S"]))
  cld_small3    <- data.frame(stage = "L1", panel = "S",
    reef_type  = names(gtest_to_cld(pgtest3_small)),
    cld_letter = unname(gtest_to_cld(pgtest3_small)))} else {
  cld_small3 <- data.frame(stage = "L1", panel = "S",
    reef_type = reef_levels3, cld_letter = "a")}

if (xmulti3_medium$pLLR < 0.05) {
  pgtest3_medium <- pairwise_gtest(table(df3_L1$reef_type[df3_L1$size_class == "M"]))
  cld_medium3    <- data.frame(stage = "L1", panel = "M",
    reef_type  = names(gtest_to_cld(pgtest3_medium)),
    cld_letter = unname(gtest_to_cld(pgtest3_medium)))} else {
  cld_medium3 <- data.frame(stage = "L1", panel = "M",
    reef_type = reef_levels3, cld_letter = "a")}

if (xmulti3_large$pLLR < 0.05) {
  pgtest3_large <- pairwise_gtest(table(df3_L1$reef_type[df3_L1$size_class == "L"]))
  cld_large3    <- data.frame(stage = "L1", panel = "L",
    reef_type  = names(gtest_to_cld(pgtest3_large)),
    cld_letter = unname(gtest_to_cld(pgtest3_large)))} else {
  cld_large3 <- data.frame(stage = "L1", panel = "L",
    reef_type = reef_levels3, cld_letter = "a")}

cld_all3 <- bind_rows(cld_combined3, cld_small3, cld_medium3, cld_large3)


# Build combined counts
exp3_top <- exp3_reef %>%
  mutate(panel = factor("Combined", levels = PANEL_LEVELS))

exp3_bot <- exp3_reef_size %>%
  mutate(panel = factor(as.character(size_class), levels = PANEL_LEVELS))

exp3_reef_all <- bind_rows(exp3_top, exp3_bot)

# Join CLD letters — must come after exp3_reef_all is built
exp3_reef_letters <- exp3_reef_all %>%
  relevel_reef3() %>%
  filter(stage == "L1") %>%
  left_join(cld_all3, by = c("stage", "panel", "reef_type"))

# One plot with a left strip for every row (Combined, S, M, L)
Exp3_reef_p <- exp3_reef_all %>%
  ggplot(aes(reef_type, prop)) +
  geom_col(color = "black") +  
  geom_text(aes(label = n), vjust = 1.3, colour = "white") +
  geom_text(data = exp3_reef_letters, aes(y = prop + 0.06, label = cld_letter), size = 3.5,fontface = "bold") +
  facet_grid(panel ~ stage, labeller = labeller(stage = lab_stage, panel = lab_panel3)) +
  labs(x = "Reef type", y = "Proportion")

ggsave(Exp3_reef_p, file = file.path(out_dir, "fig-exp3.png"), width = 7, height = 6, dpi = 300)

Exp3_reef_p



# RQ1 — Overall reef preference at L1
df4_L1     <- df4 %>% filter(stage == "L1")
tab4_L1    <- table(df4_L1$reef_type)
tab4_L1_nz <- tab4_L1[tab4_L1 > 0]

xmulti4    <- XNomial::xmulti(
  obs  = as.numeric(tab4_L1_nz),
  expr = rep(sum(tab4_L1_nz) / length(tab4_L1_nz), length(tab4_L1_nz)))
p_xmulti4  <- xmulti4$pLLR

pgtest4    <- pairwise_gtest(tab4_L1_nz)
p_bart_vs_bwood4    <- pgtest4$p_adj[pgtest4$pair == "BrickArtificial vs BrickWood"]
p_bart_vs_wall4    <- pgtest4$p_adj[pgtest4$pair == "BrickArtificial vs TankWall"]
p_bwood_vs_wall4    <- pgtest4$p_adj[pgtest4$pair == "BrickWood vs TankWall"]

cld_combined4 <- data.frame(
  stage      = "L1",
  panel      = "Combined",
  reef_type  = names(gtest_to_cld(pgtest4)),
  cld_letter = unname(gtest_to_cld(pgtest4)))

# RQ2 — Do sex classes differ from each other?
tab4_sex  <- table(df4_L1$reef_type, df4_L1$sex)
fisher4    <- fisher.test(tab4_sex, simulate.p.value = TRUE, B = 9999)
p_fisher4  <- fisher4$p.value

# RQ3 — Preference within each sex
reef_levels4 <- names(tab4_L1_nz)

xmulti4_female <- XNomial::xmulti(
  obs  = as.numeric(table(df4_L1$reef_type[df4_L1$sex == "F"])),
  expr = rep(1/3, 3))
xmulti4_male <- XNomial::xmulti(
  obs  = as.numeric(table(df4_L1$reef_type[df4_L1$sex == "M"])),
  expr = rep(1/3, 3))


if (xmulti4_female$pLLR < 0.05) {
  pgtest4_female <- pairwise_gtest(table(df4_L1$reef_type[df4_L1$sex == "F"]))
  cld_female4    <- data.frame(stage = "L1", panel = "F",
    reef_type  = names(gtest_to_cld(pgtest4_female)),
    cld_letter = unname(gtest_to_cld(pgtest4_female)))} else {
  cld_female4 <- data.frame(stage = "L1", panel = "F",
    reef_type = reef_levels4, cld_letter = "a")}

if (xmulti4_male$pLLR < 0.05) {
  pgtest4_male <- pairwise_gtest(table(df4_L1$reef_type[df4_L1$sex == "M"]))
  cld_male4    <- data.frame(stage = "L1", panel = "M",
    reef_type  = names(gtest_to_cld(pgtest4_male)),
    cld_letter = unname(gtest_to_cld(pgtest4_male)))} else {
  cld_male4 <- data.frame(stage = "L1", panel = "M",
    reef_type = reef_levels4, cld_letter = "a")}

cld_all4 <- bind_rows(cld_combined4, cld_female4, cld_male4)



exp4_reef <- df_exp4_brick_long %>%
  dplyr::filter(stage %in% c("L1"), !is.na(reef_type)) %>%
  dplyr::count(stage, reef_type, name = "n") %>%
  dplyr::group_by(stage) %>%
  dplyr::mutate(N = sum(n), prop = n / N) %>%
  dplyr::ungroup() %>%
  relevel_reef4()

# By SEX
exp4_reef_sex <- df_exp4_brick_long %>%
  dplyr::filter(stage %in% c("L1")) %>%
  dplyr::count(stage, reef_type, sex, name = "n") %>%
  dplyr::group_by(stage, sex) %>%
  dplyr::mutate(N = sum(n), prop = n / N) %>%
  dplyr::ungroup() %>%
  relevel_reef4() %>%
  dplyr::mutate(panel = dplyr::recode(sex, F = "Female", M = "Male"))


# Labels (facets)
PANEL_LEVELS4  <- c("Combined","M","F")
lab_panel4     <- c(Combined = "Combined", M = "Male", F = "Female")


sex_n <- exp4_reef_sex %>%
  group_by(sex) %>%
  summarise(n_total = sum(n), .groups = "drop")

# Build named vector for labeller
lab_panel_n_sex <- setNames(paste0(c("Combined", sex_n$sex),c(" (combined)",paste0(" (n=", sex_n$n_total, ")"))),c("Combined", sex_n$sex))

# Rename F/M to Female/Male with n
lab_panel_n_sex <- c( Combined = "Combined",  M = paste0("Male"), F = paste0("Female"))  

# Build combined counts
exp4_sex_top <- exp4_reef %>%
  dplyr::mutate(panel = factor("Combined", levels = PANEL_LEVELS4))

exp4_sex_bot <- exp4_reef_sex %>%
  dplyr::mutate(panel = factor(as.character(sex), levels = PANEL_LEVELS4))

exp4_sex_all <- dplyr::bind_rows(exp4_sex_top, exp4_sex_bot)

# Join CLD letters 
exp4_reef_letters  <- exp4_sex_all %>%
  relevel_reef4() %>%
  left_join(cld_all4, by = c("panel", "reef_type"))

# Plot
Exp4_sex_p <- exp4_sex_all %>%
  relevel_reef4() %>%
  ggplot(aes(reef_type, prop)) +
  geom_col(color = "black") +
  geom_text(aes(label = n), vjust = 1.3, colour = "white") +
  geom_text( data = exp4_reef_letters, aes(y = prop + 0.06, label = cld_letter), size = 3.5, fontface = "bold") +
  facet_grid(panel ~ stage, labeller = labeller(stage = lab_stage, panel = lab_panel_n_sex )) +
  labs(x = "Reef type", y = "Proportion")

ggplot2::ggsave(filename = file.path(out_dir, "fig-exp4-sex.png"),plot = Exp4_sex_p,width = 4, height = 5, dpi = 300)

Exp4_sex_p

#| label: fig-exp4-size
#| fig-width: 4
#| fig-height: 5
#| fig-cap: "."

# By SIZE
exp4_reef_size <- df_exp4_brick_long %>%
  dplyr::filter(stage %in% c("L1")) %>%
  dplyr::count(stage, reef_type, size_class, name = "n") %>%
  dplyr::group_by(stage, size_class) %>%
  dplyr::mutate(N = sum(n), prop = n / N) %>%
  dplyr::ungroup() %>%
  relevel_reef4()

PANEL_LEVELS5 <- c("Combined","S","M","L")
lab_panel5    <- c(Combined = "Combined", S = "Small", M = "Medium", L = "Large")

size_n <- exp4_reef_size %>%
  group_by(size_class) %>%
  summarise(n_total = sum(n), .groups = "drop")

lab_panel_n_size <- c(  Combined = "Combined",S = paste0("Small"),M = paste0("Medium"),L = paste0("Large"))

# Build combined counts
exp4_size_top <- exp4_reef %>%
  dplyr::mutate(panel = factor("Combined", levels = PANEL_LEVELS5))

exp4_size_bot <- exp4_reef_size %>%
  dplyr::mutate(panel = factor(as.character(size_class), levels = PANEL_LEVELS5))

exp4_size_all <- dplyr::bind_rows(exp4_size_top, exp4_size_bot)

# Plot
Exp4_size_p <- exp4_size_all %>%
  relevel_reef4() %>%
  ggplot(aes(reef_type, prop)) +
  geom_col(color = "black") +
  geom_text(aes(label = n), vjust = 1.3, colour = "white") +
  facet_grid(panel ~ stage,
             labeller = labeller(
               stage = lab_stage,
               panel = lab_panel_n_size)) +
  labs(x = "Reef type", y = "Proportion")

#ggplot2::ggsave(filename = file.path(out_dir, "fig-exp4-size.png"), plot = Exp4_size_p, width = 4, height = 5, dpi = 300)

Exp4_size_p


#| label: fig-exp4-sex-size
#| fig-width: 7
#| fig-height: 6
#| fig-cap: "."

Exp4_size_sex_p <- Exp4_sex_p + Exp4_size_p 

#ggplot2::ggsave(filename = file.path(out_dir, "fig-exp4-sex-size.png"), plot = Exp4_size_sex_p, width = 7, height = 6, dpi = 300)

Exp4_size_sex_p