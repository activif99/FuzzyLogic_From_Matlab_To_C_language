#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define MAX_ROWS 2000 // dataset size
#define TIME_INTERVAL 0.1
#define MOTOR_MAX_POWER 125.0
#define MOTOR_EFFICIENCY 0.98
#define VEHICLE_WEIGHT 1550.0
#define DRIVING_MODE 1.2
#define SIZE_A 73 // Total number of rules

#define NUM_OUTPUT_MFS 8

// ========== Membership Function Prototypes ==========
double trapmf(double x, double a, double b, double c, double d);
double gaussmf(double x, double sigma, double c);
double pimf(double x, double a, double b, double c, double d);
double defuzzification(double outputs[], double weights[], int size);

// ========== Membership Function Definitions ==========
// Trapezoidal Membership Function
double trapmf(double x, double a, double b, double c, double d) {
    if (x <= a || x >= d) return 0.0;
    else if (x >= b && x <= c) return 1.0;
    else if (x > a && x < b) return (x - a) / (b - a);
    else return (d - x) / (d - c);
}

// Gaussian Membership Function
double gaussmf(double x, double sigma, double c) {
    return exp(-pow(x - c, 2) / (2 * pow(sigma, 2)));
}

// Pi Membership Function
double pimf(double x, double a, double b, double c, double d) {
    if (x <= a || x >= d) return 0.0;
    else if (x > a && x < b) return 2 * pow((x - a) / (b - a), 2);
    else if (x >= b && x <= c) return 1.0;
    else if (x > c && x < d) return 1 - 2 * pow((x - c) / (d - c), 2);
    else return 0.0;
}

// Weighted Average Defuzzification
double defuzzification(double outputs[], double weights[], int size) {
    double numerator = 0.0;
    double denominator = 0.0;
    for (int i = 0; i < size; i++) {
        numerator += outputs[i];
        denominator += weights[i];
    }
    return numerator / denominator;
}


// ========== Main Program ==========
int main(void) {
    clock_t start_time, end_time;
    double time_taken;
    start_time = clock();

    const char *filePath = "C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/TripB10_B11_fuzzy_throttle_hvac_1.csv";
    //const char *filePath = "C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/TripA04_test_fuzzy_throttle_hvac.csv";
    
    FILE *file = fopen(filePath, "r");
    if (file == NULL) {
        perror("Error opening file");
        return EXIT_FAILURE;
    }

    // Variables to store dataset values
    double time[MAX_ROWS], velocity[MAX_ROWS], slope[MAX_ROWS];
    double temperature[MAX_ROWS], soc[MAX_ROWS];
    int rowCount = 0;

    // Skip header line
    char header[256];
    fgets(header, sizeof(header), file);

    // Read dataset into arrays

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        if (sscanf(line, "%*lf,%lf,%*lf,%lf,%*lf,%lf,%lf,%lf,%*lf,%*lf,%*lf,%*lf,%*lf,%*lf,%*lf,%*lf,%*lf", 
               &time[rowCount], &velocity[rowCount], &slope[rowCount], 
               &temperature[rowCount], &soc[rowCount]) == 5) {
            rowCount++;
            if (rowCount >= MAX_ROWS) break;
        } else {
            printf("Error parsing line: %s\n", line);
        }
    }

    // Variables for processing
    double previousVelocity = 0.0;

    FILE *outputFile = fopen("C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/results.csv", "w");
        if (outputFile == NULL) {
            perror("Error creating output file");
            return EXIT_FAILURE;
        }

        // Write headers
    fprintf(outputFile, "Time,Coefficient\n");

    // Adaptive Fuzzy Logic loop
    for (int i = 0; i < rowCount; i++) {
        // Read inputs from the dataset
        double temp = temperature[i];
        double soc_val = soc[i];
        double slope_val = slope[i];
        double current_velocity = velocity[i];
        double velocity_change = current_velocity - previousVelocity;
        previousVelocity = current_velocity;

        // === Step 2: Evaluate Membership Functions ===
        double temp_cold = trapmf(temp, -10, -5, 15, 25);
        double temp_normal = trapmf(temp, 15, 25, 25, 35);
        double temp_hot = trapmf(temp, 25, 35, 45, 50);

        double driving_mode_eco = pimf(DRIVING_MODE, 0, 0, 1, 1);
        double driving_mode_sport = pimf(DRIVING_MODE, 1.1, 1.1, 2.1, 2.1);
        double driving_mode_normal = pimf(DRIVING_MODE, 2.2, 2.2, 3.2, 3.2);
        double driving_mode_comfort = pimf(DRIVING_MODE, 3.3, 3.3, 4, 4);

        double weight_light = trapmf(VEHICLE_WEIGHT, 1300, 1300, 1467.5, 1635);
        double weight_normal = trapmf(VEHICLE_WEIGHT, 1467.5, 1635, 1635, 1802.5);
        double weight_heavy = trapmf(VEHICLE_WEIGHT, 1635, 1802.5, 2000, 2000);

        double slope_descent = trapmf(slope_val, -1.1, -1, -0.5, 0);
        double slope_flat = trapmf(slope_val, -0.5, 0, 0, 0.5);
        double slope_ascent = trapmf(slope_val, 0, 0.5, 1, 1.1);

        double soc_low = trapmf(soc_val, 0, 0, 20, 40);
        double soc_medium = trapmf(soc_val, 20, 40, 60, 80);
        double soc_high = trapmf(soc_val, 60, 80, 100, 110);

        double velocity_change_decelerating = trapmf(velocity_change, -100, -50, -50, -0.01);
        double velocity_change_steady = trapmf(velocity_change, -0.01, 0, 0, 0.01);
        double velocity_change_Accelerating = trapmf(velocity_change, 0.01, 50, 50, 100);

        double current_velocity_stopped = gaussmf(current_velocity, 0.01, 0);
        double current_velocity_slow = gaussmf(current_velocity, 5, 30);
        double current_velocity_medium = gaussmf(current_velocity, 20, 70);
        double current_velocity_fast = gaussmf(current_velocity, 30, 160);

        // === Step 2: Output Membership Functions ===

        double outputMFs[NUM_OUTPUT_MFS] = {
            0.0,  // Zero
            0.3,  // V.V.Small
            0.4,  // V.Small
            0.5,  // Small
            0.6,  // Normal
            0.75, // Large
            0.85, // V.Large
            0.98  // V.V.Large
        };

        double coeff_zero = outputMFs[0];
        double coeff_VVsmall = outputMFs[1];
        double coeff_Vsmall = outputMFs[2];
        double coeff_small = outputMFs[3];
        double coeff_normal = outputMFs[4];
        double coeff_large = outputMFs[5];
        double coeff_Vlarge = outputMFs[6];
        double coeff_VVlarge = outputMFs[7];



        // === Step 3: Apply Fuzzy Rules ===
        // Fuzzy rules for "Eco" Driving_Mode
        // === Rule 1a ===
        double firing_strength_1a = fmin(fmin(driving_mode_eco, soc_high), fmin(temp_cold, weight_light));
        double rule1a = firing_strength_1a * coeff_normal;
        // === Rule 1b ===
        double firing_strength_1b = fmin(fmin(driving_mode_eco, soc_high), fmin(temp_normal, weight_normal));
        double rule1b = firing_strength_1b * coeff_normal;
        // === Rule 1c ===
        double firing_strength_1c = fmin(fmin(driving_mode_eco, soc_high), fmin(temp_hot, weight_heavy));
        double rule1c = firing_strength_1c * coeff_large;
        // === Rule 1d ===
        double firing_strength_1d = fmin(fmin(driving_mode_eco, soc_high), fmin(slope_ascent, weight_heavy));
        double rule1d = firing_strength_1d * coeff_Vlarge;
        // === Rule 1e ===
        double firing_strength_1e = fmin(fmin(driving_mode_eco, soc_high), fmin(slope_ascent, weight_normal));
        double rule1e = firing_strength_1e * coeff_large;
        // === Rule 1f ===
        double firing_strength_1f = fmin(fmin(driving_mode_eco, soc_high), fmin(slope_ascent, weight_light));
        double rule1f = firing_strength_1f * coeff_normal;
        // === Rule 11a ===
        double firing_strength_11a = fmin(fmin(driving_mode_eco, soc_high), velocity_change_Accelerating);
        double rule11a = firing_strength_11a * coeff_normal;
        // === Rule 11b ===
        double firing_strength_11b = fmin(fmin(driving_mode_eco, soc_high), fmin(velocity_change_steady, weight_heavy));
        double rule11b = firing_strength_11b * coeff_normal;
        // === Rule 11c ===
        double firing_strength_11c = fmin(fmin(driving_mode_eco, soc_high), velocity_change_decelerating);
        double rule11c = firing_strength_11c * coeff_VVsmall;
        // === Rule 11d === 
        double firing_strength_11d = fmin(fmin(fmin(driving_mode_eco, soc_high), fmin( slope_ascent, velocity_change_steady)), weight_heavy);
        double rule11d = firing_strength_11d * coeff_Vlarge;
        // === Rule 2a ===
        double firing_strength_2a = fmin(fmin(driving_mode_eco, soc_medium), fmin(temp_cold, weight_light));
        double rule2a = firing_strength_2a * coeff_small;
        // === Rule 2b ===
        double firing_strength_2b = fmin(fmin(driving_mode_eco, soc_medium), fmin(temp_normal, weight_normal));
        double rule2b = firing_strength_2b * coeff_small;
        // === Rule 2c ===
        double firing_strength_2c = fmin(fmin(driving_mode_eco, soc_medium), fmin(temp_hot, weight_heavy));
        double rule2c = firing_strength_2c * coeff_normal;
        // === Rule 2d ===
        double firing_strength_2d = fmin(fmin(driving_mode_eco, soc_medium), slope_ascent);
        double rule2d = firing_strength_2d * coeff_large;
        // === Rule 22a ===
        double firing_strength_22a = fmin(fmin(driving_mode_eco, soc_medium), fmin( slope_ascent, velocity_change_Accelerating));
        double rule22a = firing_strength_22a * coeff_Vlarge;
        // === Rule 22c ===
        double firing_strength_22b = fmin(fmin(fmin(driving_mode_eco, soc_medium), fmin(velocity_change_steady, weight_heavy)), slope_ascent);
        double rule22b = firing_strength_22b * coeff_large;
        // === Rule 22d === 
        double firing_strength_22c = fmin(fmin(fmin(driving_mode_eco, soc_medium), fmin( slope_ascent, velocity_change_steady)), weight_light);
        double rule22c = firing_strength_22c * coeff_normal;
        // === Rule 22e === 
        double firing_strength_22d = fmin(fmin(driving_mode_eco, soc_medium), velocity_change_decelerating);
        double rule22d = firing_strength_22d * coeff_VVsmall;
        // === Rule 3a === 
        double firing_strength_3a = fmin(fmin(driving_mode_eco, soc_low), fmin(velocity_change_steady, slope_ascent));
        double rule3a = firing_strength_3a * coeff_normal;
        // === Rule 33a === 
        double firing_strength_33a = fmin(fmin(driving_mode_eco, soc_low), velocity_change_Accelerating);
        double rule33a = firing_strength_33a * coeff_normal;
        // === Rule 333a === 
        double firing_strength_333a = fmin(fmin(driving_mode_eco, soc_low), fmin(velocity_change_Accelerating, slope_ascent));
        double rule333a = firing_strength_333a * coeff_large;
        // === Rule 3b === 
        double firing_strength_3b = fmin(fmin(driving_mode_eco, soc_low), slope_flat);
        double rule3b = firing_strength_3b * coeff_small;
        // === Rule 3c === 
        double firing_strength_3c = fmin(fmin(driving_mode_eco, soc_low), slope_descent);
        double rule3c = firing_strength_3c * coeff_VVsmall;
        // === Rule 33b === 
        double firing_strength_33b = fmin(fmin(driving_mode_eco, soc_low), velocity_change_decelerating);
        double rule33b = firing_strength_33b * coeff_VVsmall;

        // Fuzzy rules for "Comfort " Driving_Mode
        // === Rule 1g ===
        double firing_strength_1g = fmin(fmin(driving_mode_comfort, soc_high), fmin(temp_cold, velocity_change_steady));
        double rule1g = firing_strength_1g * coeff_large;
        // === Rule 1h ===
        double firing_strength_1h = fmin(fmin(driving_mode_comfort, soc_high), fmin(temp_hot, velocity_change_steady));
        double rule1h = firing_strength_1h * coeff_large;
        // === Rule 11g ===
        double firing_strength_11g = fmin(fmin(fmin(driving_mode_comfort, soc_high), fmin(temp_cold, velocity_change_Accelerating)), slope_ascent);
        double rule11g = firing_strength_11g * coeff_Vlarge;
        // === Rule 11h ===
        double firing_strength_11h = fmin(fmin(fmin(driving_mode_comfort, soc_high), fmin(temp_hot, velocity_change_Accelerating)), slope_ascent);
        double rule11h = firing_strength_11h * coeff_Vlarge;
        // === Rule 111g ===
        double firing_strength_111g = fmin(fmin(driving_mode_comfort, soc_high), temp_normal);
        double rule111g = firing_strength_111g * coeff_large;
        // === Rule 111h ===
        double firing_strength_111h = fmin(fmin(driving_mode_comfort, soc_high), velocity_change_decelerating);
        double rule111h = firing_strength_111h * coeff_VVsmall;
        // === Rule 2e ===
        double firing_strength_2e = fmin(fmin(driving_mode_comfort, soc_medium), fmin(temp_cold, velocity_change_steady));
        double rule2e = firing_strength_2e * coeff_normal;
        // === Rule 2f ===
        double firing_strength_2f = fmin(fmin(driving_mode_comfort, soc_medium), fmin(temp_hot, velocity_change_steady));
        double rule2f = firing_strength_2f * coeff_normal;
        // === Rule 22e ===
        double firing_strength_22e = fmin(fmin(fmin(driving_mode_comfort, soc_medium), fmin(temp_cold, velocity_change_Accelerating)), slope_ascent);
        double rule22e = firing_strength_22e * coeff_large;
        // === Rule 22f ===
        double firing_strength_22f = fmin(fmin(fmin(driving_mode_comfort, soc_medium), fmin(temp_hot, velocity_change_Accelerating)), slope_ascent);
        double rule22f = firing_strength_22f * coeff_large;
        // === Rule 222e === 
        double firing_strength_222e = fmin(fmin(driving_mode_comfort, soc_medium), temp_normal);
        double rule222e = firing_strength_222e * coeff_normal;
        // === Rule 222f === 
        double firing_strength_222f = fmin(fmin(driving_mode_comfort, soc_medium), velocity_change_decelerating);
        double rule222f = firing_strength_222f * coeff_VVsmall;
        // === Rule 3d === 
        double firing_strength_3d = fmin(fmin(driving_mode_comfort, soc_low), fmin(velocity_change_steady, temp_cold));
        double rule3d = firing_strength_3d * coeff_small;
        // === Rule 3e === 
        double firing_strength_3e = fmin(fmin(driving_mode_comfort, soc_low), fmin(velocity_change_steady, temp_hot));
        double rule3e = firing_strength_3e * coeff_small;
        // === Rule 33d === 
        double firing_strength_33d = fmin(fmin(driving_mode_comfort, soc_low), velocity_change_Accelerating);
        double rule33d = firing_strength_33d * coeff_normal;
        // === Rule 33e === 
        double firing_strength_33e = fmin(fmin(driving_mode_comfort, soc_low), velocity_change_decelerating);
        double rule33e = firing_strength_33e * coeff_VVsmall;
        // === Rule 7 ===
        double firing_strength_7 = fmin(driving_mode_comfort, weight_light);
        double rule7 = firing_strength_7 * coeff_small;
        // === Rule 8 ===
        double firing_strength_8 = fmin(fmin(driving_mode_comfort, weight_heavy), velocity_change_Accelerating);
        double rule8 = firing_strength_8 * coeff_large;
        // === Rule 9 ===
        double firing_strength_9 = fmin(fmin(driving_mode_comfort, slope_ascent), fmin(weight_heavy, velocity_change_Accelerating));
        double rule9 = firing_strength_9 * coeff_Vlarge;
        // === Rule 10 ===
        double firing_strength_10 = fmin(fmin(driving_mode_comfort, temp_normal), weight_normal);
        double rule10 = firing_strength_10 * coeff_normal;
        // === Rule 10a ===
        double firing_strength_10a = fmin(driving_mode_comfort, temp_normal);
        double rule10a = firing_strength_10a * coeff_large;

        // Fuzzy rules for "Sport" Driving_Mode
        // === Rule 1i ===
        double firing_strength_1i = fmin(fmin(driving_mode_sport, soc_high), slope_flat);
        double rule1i = firing_strength_1i * coeff_Vlarge;
        // === Rule 1j ===
        double firing_strength_1j = fmin(fmin(fmin(driving_mode_sport, soc_high), weight_heavy), slope_ascent);
        double rule1j = firing_strength_1j * coeff_VVlarge;
        // === Rule 1k ===
        double firing_strength_1k = fmin(fmin(driving_mode_sport, soc_high), slope_ascent);
        double rule1k = firing_strength_1k * coeff_Vlarge;
        // === Rule 11i ===
        double firing_strength_11i = fmin(fmin(driving_mode_sport, soc_high), velocity_change_Accelerating);
        double rule11i = firing_strength_11i * coeff_VVlarge;
        // === Rule 11j ===
        double firing_strength_11j = fmin(fmin(driving_mode_sport, soc_high), velocity_change_steady);
        double rule11j = firing_strength_11j * coeff_Vlarge;
        // === Rule 2g ===
        double firing_strength_2g = fmin(fmin(driving_mode_sport, soc_medium), slope_flat);
        double rule2g = firing_strength_2g * coeff_large;
        // === Rule 2h ===
        double firing_strength_2h = fmin(fmin(fmin(driving_mode_sport, soc_medium), weight_heavy), slope_ascent);
        double rule2h = firing_strength_2h * coeff_VVlarge;
        // === Rule 2i ===
        double firing_strength_2i = fmin(fmin(driving_mode_sport, soc_medium), slope_ascent);
        double rule2i = firing_strength_2i * coeff_Vlarge;
        // === Rule 22i ===
        double firing_strength_22i = fmin(fmin(driving_mode_sport, soc_medium), velocity_change_Accelerating);
        double rule22i = firing_strength_22i * coeff_Vlarge;
        // === Rule 22j ===
        double firing_strength_222i = fmin(fmin(driving_mode_sport, soc_medium), velocity_change_steady);
        double rule222i = firing_strength_222i * coeff_large;
        // === Rule 3f ===
        double firing_strength_3f = fmin(driving_mode_sport, soc_low);
        double rule3f = firing_strength_3f * coeff_normal;
        // === Rule 33f ===
        double firing_strength_33f = fmin(fmin(fmin(driving_mode_sport, soc_low), velocity_change_Accelerating), weight_heavy);
        double rule33f = firing_strength_33f * coeff_large;
        // === Rule 11k ===
        double firing_strength_11k = fmin(driving_mode_sport, velocity_change_decelerating);
        double rule11k = firing_strength_11k * coeff_VVsmall;

        // Fuzzy rules for "Normal" Driving_Mode focusing on SOC levels
        // === Rule 1l === 
        double firing_strength_1l = fmin(fmin(driving_mode_normal, soc_high), velocity_change_Accelerating);
        double rule1l = firing_strength_1l * coeff_Vlarge;
        // === Rule 11l === 
        double firing_strength_11l = fmin(fmin(fmin(driving_mode_normal, soc_high), weight_heavy), velocity_change_Accelerating);
        double rule11l = firing_strength_11l * coeff_VVlarge;
        // === Rule 111l === 
        double firing_strength_111l = fmin(fmin(fmin(driving_mode_normal, soc_high), weight_heavy), velocity_change_steady);
        double rule111l = firing_strength_111l * coeff_Vlarge;
        // === Rule 1m === 
        double firing_strength_1m = fmin(fmin(fmin(driving_mode_normal, soc_high), weight_heavy), slope_ascent);
        double rule1m = firing_strength_1m * coeff_VVlarge;
        // === Rule 1n === 
        double firing_strength_1n = fmin(fmin(driving_mode_normal, soc_high), velocity_change_steady);
        double rule1n = firing_strength_1n * coeff_large;
        // === Rule 1o === 
        double firing_strength_1o = fmin(fmin(driving_mode_normal, soc_high), velocity_change_decelerating);
        double rule1o = firing_strength_1o * coeff_VVsmall;
        // === Rule 2j === 
        double firing_strength_2j = fmin(fmin(fmin(driving_mode_normal, soc_medium), slope_ascent), weight_heavy);
        double rule2j = firing_strength_2j * coeff_Vlarge;
        // === Rule 22j === 
        double firing_strength_22j = fmin(fmin(fmin(driving_mode_normal, soc_medium), velocity_change_Accelerating), weight_heavy);
        double rule22j = firing_strength_22j * coeff_Vlarge;
        // === Rule 222j === 
        double firing_strength_222j = fmin(fmin(driving_mode_normal, soc_medium), velocity_change_Accelerating);
        double rule222j = firing_strength_222j * coeff_large;
        // === Rule 2k === 
        double firing_strength_2k = fmin(fmin(driving_mode_normal, soc_medium), velocity_change_steady);
        double rule2k = firing_strength_2k * coeff_normal;
        // === Rule 22k === 
        double firing_strength_22k = fmin(fmin(fmin(driving_mode_normal, soc_medium), weight_heavy), velocity_change_steady);
        double rule22k = firing_strength_22k * coeff_large;
        // === Rule 222k === 
        double firing_strength_222k = fmin(fmin(driving_mode_normal, soc_medium), velocity_change_decelerating);
        double rule222k = firing_strength_222k * coeff_VVsmall;
        // === Rule 3g === 
        double firing_strength_3g = fmin(fmin(fmin(driving_mode_normal, soc_low), weight_heavy), slope_ascent);
        double rule3g = firing_strength_3g * coeff_large;
        // === Rule 33g === 
        double firing_strength_33g = fmin(fmin(fmin(driving_mode_normal, soc_low), weight_heavy), velocity_change_Accelerating);
        double rule33g = firing_strength_33g * coeff_large;
        // === Rule 3h === 
        double firing_strength_3h = fmin(fmin(driving_mode_normal, soc_low), velocity_change_decelerating);
        double rule3h = firing_strength_3h * coeff_VVsmall;
        // === Rule 33h === 
        double firing_strength_33h = fmin(fmin(driving_mode_normal, soc_low), velocity_change_steady);
        double rule33h = firing_strength_33h * coeff_small;
        // === Rule 3i === 
        double firing_strength_3i = fmin(fmin(driving_mode_normal, soc_low), velocity_change_Accelerating);
        double rule3i = firing_strength_3i * coeff_normal;
        // === Rule gen1 === 
        double firing_strength_gen1 = slope_descent;
        double rule_gen1 = firing_strength_gen1 * coeff_VVsmall;
        // === Rule gen2 === 
        double firing_strength_gen2 = fmin(slope_descent, soc_medium);
        double rule_gen2 = firing_strength_gen2 * coeff_Vsmall;
        // === Rule gen3 === 
        double firing_strength_gen3 = velocity_change_decelerating;
        double rule_gen3 = firing_strength_gen3 * coeff_VVsmall;
        // === Rule stop === 
        double firing_strength_stop = current_velocity_stopped;
        double rule_stop = firing_strength_stop * coeff_zero;
        // === Rule high_speed1 === 
        double firing_strength_high_speed1 = fmin(current_velocity_fast, soc_medium);
        double rule_high_speed1 = firing_strength_high_speed1 * coeff_Vlarge;
        // === Rule high_speed2 === 
        double firing_strength_high_speed2 = fmin(current_velocity_fast, soc_high);
        double rule_high_speed2 = firing_strength_high_speed2 * coeff_VVlarge;

        // Combine rules
        double weighted_outputs[SIZE_A] = {
            // Rules for SOC High
            rule1a, rule1b, rule1c, rule1d, rule1e, rule1f, rule1g, rule1h, rule1i, rule1j, rule1k,
            rule1l, rule1m, rule11l, rule11d, rule11c, rule11b, rule11a, rule11j, rule11i, rule11h,
            rule11g, rule22e, rule22f, rule222e, rule222f, rule111h, rule111g, rule111l, rule1n, rule1o,

            // Rules for SOC Medium
            rule2a, rule2b, rule2c, rule2d, rule2e, rule2f, rule2g, rule2h, rule2i, rule2j, rule2k,
            rule22k, rule22e, rule22d, rule22c, rule22a, rule222k, rule222j, rule22j,

            // Rules for SOC Low
            rule3a, rule3b, rule3c, rule3d, rule3e, rule3f, rule3g, rule3h, rule33b, rule33a, rule33e,
            rule33d, rule33g, rule3i, rule33h, rule333a,

            // Additional generic rules
            rule11k, rule_gen1, rule_gen2, rule_gen3, rule_stop, rule_high_speed1, rule_high_speed2
        };

        double weights[SIZE_A] = {
            // Firing strengths for SOC High rules
            firing_strength_1a, firing_strength_1b, firing_strength_1c, firing_strength_1d, firing_strength_1e, 
            firing_strength_1f, firing_strength_1g, firing_strength_1h, firing_strength_1i, firing_strength_1j, 
            firing_strength_1k, firing_strength_1l, firing_strength_1m, firing_strength_11l, firing_strength_11d, 
            firing_strength_11c, firing_strength_11b, firing_strength_11a, firing_strength_11j, firing_strength_11i, 
            firing_strength_11h, firing_strength_11g, firing_strength_22e, firing_strength_22f, firing_strength_222e, 
            firing_strength_222f, firing_strength_111h, firing_strength_111g, firing_strength_111l, firing_strength_1n, 
            firing_strength_1o,

            // Firing strengths for SOC Medium rules
            firing_strength_2a, firing_strength_2b, firing_strength_2c, firing_strength_2d, firing_strength_2e, 
            firing_strength_2f, firing_strength_2g, firing_strength_2h, firing_strength_2i, firing_strength_2j, 
            firing_strength_2k, firing_strength_22k, firing_strength_22e, firing_strength_22d, firing_strength_22c, 
            firing_strength_22a, firing_strength_222k, firing_strength_222j, firing_strength_22j,

            // Firing strengths for SOC Low rules
            firing_strength_3a, firing_strength_3b, firing_strength_3c, firing_strength_3d, firing_strength_3e, 
            firing_strength_3f, firing_strength_3g, firing_strength_3h, firing_strength_33b, firing_strength_33a, 
            firing_strength_33e, firing_strength_33d, firing_strength_33g, firing_strength_3i, firing_strength_33h, 
            firing_strength_333a,

            // Additional generic rules
            firing_strength_11k, firing_strength_gen1, firing_strength_gen2, firing_strength_gen3, firing_strength_stop, 
            firing_strength_high_speed1, firing_strength_high_speed2
        };        

        // === Step 4: Defuzzification ===
        double coefficient = defuzzification(weighted_outputs, weights, SIZE_A);

        
        // Print out the result
        printf("TIME %.2f:  Coefficient = %.4f\n", (i+1.00)/10, coefficient);
        // Write data
        fprintf(outputFile, "%.2f,%.4f\n", (i+1.00)/10, coefficient);
    }

    // Get the end time
    end_time = clock();

    // Calculate the time taken for execution
    time_taken = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;

    // Print the result
    printf("Time taken: %f seconds\n", time_taken);

    fclose(outputFile);
    printf("Results saved to results.csv\n");






    return 0;
}
