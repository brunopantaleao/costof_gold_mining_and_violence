/*===========================================================================
  MINERAÇÃO E VIOLÊNCIA — PAPER-ONLY DO-FILE   ("The Cost of Gold")
  Derived from: Data_analysis_for_replication_v3.do
  Stata 14.1 compatible

  
  WHAT IT DOES NOT CONTAIN
    - Sections 1-4 of v3 (auxiliary datasets, construction of panel_replication and of
      the Bartik baseline shares): this file starts from panel_replication.dta,
      exactly as v3 did.
    - Items produced outside Stata: Figure 4 (map_total_families_BR.pdf),
      Figure 5 (mapa_ambiental_BR.pdf), Figure 6 (map_baseline_mining_BR.pdf),
      Figure A1 (sample-construction flowchart) and Table A3 (composition of the
      994 municipalities). Tables 7 and A5 are summaries typed by hand.

  REQUIRED PACKAGES:  reghdfe  ivreghdfe  ivreg2  ranktest  outreg2  coefplot  binscatter
  INPUT FILES      :  $out\panel_replication.dta
  ---------------------------------------------------------------------------
  INDEX: PAPER ITEM  ->  SECTION  ->  OUTPUT FILE(S)
  ---------------------------------------------------------------------------
  Tables A1, A2, A4 (descriptive)    1   log file only (sum / sum, d)
  Figures 1, 2, 3                    2a  f5_usd_mining_mb, f6_brl_mining_mb (Fig 1)
                                         f4_agg_brl_homicidios, f3_agg_usd_homicidios (Fig 2)
                                         f2_agg_brl_num_con, f2_agg_brl_fam,
                                         f1_agg_usd_num_con, f1_agg_usd_fam (Fig 3)
  Figure A4                          2b  ts_mapbiomas_mining.pdf
  Figures A2, A3                     2c  hist_share_{garimpo,gold}_{1985..2000}.pdf
  Table 1                            3a  rf_baseline_robustness_{gold,garimpo}.xls
  Table A20                          3b  rf_lbartik_{gold,garimpo}_2000_main.xls
  Table 2 (Panels A, B, C)           3c  lbartik_garimpo_2000_idade.xls,
                                         lbartik_garimpo_2000_raça.xls,
                                         rf_gender_lbartik_garimpo_2000.xls
  Table 3 (Panels A-D)               3d  rf_main_gold_only.xls, rf_main_no_gold.xls,
                                         rf_main_gold_only_anm.xls, rf_main_no_gold_anm.xls
  Tables 4 and 5, Table A9           4a  iv_mapbio_garimpo_main.xls, iv_mapbio_gold_main.xls,
                                         iv_mapbio_industrial_main.xls
  Tables 4 (col. 5-6) and 6          4b  iv_garimpo_sigmin.xls, iv_gold_sigmin.xls
  Tables A6, A7, A8, Figs A5, A6     5   pretrend_leads.xls, placebo_shifted_price.xls,
                                         placebo_future_shifts.xls,
                                         coefplot_pretrends.pdf, coefplot_placebo_future.pdf
  Tables A10, A11                    6a  bartik_usd_prices.xls, iv_mapbio_garimpo_usd.xls
  Table A12                          6b  rf_lbartik_{garimpo,gold}_2000_cocaine_control.xls
  Tables A13, A14                    6c  iv_mapbio_garimpo_cpt_only.xls,
                                         iv_mapbio_garimpo_amazo_legal.xls
  Tables A15, A16                    6d  rf_protegida.xls, rf_indigena.xls
  Table A17                          6e  iv_mapbio_main_nogold.xls, iv_mapbio_main_yes_gold.xls
  Table A18                          6f  rf_mb_total_fe.xls, rf_acumulado_fe.xls
  Table A19, Figure A7               7   robustness_callaway_shares.xls,
                                         robustness_callaway_num_con.xls,
                                         robustness_callaway_fam.xls,
                                         binscatter_dose_response{,2,3}.pdf

 
*===========================================================================*/
set more off
set scheme s1color
global out    "H:\My Drive\Pesquisa\Publishing\World Deve - Amazon Gold\R&R\Replication\Production" /// ADD HERE THE DIRECTORY WHERE THE FILE IS SAVED

 
/*=========================================================================== 
  1. DESCRIPTIVE STATISTICS   -> Tables A1, A2, A4   (read from the log)
===========================================================================*/

cd "$out"
use panel_replication, clear
drop if lbartik_garimpo_2000 == .
drop if empregos_pc == .
count
replace  prop_unids = 0 if  prop_unids==.
replace  prop_indig = 0 if  prop_indig==.

* Table A4 - percentiles of mapped mining area (Panel A: geological occurrence,
*            Panel B: ANM gold registry)
by ouro_ever2, sort: sum mb_total_km2 mb_garimpo_km2 mb_industrial_km2 mb_gold_km2, d
by ouro_ever, sort: sum mb_total_km2 mb_garimpo_km2 mb_industrial_km2 mb_gold_km2, d

* Table A2, column "Full sample" (also Table A1, Panel A/B)
sum taxa_homicidio_geral fam num_con mb_total_km2 accum_atv_km2 lbartik_garimpo_2000 lbartik_gold_2000 lbartik_garimpo_1995 lbartik_gold_1995 lbartik_garimpo_1990 lbartik_gold_1990 lbartik_garimpo_1985 lbartik_gold_1985

* Table A1 - full analytical sample
sum pop count_total_empregados renda_media accum_atv_km2 prop_unids prop_indig mb_total_km2 mb_garimpo_km2 mb_industrial_km2 mb_gold_km2 empregos_pc amazonia_legal ouro_ever2 ever_conflict

* Table A2, columns "Legal Amazon", "CPT conflicts only", "Gold occurrence"
sum taxa_homicidio_geral fam num_con mb_total_km2 accum_atv_km2 lbartik_garimpo_2000 ///
    if amazonia_legal == 1

sum taxa_homicidio_geral fam num_con mb_total_km2 accum_atv_km2 lbartik_garimpo_2000 ///
    if ever_conflict == 1

sum taxa_homicidio_geral fam num_con mb_total_km2 accum_atv_km2 lbartik_garimpo_2000 ///
    if ouro_ever2 == 1


/*===========================================================================
  2. DESCRIPTIVE FIGURES
===========================================================================*/

/* --- 2a. Figures 1, 2, 3: gold prices vs. mining / homicides / conflicts --- */
cd "$out"
clear
use panel_replication
xtset codmun ano

/* ever-mining cities only */
keep if max_extra > 0

label variable averageclosingprice    "International gold price (USD)"
label variable cont2                  "Domestic gold price (BRL)"
label variable n_homicidio_total      "Homicides (all)"
label variable fam                    "Number of displaced peasant families"
label variable num_con                "Number of agrarian conflicts involving peasant families"

* Figure 3 (agrarian conflicts and families) and Figure 2 (homicides)
scatter averageclosingprice  fam if fam>0,    graphregion(color(white))
graph export "f1_agg_usd_fam.pdf", replace
scatter cont2  fam if fam>0,    graphregion(color(white))
graph export "f2_agg_brl_fam.pdf", replace
scatter averageclosingprice n_homicidio_total if n_homicidio_total>0, graphregion(color(white))
graph export "f3_agg_usd_homicidios.pdf", replace
scatter cont2 n_homicidio_total if n_homicidio_total>0,      graphregion(color(white))
graph export "f4_agg_brl_homicidios.pdf", replace
scatter averageclosingprice num_con if num_con>0,    graphregion(color(white))
graph export "f1_agg_usd_num_con.pdf", replace
scatter cont2  num_con if num_con>0,    graphregion(color(white))
graph export "f2_agg_brl_num_con.pdf", replace

* Figure 1 (yearly change in mapped mining area vs. gold prices)
collapse (first) averageclosingprice cont2 ///
         (rawsum) mb_total_km2, by(ano)

* Compute year-on-year change in aggregate mining area AFTER collapsing
* (using D. before collapse gives sum of municipality diffs, which can be
*  very large negative when MapBiomas reclassifies land between years)
sort ano
gen var_mb_total_km2 = mb_total_km2 - mb_total_km2[_n-1]

label variable averageclosingprice    "International gold price (USD)"
label variable cont2                  "Domestic gold price (BRL)"
label variable var_mb_total_km2       "New mining area ha (MapBiomas)"    // label only: was km²

scatter averageclosingprice var_mb_total_km2 if var_mb_total_km2>=0,  graphregion(color(white))     mlabel(ano)
graph export "f5_usd_mining_mb.pdf", replace
scatter cont2 var_mb_total_km2 if var_mb_total_km2>=0,               graphregion(color(white))      mlabel(ano)
graph export "f6_brl_mining_mb.pdf", replace


 

/*===========================================================================
  3. REDUCED-FORM REGRESSIONS
     Outcomes: taxa_* (per 100,000, pre-computed) and lfam / lconf = ln(1+x)
     Controls: lpop empregos_pc.   FE: municipality + year (reghdfe), SE clustered
     by municipality.  Sample: "RF sample" = drop missing laccum_atv_km2, codmun,
     lbartik_gold_2000, lbartik_garimpo_2000.
===========================================================================*/

cd "$out"
clear
use panel_replication

/* --- 3a. TABLE 1: baseline-year sensitivity (1985, 1990, 1995, 2000) ------
   Panels = outcomes (homicide rate / affected families / agrarian conflicts);
   columns = baseline year; one file per Bartik type.
   Control mean: cities with zero total mapped mining area.                   */
foreach y in 1985 1990 1995 2000 {
    foreach trt in gold garimpo {
        foreach z in taxa_homicidio_geral lfam lconf {
            sum `z' if mb_total_km2 == 0
            local Cm = r(mean)
            reghdfe `z' lbartik_`trt'_`y' lpop empregos_pc, ///
                absorb(codmun ano) cluster(codmun)
            outreg2 using "rf_baseline_robustness_`trt'.xls", append ///
                addstat(Control Mean, `Cm') ///
                addtext(Municipality FE, Yes, Year FE, Yes, ///
                        Baseline Year, `y')
        }
    }
}


/* --- 3b. TABLE A20: mortality outcomes (intoxication, all-cause, undetermined) */
foreach trt in  lbartik_gold_2000  lbartik_garimpo_2000 {
    foreach z in taxa_intoxicacao_geral taxa_todas_geral taxa_indeterminada_geral {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc, absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_`trt'_main.xls", append addstat(Control Mean, `Cm')
    }
}


/* --- 3c. TABLE 2: heterogeneity of the garimpo Bartik (2000 baseline) -------
   Panel A (age) and Panel B (race): xtreg with municipality FE (as in v3).
   Panel C (gender): reghdfe, municipality + year FE (as in v3).              */
xtset codmun ano

* Panel B: race
foreach trt in lbartik_garimpo_2000 {
    foreach z in taxa_homicidio_branca taxa_homicidio_preta_parda taxa_homicidio_indigena {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        xtreg `z' `trt' lpop empregos_pc, fe cluster(codmun)
        outreg2 using "`trt'_raça.xls", append addstat(Control Mean, `Cm')
    }
}

* Panel A: age groups
foreach trt in lbartik_garimpo_2000 {
    foreach z in taxa_homicidio_0013 taxa_homicidio_1429 taxa_homicidio_3039 taxa_homicidio_4059 taxa_homicidio_60mais {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        xtreg `z' `trt' lpop empregos_pc, fe cluster(codmun)
        outreg2 using "`trt'_idade.xls", append addstat(Control Mean, `Cm')
    }
}

* Panel C: gender  (Data: painel_mortes_genero.dta)
cd "$out"
clear
use panel_replication


* Collapse to one obs per codmun-ano (sum across age groups)
collapse (sum) homem mulher, by(codmun ano)
merge 1:1 codmun ano using panel_replication, keepusing(populacao lpop empregos_pc ///
    lbartik_gold_2000 lbartik_garimpo_2000 mb_total_km2 amazonia_legal ///
    ouro_ever2 laccum_atv_km2)
drop if _merge == 2
drop _merge

gen taxa_homic_homem  = (homem  / populacao) * 100000
gen taxa_homic_mulher = (mulher / populacao) * 100000
label variable taxa_homic_homem  "Male homicide rate per 100k"
label variable taxa_homic_mulher "Female homicide rate per 100k"

drop if laccum_atv_km2==.
drop if codmun==.
drop if lbartik_gold_2000==.
drop if lbartik_garimpo_2000==.

foreach trt in lbartik_garimpo_2000 {
    foreach z in taxa_homic_homem taxa_homic_mulher {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc, absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_gender_`trt'.xls", append addstat(Control Mean, `Cm') ///
            addtext(Municipality FE, Yes, Year FE, Yes)
    }
}


/* --- 3d. TABLE 3: RF by geological gold occurrence (SGB) and ANM gold registry
   Panel A: ouro_ever2==1   Panel B: ouro_ever2==0   (SGB geological occurrence)
   Panel C: ouro_ever==1    Panel D: ouro_ever==0    (ANM registry, any process)
   Control mean: cities with zero mapped gold-mining area.                    */

* Panel A - geological gold occurrence
cd "$out"
clear
use panel_replication
keep if ouro_ever2==1

foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in taxa_homicidio_geral taxa_homicidio_preta_parda {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_gold_only.xls", append addstat(Control Mean, `Cm')
    }
}
foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in lfam lconf {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_gold_only.xls", append addstat(Control Mean, `Cm')
    }
}

* Panel B - no geological gold occurrence
cd "$out"
clear
use panel_replication
keep if ouro_ever2==0

foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in taxa_homicidio_geral taxa_homicidio_preta_parda {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_no_gold.xls", append addstat(Control Mean, `Cm')
    }
}
foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in lfam lconf {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_no_gold.xls", append addstat(Control Mean, `Cm')
    }
}

* Panel C - ANM gold registry
cd "$out"
clear
use panel_replication
keep if ouro_ever==1

foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in taxa_homicidio_geral taxa_homicidio_preta_parda {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_gold_only_anm.xls", append addstat(Control Mean, `Cm')
    }
}
foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in lfam lconf {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_gold_only_anm.xls", append addstat(Control Mean, `Cm')
    }
}

* Panel D - no ANM gold registry
cd "$out"
clear
use panel_replication
keep if ouro_ever==0

foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in taxa_homicidio_geral taxa_homicidio_preta_parda {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_no_gold_anm.xls", append addstat(Control Mean, `Cm')
    }
}
foreach trt in  lbartik_gold_2000   lbartik_garimpo_2000 {
    foreach z in lfam lconf {
        sum `z' if mb_gold_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_main_no_gold_anm.xls", append addstat(Control Mean, `Cm')
    }
}


/*===========================================================================
  4. IV: BARTIK INSTRUMENTS
     IV sample: panel_replication (year <= 2019), ouro_ever2 regenerated from
     n_ocorrencias_ouro, drop missing laccum_atv_km2 / codmun / both Bartiks.
===========================================================================*/

cd "$out"
clear
use panel_replication
xtset codmun ano
drop if ano>2019
capture drop ouro_ever2
g ouro_ever2 = (n_ocorrencias_ouro>0)

/* --- 4a. TABLE 5 (2SLS, Panel A garimpo area / Panel B gold area) and the
           first stages + KP F-statistics of TABLE 4 (columns 1-4)              */

* Panel A: garimpo mining area (2SLS)
foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 lbartik_gold_1995 lbartik_garimpo_1995 lbartik_gold_1990 lbartik_garimpo_1990  lbartik_gold_1985 lbartik_garimpo_1985  {
     foreach i in taxa_homicidio_geral lfam lconf {

        ivreghdfe `i' (lmb_garimpo  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun)

        outreg2 using "iv_mapbio_garimpo_main.xls", append                             ///
                keep(lmb_garimpo)                           ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))
        }
}

* First stage: garimpo mining area (Table 4)
foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 lbartik_gold_1995 lbartik_garimpo_1995 lbartik_gold_1990 lbartik_garimpo_1990  lbartik_gold_1985 lbartik_garimpo_1985  {
        reghdfe   lmb_garimpo `iv' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "iv_mapbio_garimpo_main.xls", append
}

* Panel B: gold mining area (2SLS)
foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 lbartik_gold_1995 lbartik_garimpo_1995 lbartik_gold_1990 lbartik_garimpo_1990  lbartik_gold_1985 lbartik_garimpo_1985  {
     foreach i in taxa_homicidio_geral lfam lconf {

        ivreghdfe `i' (lmb_gold  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun)

        outreg2 using "iv_mapbio_gold_main.xls", append                             ///
                keep(lmb_gold)                           ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))
        }
}

* First stage: gold mining area (Table 4)
foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 lbartik_gold_1995 lbartik_garimpo_1995 lbartik_gold_1990 lbartik_garimpo_1990  lbartik_gold_1985 lbartik_garimpo_1985  {
        reghdfe  lmb_gold `iv' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "iv_mapbio_gold_main.xls", append
}

/* --- TABLE A9: industrial mining (Panel A gold Bartik, Panel B garimpo Bartik)
           2SLS + first stage (the first stage of the garimpo Bartik is the
           sectoral placebo).                                                    */
foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 {
     foreach i in taxa_homicidio_geral n_homicidio_total lfam lconf {

        ivreghdfe `i' (lmb_industrial  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first

        outreg2 using "iv_mapbio_industrial_main.xls", append                             ///
                keep(lmb_industrial)                           ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

        }
}
*FIRST STAGE
foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 {
        reghdfe  lmb_industrial `iv' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "iv_mapbio_industrial_main.xls", append
}


/* --- 4b. TABLE 6 (2SLS with ANM-registered area) and first stages of
           TABLE 4 (columns 5-6: ANM-registered area)                          */

* garimpo Bartik
foreach iv in lbartik_garimpo_2000 lbartik_garimpo_1995 lbartik_garimpo_1990 lbartik_garimpo_1985 {
    foreach i in taxa_homicidio_geral  lfam lconf {
        ivreghdfe `i' (laccum_atv_km2 = `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
        outreg2 using "iv_garimpo_sigmin.xls", append keep(laccum_atv_km2) addtext(Municipality FE, Yes, Year FE, Yes)  addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

    }
}

foreach iv in lbartik_garimpo_2000 lbartik_garimpo_1995 lbartik_garimpo_1990 lbartik_garimpo_1985 {

reghdfe laccum_atv_km2 `iv' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
outreg2 using "iv_garimpo_sigmin.xls", append keep(`iv') addtext(Municipality FE, Yes, Year FE, Yes)
}

* gold Bartik
foreach iv in lbartik_gold_2000 lbartik_gold_1995 lbartik_gold_1990 lbartik_gold_1985 {
    foreach i in taxa_homicidio_geral  lfam lconf {
        ivreghdfe `i' (laccum_atv_km2 = `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
        outreg2 using "iv_gold_sigmin.xls", append keep(laccum_atv_km2) addtext(Municipality FE, Yes, Year FE, Yes)  addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

    }
}

foreach iv in lbartik_gold_2000 lbartik_gold_1995 lbartik_gold_1990 lbartik_gold_1985 {

reghdfe laccum_atv_km2 `iv' lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
outreg2 using "iv_gold_sigmin.xls", append keep(`iv') addtext(Municipality FE, Yes, Year FE, Yes)
}


/*===========================================================================
  5. PRE-TREND / PLACEBO TESTS   -> Tables A6, A7, A8; Figures A5, A6
     Sample: panel_replication as is (no sample restrictions), as in v3.

     NOTE: as in v3, the placebo instruments are built from the GOLD Bartik
     (lbartik_gold_2000 and base_gold_sh_2000). To run them with the garimpo
     Bartik instead, replace lbartik_gold_2000 -> lbartik_garimpo_2000 and
     base_gold_sh_2000 -> base_garimpo_sh_2000 (3 places below).
===========================================================================*/

cd "$out"
clear
use panel_replication
xtset codmun ano

gen bartik = lbartik_gold_2000

* Leads (F1 ... F5 of the Bartik)
gen bartik_m1 = F1.bartik
gen bartik_m2 = F2.bartik
gen bartik_m3 = F3.bartik
gen bartik_m4 = F4.bartik
gen bartik_m5 = F5.bartik

* Labels: X periods ahead   (label only: v3 used the event-study notation t-X)
label variable bartik_m1 "t+1"
label variable bartik_m2 "t+2"
label variable bartik_m3 "t+3"
label variable bartik_m4 "t+4"
label variable bartik_m5 "t+5"

* TABLE A6 (+ Figure A5): five leads jointly, with joint F-test
reghdfe taxa_homicidio_geral ///
    bartik_m5 bartik_m4 bartik_m3 bartik_m2 bartik_m1 ///
    lpop empregos_pc, ///
    absorb(codmun ano) cluster(codmun)

test bartik_m5 bartik_m4 bartik_m3 bartik_m2 bartik_m1
local Fj = r(F)
local pj = r(p)
cd "$out"
outreg2 using "pretrend_leads.xls", replace addtext(Municipality FE, Yes, Year FE, Yes) ///
    addstat(Joint F-test, `Fj', Joint F-test p-value, `pj')

coefplot, keep(bartik_m5 bartik_m4 bartik_m3 bartik_m2 bartik_m1) ///
    vertical yline(0, lpattern(dash) lcolor(gray)) ///
    ciopts(recast(rcap)) msymbol(O) mcolor(navy) lcolor(navy) ///
    xtitle("Future Prices") ytitle("Coefficient on Bartik") ///
    xlabel(1 "t+5" 2 "t+4" 3 "t+3" 4 "t+2" 5 "t+1") ///
    graphregion(color(white)) xsize(6) ysize(4)
graph export "coefplot_pretrends.pdf", replace



cd "$out"
clear
use panel_replication
xtset codmun ano

gen bartik = lbartik_gold_2000

* Leads (F1 ... F5 of the Bartik)
gen bartik_m1 = L1.bartik
gen bartik_m2 = L2.bartik
gen bartik_m3 = L3.bartik
gen bartik_m4 = L4.bartik
gen bartik_m5 = L5.bartik

* Labels: X periods ahead   (label only: v3 used the event-study notation t-X)
label variable bartik_m1 "t-1"
label variable bartik_m2 "t-2"
label variable bartik_m3 "t-3"
label variable bartik_m4 "t-4"
label variable bartik_m5 "t-5"

* TABLE A6 (+ Figure A5): five leads jointly, with joint F-test
reghdfe taxa_homicidio_geral ///
    bartik_m5 bartik_m4 bartik_m3 bartik_m2 bartik_m1 ///
    lpop empregos_pc, ///
    absorb(codmun ano) cluster(codmun)

test bartik_m5 bartik_m4 bartik_m3 bartik_m2 bartik_m1
local Fj = r(F)
local pj = r(p)
cd "$out"
outreg2 using "pretrend_lags.xls", replace addtext(Municipality FE, Yes, Year FE, Yes) ///
    addstat(Joint F-test, `Fj', Joint F-test p-value, `pj')

coefplot, keep(bartik_m5 bartik_m4 bartik_m3 bartik_m2 bartik_m1) ///
    vertical yline(0, lpattern(dash) lcolor(gray)) ///
    ciopts(recast(rcap)) msymbol(O) mcolor(navy) lcolor(navy) ///
    xtitle("Past Prices") ytitle("Coefficient on Bartik") ///
    xlabel(1 "t-5" 2 "t-4" 3 "t-3" 4 "t-2" 5 "t-1") ///
    graphregion(color(white)) xsize(6) ysize(4)
graph export "coefplot_pretrends_lags.pdf", replace




* TABLE A7: placebo using the future BRL gold price (t+3)
* NOTE: Must use cont2 (= USD price x exchange rate) to match main Bartik,
*       not lprice (log USD price only).
gen cont2_f3 = F3.cont2

* Construct placebo Bartik
gen bartik_placebo_f3 = base_gold_sh_2000 * cont2_f3
gen lbartik_placebo_f3 = log(1 + bartik_placebo_f3)

cd "$out"
reghdfe taxa_homicidio_geral ///
    lbartik_placebo_f3 ///
    lpop empregos_pc, ///
    absorb(codmun ano) cluster(codmun)
outreg2 using "placebo_shifted_price.xls", replace addtext(Municipality FE, Yes, Year FE, Yes)


* TABLE A8 (+ Figure A6): several future shifts (t+2 ... t+5) jointly
capture drop cont2_f*	bartik_placebo_f* lbartik_placebo_f*

foreach k in 2 3 4 5 {
    gen cont2_f`k' = F`k'.cont2
    gen bartik_placebo_f`k' = base_gold_sh_2000 * cont2_f`k'
    gen lbartik_placebo_f`k' = log(1 + bartik_placebo_f`k')
}
reghdfe taxa_homicidio_geral ///
    lbartik_placebo_f2 lbartik_placebo_f3 lbartik_placebo_f4 lbartik_placebo_f5 ///
    lpop empregos_pc, ///
    absorb(codmun ano) cluster(codmun)

test lbartik_placebo_f2 lbartik_placebo_f3 lbartik_placebo_f4 lbartik_placebo_f5
local Fj = r(F)
local pj = r(p)
cd "$out"
outreg2 using "placebo_future_shifts.xls", replace addtext(Municipality FE, Yes, Year FE, Yes) ///
    addstat(Joint F-test, `Fj', Joint F-test p-value, `pj')

* Label placebo shifts clearly
label variable lbartik_placebo_f2 "t+2"
label variable lbartik_placebo_f3 "t+3"
label variable lbartik_placebo_f4 "t+4"
label variable lbartik_placebo_f5 "t+5"

coefplot, keep(lbartik_placebo_f2 lbartik_placebo_f3 ///
               lbartik_placebo_f4 lbartik_placebo_f5) ///
    vertical yline(0, lpattern(dash) lcolor(gray)) ///
    ciopts(recast(rcap)) msymbol(D) mcolor(cranberry) lcolor(cranberry) ///
    xtitle("Periods ahead (placebo)") ytitle("Coefficient on future Bartik") ///
    xlabel(1 "t+2" 2 "t+3" 3 "t+4" 4 "t+5") ///
    graphregion(color(white)) xsize(6) ysize(4)
graph export "coefplot_placebo_future.pdf", replace








/*===========================================================================
  6. ALTERNATIVE SPECIFICATIONS AND SAMPLES (appendix tables)
===========================================================================*/

/* --- 6a. TABLES A10 and A11: international USD gold price ------------------ */
cd "$out"
clear
use panel_replication

g bartik_garimpo_usd =  base_garimpo_km2_2000  * lprice
g lbartik_garimpo_usd = ln(1+bartik_garimpo_usd)

* TABLE A10: reduced form, garimpo USD Bartik
foreach z in taxa_homicidio_geral taxa_homicidio_branca taxa_homicidio_preta_parda taxa_homicidio_indigena  lfam lconf {
    reghdfe `z' lbartik_garimpo_usd  lpop empregos_pc     , absorb(codmun ano) cluster(codmun)
    outreg2 using "bartik_usd_prices.xls", append
}

* TABLE A11: IV with the garimpo USD Bartik (Panel A garimpo area / Panel B gold area)
foreach iv in lbartik_garimpo_usd   {
     foreach i in taxa_homicidio_geral taxa_homicidio_preta_parda lfam lconf {

        ivreghdfe `i' (lmb_garimpo  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun)

        outreg2 using "iv_mapbio_garimpo_usd.xls", append                             ///
                keep(lmb_garimpo)                           ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

        ivreghdfe `i' (lmb_gold  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun)

        outreg2 using "iv_mapbio_garimpo_usd.xls", append                             ///
                keep(lmb_gold)                                  ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))
      }
}

* first stages
reghdfe lmb_garimpo lbartik_garimpo_usd  lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "iv_mapbio_garimpo_usd.xls", append                             ///
                keep(lbartik_garimpo_usd)                           ///
                addtext(Municipality FE, Yes, Year FE, Yes)

reghdfe lmb_gold  lbartik_garimpo_usd  lpop empregos_pc  , absorb(codmun ano) cluster(codmun)
        outreg2 using "iv_mapbio_garimpo_usd.xls", append                             ///
                keep(lbartik_garimpo_usd)                           ///
                addtext(Municipality FE, Yes, Year FE, Yes)


/* --- 6b. TABLE A12: cocaine-corridor exposure -------------------------------
   Source: Pereira, Pucci & Soares - cocaine corridor exposure via fluvial routes
   var_exposure = ln(sum of cocaine production in origin countries - Bolivia,
   Colombia, Peru - of fluvial routes passing through each municipality), by year.
   Zero for municipalities not located on any documented cocaine route.
   NOTE: only municipalities that match the cocaine exposure dataset are kept
   (keep if _merge==3); compare N with the main specification.               */
cd "$out"
clear
use panel_replication


label variable var_exposure ///
    "Exposure to Cocaine Routes (ln cocaine production, origin countries of fluvial routes)"

di "Cocaine exposure sample: " _N " observations"

foreach trt in lbartik_garimpo_2000 lbartik_gold_2000 {
    foreach z in taxa_homicidio_geral lfam lconf {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' var_exposure lpop empregos_pc, ///
            absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_`trt'_cocaine_control.xls", append ///
            addstat(Control Mean, `Cm') ///
            addtext(Municipality FE, Yes, Year FE, Yes, ///
                    Cocaine exposure control, Yes)
    }
}


/* --- 6c. TABLES A13 (CPT sample) and A14 (Legal Amazon): restricted-sample IV */
* Table A14 - Legal Amazon
cd "$out"
clear
use panel_replication
xtset codmun ano
drop if ano>2019
capture drop ouro_ever2
g ouro_ever2 = (n_ocorrencias_ouro>0)


 * Legal Amazon states
capture drop amazonia_legal
gen amazonia_legal = inlist(sigla_uf, "AC","AM","AP","MA","MT","PA","RO","RR","TO")
keep if amazonia_legal == 1

foreach i in taxa_homicidio_geral n_homicidio_total lfam lconf {

    ivreghdfe `i' (lmb_garimpo  =  lbartik_garimpo_2000) lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
    outreg2 using "iv_mapbio_garimpo_amazo_legal.xls", append                             ///
            keep(lmb_garimpo)                           ///
            addtext(Municipality FE, Yes, Year FE, Yes) ///
            addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

    ivreghdfe `i' (lmb_gold  = lbartik_gold_2000) lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
    outreg2 using "iv_mapbio_garimpo_amazo_legal.xls", append                             ///
            keep(lmb_gold )                           ///
            addtext(Municipality FE, Yes, Year FE, Yes) ///
            addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))
}

* Table A13 - municipalities with at least one recorded agrarian conflict
cd "$out"
clear
use panel_replication
xtset codmun ano
drop if ano>2019
capture drop ouro_ever2
g ouro_ever2 = (n_ocorrencias_ouro>0)

* Cities with at least one recorded conflict in any year
capture drop ever_conflict
by codmun, sort: egen ever_conflict = max(num_con > 0 & num_con < .)
keep if ever_conflict == 1

foreach i in taxa_homicidio_geral n_homicidio_total lfam lconf {

    ivreghdfe `i' (lmb_garimpo  =  lbartik_garimpo_2000) lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
    outreg2 using "iv_mapbio_garimpo_cpt_only.xls", append                             ///
            keep(lmb_garimpo)                           ///
            addtext(Municipality FE, Yes, Year FE, Yes) ///
            addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

    ivreghdfe `i' (lmb_gold  = lbartik_gold_2000) lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
    outreg2 using "iv_mapbio_garimpo_cpt_only.xls", append                             ///
            keep(lmb_gold )                           ///
            addtext(Municipality FE, Yes, Year FE, Yes) ///
            addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))
}


/* --- 6d. TABLES A15 (protected land) and A16 (Indigenous territory): RF, all
           baseline years                                                       */
cd "$out"
clear
use panel_replication


* Table A16 - cities with some recognized Indigenous territory
foreach trt in lbartik_gold_2000 lbartik_garimpo_2000 lbartik_gold_1995 lbartik_garimpo_1995 lbartik_gold_1990 lbartik_garimpo_1990  lbartik_gold_1985 lbartik_garimpo_1985  {
    foreach z in taxa_homicidio_geral taxa_homicidio_indigena   lfam lconf {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc if prop_indig > 0  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_indigena.xls", append addstat(Control Mean, `Cm')
    }
}

* Table A15 - cities with some environmentally protected land (conservation units)
foreach trt in lbartik_gold_2000 lbartik_garimpo_2000 lbartik_gold_1995 lbartik_garimpo_1995 lbartik_gold_1990 lbartik_garimpo_1990  lbartik_gold_1985 lbartik_garimpo_1985  {
    foreach z in taxa_homicidio_geral taxa_homicidio_indigena   lfam lconf {
        sum `z' if mb_total_km2 == 0
        local Cm = r(mean)
        reghdfe `z' `trt' lpop empregos_pc if prop_unids > 0  , absorb(codmun ano) cluster(codmun)
        outreg2 using "rf_protegida.xls", append addstat(Control Mean, `Cm')
    }
}


/* --- 6e. TABLE A17: IV of gold-mining area, by geological gold occurrence --- */
* Panel "Non-gold municipalities"
cd "$out"
clear
use panel_replication
xtset codmun ano
drop if ano>2019
capture drop ouro_ever2
g ouro_ever2 = (n_ocorrencias_ouro>0)


keep if ouro_ever2==0

foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 {
     foreach i in taxa_homicidio_geral taxa_homicidio_indigena lfam lconf {

        ivreghdfe `i' (lmb_gold  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
        outreg2 using "iv_mapbio_main_nogold.xls", append                             ///
                keep(lmb_gold)                              ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

        }
}

* Panel "Gold municipalities only"
cd "$out"
clear
use panel_replication
xtset codmun ano
drop if ano>2019
capture drop ouro_ever2
g ouro_ever2 = (n_ocorrencias_ouro>0)
keep if ouro_ever2==1

foreach iv in lbartik_gold_2000 lbartik_garimpo_2000 {
     foreach i in taxa_homicidio_geral taxa_homicidio_indigena lfam lconf {

        ivreghdfe `i' (lmb_gold  =  `iv') lpop empregos_pc  , absorb(codmun ano) cluster(codmun) first
        outreg2 using "iv_mapbio_main_yes_gold.xls", append                             ///
                keep(lmb_gold)                              ///
                addtext(Municipality FE, Yes, Year FE, Yes) ///
                addstat(KP rk Wald F-stat, e(rkf), KP rk LM (p-val), e(idp), CD Wald F-stat, e(cdf))

        }
}


/* --- 6f. TABLE A18: uninstrumented associations (municipality + year FE) ---- */
cd "$out"
clear
use panel_replication


* MapBiomas mining area (industrial, gold, garimpo)
foreach z in taxa_homicidio_geral  lfam lconf {
    sum  `z' if mb_total_km2 == 0
    local Cm = r(mean)
    reghdfe `z' lmb_industrial lpop empregos_pc, absorb(codmun ano) cluster(codmun)
    outreg2 using "rf_mb_total_fe.xls", append addstat(Control Mean, `Cm')

    reghdfe  `z' lmb_gold lpop empregos_pc, absorb(codmun ano) cluster(codmun)
    outreg2 using "rf_mb_total_fe.xls", append addstat(Control Mean, `Cm')

    reghdfe  `z' lmb_garimpo lpop empregos_pc, absorb(codmun ano) cluster(codmun)
    outreg2 using "rf_mb_total_fe.xls", append addstat(Control Mean, `Cm')
}

* ANM-registered (cumulative) area
foreach z in taxa_homicidio_geral lfam lconf {
    sum  `z' if accum_atv_km2 == 0
    local Cm = r(mean)
    reghdfe `z' laccum_atv_km2 lpop empregos_pc, absorb(codmun ano) cluster(codmun)
    outreg2 using "rf_acumulado_fe.xls", append addstat(Control Mean, `Cm')
}


/*===========================================================================
  7. ROBUSTNESS TO EXTREME BASELINE SHARES (CALLAWAY ET AL.)
     -> TABLE A19 (three panels) and FIGURE A7 (binscatters)
     Shares: base_garimpo_sh_2000. Thresholds p95 / p99 are computed on
     positive shares only. All three blocks start from the unrestricted panel
     (regressions drop missing regressors automatically).
===========================================================================*/

* ---- Panel A: homicide rate --------------------------------------------------
cd "$out"
use panel_replication, clear

local share "base_garimpo_sh_2000"
local bartik "lbartik_garimpo_2000"
local outcome "taxa_homicidio_geral"

sum `share' if `share' > 0 , detail
local p95 = r(p95)
local p99 = r(p99)

* Rank-based instrument (robust to extreme shares, as per Callaway et al.)
egen rank_sh = rank(base_garimpo_sh_2000)  if ano==2004
by codmun, sort: egen m_rank_sh = max(rank_sh)
gen bartik_rank = m_rank_sh * cont3
gen lbartik_rank = ln(1 + bartik_rank)
replace lbartik_rank = 0 if lbartik_rank==.

eststo clear

* A. Baseline (Full Sample)
reghdfe `outcome' `bartik' lpop empregos_pc, absorb(codmun ano) cluster(codmun)
eststo full_sample

* B. Trimmed Sample (Excluding top 5% of positive shares)
reghdfe `outcome' `bartik' lpop empregos_pc if `share' < `p95', absorb(codmun ano) cluster(codmun)
eststo excl_p95

* C. Highly Trimmed Sample (Excluding top 1% of positive shares)
reghdfe `outcome' `bartik' lpop empregos_pc if `share' < `p99', absorb(codmun ano) cluster(codmun)
eststo excl_p99

* D. Rank-Bartik (Testing if results depend on share magnitude)
reghdfe taxa_homicidio_geral lbartik_rank lpop empregos_pc, absorb(codmun ano) cluster(codmun)
eststo rank_model

outreg2 [full_sample excl_p95 excl_p99 rank_model] using "robustness_callaway_shares.xls", ///
    replace label addtext(Municipality FE, Yes, Year FE, Yes) ///
    addstat(P95_Threshold, `p95', P99_Threshold, `p99')

* Figure A7(a): binscatter (requires 'binscatter': ssc install binscatter)
binscatter `outcome' `bartik', line(connect) ///
    xtitle("Log Bartik Instrument") ytitle("Homicide Rate")
graph export "binscatter_dose_response.pdf", replace


* ---- Panel B: number of affected families (lfam) -----------------------------
cd "$out"
use panel_replication, clear

local share "base_garimpo_sh_2000"
local bartik "lbartik_garimpo_2000"
local outcome "lfam"

sum `share' if `share' > 0 , detail
local p95 = r(p95)
local p99 = r(p99)

egen rank_sh = rank(`share') if ano == 2001
by codmun, sort: egen m_rank_sh = max(rank_sh)
gen bartik_rank = m_rank_sh * cont3
gen lbartik_rank = ln(1 + bartik_rank)

eststo clear

reghdfe `outcome' `bartik' lpop empregos_pc, absorb(codmun ano) cluster(codmun)
eststo full_sample

reghdfe `outcome' `bartik' lpop empregos_pc if `share' < `p95', absorb(codmun ano) cluster(codmun)
eststo excl_p95

reghdfe `outcome' `bartik' lpop empregos_pc if `share' < `p99', absorb(codmun ano) cluster(codmun)
eststo excl_p99

reghdfe `outcome' bartik_rank lpop empregos_pc, absorb(codmun ano) cluster(codmun)
eststo rank_model

outreg2 [full_sample excl_p95 excl_p99 rank_model] using "robustness_callaway_fam.xls", ///
    replace label addtext(Municipality FE, Yes, Year FE, Yes) ///
    addstat(P95_Threshold, `p95', P99_Threshold, `p99')

* Figure A7(c)
binscatter `outcome' `bartik', line(connect) ///
    xtitle("Log Bartik Instrument") ytitle("Number of Families")
graph export "binscatter_dose_response3.pdf", replace


* ---- Panel C: number of agrarian conflicts (lconf) ---------------------------
cd "$out"
use panel_replication, clear

local share "base_garimpo_sh_2000"
local bartik "lbartik_garimpo_2000"
local outcome "lconf"

sum `share' if `share' > 0 , detail
local p95 = r(p95)
local p99 = r(p99)

egen rank_sh = rank(`share') if ano == 2001
by codmun, sort: egen m_rank_sh = max(rank_sh)
gen bartik_rank = m_rank_sh * cont3
gen lbartik_rank = ln(bartik_rank)

eststo clear

reghdfe `outcome' `bartik' lpop empregos_pc, absorb(codmun ano) cluster(codmun)
eststo full_sample

reghdfe `outcome' `bartik' lpop empregos_pc if `share' < `p95', absorb(codmun ano) cluster(codmun)
eststo excl_p95

reghdfe `outcome' `bartik' lpop empregos_pc if `share' < `p99', absorb(codmun ano) cluster(codmun)
eststo excl_p99

reghdfe `outcome' bartik_rank lpop empregos_pc, absorb(codmun ano) cluster(codmun)
eststo rank_model

outreg2 [full_sample excl_p95 excl_p99 rank_model] using "robustness_callaway_num_con.xls", ///
    replace label addtext(Municipality FE, Yes, Year FE, Yes) ///
    addstat(P95_Threshold, `p95', P99_Threshold, `p99')

* Figure A7(b)
binscatter `outcome' `bartik', line(connect) ///
    xtitle("Log Bartik Instrument") ytitle("Number of Conflicts")
graph export "binscatter_dose_response2.pdf", replace

 

/*===========================================================================
  END OF FILE
===========================================================================*/
di "=== Data_analysis_paper_only.do completed successfully ==="
