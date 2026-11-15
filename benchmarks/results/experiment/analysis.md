# Analysis of the section 6 experiment

10 runs. Values per run are listed in run order; median; range; rule outcome.

Flags (whole-block time above three times the median of its condition across runs):

- none

## Primary statistics, per condition (ns/op)

| condition | control | statistic | per run | median | range | rule |
|---|---|---|---|---|---|---|
| batched_chrono@10 | control_batched | whole-block minus control | -8.6 +12.8 +13.6 +10.4 +9.5 +32.0 +15.4 +16.1 +20.3 +9.8 | +13.19 | -8.65 to +31.98 | not resolved at n=10 |
| batched_chrono@10 | control_batched | reported minus control | -12.3 +9.1 +9.8 +6.5 +5.7 +28.3 +11.0 +9.3 +16.6 +6.2 | +9.17 | -12.27 to +28.27 | not resolved at n=10 |
| batched_chrono@10 | control_batched | whole-block minus reported | +3.6 +3.7 +3.7 +3.9 +3.8 +3.7 +4.5 +6.8 +3.7 +3.6 | +3.74 | +3.61 to +6.83 | resolved |
| batched_rdtsc@10 | control_batched | whole-block minus control | +8.8 -1.7 -1.2 +2.8 -0.8 +1.4 +3.4 +2.6 -3.6 +3.4 | +1.99 | -3.61 to +8.78 | not resolved at n=10 |
| batched_rdtsc@10 | control_batched | reported minus control | +7.3 -3.1 -2.6 +1.4 -2.3 -0.0 +1.8 +1.1 -5.1 +2.0 | +0.54 | -5.07 to +7.33 | not resolved at n=10 |
| batched_rdtsc@10 | control_batched | whole-block minus reported | +1.5 +1.5 +1.5 +1.4 +1.4 +1.4 +1.6 +1.5 +1.5 +1.4 | +1.45 | +1.44 to +1.56 | resolved |
| batched_rdtsc@100 | control_batched | whole-block minus control | +1.4 +0.2 -0.3 -7.9 -0.2 -3.7 -10.5 -4.7 -1.0 -0.9 | -0.97 | -10.54 to +1.40 | not resolved at n=10 |
| batched_rdtsc@100 | control_batched | reported minus control | +1.2 +0.1 -0.4 -8.0 -0.4 -3.8 -10.7 -4.9 -1.2 -1.1 | -1.13 | -10.69 to +1.25 | not resolved at n=10 |
| batched_rdtsc@100 | control_batched | whole-block minus reported | +0.1 +0.2 +0.2 +0.1 +0.2 +0.2 +0.2 +0.2 +0.2 +0.2 | +0.15 | +0.15 to +0.16 | resolved |
| batched_chrono@50 | control_batched | whole-block minus control | -2.8 -5.3 +45.1 -12.3 +12.8 +3.6 -3.9 +6.9 -3.1 +11.1 | +0.42 | -12.30 to +45.15 | not resolved at n=10 |
| batched_chrono@50 | control_batched | reported minus control | -3.5 -6.0 +44.3 -13.0 +12.0 +2.9 -4.6 +6.2 -4.3 +10.3 | -0.31 | -13.02 to +44.28 | not resolved at n=10 |
| batched_chrono@50 | control_batched | whole-block minus reported | +0.7 +0.7 +0.9 +0.7 +0.7 +0.7 +0.7 +0.7 +1.2 +0.7 | +0.74 | +0.73 to +1.16 | resolved |
| batched_rdtsc@25 | control_batched | whole-block minus control | +2.6 +2.2 +0.8 -62.6 +5.5 -10.4 +0.9 +5.1 -4.8 +9.1 | +1.55 | -62.61 to +9.12 | not resolved at n=10 |
| batched_rdtsc@25 | control_batched | reported minus control | +2.1 +1.6 +0.3 -63.2 +5.0 -11.0 +0.4 +4.5 -5.4 +8.5 | +0.97 | -63.21 to +8.53 | not resolved at n=10 |
| batched_rdtsc@25 | control_batched | whole-block minus reported | +0.6 +0.6 +0.6 +0.6 +0.6 +0.6 +0.6 +0.6 +0.6 +0.6 | +0.58 | +0.58 to +0.59 | resolved |
| per_op_rdtscp_lfence_inside | control_flat | whole-block minus control | +165.1 +160.4 +164.7 +192.0 +159.6 +155.8 +259.1 +127.4 +169.7 +159.7 | +162.57 | +127.40 to +259.08 | resolved |
| per_op_rdtscp_lfence_inside | control_flat | reported minus control | +123.7 +120.9 +126.0 +149.5 +119.3 +117.4 +216.9 +88.3 +130.0 +121.2 | +122.48 | +88.35 to +216.93 | resolved |
| per_op_rdtscp_lfence_inside | control_flat | whole-block minus reported | +41.4 +39.5 +38.7 +42.6 +40.3 +38.4 +42.1 +39.1 +39.7 +38.5 | +39.58 | +38.40 to +42.56 | resolved |
| batched_chrono@25 | control_batched | whole-block minus control | +11.8 +5.2 +0.9 +6.6 +3.7 +9.9 +5.8 +22.4 +13.2 +3.4 | +6.18 | +0.92 to +22.35 | resolved |
| batched_chrono@25 | control_batched | reported minus control | +10.4 +3.6 -0.5 +5.1 +2.2 +8.3 +4.4 +20.9 +11.2 +1.9 | +4.72 | -0.53 to +20.89 | not resolved at n=10 |
| batched_chrono@25 | control_batched | whole-block minus reported | +1.5 +1.6 +1.5 +1.5 +1.4 +1.6 +1.4 +1.5 +2.0 +1.4 | +1.46 | +1.45 to +1.96 | resolved |
| batched_rdtsc@1 | control_batched | whole-block minus control | +17.3 +30.7 +31.6 +33.8 +27.3 +34.7 +34.5 +36.3 +19.3 +26.2 | +31.14 | +17.32 to +36.27 | resolved |
| batched_rdtsc@1 | control_batched | reported minus control | +2.6 +16.1 +16.8 +18.9 +12.2 +19.7 +19.5 +21.5 +4.5 +11.7 | +16.45 | +2.65 to +21.45 | resolved |
| batched_rdtsc@1 | control_batched | whole-block minus reported | +14.7 +14.6 +14.7 +14.9 +15.1 +15.0 +15.0 +14.8 +14.8 +14.6 | +14.81 | +14.58 to +15.08 | resolved |
| per_op_rdtscp_lfence_outside | control_flat | whole-block minus control | +225.8 +220.1 +186.4 +189.0 +152.5 +151.2 +191.6 +165.6 +152.3 +156.9 | +176.02 | +151.22 to +225.80 | resolved |
| per_op_rdtscp_lfence_outside | control_flat | reported minus control | +184.2 +180.0 +144.1 +150.8 +114.0 +112.6 +149.2 +126.7 +114.0 +119.1 | +135.35 | +112.57 to +184.17 | resolved |
| per_op_rdtscp_lfence_outside | control_flat | whole-block minus reported | +41.6 +40.1 +42.4 +38.2 +38.5 +38.7 +42.5 +39.0 +38.3 +37.9 | +38.81 | +37.89 to +42.47 | resolved |
| per_op_chrono_outside | control_flat | whole-block minus control | +149.5 +171.1 +160.3 +157.6 +158.1 +190.7 +153.2 +160.9 +134.8 +221.5 | +159.21 | +134.79 to +221.53 | resolved |
| per_op_chrono_outside | control_flat | reported minus control | +111.0 +133.9 +120.7 +120.4 +121.1 +152.4 +114.3 +123.4 +97.4 +184.4 | +120.93 | +97.44 to +184.40 | resolved |
| per_op_chrono_outside | control_flat | whole-block minus reported | +38.5 +37.2 +39.6 +37.2 +37.0 +38.3 +39.0 +37.5 +37.4 +37.1 | +37.44 | +36.98 to +39.59 | resolved |
| batched_rdtsc@5 | control_batched | whole-block minus control | +8.5 +4.6 +10.8 +5.4 +8.2 +0.6 +6.5 +4.6 +4.4 +1.7 | +4.99 | +0.58 to +10.81 | resolved |
| batched_rdtsc@5 | control_batched | reported minus control | +5.6 +1.7 +7.8 +2.5 +5.4 -2.3 +3.6 +1.6 +1.3 -1.2 | +2.09 | -2.31 to +7.79 | not resolved at n=10 |
| batched_rdtsc@5 | control_batched | whole-block minus reported | +2.9 +2.9 +3.0 +2.9 +2.9 +2.9 +2.9 +3.0 +3.1 +2.9 | +2.91 | +2.89 to +3.15 | resolved |
| per_op_chrono_inside | control_flat | whole-block minus control | +167.4 +239.7 +149.7 +154.8 +157.8 +170.9 +148.6 +135.1 +171.9 +137.4 | +156.33 | +135.06 to +239.68 | resolved |
| per_op_chrono_inside | control_flat | reported minus control | +128.3 +194.6 +113.0 +116.9 +121.0 +134.4 +111.8 +97.9 +132.4 +100.8 | +118.97 | +97.94 to +194.64 | resolved |
| per_op_chrono_inside | control_flat | whole-block minus reported | +39.1 +45.0 +36.7 +37.9 +36.8 +36.5 +36.8 +37.1 +39.5 +36.7 | +36.97 | +36.51 to +45.04 | resolved |
| batched_chrono@5 | control_batched | whole-block minus control | +13.9 +24.7 +20.5 +31.1 +22.8 +24.0 +23.0 +26.3 +20.4 +32.9 | +23.48 | +13.85 to +32.89 | resolved |
| batched_chrono@5 | control_batched | reported minus control | +6.4 +17.2 +13.1 +22.3 +15.4 +16.6 +15.7 +18.5 +13.1 +25.6 | +16.12 | +6.44 to +25.61 | resolved |
| batched_chrono@5 | control_batched | whole-block minus reported | +7.4 +7.5 +7.4 +8.8 +7.4 +7.4 +7.3 +7.8 +7.3 +7.3 | +7.40 | +7.28 to +8.81 | resolved |
| per_op_rdtsc_outside | control_flat | whole-block minus control | +31.2 +36.8 +25.1 +27.9 +35.9 +24.9 +49.8 +32.6 +33.6 +29.3 | +31.86 | +24.88 to +49.78 | resolved |
| per_op_rdtsc_outside | control_flat | reported minus control | +2.9 +6.6 -15.1 -1.3 +8.0 -1.7 +11.6 +2.1 +8.5 +0.2 | +2.52 | -15.12 to +11.60 | not resolved at n=10 |
| per_op_rdtsc_outside | control_flat | whole-block minus reported | +28.3 +30.3 +40.2 +29.1 +27.8 +26.6 +38.2 +30.4 +25.1 +29.1 | +29.14 | +25.10 to +40.19 | resolved |
| batched_rdtsc@50 | control_batched | whole-block minus control | -23.2 +10.2 -0.3 -16.4 -0.6 +0.9 +4.7 -1.1 +2.0 -0.2 | -0.29 | -23.19 to +10.18 | not resolved at n=10 |
| batched_rdtsc@50 | control_batched | reported minus control | -23.5 +9.9 -0.6 -16.7 -0.8 +0.6 +4.4 -1.4 +1.7 -0.5 | -0.58 | -23.48 to +9.87 | not resolved at n=10 |
| batched_rdtsc@50 | control_batched | whole-block minus reported | +0.3 +0.3 +0.3 +0.3 +0.3 +0.3 +0.3 +0.3 +0.3 +0.3 | +0.30 | +0.29 to +0.31 | resolved |
| batched_chrono@100 | control_batched | whole-block minus control | -0.8 +0.3 +2.6 -0.3 -3.6 +2.1 -2.8 -8.3 +2.7 +3.1 | +0.04 | -8.28 to +3.12 | not resolved at n=10 |
| batched_chrono@100 | control_batched | reported minus control | -1.5 -0.0 +2.2 -0.6 -4.0 +1.7 -3.2 -8.6 +2.3 +2.8 | -0.33 | -8.65 to +2.75 | not resolved at n=10 |
| batched_chrono@100 | control_batched | whole-block minus reported | +0.6 +0.4 +0.4 +0.4 +0.4 +0.4 +0.4 +0.4 +0.4 +0.4 | +0.37 | +0.37 to +0.64 | resolved |
| batched_chrono@1 | control_batched | whole-block minus control | +150.8 +150.6 +138.8 +175.8 +162.4 +158.5 +141.2 +146.0 +130.8 +358.8 | +150.72 | +130.79 to +358.76 | resolved |
| batched_chrono@1 | control_batched | reported minus control | +113.0 +112.5 +101.2 +136.9 +125.2 +119.5 +104.0 +108.8 +93.6 +316.2 | +112.77 | +93.64 to +316.21 | resolved |
| batched_chrono@1 | control_batched | whole-block minus reported | +37.8 +38.1 +37.6 +38.9 +37.2 +39.0 +37.2 +37.2 +37.1 +42.6 | +37.70 | +37.15 to +42.55 | resolved |
| per_op_rdtsc_inside | control_flat | whole-block minus control | +18.7 +23.0 +36.1 +26.3 +95.4 +36.1 +17.5 +24.0 +25.5 +24.2 | +24.86 | +17.48 to +95.40 | resolved |
| per_op_rdtsc_inside | control_flat | reported minus control | -8.5 -1.6 +2.9 -0.6 +64.3 +8.3 -7.1 -2.6 +1.7 -2.6 | -1.11 | -8.52 to +64.27 | not resolved at n=10 |
| per_op_rdtsc_inside | control_flat | whole-block minus reported | +27.2 +24.5 +33.2 +27.0 +31.1 +27.8 +24.6 +26.6 +23.9 +26.8 | +26.88 | +23.85 to +33.21 | resolved |

## Pre-registered contrasts

| question | contrast | unit | per run | median | range | rule |
|---|---|---|---|---|---|---|
| Q1 reported | per_op_chrono_inside minus batched_chrono@1 | ns | +23.5 +71.3 +9.7 -68.4 -3.3 +8.1 +4.9 +5.7 +27.9 -308.2 | +6.90 | -308.22 to +71.30 | not resolved at n=10 |
| Q1 whole-block | per_op_chrono_inside minus batched_chrono@1 | ns | +24.7 +78.2 +8.7 -69.4 -3.7 +5.5 +4.5 +5.6 +30.2 -314.1 | +5.57 | -314.09 to +78.24 | not resolved at n=10 |
| Q1 reported | per_op_chrono_inside minus batched_chrono@25 | ns | +129.3 +195.0 +111.2 +112.1 +121.6 +120.5 +112.3 +92.7 +120.1 +98.2 | +116.20 | +92.67 to +194.99 | resolved |
| Q1 whole-block | per_op_chrono_inside minus batched_chrono@25 | ns | +166.9 +238.4 +146.4 +148.6 +157.0 +155.4 +147.6 +128.3 +157.6 +133.4 | +151.98 | +128.33 to +238.42 | resolved |
| Q1 reported | per_op_rdtsc_inside minus batched_rdtsc@1 | ns | -17.2 -18.7 +1.0 -14.1 +58.1 -17.1 -17.0 -25.3 -18.1 -10.6 | -17.08 | -25.32 to +58.08 | not resolved at n=10 |
| Q1 whole-block | per_op_rdtsc_inside minus batched_rdtsc@1 | ns | -4.6 -8.8 +19.5 -2.0 +74.1 -4.4 -7.4 -13.6 -9.0 +1.6 | -4.50 | -13.58 to +74.12 | not resolved at n=10 |
| Q1 reported | per_op_rdtsc_inside minus batched_rdtsc@25 | ns | +0.8 +1.0 +20.2 -0.9 +66.6 +13.5 +9.7 -7.4 +0.8 -10.3 | +0.93 | -10.34 to +66.60 | not resolved at n=10 |
| Q1 whole-block | per_op_rdtsc_inside minus batched_rdtsc@25 | ns | +27.5 +25.0 +52.8 +25.5 +97.1 +40.7 +33.7 +18.6 +24.1 +15.8 | +26.49 | +15.84 to +97.13 | resolved |
| Q2 reported | per_op_chrono_inside minus per_op_chrono_outside | ns | +21.8 +56.5 -16.7 -6.8 +0.2 -13.6 -7.4 -13.5 +39.9 -98.7 | -7.12 | -98.71 to +56.46 | not resolved at n=10 |
| Q2 whole-block | per_op_chrono_inside minus per_op_chrono_outside | ns | +22.4 +64.3 -19.6 -6.1 +0.0 -15.4 -9.6 -13.9 +42.0 -99.2 | -7.84 | -99.16 to +64.32 | not resolved at n=10 |
| Q2 reported | per_op_rdtsc_inside minus per_op_rdtsc_outside | ticks | -8.5 -56.6 -143.5 -12.8 +142.9 +39.2 -78.8 -17.9 -27.0 -7.8 | -15.32 | -143.46 to +142.95 | not resolved at n=10 |
| Q2 whole-block | per_op_rdtsc_inside minus per_op_rdtsc_outside | ns | -4.6 -29.3 -66.9 -7.5 +63.0 +17.6 -46.5 -11.3 -12.5 -5.6 | -9.40 | -66.86 to +62.97 | not resolved at n=10 |
| Q2 reported | per_op_rdtscp_lfence_inside minus per_op_rdtscp_lfence_outside | ticks | -156.6 -170.5 -14.4 +7.9 +18.8 -21.4 +127.9 -41.0 +44.7 -27.2 | -17.88 | -170.52 to +127.91 | not resolved at n=10 |
| Q2 whole-block | per_op_rdtscp_lfence_inside minus per_op_rdtscp_lfence_outside | ns | -65.6 -71.9 -9.6 +7.6 +9.6 -9.2 +53.1 -17.0 +20.0 -10.8 | -9.41 | -71.85 to +53.07 | not resolved at n=10 |
| Q2 loop shape (reported, ticks) | batched_rdtsc@1 minus per_op_rdtsc_inside | ticks | +41.2 +44.8 -2.5 +33.7 -139.1 +41.0 +40.8 +60.6 +43.4 +25.5 | +40.92 | -139.12 to +60.65 | not resolved at n=10 |
| Q3 reported | batched_chrono@1 minus batched_rdtsc@1 | ns | +94.1 +108.2 +85.3 +167.2 +117.2 +102.2 +84.2 +83.8 +90.4 +398.1 | +98.16 | +83.83 to +398.13 | resolved |
| Q3 reported | batched_chrono@5 minus batched_rdtsc@5 | ns | +14.0 +15.4 +7.1 +23.4 +12.7 +10.6 +12.4 +18.4 +8.1 +24.7 | +13.34 | +7.13 to +24.71 | resolved |
| Q3 reported | batched_chrono@10 minus batched_rdtsc@10 | ns | +0.1 +5.6 +5.3 +13.3 +14.4 +28.7 +42.8 +12.3 +14.4 +5.3 | +12.82 | +0.09 to +42.84 | resolved |
| Q3 reported | batched_chrono@25 minus batched_rdtsc@25 | ns | +6.3 +4.3 +2.9 -0.1 +0.7 +20.4 +3.5 +14.8 +17.1 -8.0 | +3.89 | -7.97 to +20.43 | not resolved at n=10 |
| Q3 reported | batched_chrono@50 minus batched_rdtsc@50 | ns | +0.5 -3.0 +91.4 +3.1 +18.1 +6.7 -4.0 +5.0 -10.4 +14.9 | +4.09 | -10.41 to +91.41 | not resolved at n=10 |
| Q3 reported | batched_chrono@100 minus batched_rdtsc@100 | ns | +0.7 +2.8 +0.4 +7.7 +0.9 +0.4 +0.4 -2.2 -2.4 +0.6 | +0.50 | -2.36 to +7.72 | not resolved at n=10 |

## Question 4: control blocks (whole-block ns/op)

### control_flat

| run | values by position | range | sd |
|---|---|---|---|
| 1 | 63.1@16 61.3@18 63.2@25 71.0@27 61.7@28 67.8@30 67.9@34 70.6@36 60.7@41 66.2@43 59.7@53 83.0@55 | 59.7 to 83.0 | 6.23 |
| 2 | 79.9@1 69.1@3 61.2@7 60.7@9 65.8@10 58.9@12 58.9@25 75.6@27 71.3@28 81.6@30 57.9@38 68.1@40 | 57.9 to 81.6 | 7.97 |
| 3 | 157.1@1 145.3@3 64.9@8 81.8@10 59.4@11 65.7@13 57.2@29 57.2@31 64.2@35 68.0@37 79.1@38 70.1@40 | 57.2 to 157.1 | 32.40 |
| 4 | 58.7@7 68.5@9 66.2@13 72.9@15 68.1@16 68.5@18 62.0@19 62.8@21 58.2@25 69.2@27 56.0@41 62.0@43 | 56.0 to 72.9 | 5.03 |
| 5 | 59.0@10 65.2@12 57.7@22 61.7@24 59.4@28 65.4@30 59.7@31 60.2@33 68.4@47 58.4@49 55.6@50 58.6@52 | 55.6 to 68.4 | 3.58 |
| 6 | 55.4@10 57.4@12 58.2@13 58.3@15 64.6@22 75.8@24 60.3@34 71.6@36 68.7@37 60.5@39 59.2@49 63.9@51 | 55.4 to 75.8 | 6.03 |
| 7 | 104.7@1 67.4@3 59.9@10 83.9@12 58.5@16 63.4@18 61.2@19 89.5@21 55.8@41 62.3@43 59.0@44 69.0@46 | 55.8 to 104.7 | 14.49 |
| 8 | 92.1@1 82.4@3 65.4@7 62.9@9 61.6@29 71.4@31 62.6@32 71.2@34 62.3@35 69.8@37 77.5@53 79.4@55 | 61.6 to 92.1 | 9.21 |
| 9 | 54.1@19 54.7@21 55.3@22 56.2@24 54.9@28 55.4@30 56.3@35 61.3@37 59.9@44 60.2@46 54.4@50 62.4@52 | 54.1 to 62.4 | 2.85 |
| 10 | 56.7@4 65.6@6 65.1@7 80.8@9 77.3@28 62.5@30 55.4@34 57.2@36 57.7@37 58.1@39 56.1@43 65.2@45 | 55.4 to 80.8 | 8.00 |

across-run median of within-run sd: 7.10 ns; between-run sd of per-run means: 6.25 ns

The within-run spread is a description of drift and is not a bound on any paired difference.

### control_batched

| run | values by position | range | sd |
|---|---|---|---|
| 1 | 89.2@1 70.1@3 62.3@4 57.6@6 56.8@7 54.6@9 71.1@10 59.7@12 64.4@13 55.5@15 57.1@19 58.6@21 63.9@22 90.9@24 63.4@31 58.1@33 87.1@38 60.6@40 110.9@44 58.9@46 57.8@47 60.4@49 57.8@50 64.3@52 | 54.6 to 110.9 | 13.78 |
| 2 | 69.9@4 77.2@6 59.8@13 58.3@15 57.4@16 58.3@18 55.9@19 57.6@21 57.6@22 55.7@24 70.4@32 58.3@34 55.7@35 63.3@37 61.5@41 86.1@43 61.3@44 62.7@46 57.6@47 60.0@49 57.4@50 63.9@52 56.9@53 60.7@55 | 55.7 to 86.1 | 7.21 |
| 3 | 139.1@5 67.1@7 61.1@14 57.9@16 72.6@17 55.6@19 55.5@20 56.0@22 54.5@23 62.2@25 58.0@26 55.2@28 56.4@32 62.2@34 64.8@41 59.7@43 62.2@44 64.8@46 64.9@47 67.6@49 76.9@50 64.4@52 67.5@53 60.6@55 | 54.5 to 139.1 | 16.38 |
| 4 | 91.1@1 55.9@3 56.1@4 60.1@6 57.7@10 59.7@12 68.0@22 62.0@24 90.5@28 57.5@30 141.2@32 73.5@34 56.9@35 69.4@37 57.4@38 56.3@40 58.6@44 56.8@46 59.1@47 63.4@49 64.5@50 62.6@52 65.3@53 188.9@55 | 55.9 to 188.9 | 30.31 |
| 5 | 73.4@1 62.0@3 61.4@4 61.6@6 54.1@7 55.0@9 62.2@13 56.9@15 56.7@16 57.6@18 53.6@19 61.1@21 60.6@25 60.8@27 63.9@34 66.5@36 63.8@37 56.4@39 64.0@40 58.6@42 55.6@43 56.6@45 56.8@53 53.0@55 | 53.0 to 73.4 | 4.62 |
| 6 | 85.6@1 55.3@3 59.9@4 62.6@6 63.8@7 55.4@9 56.4@16 55.7@18 55.8@19 56.0@21 62.2@25 58.7@27 61.8@28 83.8@30 72.6@31 70.5@33 60.9@40 57.4@42 60.2@43 68.1@45 56.5@46 55.6@48 75.3@53 65.4@55 | 55.3 to 85.6 | 8.57 |
| 7 | 61.2@4 65.6@6 58.8@7 65.8@9 57.2@13 63.2@15 60.0@22 56.8@24 55.6@25 68.4@27 54.7@28 53.8@30 54.8@31 54.7@33 58.3@35 55.4@37 55.9@38 57.1@40 107.4@47 74.7@49 69.2@50 65.3@52 58.4@53 56.3@55 | 53.8 to 107.4 | 10.89 |
| 8 | 62.1@4 69.9@6 72.8@11 56.2@13 57.3@14 66.5@16 57.1@17 58.9@19 62.4@20 66.6@22 69.4@23 65.5@25 76.9@26 61.1@28 60.9@38 60.0@40 59.1@41 66.6@43 66.0@44 64.8@46 59.9@47 70.9@49 61.4@50 61.1@52 | 56.2 to 76.9 | 5.24 |
| 9 | 77.2@1 56.0@3 56.9@4 57.5@6 54.6@7 71.4@9 59.7@10 79.6@12 65.4@13 59.0@15 71.3@16 59.9@18 62.5@25 54.5@27 60.0@32 81.8@34 65.5@38 57.0@40 61.2@41 61.0@43 64.2@47 57.1@49 61.0@53 57.7@55 | 54.5 to 81.8 | 7.63 |
| 10 | 215.9@1 85.4@3 59.7@10 56.7@12 58.7@13 58.3@15 55.3@16 61.3@18 67.0@19 58.3@21 58.1@22 61.1@24 62.8@25 60.3@27 62.1@31 57.7@33 56.0@40 55.1@42 56.2@46 57.9@48 56.4@49 57.9@51 57.9@52 63.2@54 | 55.1 to 215.9 | 31.68 |

across-run median of within-run sd: 9.73 ns; between-run sd of per-run means: 3.29 ns

The within-run spread is a description of drift and is not a bound on any paired difference.


## Descriptive percentiles (native unit; per-operation rows are percentiles of instrumented single intervals, batched rows of batch means)

| condition | unit | kind | median of run p50 | p50 range | median of run p95 | median of run p99 | p99 range |
|---|---|---|---|---|---|---|---|
| batched_chrono@10 | ns | batch mean | 63.2 | 60.1 to 72.2 | 87.7 | 109.2 | 86.2 to 156.3 |
| batched_rdtsc@10 | ticks | batch mean | 132.0 | 129.6 to 144.0 | 189.6 | 241.2 | 211.2 to 268.8 |
| batched_rdtsc@100 | ticks | batch mean | 130.7 | 126.5 to 144.7 | 163.0 | 236.5 | 199.7 to 524.2 |
| batched_chrono@50 | ns | batch mean | 57.7 | 54.3 to 114.4 | 86.0 | 100.8 | 86.6 to 292.6 |
| batched_rdtsc@25 | ticks | batch mean | 130.1 | 126.7 to 138.2 | 164.6 | 224.6 | 164.2 to 260.2 |
| per_op_rdtscp_lfence_inside | ticks | single-op | 384.0 | 384.0 to 576.0 | 624.0 | 924.0 | 696.0 to 1536.0 |
| batched_chrono@25 | ns | batch mean | 57.9 | 55.7 to 74.5 | 74.1 | 91.0 | 77.0 to 136.7 |
| batched_rdtsc@1 | ticks | batch mean | 144.0 | 144.0 to 168.0 | 408.0 | 648.0 | 456.0 to 720.0 |
| per_op_rdtscp_lfence_outside | ticks | single-op | 396.0 | 384.0 to 504.0 | 828.0 | 1140.0 | 648.0 to 1560.0 |
| per_op_chrono_outside | ns | single-op | 150.0 | 141.0 to 220.0 | 316.0 | 451.0 | 251.0 to 641.0 |
| batched_rdtsc@5 | ticks | batch mean | 139.2 | 134.4 to 148.8 | 220.8 | 276.0 | 244.8 to 336.0 |
| per_op_chrono_inside | ns | single-op | 150.5 | 150.0 to 191.0 | 320.0 | 481.0 | 271.0 to 642.0 |
| batched_chrono@5 | ns | batch mean | 70.1 | 68.0 to 76.2 | 102.2 | 135.3 | 100.2 to 162.4 |
| per_op_rdtsc_outside | ticks | single-op | 72.0 | 72.0 to 168.0 | 432.0 | 672.0 | 504.0 to 1392.0 |
| batched_rdtsc@50 | ticks | batch mean | 130.3 | 124.8 to 143.0 | 156.7 | 222.2 | 147.8 to 318.7 |
| batched_chrono@100 | ns | batch mean | 55.2 | 53.5 to 57.2 | 72.4 | 93.7 | 76.1 to 107.0 |
| batched_chrono@1 | ns | batch mean | 150.5 | 150.0 to 360.0 | 285.5 | 416.0 | 310.0 to 882.0 |
| per_op_rdtsc_inside | ticks | single-op | 72.0 | 72.0 to 144.0 | 384.0 | 588.0 | 432.0 to 1320.0 |

## Frequency probe (adds per tick)

- run 1: 0.811@0 0.557@37 0.941@56
- run 2: 0.918@0 0.824@31 0.872@56
- run 3: 0.654@0 0.723@4 0.860@56
- run 4: 0.975@0 0.868@31 0.370@56
- run 5: 0.974@0 0.793@46 1.012@56
- run 6: 0.970@0 0.993@52 0.728@56
- run 7: 0.918@0 1.009@34 0.996@56
- run 8: 1.004@0 0.879@10 0.920@56
- run 9: 0.930@0 1.008@31 0.971@56
- run 10: 0.633@0 0.927@55 0.901@56
